import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_colors.dart';
import '../models/freshness_result.dart';
import '../widgets/freshness_widgets.dart';
import '../features/ml/species_classifier.dart';
import '../features/corrections/species_feedback_sheet.dart';

class ResultScreen extends StatefulWidget {
  final FreshnessResult result;
  final Uint8List? imageBytes;

  const ResultScreen({super.key, required this.result, this.imageBytes});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Uint8List? get _bytes => widget.imageBytes ?? widget.result.imageBytes;

  @override
  void initState() {
    super.initState();
    if (!widget.result.isPending) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _showFeedback();
        });
      });
    }
  }

  void _showFeedback() {
    final species = ZambianSpeciesExt.fromAiResponse(widget.result.fishType);
    final confidence = widget.result.confidence / 100.0;
    SpeciesFeedbackSheet.show(
      context,
      result: widget.result,
      detectedSpecies: species,
      confidence: confidence,
    );
  }

  Future<void> _share() async {
    final text = '''
FishCheck ZM — Freshness Report
================================
Fish:       ${widget.result.fishType}
Freshness:  ${widget.result.freshnessLabel} (${widget.result.score}%)
Sell by:    ${widget.result.sellBy}
Safe:       ${widget.result.safeToEat ? "Yes" : "No"}
${widget.result.priceImpact.isNotEmpty ? "Pricing:    ${widget.result.priceImpact}" : ""}

Visual check:
  Eyes:   ${widget.result.eyes}
  Skin:   ${widget.result.skin}
  Gills:  ${widget.result.gills}
  Flesh:  ${widget.result.flesh}
  Odour:  ${widget.result.odourGuess}

Advice: ${widget.result.advice}
${widget.result.storageTip.isNotEmpty ? "Storage: ${widget.result.storageTip}" : ""}

Scanned: ${DateFormat('d MMM yyyy, HH:mm').format(widget.result.analysedAt)}
FishCheck ZM
''';
    await Share.share(text,
        subject: 'Freshness report — ${widget.result.fishType}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = FreshnessColors.forLevel(widget.result.freshness);
    final bg = FreshnessColors.bgForLevel(widget.result.freshness);
    final bytes = _bytes;
    final screenW = MediaQuery.of(context).size.width;
    final isNarrow = screenW < 420;
    final pad = isNarrow ? 14.0 : 20.0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Hero ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: bytes != null ? (isNarrow ? 220 : 280) : 160,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: bytes != null
                    ? Colors.black.withOpacity(0.4)
                    : AppColors.primarySurface,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded,
                      size: 18,
                      color: bytes != null
                          ? Colors.white
                          : AppColors.primary),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              if (!widget.result.isPending &&
                  !(!kIsWeb &&
                      defaultTargetPlatform == TargetPlatform.windows))
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: bytes != null
                        ? Colors.black.withOpacity(0.4)
                        : AppColors.primarySurface,
                    child: IconButton(
                      icon: Icon(Icons.share_rounded,
                          size: 18,
                          color: bytes != null
                              ? Colors.white
                              : AppColors.primary),
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
                              Colors.black.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: pad,
                        right: pad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FreshnessBadge(
                              level: widget.result.freshness,
                              label: widget.result.freshnessLabel,
                              large: !isNarrow,
                            ),
                            if (widget.result.confidence > 0) ...[
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '${widget.result.confidence}% confident in species ID',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: isNarrow ? 10 : 11,
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
                      padding: EdgeInsets.fromLTRB(pad, 0, pad, 14),
                      child: FreshnessBadge(
                        level: widget.result.freshness,
                        label: widget.result.freshnessLabel,
                        large: !isNarrow,
                      ),
                    ),
            ),
          ),

          // ─── Body ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fish name + time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.result.fishType,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isNarrow ? 17 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMM, HH:mm')
                            .format(widget.result.analysedAt),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: isNarrow ? 10 : 12,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isNarrow ? 16 : 20),

                  // Pending banner
                  if (widget.result.isPending) ...[
                    _PendingBanner(),
                    SizedBox(height: isNarrow ? 14 : 20),
                  ],

                  // Gauge — scales with screen width
                  if (!widget.result.isPending) ...[
                    _FreshnessGauge(
                      score: widget.result.score,
                      level: widget.result.freshness,
                      compact: isNarrow,
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    SizedBox(height: isNarrow ? 14 : 20),
                  ],

                  // Sell-by banner
                  if (!widget.result.isPending)
                    _SellByBanner(
                      result: widget.result,
                      color: color,
                      bg: bg,
                      compact: isNarrow,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 150.ms)
                        .slideY(begin: 0.1, end: 0),

                  // Price impact
                  if (!widget.result.isPending &&
                      widget.result.priceImpact.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PriceImpactBadge(impact: widget.result.priceImpact)
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 180.ms),
                  ],

                  SizedBox(height: isNarrow ? 16 : 20),

                  // Visual indicators
                  if (!widget.result.isPending) ...[
                    _SectionLabel('Visual indicators'),
                    const SizedBox(height: 8),
                    _IndicatorsCard(result: widget.result)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms),
                    SizedBox(height: isNarrow ? 16 : 20),
                  ],

                  // Advice
                  _SectionLabel('Advice'),
                  const SizedBox(height: 8),
                  _InfoCard(
                    icon: Icons.lightbulb_rounded,
                    iconBg: AppColors.primarySurface,
                    iconColor: AppColors.primary,
                    text: widget.result.advice,
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  // Storage tip
                  if (widget.result.storageTip.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.ac_unit_rounded,
                      iconBg: const Color(0xFFE6F1FB),
                      iconColor: const Color(0xFF185FA5),
                      text: widget.result.storageTip,
                    ).animate().fadeIn(duration: 400.ms, delay: 280.ms),
                  ],

                  SizedBox(height: isNarrow ? 20 : 28),

                  // Scan again
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/scan'),
                      icon: const Icon(Icons.camera_alt_rounded, size: 17),
                      label: const Text('Scan another fish'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isNarrow ? 13 : 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 320.ms),

                  const SizedBox(height: 8),

                  // History
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/history'),
                      icon: const Icon(Icons.history_rounded, size: 17),
                      label: const Text('View scan history'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isNarrow ? 12 : 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                  const SizedBox(height: 20),
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
  final bool compact;
  const _FreshnessGauge(
      {required this.score, required this.level, this.compact = false});

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
    _anim = Tween<double>(begin: 0, end: widget.score / 100).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = FreshnessColors.forLevel(widget.level);
    final gaugeH = widget.compact ? 90.0 : 110.0;
    final numSize = widget.compact ? 28.0 : 34.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        children: [
          SizedBox(
            height: gaugeH,
            child: CustomPaint(
              painter: _GaugePainter(
                progress: _anim.value,
                color: color,
                trackColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.borderLight,
                strokeWidth: widget.compact ? 10.0 : 12.0,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: widget.compact ? 14 : 18),
                    Text(
                      '${(_anim.value * 100).round()}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: numSize,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text('%',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: widget.compact ? 11 : 13,
                            color: color)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: Theme.of(context).textTheme.bodySmall),
              Text('Freshness score',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('100%',
                  style: Theme.of(context).textTheme.bodySmall),
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
  final double strokeWidth;
  const _GaugePainter(
      {required this.progress,
      required this.color,
      required this.trackColor,
      this.strokeWidth = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 8;
    final radius = size.width * 0.42;
    const startAngle = pi;
    const sweepAngle = pi;

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
      style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2));
}

class _PendingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.acceptableSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.acceptable.withOpacity(0.3)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.acceptable),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Analysis pending',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.acceptable)),
                const SizedBox(height: 2),
                Text(
                    'Saved — will analyse when reconnected.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.acceptable.withOpacity(0.8),
                        height: 1.4)),
              ])),
        ]),
      );
}

