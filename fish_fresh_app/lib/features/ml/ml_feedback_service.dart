import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'species_classifier.dart';

/// A single user correction record
class CorrectionRecord {
  final String id;
  final String predictedSpecies;
  final String correctedSpecies;
  final int originalConfidence;
  final DateTime recordedAt;
  final String scanId; // links back to the scan

  const CorrectionRecord({
    required this.id,
    required this.predictedSpecies,
    required this.correctedSpecies,
    required this.originalConfidence,
    required this.recordedAt,
    required this.scanId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'predictedSpecies': predictedSpecies,
    'correctedSpecies': correctedSpecies,
    'originalConfidence': originalConfidence,
    'recordedAt': recordedAt.toIso8601String(),
    'scanId': scanId,
  };

  factory CorrectionRecord.fromMap(Map<String, dynamic> m) => CorrectionRecord(
    id: m['id'] ?? '',
    predictedSpecies: m['predictedSpecies'] ?? '',
    correctedSpecies: m['correctedSpecies'] ?? '',
    originalConfidence: m['originalConfidence'] ?? 0,
    recordedAt: DateTime.tryParse(m['recordedAt'] ?? '') ?? DateTime.now(),
    scanId: m['scanId'] ?? '',
  );
}

/// Manages the ML feedback loop:
/// 1. Records user corrections
/// 2. Persists correction counts for the classifier
/// 3. Builds a training dataset for future model retraining
/// 4. Tracks which scans have been confirmed/corrected
class MlFeedbackService {
  static const _correctionsKey = 'ml_corrections';
  static const _correctionCountsKey = 'ml_correction_counts';
  static const _confirmedScansKey = 'ml_confirmed_scans';

  // ─── Initialise ────────────────────────────────────────────────────────────

  /// Load persisted corrections into the classifier on app start
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_correctionCountsKey);
    if (raw != null) {
      try {
        final map = (jsonDecode(raw) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as int));
        SpeciesClassifier.loadCorrections(map);
      } catch (_) {}
    }
  }

  // ─── Record correction ─────────────────────────────────────────────────────

  /// Called when user says "this species is actually X"
  static Future<void> recordCorrection({
    required String scanId,
    required ZambianSpecies predicted,
    required ZambianSpecies corrected,
    required int originalConfidence,
  }) async {
    if (predicted == corrected) return;

    final record = CorrectionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      predictedSpecies: predicted.name,
      correctedSpecies: corrected.name,
      originalConfidence: originalConfidence,
      recordedAt: DateTime.now(),
      scanId: scanId,
    );

    // Persist to storage
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_correctionsKey) ?? [];
    existing.add(jsonEncode(record.toMap()));
    await prefs.setStringList(_correctionsKey, existing);

    // Update correction counts for classifier
    await _updateCorrectionCounts(corrected.name);

    // Notify classifier
    SpeciesClassifier.recordCorrection(
        predicted: predicted, corrected: corrected);

    debugPrint('MlFeedback: saved correction ${predicted.name} → ${corrected.name}');
  }

  /// Called when user confirms the species ID was correct
  static Future<void> confirmCorrect(String scanId) async {
    final prefs = await SharedPreferences.getInstance();
    final confirmed = prefs.getStringList(_confirmedScansKey) ?? [];
    if (!confirmed.contains(scanId)) {
      confirmed.add(scanId);
      await prefs.setStringList(_confirmedScansKey, confirmed);
    }
  }

  // ─── Query ─────────────────────────────────────────────────────────────────

  static Future<bool> hasFeedback(String scanId) async {
    final prefs = await SharedPreferences.getInstance();
    final confirmed = prefs.getStringList(_confirmedScansKey) ?? [];
    if (confirmed.contains(scanId)) return true;
    final corrections = await getAllCorrections();
    return corrections.any((c) => c.scanId == scanId);
  }

  static Future<List<CorrectionRecord>> getAllCorrections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_correctionsKey) ?? [];
    return raw.map((s) {
      try { return CorrectionRecord.fromMap(jsonDecode(s)); }
      catch (_) { return null; }
    }).whereType<CorrectionRecord>().toList();
  }

  /// Returns stats useful for the ML dashboard
  static Future<Map<String, dynamic>> getStats() async {
    final corrections = await getAllCorrections();
    final prefs = await SharedPreferences.getInstance();
    final confirmed = (prefs.getStringList(_confirmedScansKey) ?? []).length;

    final speciesCorrectionMap = <String, int>{};
    for (final c in corrections) {
      speciesCorrectionMap[c.correctedSpecies] =
          (speciesCorrectionMap[c.correctedSpecies] ?? 0) + 1;
    }

    return {
      'totalCorrections': corrections.length,
      'totalConfirmed': confirmed,
      'totalFeedback': corrections.length + confirmed,
      'speciesBreakdown': speciesCorrectionMap,
    };
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  static Future<void> _updateCorrectionCounts(String speciesName) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_correctionCountsKey);
    Map<String, int> counts = {};
    if (raw != null) {
      try {
        counts = (jsonDecode(raw) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }
    counts[speciesName] = (counts[speciesName] ?? 0) + 1;
    await prefs.setString(_correctionCountsKey, jsonEncode(counts));
  }
}
