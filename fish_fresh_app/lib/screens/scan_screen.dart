import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../platform/image_pipeline.dart';
import '../services/tflite_freshness_service.dart';
import '../services/history_service.dart';
import '../services/offline_queue_service.dart';
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  ProcessedImage? _picked;
  bool _analysing = false;

  bool get _hasImage => _picked != null;

  // ─── Pick image ────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSourceType source) async {
    try {
      final result = await ImagePipeline.pick(source);
      if (result == null) return;
      if (mounted) setState(() => _picked = result);
    } catch (e) {
      if (mounted) _showError('Could not load image: $e');
    }
  }

  // ─── Analyse ───────────────────────────────────────────────────────────────

  Future<void> _analyse() async {
    if (_picked == null) return;
    setState(() => _analysing = true);
    HapticFeedback.lightImpact();

try {
      // Analyse using TFLite model — no internet or API key needed
      final result = await TfliteAnalysisService.analyseBytes(
          _picked!.bytes, _picked!.mediaType);
      await HistoryService.saveResult(result);
      if (mounted) {
        context.push('/result',
            extra: {'result': result, 'bytes': _picked!.bytes});
      }
    } catch (e) {
      if (mounted) _showError('Analysis failed. Please try a clearer photo.');
    } finally {
      if (mounted) setState(() => _analysing = false);
    }
  }

  void _retake() => setState(() => _picked = null);

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.spoiled,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return _hasImage ? _buildPreview() : _buildPickerView();
  }

  // ─── Picker view (no image yet) ────────────────────────────────────────────

  Widget _buildPickerView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Header
              Text('Scan a fish',
                      style: Theme.of(context).textTheme.headlineMedium)
                  .animate()
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 4),
              Text('Take a photo or upload from your gallery',
                      style: Theme.of(context).textTheme.bodyMedium)
                  .animate(delay: 50.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 32),

              // Large tap target
              Expanded(
                child: GestureDetector(
                  onTap: () => isMobile
                      ? _showSourceSheet()
                      : _pickImage(ImageSourceType.gallery),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.primarySurface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                          style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo_rounded,
                              color: AppColors.primary, size: 40),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isMobile
                              ? 'Tap to take or upload a photo'
                              : 'Click to upload a fish photo',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isMobile
                              ? 'Works best with clear, well-lit photos'
                              : 'JPG · PNG · WEBP · HEIC · BMP · GIF',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.97, 0.97),
                    duration: 400.ms,
                    curve: Curves.easeOut),
              ),

              const SizedBox(height: 16),

              // Button row
              if (isMobile) ...[
                Row(children: [
                  Expanded(
                    child: _PickButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSourceType.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSourceType.gallery),
                    ),
                  ),
                ]).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              ] else ...[
                _PickButton(
                  icon: Icons.upload_file_rounded,
                  label: 'Choose image file',
                  onTap: () => _pickImage(ImageSourceType.gallery),
                ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              ],

              const SizedBox(height: 16),

              // Tips
              _TipsRow().animate(delay: 300.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primary),
              ),
              title: const Text('Take a photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Use your device camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSourceType.camera);
              },
            ),
            const SizedBox(height: 4),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.photo_library_rounded,
                    color: AppColors.primary),
              ),
              title: const Text('Choose from gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Pick an existing photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSourceType.gallery);
              },
            ),
          ]),
        ),
      ),
    );
  }

  // ─── Preview view (image selected) ────────────────────────────────────────

  Widget _buildPreview() {
    final img = _picked!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Full-screen image
        Positioned.fill(
          child: Image.memory(img.bytes, fit: BoxFit.cover)
              .animate()
              .fadeIn(duration: 300.ms),
        ),

        // Gradient overlay at bottom
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),

        // Back button top-left
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: _retake,
                ),
              ]),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File info
                  if (img.filename != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.image_rounded,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          '${img.filename!.length > 24 ? img.filename!.substring(0, 24) + "…" : img.filename} · ${img.sizeKb}KB',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ]),
                    ),

                  // Analyse button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _analysing ? null : _analyse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _analysing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Text('Analysing freshness...',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.biotech_rounded, size: 20),
                                SizedBox(width: 10),
                                Text('Analyse freshness',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Retake
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.refresh_rounded,
                          size: 18, color: Colors.white70),
                      label: const Text('Choose a different photo',
                          style: TextStyle(color: Colors.white70)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.3)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Small widgets ────────────────────────────────────────────────────────────

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );
}

class _TipsRow extends StatelessWidget {
  static const _tips = [
    (Icons.visibility_rounded, 'Clear eyes'),
    (Icons.water_drop_rounded, 'Shiny skin'),
    (Icons.air_rounded, 'Red gills'),
    (Icons.touch_app_rounded, 'Firm flesh'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: _tips.map((t) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Icon(t.$1, size: 16, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(t.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                )),
          ]),
        ),
      )).toList(),
    );
  }
}
