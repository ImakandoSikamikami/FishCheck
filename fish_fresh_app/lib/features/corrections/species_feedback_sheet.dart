import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../../models/freshness_result.dart';
import '../ml/ml_feedback_service.dart';
import '../ml/species_classifier.dart';

/// Shows after a scan result to collect user feedback on species ID accuracy.
/// This is the core of the ML learning loop.
class SpeciesFeedbackSheet extends StatefulWidget {
  final FreshnessResult result;
  final ZambianSpecies detectedSpecies;
  final double confidence;
  final VoidCallback? onDismiss;

  const SpeciesFeedbackSheet({
    super.key,
    required this.result,
    required this.detectedSpecies,
    required this.confidence,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required FreshnessResult result,
    required ZambianSpecies detectedSpecies,
    required double confidence,
  }) async {
    // Don't show if we already have feedback for this scan
    final hasFeedback = await MlFeedbackService.hasFeedback(result.id);
    if (hasFeedback || !context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpeciesFeedbackSheet(
        result: result,
        detectedSpecies: detectedSpecies,
        confidence: confidence,
      ),
    );
  }

  @override
  State<SpeciesFeedbackSheet> createState() => _SpeciesFeedbackSheetState();
}

class _SpeciesFeedbackSheetState extends State<SpeciesFeedbackSheet> {
  bool _showCorrection = false;
  ZambianSpecies? _selectedCorrection;
  bool _submitting = false;
  bool _done = false;

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    await MlFeedbackService.confirmCorrect(widget.result.id);
    setState(() { _submitting = false; _done = true; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _submitCorrection() async {
    if (_selectedCorrection == null) return;
    setState(() => _submitting = true);
    await MlFeedbackService.recordCorrection(
      scanId: widget.result.id,
      predicted: widget.detectedSpecies,
      corrected: _selectedCorrection!,
      originalConfidence: (widget.confidence * 100).round(),
    );
    setState(() { _submitting = false; _done = true; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: _done ? _buildDoneState() : _buildContent(isDark),
    );
  }

  Widget _buildDoneState() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 20),
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
            color: AppColors.freshSurface, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded,
            color: AppColors.fresh, size: 32),
      ),
      const SizedBox(height: 12),
      const Text('Thanks! This helps improve accuracy.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 20),
    ],
  ).animate().fadeIn(duration: 300.ms).scale(
      begin: const Offset(0.9, 0.9), duration: 300.ms);

  Widget _buildContent(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              borderRadius: BorderRadius.circular(2)),
        )),
        const SizedBox(height: 20),

        // Header
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.psychology_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Help improve species detection',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                      fontWeight: FontWeight.w600)),
              Text('Your feedback trains the AI',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                      color: isDark ? AppColors.darkTextTertiary
                          : AppColors.textTertiary)),
            ],
          )),
          // Confidence badge
          _ConfidenceBadge(confidence: widget.confidence),
        ]),

        const SizedBox(height: 20),

        // Detected species
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.primarySurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.set_meal_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Detected as',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.textSecondary)),
              Text(widget.detectedSpecies.displayName,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
                      fontWeight: FontWeight.w600, color: AppColors.primary)),
            ]),
          ]),
        ),

        const SizedBox(height: 16),

        if (!_showCorrection) ...[
          const Text('Is this correct?',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: _submitting ? null : _confirm,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Yes, correct!'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => setState(() => _showCorrection = true),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('No, correct it'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )),
          ]),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Skip',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                      color: isDark ? AppColors.darkTextTertiary
                          : AppColors.textTertiary)),
            ),
          ),
        ] else ...[
          // Correction picker
          const Text('Select the correct species:',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ZambianSpecies.values
                .where((s) => s != ZambianSpecies.unknown)
                .map((s) {
              final selected = _selectedCorrection == s;
              return GestureDetector(
                onTap: () => setState(() => _selectedCorrection = s),
                child: AnimatedContainer(
                  duration: 150.ms,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      width: selected ? 0 : 0.5,
                    ),
                  ),
                  child: Text(s.displayName,
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedCorrection != null && !_submitting)
                  ? _submitCorrection
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Submit correction',
                      style: TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: TextButton(
            onPressed: () => setState(() => _showCorrection = false),
            child: const Text('Back',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
          )),
        ],
      ],
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;
  const _ConfidenceBadge({required this.confidence});

  Color get _color {
    if (confidence >= 0.8) return AppColors.fresh;
    if (confidence >= 0.6) return AppColors.acceptable;
    return AppColors.poor;
  }

  String get _label {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: _color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$_label (${(confidence * 100).round()}%)',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
              fontWeight: FontWeight.w600, color: _color)),
    ]),
  );
}