class _SellByBanner extends StatelessWidget {
  final FreshnessResult result;
  final Color color;
  final Color bg;
  final bool compact;
  const _SellByBanner(
      {required this.result,
      required this.color,
      required this.bg,
      this.compact = false});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: compact ? 10 : 13, horizontal: compact ? 12 : 16),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(Icons.schedule_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Sell by',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: compact ? 10 : 11,
                      color: color)),
              Text(result.sellBy,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 10,
                vertical: compact ? 4 : 5),
            decoration: BoxDecoration(
              color: result.safeToEat
                  ? AppColors.fresh.withOpacity(0.18)
                  : AppColors.spoiled.withOpacity(0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              result.safeToEat ? 'Safe to eat' : 'Do not eat',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: result.safeToEat
                      ? AppColors.fresh
                      : AppColors.spoiled),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: _color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.sell_rounded, size: 13, color: _color),
          const SizedBox(width: 6),
          Flexible(
            child: Text('Price: $impact',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _color)),
          ),
        ]),
      );
}

class _IndicatorsCard extends StatelessWidget {
  final FreshnessResult result;
  const _IndicatorsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 420;
    final rows = [
      (Icons.visibility_rounded, 'Eyes', result.eyes),
      (Icons.water_drop_rounded, 'Skin', result.skin),
      (Icons.air_rounded, 'Gills', result.gills),
      (Icons.touch_app_rounded, 'Flesh', result.flesh),
      (Icons.cloud_queue_rounded, 'Odour', result.odourGuess),
    ];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          final row = e.value;
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 12 : 16,
                vertical: isNarrow ? 10 : 12),
            decoration: isLast
                ? null
                : BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.borderLight,
                      width: 0.5,
                    ))),
            child: Row(children: [
              Icon(row.$1,
                  size: 15,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary),
              const SizedBox(width: 8),
              SizedBox(
                width: isNarrow ? 55 : 72,
                child: Text(row.$2,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isNarrow ? 12 : 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary)),
              ),
              Expanded(
                child: Text(row.$3,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isNarrow ? 12 : 13,
                        fontWeight: FontWeight.w500)),
              ),
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
  const _InfoCard(
      {required this.icon,
      required this.iconBg,
      required this.iconColor,
      required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13, height: 1.6))),
      ]),
    );
  }
}