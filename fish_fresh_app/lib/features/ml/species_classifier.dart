import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Zambian fish species known to the classifier
enum ZambianSpecies {
  kapenta,
  bream,
  tigerFish,
  mpumbu,
  chessa,
  vundu,
  unknown,
}

extension ZambianSpeciesExt on ZambianSpecies {
  String get displayName {
    switch (this) {
      case ZambianSpecies.kapenta:    return 'Kapenta';
      case ZambianSpecies.bream:      return 'Bream (Tilapia)';
      case ZambianSpecies.tigerFish:  return 'Tiger fish';
      case ZambianSpecies.mpumbu:     return 'Mpumbu';
      case ZambianSpecies.chessa:     return 'Chessa';
      case ZambianSpecies.vundu:      return 'Vundu (Catfish)';
      case ZambianSpecies.unknown:    return 'Unknown fish';
    }
  }

  String get localNames {
    switch (this) {
      case ZambianSpecies.kapenta:    return 'Kapenta · Ndakala · Matemba';
      case ZambianSpecies.bream:      return 'Brim · Tilapia · Ngumbu';
      case ZambianSpecies.tigerFish:  return 'Nkupi · Mupende · Mputi';
      case ZambianSpecies.mpumbu:     return 'Mpumbu · Mupumbu';
      case ZambianSpecies.chessa:     return 'Chessa · Lisabi';
      case ZambianSpecies.vundu:      return 'Vundu · Mamba · Kampoyo';
      case ZambianSpecies.unknown:    return '—';
    }
  }

  /// Match AI text response to a known species enum
  static ZambianSpecies fromAiResponse(String fishType) {
    final t = fishType.toLowerCase();
    if (t.contains('kapenta') || t.contains('ndakala') || t.contains('matemba')) {
      return ZambianSpecies.kapenta;
    }
    if (t.contains('bream') || t.contains('tilapia') || t.contains('ngumbu')) {
      return ZambianSpecies.bream;
    }
    if (t.contains('tiger') || t.contains('nkupi') || t.contains('mupende')) {
      return ZambianSpecies.tigerFish;
    }
    if (t.contains('mpumbu') || t.contains('mupumbu')) {
      return ZambianSpecies.mpumbu;
    }
    if (t.contains('chessa') || t.contains('lisabi')) {
      return ZambianSpecies.chessa;
    }
    if (t.contains('vundu') || t.contains('catfish') || t.contains('mamba') ||
        t.contains('kampoyo')) {
      return ZambianSpecies.vundu;
    }
    return ZambianSpecies.unknown;
  }
}

/// Result from the on-device classifier
class ClassificationResult {
  final ZambianSpecies species;
  final double confidence; // 0.0 – 1.0
  final bool needsUserConfirmation; // true when confidence < threshold
  final List<RankedSpecies> topCandidates;

  const ClassificationResult({
    required this.species,
    required this.confidence,
    required this.needsUserConfirmation,
    required this.topCandidates,
  });
}

class RankedSpecies {
  final ZambianSpecies species;
  final double score;
  const RankedSpecies({required this.species, required this.score});
}

/// On-device species classifier.
///
/// Architecture:
/// - Phase 4a (current): heuristic pre-classifier using AI text output + user corrections
/// - Phase 4b (future): TFLite MobileNetV3 model trained on Zambian fish dataset
///   loaded from assets/ml/species_classifier.tflite
///
/// The classifier improves over time through the feedback loop:
/// user corrections → local storage → training data export → model retrain → OTA update
class SpeciesClassifier {
  static const double _lowConfidenceThreshold = 0.65;

  // Correction weights: when a user corrects a species ID,
  // we apply a boost to that species for similar confidence levels
  static Map<String, int> _correctionCounts = {};

  /// Primary classification entry point.
  /// Takes the AI's text output and refines it with local correction data.
  static Future<ClassificationResult> classify({
    required String aiSpeciesText,
    required int aiConfidence,
    Uint8List? imageBytes,
  }) async {
    // Step 1: Parse AI species text into enum
    final primarySpecies = ZambianSpeciesExt.fromAiResponse(aiSpeciesText);
    double confidence = aiConfidence / 100.0;

    // Step 2: Apply correction boost if we have local data
    final correctionKey = primarySpecies.name;
    final corrections = _correctionCounts[correctionKey] ?? 0;
    if (corrections > 0) {
      // Each correction nudges confidence up slightly (capped at 0.98)
      confidence = (confidence + (corrections * 0.02)).clamp(0.0, 0.98);
    }

    // Step 3: Build ranked candidates for the confirmation UI
    final candidates = _buildCandidates(primarySpecies, confidence);

    return ClassificationResult(
      species: primarySpecies,
      confidence: confidence,
      needsUserConfirmation: confidence < _lowConfidenceThreshold ||
          primarySpecies == ZambianSpecies.unknown,
      topCandidates: candidates,
    );
  }

  /// Record a user correction — called when user says "this is actually X"
  static void recordCorrection({
    required ZambianSpecies predicted,
    required ZambianSpecies corrected,
  }) {
    if (predicted == corrected) return;
    // Boost the corrected species
    _correctionCounts[corrected.name] =
        (_correctionCounts[corrected.name] ?? 0) + 1;
    debugPrint('SpeciesClassifier: correction recorded $predicted → $corrected');
  }

  /// Load persisted correction counts (called at app start)
  static void loadCorrections(Map<String, int> saved) {
    _correctionCounts = Map.from(saved);
  }

  static List<RankedSpecies> _buildCandidates(
    ZambianSpecies primary,
    double primaryScore,
  ) {
    // Build plausible alternatives with lower scores
    final all = ZambianSpecies.values
        .where((s) => s != ZambianSpecies.unknown && s != primary)
        .toList();

    final candidates = <RankedSpecies>[
      RankedSpecies(species: primary, score: primaryScore),
    ];

    // Distribute remaining probability among alternatives
    double remaining = 1.0 - primaryScore;
    for (int i = 0; i < all.length && i < 3; i++) {
      final altScore = remaining / (i + 2);
      candidates.add(RankedSpecies(species: all[i], score: altScore));
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates;
  }
}
