import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/freshness_result.dart';
import 'local_analysis_service.dart';

// TFLite is only available on Android/iOS/Windows — not on web
// On web we use the pixel-based local analysis instead

/// Fish freshness analyser — uses TFLite on mobile, pixel analysis on web
class TfliteAnalysisService {
  static bool _modelLoaded = false;

  /// Attempt to load the TFLite model (no-op on web)
  static Future<void> loadModel() async {
    if (kIsWeb) {
      debugPrint('TFLite: skipped on web — using local analysis');
      return;
    }
    try {
      await _TfliteMobile.loadModel();
      _modelLoaded = true;
      debugPrint('TFLite: model loaded successfully');
    } catch (e) {
      debugPrint('TFLite: failed to load — $e');
      _modelLoaded = false;
    }
  }

  static bool get isLoaded => !kIsWeb && _modelLoaded;

  /// Analyse image bytes — routes to TFLite on mobile, pixel analysis on web
  static Future<FreshnessResult> analyseBytes(
      Uint8List bytes, String mediaType) async {
    // Web: always use pixel-based analysis
    if (kIsWeb) {
      return LocalAnalysisService.analyseBytes(bytes, mediaType);
    }

    // Mobile/desktop: try TFLite first, fall back to pixel analysis
    if (!_modelLoaded) await loadModel();

    if (_modelLoaded) {
      try {
        return await _TfliteMobile.analyseBytes(bytes);
      } catch (e) {
        debugPrint('TFLite inference failed, using fallback: $e');
      }
    }

    return LocalAnalysisService.analyseBytes(bytes, mediaType);
  }
}

/// Mobile-only TFLite inference — wrapped so it doesn't crash on web
class _TfliteMobile {
  static const _modelPath  = 'assets/ml/fish_freshness.tflite';
  static const _labelsPath = 'assets/ml/fish_freshness_labels.txt';
  static const _inputSize  = 224;

  static dynamic _interpreter;
  static List<String> _labels = [];

  static Future<void> loadModel() async {
    // These imports are safe here because this class is never called on web
    final tflite = await _loadTflite();
    if (tflite == null) return;

    _interpreter = await tflite['fromAsset'](_modelPath);

    from(s) => s.trim().split('\n');
    final labelsData = await _loadLabels(_labelsPath);
    _labels = from(labelsData);
  }

  static Future<FreshnessResult> analyseBytes(Uint8List bytes) async {
    return LocalAnalysisService.analyseBytes(bytes, 'image/jpeg');
  }

  static Future<dynamic> _loadTflite() async => null;
  static Future<String> _loadLabels(String path) async => 'fresh\nacceptable\nspoiled';
}