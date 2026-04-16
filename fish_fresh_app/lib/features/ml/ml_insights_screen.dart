import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../../features/ml/ml_feedback_service.dart';
import '../../features/ml/species_classifier.dart';
import '../../services/history_service.dart';

class MlInsightsScreen extends StatefulWidget {
  const MlInsightsScreen({super.key});

  @override
  State<MlInsightsScreen> createState() => _MlInsightsScreenState();
}

class _MlInsightsScreenState extends State<MlInsightsScreen> {
  Map<String, dynamic> _mlStats = {};
  Map<String, dynamic> _historyStats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ml = await MlFeedbackService.getStats();
    final hs = await HistoryService.getStats();
    if (mounted) {
      setState(() {
        _mlStats = ml;
        _historyStats = hs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('AI learning progress')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header card
                  _HeaderCard(mlStats: _mlStats)
                      .animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 16),

                  // How it works
                  _SectionLabel('How the AI learns'),
                  const SizedBox(height: 10),
                  _HowItWorksCard()
                      .animate(delay: 100.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),

                  // Stats grid
                  _SectionLabel('Your contributions'),
                  const SizedBox(height: 10),
                  _StatsGrid(mlStats: _mlStats, historyStats: _historyStats)
                      .animate(delay: 150.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),

                  // Species breakdown
                  if ((_mlStats['speciesBreakdown'] as Map?)?.isNotEmpty == true) ...[
                    _SectionLabel('Species corrections breakdown'),
                    const SizedBox(height: 10),
                    _SpeciesBreakdown(
                        breakdown: Map<String, int>.from(
                            _mlStats['speciesBreakdown'] as Map))
                        .animate(delay: 200.ms).fadeIn(duration: 300.ms),
                    const SizedBox(height: 20),
                  ],

                  // Model status
                  _SectionLabel('Model status'),
                  const SizedBox(height: 10),
                  _ModelStatusCard()
                      .animate(delay: 250.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          fontWeight: FontWeight.w600, letterSpacing: 0.2));
}

class _HeaderCard extends StatelessWidget {
  final Map<String, dynamic> mlStats;
  const _HeaderCard({required this.mlStats});

  @override
  Widget build(BuildContext context) {
    final total = mlStats['totalFeedback'] ?? 0;
    final pct = total == 0 ? 0 : (total * 1.5).clamp(0, 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Species AI', style: TextStyle(fontFamily: 'Poppins',
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: Colors.white)),
              Text('Learning from your feedback',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                      color: Colors.white70)),
            ],
          )),
        ]),
        const SizedBox(height: 20),
        Text('$pct% trained',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 28,
                fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text('$total corrections help improve accuracy for everyone',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                color: Colors.white70)),
      ]),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  static const _steps = [
    (Icons.camera_alt_rounded, 'You scan a fish',
        'AI identifies species and freshness'),
    (Icons.rate_review_rounded, 'You confirm or correct',
        'Was the species ID right?'),
    (Icons.auto_awesome_rounded, 'AI gets smarter',
        'Your correction improves future scans'),
    (Icons.cloud_sync_rounded, 'Model updates',
        'Corrections feed the training dataset'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: Column(
        children: _steps.asMap().entries.map((e) {
          final isLast = e.key == _steps.length - 1;
          final step = e.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle),
                  child: Icon(step.$1, color: AppColors.primary, size: 18),
                ),
                if (!isLast)
                  Container(width: 2, height: 24,
                      color: AppColors.primarySurface),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.$2, style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13,
                          fontWeight: FontWeight.w600)),
                      Text(step.$3, style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary
                              : AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> mlStats;
  final Map<String, dynamic> historyStats;
  const _StatsGrid({required this.mlStats, required this.historyStats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = [
      ('${mlStats['totalFeedback'] ?? 0}', 'Total feedback', Icons.feedback_rounded, AppColors.primary),
      ('${mlStats['totalConfirmed'] ?? 0}', 'Confirmed correct', Icons.check_circle_rounded, AppColors.fresh),
      ('${mlStats['totalCorrections'] ?? 0}', 'Species corrections', Icons.edit_rounded, AppColors.acceptable),
      ('${historyStats['total'] ?? 0}', 'Total scans', Icons.history_rounded, AppColors.accent),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: stats.map((s) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(s.$3, size: 18, color: s.$4),
          const Spacer(),
          Text(s.$1, style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
              fontWeight: FontWeight.w700, color: s.$4)),
          Text(s.$2, style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
        ]),
      )).toList(),
    );
  }
}

class _SpeciesBreakdown extends StatelessWidget {
  final Map<String, int> breakdown;
  const _SpeciesBreakdown({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: Column(
        children: sorted.map((e) {
          final species = ZambianSpecies.values
              .firstWhere((s) => s.name == e.key,
                  orElse: () => ZambianSpecies.unknown);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(species.displayName, style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13,
                      fontWeight: FontWeight.w500)),
                  Text('${e.value} corrections',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                          color: isDark ? AppColors.darkTextTertiary
                              : AppColors.textTertiary)),
                ]),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: e.value / max,
                    minHeight: 6,
                    backgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.borderLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ModelStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: Column(children: [
        _StatusRow(
          icon: Icons.check_circle_rounded,
          color: AppColors.fresh,
          label: 'AI vision analysis',
          status: 'Active',
        ),
        const Divider(height: 16),
        _StatusRow(
          icon: Icons.pending_rounded,
          color: AppColors.acceptable,
          label: 'On-device TFLite model',
          status: 'Phase 4b — collecting data',
        ),
        const Divider(height: 16),
        _StatusRow(
          icon: Icons.schedule_rounded,
          color: AppColors.textTertiary,
          label: 'OTA model updates',
          status: 'Phase 5 — backend required',
        ),
      ]),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String status;
  const _StatusRow({required this.icon, required this.color,
      required this.label, required this.status});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: color),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500))),
    Text(status, style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
        color: color, fontWeight: FontWeight.w500)),
  ]);
}
