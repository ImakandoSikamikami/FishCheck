import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/freshness_result.dart';

class HistoryService {
  static const _key = 'scan_history';
  static const _maxItems = 100;

  // ─── Read ──────────────────────────────────────────────────────────────────

  static Future<List<FreshnessResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) {
          try { return FreshnessResult.fromStorageMap(jsonDecode(s)); }
          catch (_) { return null; }
        })
        .whereType<FreshnessResult>()
        .toList()
        .reversed
        .toList();
  }

  /// Search history by fish type name (case-insensitive)
  static Future<List<FreshnessResult>> search(String query) async {
    if (query.trim().isEmpty) return getHistory();
    final all = await getHistory();
    final q = query.toLowerCase();
    return all.where((r) => r.fishType.toLowerCase().contains(q)).toList();
  }

  // ─── Write ─────────────────────────────────────────────────────────────────

  static Future<void> saveResult(FreshnessResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(result.toStorageMap()));
    if (existing.length > _maxItems) existing.removeAt(0);
    await prefs.setStringList(_key, existing);
  }

  /// Replace a pending placeholder with the real analysed result
  static Future<void> updateResult(String id, FreshnessResult updated) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final newList = existing.map((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        if (m['id'] == id) return jsonEncode(updated.toStorageMap());
      } catch (_) {}
      return s;
    }).toList();
    await prefs.setStringList(_key, newList);
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  static Future<void> deleteResult(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final updated = existing.where((s) {
      try {
        return (jsonDecode(s) as Map<String, dynamic>)['id'] != id;
      } catch (_) { return true; }
    }).toList();
    await prefs.setStringList(_key, updated);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ─── Stats ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getStats() async {
    final history = await getHistory();
    if (history.isEmpty) {
      return {'total': 0, 'today': 0, 'freshRate': 0.0, 'topSpecies': '—'};
    }

    final today = DateTime.now();
    final todayCount = history.where((r) =>
      r.analysedAt.year == today.year &&
      r.analysedAt.month == today.month &&
      r.analysedAt.day == today.day).length;

    final freshCount = history
        .where((r) => r.freshness == FreshnessLevel.fresh).length;
    final freshRate = history.isEmpty ? 0.0 : freshCount / history.length;

    // Most scanned species
    final speciesCounts = <String, int>{};
    for (final r in history) {
      if (r.fishType != 'Unknown fish' && !r.isPending) {
        speciesCounts[r.fishType] = (speciesCounts[r.fishType] ?? 0) + 1;
      }
    }
    final topSpecies = speciesCounts.isEmpty
        ? '—'
        : speciesCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'total': history.length,
      'today': todayCount,
      'freshRate': freshRate,
      'topSpecies': topSpecies,
    };
  }
}
