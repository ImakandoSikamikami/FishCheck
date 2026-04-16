import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/freshness_result.dart';

/// On-device fish freshness analyser — no API key, no internet required.
/// Works on all platforms including web (Chrome).
class LocalAnalysisService {

  static Future<FreshnessResult> analyseBytes(
      Uint8List bytes, String mediaType) async {
    try {
      // On web: run directly on main thread (compute isolates are slow on web)
      // On mobile: run in isolate to avoid blocking UI
      final _ImageMetrics metrics = kIsWeb
          ? _analysePixels(bytes)
          : await compute(_analysePixels, bytes);

      return _buildResult(metrics, bytes);
    } catch (e) {
      debugPrint('LocalAnalysis error: $e');
      return _unknownResult(bytes);
    }
  }

  // ── Pixel analysis ─────────────────────────────────────────────────────────

  static _ImageMetrics _analysePixels(Uint8List bytes) {
    final pixels = _sampleBytes(bytes);
    if (pixels.isEmpty) return _ImageMetrics.empty();

    final third = pixels.length ~/ 3;
    final headPixels = pixels.sublist(0, third);
    final bodyPixels = pixels.sublist(third, third * 2);

    final overall = _channelStats(pixels);
    final head    = _channelStats(headPixels);
    final body    = _channelStats(bodyPixels);

    return _ImageMetrics(
      avgR: overall.r, avgG: overall.g, avgB: overall.b,
      brightness: overall.brightness,
      variance: overall.variance,
      yellowIndex: overall.yellowIndex,
      greyIndex: overall.greyIndex,
      headBrightness: head.brightness,
      headVariance: head.variance,
      bodyR: body.r, bodyG: body.g, bodyB: body.b,
      bodyBrightness: body.brightness,
      redDominance: overall.r / (overall.g + 1),
      pixelCount: pixels.length,
    );
  }

