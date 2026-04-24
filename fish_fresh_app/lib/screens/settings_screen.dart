import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import '../core/theme_notifier.dart';
import '../core/app_router.dart';
import '../services/history_service.dart';
import '../features/backend/auth_service.dart';
import '../features/backend/supabase_config.dart';
import '../features/notifications/notification_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Account ────────────────────────────────────────────────────
          _SectionHeader(l.settingsAccount),
          _Card(child: SupabaseConfig.isLoggedIn
              ? Column(children: [
                  _SettingsTile(
                    icon: Icons.person_rounded,
                    label: AuthService.currentUser?.email ?? l.settingsAccount,
                    sublabel: l.settingsScansToCloud,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: l.settingsSignOut,
                    sublabel: l.settingsHistoryOnDevice,
                    color: AppColors.spoiled,
                    onTap: () async {
                      await AuthService.signOut();
                      if (context.mounted) setState(() {});
                    },
                  ),
                ])
              : _SettingsTile(
                  icon: Icons.login_rounded,
                  label: l.settingsSignIn,
                  sublabel: l.settingsSyncAcrossDevices,
                  color: AppColors.primary,
                  onTap: () => context.push(AppRouter.auth),
                )),

          const SizedBox(height: 20),

          // ── Notifications ──────────────────────────────────────────────
          _SectionHeader(l.settingsNotifications),
          _Card(child: _SettingsTile(
            icon: Icons.notifications_rounded,
            label: l.settingsEnableReminders,
            sublabel: l.settingsRemindersSubtitle,
            onTap: () async {
              final granted = await NotificationService.requestPermission();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(granted
                      ? l.settingsNotificationsEnabled
                      : l.settingsNotificationsDisabled),
                ));
              }
            },
          )),

          const SizedBox(height: 20),

          // ── Appearance ─────────────────────────────────────────────────
          _SectionHeader(l.settingsAppearance),
          _Card(child: _ThemeTile()),

          const SizedBox(height: 20),

          // ── Language ───────────────────────────────────────────────────
          _SectionHeader(l.settingsLanguage),
          _Card(child: _LanguageTile()),

          const SizedBox(height: 20),

          // ── Machine Learning ───────────────────────────────────────────
          _SectionHeader(l.settingsMachineLearning),
          _Card(child: Column(children: [
            _SettingsTile(
              icon: Icons.psychology_rounded,
              label: l.settingsAiProgress,
              sublabel: l.settingsAiProgressSubtitle,
              color: AppColors.primary,
              onTap: () => context.push(AppRouter.mlInsights),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.biotech_rounded,
              label: l.settingsAnalysisEngine,
              sublabel: l.settingsAnalysisEngineSubtitle,
              onTap: () {},
            ),
          ])),

          const SizedBox(height: 20),

          // ── Data ───────────────────────────────────────────────────────
          _SectionHeader(l.settingsData),
          _Card(child: _SettingsTile(
            icon: Icons.delete_outline_rounded,
            label: l.settingsClearHistory,
            sublabel: l.settingsClearHistorySubtitle,
            color: AppColors.spoiled,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l.settingsClearHistoryDialog,
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
                  content: Text(l.settingsClearHistoryContent,
                      style: const TextStyle(fontFamily: 'Poppins')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.cancel,
                          style: const TextStyle(fontFamily: 'Poppins')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l.clearAll,
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
                    SnackBar(content: Text(l.settingsClearHistorySuccess)),
                  );
                }
              }
            },
          )),

          const SizedBox(height: 20),

          // ── About ──────────────────────────────────────────────────────
          _SectionHeader(l.settingsAbout),
          _Card(child: Column(children: [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: l.settingsAboutApp,
              sublabel: l.settingsAboutSubtitle,
              onTap: () => context.push(AppRouter.about),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.set_meal_rounded,
              label: l.settingsSpeciesSupported,
              sublabel: l.settingsSpeciesSubtitle,
              onTap: () => context.go(AppRouter.species),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.store_rounded,
              label: l.settingsFishVendors,
              sublabel: l.settingsVendorsSubtitle,
              onTap: () => context.go(AppRouter.vendors),
            ),
          ])),

          const SizedBox(height: 40),

          Center(
            child: Text(
              l.settingsFooter,
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

class _ThemeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final notifier = context.watch<ThemeNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(Icons.dark_mode_outlined, size: 18,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.settingsTheme, style: TextStyle(
                fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            Text(l.settingsThemeSubtitle,
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
          ]),
        ),
        const SizedBox(width: 12),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded, size: 16)),
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded, size: 16)),
            ButtonSegment(value: ThemeMode.dark,  icon: Icon(Icons.dark_mode_rounded, size: 16)),
          ],
          selected: {notifier.mode},
          onSelectionChanged: (s) => notifier.setMode(s.first),
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ]),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(Icons.language_rounded, size: 18,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.settingsLanguage, style: TextStyle(
                fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            Text(l.settingsLanguageSubtitle,
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
          ]),
        ),
        const SizedBox(width: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'en',
              label: Text('🇬🇧 EN',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            ),
            ButtonSegment(
              value: 'ru',
              label: Text('🇷🇺 RU',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            ),
          ],
          selected: {localeProvider.locale.languageCode},
          onSelectionChanged: (s) =>
              localeProvider.setLocale(Locale(s.first)),
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ]),
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
