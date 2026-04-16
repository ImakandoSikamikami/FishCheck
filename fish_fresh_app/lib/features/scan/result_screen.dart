import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_colors.dart';
import '../../models/freshness_result.dart';
import '../../widgets/freshness_widgets.dart';

class ResultScreen extends StatelessWidget {
  final FreshnessResult result;
  final Uint8List? imageBytes;

  const ResultScreen({super.key, required this.result, this.imageBytes});

  Uint8List? get _bytes => imageBytes ?? result.imageBytes;

  Future<void> _share() async {
    final text = '''
FishCheck ZM — Freshness Report
================================
Fish:       ${result.fishType}
Freshness:  ${result.freshnessLabel} (${result.score}%)
Sell by:    ${result.sellBy}
Safe:       ${result.safeToEat ? "Yes" : "No"}
${result.priceImpact.isNotEmpty ? "Pricing:    ${result.priceImpact}" : ""}

Visual check:
  Eyes:   ${result.eyes}
  Skin:   ${result.skin}
  Gills:  ${result.gills}
  Flesh:  ${result.flesh}
  Odour:  ${result.odourGuess}

Advice: ${result.advice}
${result.storageTip.isNotEmpty ? "Storage: ${result.storageTip}" : ""}

Scanned: ${DateFormat('d MMM yyyy, HH:mm').format(result.analysedAt)}
FishCheck ZM
''';
    await Share.share(text, subject: 'Freshness report — ${result.fishType}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = FreshnessColors.forLevel(result.freshness);
    final bg = FreshnessColors.bgForLevel(result.freshness);
    final bytes = _bytes;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Hero ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: bytes != null ? 300 : 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: bytes != null
                    ? Colors.black.withOpacity(0.4)
                    : AppColors.primarySurface,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, size: 18,
                      color: bytes != null ? Colors.white : AppColors.primary),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              if (!result.isPending &&
                  !(!kIsWeb && defaultTargetPlatform == TargetPlatform.windows))
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: bytes != null
                        ? Colors.black.withOpacity(0.4)
                        : AppColors.primarySurface,
                    child: IconButton(
                      icon: Icon(Icons.share_rounded, size: 18,
                          color: bytes != null ? Colors.white : AppColors.primary),
                      onPressed: _share,
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: bytes != null
                  ? Stack(fit: StackFit.expand, children: [
                      Image.memory(bytes, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.65)
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16, left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FreshnessBadge(
                              level: result.freshness,
                              label: result.freshnessLabel,
                              large: true,
                            ),
                            if (result.confidence > 0) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '${result.confidence}% confident in species ID',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 11,
                                    color: Colors.white70),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ])
                  : Container(
                      color: bg,
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: FreshnessBadge(
                        level: result.freshness,
                        label: result.freshnessLabel,
                        large: true,
                      ),
                    ),
            ),
          ),

          // ─── Body ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fish name + time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(result.fishType,
                            style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('d MMM, HH:mm').format(result.analysedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pending state banner
                  if (result.isPending) ...[
                    _PendingBanner(),
                    const SizedBox(height: 20),
                  ],

                  // Animated freshness gauge
                  if (!result.isPending) ...[
                    _FreshnessGauge(score: result.score, level: result.freshness)
                        .animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 20),
                  ],

                  // Sell-by + safe banner
                  if (!result.isPending)
                    _SellByBanner(result: result, color: color, bg: bg)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 150.ms)
                        .slideY(begin: 0.1, end: 0),

                  // Price impact
                  if (!result.isPending && result.priceImpact.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _PriceImpactBadge(impact: result.priceImpact)
                        .animate().fadeIn(duration: 300.ms, delay: 180.ms),
                  ],

                  const SizedBox(height: 24),

                  // Visual indicators
                  if (!result.isPending) ...[
                    _SectionLabel('Visual indicators'),
                    const SizedBox(height: 10),
                    _IndicatorsCard(result: result)
                        .animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    const SizedBox(height: 24),
                  ],

                  // Advice
                  _SectionLabel('Advice'),
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.lightbulb_rounded,
                    iconBg: AppColors.primarySurface,
                    iconColor: AppColors.primary,
                    text: result.advice,
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  // Storage tip
                  if (result.storageTip.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.ac_unit_rounded,
                      iconBg: const Color(0xFFE6F1FB),
                      iconColor: const Color(0xFF185FA5),
                      text: result.storageTip,
                    ).animate().fadeIn(duration: 400.ms, delay: 280.ms),
                  ],

                  const SizedBox(height: 32),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/scan'),
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text('Scan another fish'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 320.ms),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/history'),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('View scan history'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gauge ────────────────────────────────────────────────────────────────────

