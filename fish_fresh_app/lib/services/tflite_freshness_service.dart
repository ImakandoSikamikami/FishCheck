import 'package:flutter/foundation.dart';
import '../models/freshness_result.dart';
import 'local_analysis_service.dart';
import 'tflite_runner_io.dart' if (dart.library.html) 'tflite_runner_web.dart';

// TFLite runs on Android / iOS / Windows.
// On web both conditional imports load stubs and we fall back to
// pixel-based LocalAnalysisService throughout.

/// Fish freshness analyser — TFLite on mobile/desktop, pixel analysis on web.
class TfliteAnalysisService {
  static bool _modelLoaded = false;

  /// Load TFLite freshness model from assets. No-op on web.
  static Future<void> loadModel() async {
    if (kIsWeb) {
      debugPrint('TFLite: skipped on web — using local analysis');
      return;
    }
    _modelLoaded = await TfliteRunner.loadFromAsset('assets/ml/fish_freshness.tflite');
    debugPrint(_modelLoaded ? 'TFLite freshness: loaded' : 'TFLite freshness: failed to load');
  }

  static bool get isLoaded => !kIsWeb && _modelLoaded;

  /// Analyse image bytes.
  /// - Web: pixel-based analysis only.
  /// - Mobile/desktop: TFLite freshness scoring → pixel indicators.
  static Future<FreshnessResult> analyseBytes(
      Uint8List bytes, String mediaType) async {
    if (kIsWeb) {
      return LocalAnalysisService.analyseBytes(bytes, mediaType);
    }

    if (!_modelLoaded) await loadModel();

    // Pixel analysis provides visual indicators, species, and fallback score.
    final pixelResult = await LocalAnalysisService.analyseBytes(bytes, mediaType);

    if (_modelLoaded) {
      final probs = await TfliteRunner.classify(bytes);
      if (probs != null && probs.length >= 3) {
        return _applyTfliteProbs(pixelResult, probs);
      }
    }

    return pixelResult;
  }

  // ── TFLite result merging ─────────────────────────────────────────────────

  /// Overrides freshness-specific fields with TFLite output while keeping
  /// visual indicators (eyes, skin, gills, flesh, species) from pixel analysis.
  static FreshnessResult _applyTfliteProbs(
      FreshnessResult base, List<double> probs) {
    final freshProb      = probs[0];
    final acceptableProb = probs[1];
    final spoiledProb    = probs[2];

    // Weighted score: fresh ≈ 90, acceptable ≈ 55, spoiled ≈ 15
    final score =
        (freshProb * 90 + acceptableProb * 55 + spoiledProb * 15)
            .round()
            .clamp(5, 98);

    final FreshnessLevel level;
    if (freshProb >= acceptableProb && freshProb >= spoiledProb) {
      level = FreshnessLevel.fresh;
    } else if (acceptableProb >= spoiledProb) {
      level = FreshnessLevel.acceptable;
    } else {
      level = FreshnessLevel.spoiled;
    }

    final maxProb = probs.reduce((a, b) => a > b ? a : b);
    final confidence = (maxProb * 100).round().clamp(30, 95);

    return base.copyWith(
      score:       score,
      freshness:   level,
      confidence:  confidence,
      safeToEat:   level == FreshnessLevel.fresh ||
                   level == FreshnessLevel.acceptable,
      advice:      _advice(level, base.fishType),
      sellBy:      _sellBy(level),
      storageTip:  _storage(level),
      priceImpact: _price(level),
    );
  }

  static String _advice(FreshnessLevel l, String species) {
    switch (l) {
      case FreshnessLevel.fresh:
        return '$species is in excellent condition. Price at full market rate.';
      case FreshnessLevel.acceptable:
        return '$species is acceptable but sell today. Consider a small discount.';
      case FreshnessLevel.poor:
        return '$species quality is declining. Apply 30–50% discount and sell immediately.';
      case FreshnessLevel.spoiled:
        return '$species should not be sold. Remove from display immediately.';
      default:
        return 'Could not assess quality. Inspect manually before selling.';
    }
  }

  static String _sellBy(FreshnessLevel l) {
    switch (l) {
      case FreshnessLevel.fresh:      return 'Within 48 hours';
      case FreshnessLevel.acceptable: return 'Sell today';
      case FreshnessLevel.poor:       return 'Within 24 hours';
      case FreshnessLevel.spoiled:    return 'Do not sell';
      default:                        return '—';
    }
  }

  static String _storage(FreshnessLevel l) {
    switch (l) {
      case FreshnessLevel.fresh:
        return 'Store on ice below 4°C. Keep covered to prevent contamination.';
      case FreshnessLevel.acceptable:
        return 'Keep on ice and sell within the day. Do not refreeze.';
      case FreshnessLevel.poor:
        return 'Move to a cool area immediately. Do not store overnight.';
      case FreshnessLevel.spoiled:
        return 'Remove and dispose safely to protect other stock.';
      default:
        return 'Keep cool and inspect manually.';
    }
  }

  static String _price(FreshnessLevel l) {
    switch (l) {
      case FreshnessLevel.fresh:      return 'No discount needed';
      case FreshnessLevel.acceptable: return '10–20% discount';
      case FreshnessLevel.poor:       return '30–50% discount';
      case FreshnessLevel.spoiled:    return 'Remove from sale';
      default:                        return 'Inspect before pricing';
    }
  }

}
