import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import '../core/app_router.dart';
import '../services/history_service.dart';
import '../features/backend/auth_service.dart';
import '../features/backend/supabase_config.dart';
import '../features/notifications/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Account ────────────────────────────────────────────────────
          _SectionHeader('Account'),
          _Card(child: SupabaseConfig.isLoggedIn
              ? Column(children: [
                  _SettingsTile(
                    icon: Icons.person_rounded,
                    label: AuthService.currentUser?.email ?? 'Signed in',
                    sublabel: 'Scans synced to cloud',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign out',
                    sublabel: 'History stays on this device',
                    color: AppColors.spoiled,
                    onTap: () async {
                      await AuthService.signOut();
                      if (context.mounted) setState(() {});
                    },
                  ),
                ])
              : _SettingsTile(
                  icon: Icons.login_rounded,
                  label: 'Sign in or create account',
                  sublabel: 'Sync scans across devices',
                  color: AppColors.primary,
                  onTap: () => context.push(AppRouter.auth),
                )),

          const SizedBox(height: 20),

          // ── Notifications ──────────────────────────────────────────────
          _SectionHeader('Notifications'),
          _Card(child: _SettingsTile(
            icon: Icons.notifications_rounded,
            label: 'Enable reminders',
            sublabel: 'Get reminded to re-check fish after 24 hours',
            onTap: () async {
              final granted = await NotificationService.requestPermission();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(granted
                      ? 'Notifications enabled!'
                      : 'Please enable notifications in device settings.'),
                ));
              }
            },
          )),

          const SizedBox(height: 20),

          // ── Appearance ─────────────────────────────────────────────────
          _SectionHeader('Appearance'),
          _Card(child: _SettingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'Theme',
            sublabel: 'Follows your system setting (light / dark)',
            onTap: () {},
          )),

          const SizedBox(height: 20),

          // ── Machine Learning ───────────────────────────────────────────
          _SectionHeader('Machine learning'),
          _Card(child: Column(children: [
            _SettingsTile(
              icon: Icons.psychology_rounded,
              label: 'AI learning progress',
              sublabel: 'View species corrections and model accuracy',
              color: AppColors.primary,
              onTap: () => context.push(AppRouter.mlInsights),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.biotech_rounded,
              label: 'Analysis engine',
              sublabel: 'On-device image analysis — works offline',
              onTap: () {},
            ),
          ])),

          const SizedBox(height: 20),

          // ── Data ───────────────────────────────────────────────────────
          _SectionHeader('Data'),
          _Card(child: _SettingsTile(
            icon: Icons.delete_outline_rounded,
            label: 'Clear scan history',
            sublabel: 'Remove all past fish scans from this device',
            color: AppColors.spoiled,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear history',
                      style: TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
                  content: const Text(
                      'Delete all scan history? This cannot be undone.',
                      style: TextStyle(fontFamily: 'Poppins')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Clear all',
                          style: TextStyle(fontFamily: 'Poppins',
                              color: AppColors.spoiled,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await HistoryService.clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan history cleared')),
                  );
                }
              }
            },
          )),

          const SizedBox(height: 20),

          // ── About ──────────────────────────────────────────────────────
          _SectionHeader('About'),
          _Card(child: Column(children: [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'About FishCheck ZM',
              sublabel: 'Version, mission, credits',
              onTap: () => context.push(AppRouter.about),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.set_meal_rounded,
              label: 'Species supported',
              sublabel: 'Kapenta · Bream · Tiger fish · Mpumbu · Chessa · Vundu',
              onTap: () => context.go(AppRouter.species),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.store_rounded,
              label: 'Fish vendors',
              sublabel: 'Browse vendors near you',
              onTap: () => context.go(AppRouter.vendors),
            ),
          ])),

          const SizedBox(height: 40),

          Center(
            child: Text(
              'FishCheck ZM · v1.0.0 · ',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color? color;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon, required this.label, required this.sublabel,
    this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, size: 18,
              color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500,
                  color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))),
              Text(sublabel, style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 11,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
            ],
          )),
          Icon(Icons.chevron_right_rounded, size: 16,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
        ]),
      ),
    );
  }
}
