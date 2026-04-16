import 'package:flutter/material.dart';
import '../models/freshness_result.dart';
import '../core/app_colors.dart';

class FreshnessColors {
  static Color forLevel(FreshnessLevel level) {
    switch (level) {
      case FreshnessLevel.fresh: return AppColors.fresh;
      case FreshnessLevel.acceptable: return AppColors.acceptable;
      case FreshnessLevel.poor: return AppColors.poor;
      case FreshnessLevel.spoiled: return AppColors.spoiled;
      case FreshnessLevel.unknown: return Colors.grey;
    }
  }

  static Color bgForLevel(FreshnessLevel level) {
    switch (level) {
      case FreshnessLevel.fresh: return AppColors.freshSurface;
      case FreshnessLevel.acceptable: return AppColors.acceptableSurface;
      case FreshnessLevel.poor: return AppColors.poorSurface;
      case FreshnessLevel.spoiled: return AppColors.spoiledSurface;
      case FreshnessLevel.unknown: return Colors.grey.shade100;
    }
  }

  static IconData iconForLevel(FreshnessLevel level) {
    switch (level) {
      case FreshnessLevel.fresh: return Icons.check_circle_rounded;
      case FreshnessLevel.acceptable: return Icons.info_rounded;
      case FreshnessLevel.poor: return Icons.warning_rounded;
      case FreshnessLevel.spoiled: return Icons.cancel_rounded;
      case FreshnessLevel.unknown: return Icons.help_rounded;
    }
  }
}

class FreshnessBadge extends StatelessWidget {
  final FreshnessLevel level;
  final String label;
  final bool large;

  const FreshnessBadge({
    super.key,
    required this.level,
    required this.label,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = FreshnessColors.forLevel(level);
    final bg = FreshnessColors.bgForLevel(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FreshnessColors.iconForLevel(level), size: large ? 18 : 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: large ? 15 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreBar extends StatefulWidget {
  final int score;
  final FreshnessLevel level;

  const ScoreBar({super.key, required this.score, required this.level});

  @override
  State<ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<ScoreBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Freshness score', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text('${widget.score}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => LinearProgressIndicator(
              value: _anim.value,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}
