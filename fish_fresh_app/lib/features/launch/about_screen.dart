import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) {
      if (mounted) setState(() => _info = i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('About FishCheck ZM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App logo + name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.set_meal_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 14),
                const Text('FishCheck ZM',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  _info != null
                      ? 'Version ${_info!.version} (${_info!.buildNumber})'
                      : 'Version 1.0.0',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                      color: Colors.white.withOpacity(0.75)),
                ),
                const SizedBox(height: 8),
                Text('AI-powered fish freshness analyser for Zambia',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        color: Colors.white.withOpacity(0.65)),
                    textAlign: TextAlign.center),
              ]),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Mission
            _InfoCard(
              icon: Icons.flag_rounded,
              iconColor: AppColors.primary,
              title: 'Our mission',
              body: 'FishCheck ZM helps Zambian fish vendors and consumers '
                  'make informed decisions about fish quality. By combining '
                  'AI vision analysis with local fish knowledge, we aim to '
                  'reduce food waste and protect public health across Zambia\'s '
                  'markets — from Lusaka\'s Soweto Market to the shores of '
                  'Lake Bangweulu.',
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 12),

            // Species
            _InfoCard(
              icon: Icons.set_meal_rounded,
              iconColor: const Color(0xFF185FA5),
              title: 'Zambian species supported',
              body: 'Kapenta (Ndakala) · Bream (Tilapia/Brim) · '
                  'Tiger fish (Nkupi) · Mpumbu · Chessa (Lisabi) · '
                  'Vundu catfish (Mamba) · and more being added.',
            ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 12),

            // Technology
            _InfoCard(
              icon: Icons.psychology_rounded,
              iconColor: AppColors.accent,
              title: 'Technology',
              body: 'Built for Android, iOS, web and Windows. ',
                  
            ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            // Links
            _SectionLabel('Links & support'),
            const SizedBox(height: 10),

            _LinkTile(
              icon: Icons.bug_report_rounded,
              label: 'Report a problem',
              onTap: () => _launch('mailto:support@fishcheckzm.app'),
            ),
            _LinkTile(
              icon: Icons.privacy_tip_rounded,
              label: 'Privacy policy',
              onTap: () => _launch('https://fishcheckzm.app/privacy'),
            ),
            _LinkTile(
              icon: Icons.description_rounded,
              label: 'Terms of use',
              onTap: () => _launch('https://fishcheckzm.app/terms'),
            ),

            const SizedBox(height: 32),

            // Footer
            Text(
              '© ${DateTime.now().year} FishCheck ZM\nBuilt for Zambia with pride',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  color: isDark ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  height: 1.6),
            ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(fontFamily: 'Poppins',
        fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.iconColor,
      required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontFamily: 'Poppins',
              fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        Text(body, style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
            height: 1.6,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
      ]),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 14))),
          Icon(Icons.chevron_right_rounded, size: 18,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
        ]),
      ),
    );
  }
}