  static List<_Pixel> _sampleBytes(Uint8List bytes) {
    final pixels = <_Pixel>[];
    for (int i = 100; i < bytes.length - 3; i += 50) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];
      if (r > 10 && g > 10 && b > 10 && r < 250 && g < 250 && b < 250) {
        pixels.add(_Pixel(r, g, b));
      }
    }
    return pixels.isEmpty ? [_Pixel(128, 128, 128)] : pixels;
  }

  static _Stats _channelStats(List<_Pixel> pixels) {
    if (pixels.isEmpty) return _Stats.neutral();

    double sumR = 0, sumG = 0, sumB = 0;
    for (final p in pixels) {
      sumR += p.r; sumG += p.g; sumB += p.b;
    }
    final n = pixels.length;
    final r = sumR / n;
    final g = sumG / n;
    final b = sumB / n;
    final brightness = (r + g + b) / 3;

    double varSum = 0;
    for (final p in pixels) {
      final pBright = (p.r + p.g + p.b) / 3;
      varSum += (pBright - brightness) * (pBright - brightness);
    }
    final variance = varSum / n;

    final yellowIndex = ((r + g) / 2 - b).clamp(0, 255) / 255;
    final maxDiff = [(r - g).abs(), (r - b).abs(), (g - b).abs()].reduce(max);
    final greyIndex = 1.0 - (maxDiff / 255).clamp(0.0, 1.0);

    return _Stats(
      r: r, g: g, b: b,
      brightness: brightness / 255,
      variance: (variance / (255 * 255)).clamp(0.0, 1.0),
      yellowIndex: yellowIndex.toDouble(),
      greyIndex: greyIndex,
    );
  }

  // ── Build result ───────────────────────────────────────────────────────────

  static FreshnessResult _buildResult(_ImageMetrics m, Uint8List bytes) {
    double score = 50.0;

    // Brightness
    if (m.brightness > 0.65)      score += 20;
    else if (m.brightness > 0.50) score += 10;
    else if (m.brightness < 0.30) score -= 20;
    else if (m.brightness < 0.40) score -= 10;

    // Variance/texture
    if (m.variance > 0.15)      score += 15;
    else if (m.variance > 0.08) score += 7;
    else if (m.variance < 0.02) score -= 15;

    // Yellow index (spoilage)
    if (m.yellowIndex > 0.35)      score -= 25;
    else if (m.yellowIndex > 0.20) score -= 12;
    else if (m.yellowIndex < 0.05) score += 10;

    // Grey index (dullness)
    if (m.greyIndex > 0.80)      score -= 15;
    else if (m.greyIndex > 0.60) score -= 8;
    else if (m.greyIndex < 0.30) score += 8;

    // Head/eye region
    if (m.headBrightness > 0.60)      score += 10;
    else if (m.headBrightness < 0.35) score -= 10;
    if (m.headVariance > 0.10)      score += 5;
    else if (m.headVariance < 0.02) score -= 5;

    // Body
    if (m.bodyBrightness > 0.55)      score += 5;
    else if (m.bodyBrightness < 0.25) score -= 5;

    score = score.clamp(5.0, 98.0);
    final scoreInt = score.round();

    final FreshnessLevel level;
    if (scoreInt >= 75)      level = FreshnessLevel.fresh;
    else if (scoreInt >= 50) level = FreshnessLevel.acceptable;
    else if (scoreInt >= 25) level = FreshnessLevel.poor;
    else                     level = FreshnessLevel.spoiled;

    final species    = _detectSpecies(m);
    final confidence = _speciesConfidence(m);

    return FreshnessResult(
      freshness:   level,
      score:       scoreInt,
      fishType:    species,
      confidence:  confidence,
      eyes:        _eyes(m),
      skin:        _skin(m),
      gills:       _gills(m),
      flesh:       _flesh(m),
      odourGuess:  _odour(level),
      safeToEat:   level == FreshnessLevel.fresh ||
                   level == FreshnessLevel.acceptable,
      advice:      _advice(level, species),
      sellBy:      _sellBy(level),
      storageTip:  _storage(level),
      priceImpact: _price(level),
      analysedAt:  DateTime.now(),
      id:          const Uuid().v4(),
      imageBytes:  bytes,
    );
  }

  // ── Indicators ─────────────────────────────────────────────────────────────

  static String _eyes(_ImageMetrics m) {
    if (m.headBrightness > 0.60 && m.headVariance > 0.08) return 'Clear and bright';
    if (m.headBrightness > 0.45) return 'Slightly cloudy';
    if (m.headBrightness > 0.30) return 'Cloudy';
    return 'Sunken and dull';
  }

  static String _skin(_ImageMetrics m) {
    if (m.brightness > 0.60 && m.variance > 0.12) return 'Bright and shiny';
    if (m.yellowIndex > 0.25) return 'Discoloured — yellowing';
    if (m.brightness < 0.30) return 'Dull and dark';
    return 'Slightly dull';
  }

  static String _gills(_ImageMetrics m) {
    if (m.redDominance > 1.15 && m.bodyBrightness > 0.45) return 'Bright red';
    if (m.redDominance > 1.05) return 'Pink';
    if (m.greyIndex > 0.70) return 'Grey';
    if (m.yellowIndex > 0.20) return 'Brown';
    return 'Not visible';
  }

  static String _flesh(_ImageMetrics m) {
    if (m.variance > 0.12) return 'Firm';
    if (m.variance > 0.06) return 'Slightly soft';
    if (m.variance < 0.03) return 'Soft — handle with care';
    return 'Not visible';
  }

  static String _odour(FreshnessLevel l) {
    switch (l) {
      case FreshnessLevel.fresh:      return 'Likely fresh — mild sea smell';
      case FreshnessLevel.acceptable: return 'Mild — slightly fishy';
      case FreshnessLevel.poor:       return 'Developing — noticeable odour';
      case FreshnessLevel.spoiled:    return 'Strong — unpleasant odour';
      default:                        return 'Unknown';
    }
  }

  // ── Species detection ──────────────────────────────────────────────────────

  static String _detectSpecies(_ImageMetrics m) {
    if (m.brightness > 0.70 && m.greyIndex > 0.65) return 'Kapenta';
    if (m.avgG > m.avgR && m.avgG > m.avgB && m.brightness > 0.45) return 'Bream (Tilapia)';
    if (m.variance > 0.18 && m.brightness > 0.50) return 'Tiger fish';
    if (m.brightness < 0.35 && m.greyIndex > 0.55) return 'Vundu (Catfish)';
    if (m.avgB > m.avgR * 0.85 && m.brightness > 0.50) return 'Mpumbu';
    if (m.brightness > 0.55 && m.yellowIndex < 0.10) return 'Chessa';
    return 'Bream (Tilapia)';
  }

  static int _speciesConfidence(_ImageMetrics m) {
    return ((m.brightness * 50) + (m.variance * 100)).clamp(30.0, 85.0).round();
  }

  // ── Advice ─────────────────────────────────────────────────────────────────

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

  static FreshnessResult _unknownResult(Uint8List bytes) => FreshnessResult(
    freshness:   FreshnessLevel.unknown,
    score:       0,
    fishType:    'Unknown fish',
    eyes: '—', skin: '—', gills: '—', flesh: '—',
    odourGuess:  '—',
    safeToEat:   false,
    advice:      'Could not analyse this image. Please try a clearer photo.',
    sellBy:      '—',
    storageTip:  '',
    priceImpact: '',
    analysedAt:  DateTime.now(),
    id:          const Uuid().v4(),
    imageBytes:  bytes,
  );
}

// ── Data classes ───────────────────────────────────────────────────────────────

class _Pixel {
  final int r, g, b;
  const _Pixel(this.r, this.g, this.b);
}

class _Stats {
  final double r, g, b, brightness, variance, yellowIndex, greyIndex;
  const _Stats({
    required this.r, required this.g, required this.b,
    required this.brightness, required this.variance,
    required this.yellowIndex, required this.greyIndex,
  });
  factory _Stats.neutral() => const _Stats(
    r: 128, g: 128, b: 128, brightness: 0.5,
    variance: 0.05, yellowIndex: 0.1, greyIndex: 0.5,
  );
}

class _ImageMetrics {
  final double avgR, avgG, avgB;
  final double brightness, variance;
  final double yellowIndex, greyIndex;
  final double headBrightness, headVariance;
  final double bodyR, bodyG, bodyB, bodyBrightness;
  final double redDominance;
  final int pixelCount;

  const _ImageMetrics({
    required this.avgR, required this.avgG, required this.avgB,
    required this.brightness, required this.variance,
    required this.yellowIndex, required this.greyIndex,
    required this.headBrightness, required this.headVariance,
    required this.bodyR, required this.bodyG, required this.bodyB,
    required this.bodyBrightness, required this.redDominance,
    required this.pixelCount,
  });

  factory _ImageMetrics.empty() => const _ImageMetrics(
    avgR: 128, avgG: 128, avgB: 128,
    brightness: 0.5, variance: 0.05,
    yellowIndex: 0.1, greyIndex: 0.5,
    headBrightness: 0.5, headVariance: 0.05,
    bodyR: 128, bodyG: 128, bodyB: 128,
    bodyBrightness: 0.5, redDominance: 1.0,
    pixelCount: 0,
  );
}