class _FreshnessGauge extends StatefulWidget {
  final int score;
  final FreshnessLevel level;
  const _FreshnessGauge({required this.score, required this.level});

  @override
  State<_FreshnessGauge> createState() => _FreshnessGaugeState();
}

class _FreshnessGaugeState extends State<_FreshnessGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = FreshnessColors.forLevel(widget.level);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        children: [
          // Arc gauge
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _GaugePainter(
                progress: _anim.value,
                color: color,
                trackColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder : AppColors.borderLight,
              ),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 20),
                  Text(
                    '${(_anim.value * 100).round()}',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 36,
                      fontWeight: FontWeight.w700, color: color,
                    ),
                  ),
                  Text('%', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 14, color: color)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: Theme.of(context).textTheme.bodySmall),
              Text('Freshness score',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('100%', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  const _GaugePainter(
      {required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final radius = size.width * 0.42;
    const startAngle = pi;
    const sweepAngle = pi;
    const strokeWidth = 12.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepAngle, false, trackPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepAngle * progress, false, progressPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.progress != progress;
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
        fontWeight: FontWeight.w600, letterSpacing: 0.2));
}

class _PendingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.acceptableSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.acceptable.withOpacity(0.3)),
    ),
    child: Row(children: [
      const SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5, color: AppColors.acceptable),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Analysis pending',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                fontWeight: FontWeight.w600, color: AppColors.acceptable)),
        const SizedBox(height: 3),
        Text('This scan is saved and will be analysed automatically when you reconnect.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                color: AppColors.acceptable.withOpacity(0.8), height: 1.4)),
      ])),
    ]),
  );
}

class _SellByBanner extends StatelessWidget {
  final FreshnessResult result;
  final Color color;
  final Color bg;
  const _SellByBanner(
      {required this.result, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Icon(Icons.schedule_rounded, color: color, size: 20),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Sell by', style: TextStyle(
            fontFamily: 'Poppins', fontSize: 11, color: color)),
        Text(result.sellBy, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 15,
            fontWeight: FontWeight.w600, color: color)),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: result.safeToEat
              ? AppColors.fresh.withOpacity(0.18)
              : AppColors.spoiled.withOpacity(0.18),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          result.safeToEat ? 'Safe to eat' : 'Do not eat',
          style: TextStyle(
            fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
            color: result.safeToEat ? AppColors.fresh : AppColors.spoiled),
        ),
      ),
    ]),
  );
}

class _PriceImpactBadge extends StatelessWidget {
  final String impact;
  const _PriceImpactBadge({required this.impact});

  Color get _color {
    if (impact.contains('No discount')) return AppColors.fresh;
    if (impact.contains('Remove')) return AppColors.spoiled;
    if (impact.contains('30')) return AppColors.poor;
    return AppColors.acceptable;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: _color.withOpacity(0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.sell_rounded, size: 14, color: _color),
      const SizedBox(width: 6),
      Text('Price: $impact',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
              fontWeight: FontWeight.w500, color: _color)),
    ]),
  );
}

class _IndicatorsCard extends StatelessWidget {
  final FreshnessResult result;
  const _IndicatorsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = [
      (Icons.visibility_rounded, 'Eyes', result.eyes),
      (Icons.water_drop_rounded, 'Skin', result.skin),
      (Icons.air_rounded, 'Gills', result.gills),
      (Icons.touch_app_rounded, 'Flesh', result.flesh),
      (Icons.cloud_queue_rounded, 'Likely odour', result.odourGuess),
    ];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border, width: 0.5),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          final row = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: isLast ? null : BoxDecoration(
              border: Border(bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                width: 0.5)),
            ),
            child: Row(children: [
              Icon(row.$1, size: 16,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
              const SizedBox(width: 10),
              Text(row.$2, style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              const Spacer(),
              Text(row.$3, style: const TextStyle(fontFamily: 'Poppins',
                  fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String text;
  const _InfoCard({required this.icon, required this.iconBg,
      required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border, width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13, height: 1.6))),
      ]),
    );
  }
}
