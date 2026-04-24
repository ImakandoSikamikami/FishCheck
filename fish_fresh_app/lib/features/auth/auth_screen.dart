import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
import '../backend/auth_service.dart';
import '../../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  const AuthScreen({super.key, this.isSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      if (_isSignUp) {
        await AuthService.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );
      } else {
        await AuthService.signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      }
      if (mounted) context.go(AppRouter.home);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final l = AppLocalizations.of(context)!;
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = l.authEnterEmailFirst);
      return;
    }
    await AuthService.resetPassword(_emailCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.authPasswordResetSent),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.set_meal_rounded,
                      color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                const Text('FishCheck ZM',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ]).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 40),

              Text(
                _isSignUp ? l.authCreateAccount : l.authWelcomeBack,
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate(delay: 50.ms).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 4),

              Text(
                _isSignUp ? l.authSignUpSubtitle : l.authSignInSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate(delay: 80.ms).fadeIn(),

              const SizedBox(height: 32),

              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.spoiledSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.spoiled.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Icon(Icons.error_outline_rounded,
                        color: AppColors.spoiled, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                            color: AppColors.spoiled))),
                  ]),
                ).animate().fadeIn(duration: 200.ms),

              Form(
                key: _formKey,
                child: Column(children: [
                  if (_isSignUp) ...[
                    _Field(
                      controller: _nameCtrl,
                      label: l.authFullName,
                      icon: Icons.person_rounded,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? l.authNameRequired : null,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      controller: _phoneCtrl,
                      label: l.authPhone,
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _Field(
                    controller: _emailCtrl,
                    label: l.authEmail,
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return l.authEmailRequired;
                      if (!v!.contains('@')) return l.authEmailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _passwordCtrl,
                    label: l.authPassword,
                    icon: Icons.lock_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return l.authPasswordRequired;
                      if (_isSignUp && v!.length < 8)
                        return l.authPasswordTooShort;
                      return null;
                    },
                  ),
                ]),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 8),

              if (!_isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(l.authForgotPassword,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isSignUp ? l.authCreateAccount : l.authSignIn,
                          style: const TextStyle(fontFamily: 'Poppins',
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ).animate(delay: 150.ms).fadeIn(),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _error = null;
                  }),
                  child: Text(
                    _isSignUp ? l.authAlreadyHaveAccount : l.authDontHaveAccount,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRouter.home),
                  child: Text(l.authContinueWithout,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                          color: isDark ? AppColors.darkTextTertiary
                              : AppColors.textTertiary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    validator: validator,
    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Poppins'),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textTertiary),
      suffixIcon: suffixIcon,
    ),
  );
}
