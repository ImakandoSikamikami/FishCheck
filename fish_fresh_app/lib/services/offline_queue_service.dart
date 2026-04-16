import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/freshness_result.dart';
import '../services/ai_service.dart';
import '../services/history_service.dart';

/// Queued scan item waiting for connectivity
class _QueueItem {
  final String id;
  final String imageB64;
  final String mediaType;
  final DateTime queuedAt;

  const _QueueItem({
    required this.id,
    required this.imageB64,
    required this.mediaType,
    required this.queuedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'imageB64': imageB64,
    'mediaType': mediaType,
    'queuedAt': queuedAt.toIso8601String(),
  };

  factory _QueueItem.fromMap(Map<String, dynamic> m) => _QueueItem(
    id: m['id'],
    imageB64: m['imageB64'],
    mediaType: m['mediaType'],
    queuedAt: DateTime.tryParse(m['queuedAt'] ?? '') ?? DateTime.now(),
  );
}

/// Manages offline scan queue and auto-drains when connectivity returns
class OfflineQueueService {
  static const _queueKey = 'offline_scan_queue';
  static bool _draining = false;

  /// Called on app start — listen for connectivity changes and drain queue
  static void init() {
    Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected && !_draining) drainQueue();
    });
  }

  /// Check if device currently has internet
  static Future<bool> hasConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Add a scan to the offline queue and save a pending placeholder to history
  static Future<FreshnessResult> enqueue(
      Uint8List bytes, String mediaType) async {
    final id = const Uuid().v4();
    final item = _QueueItem(
      id: id,
      imageB64: base64Encode(bytes),
      mediaType: mediaType,
      queuedAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_queueKey) ?? [];
    existing.add(jsonEncode(item.toMap()));
    await prefs.setStringList(_queueKey, existing);

    // Save a pending placeholder in history so user sees it immediately
    final placeholder = FreshnessResult.pending(id: id, imageBytes: bytes);
    await HistoryService.saveResult(placeholder);

    return placeholder;
  }

  /// Returns how many scans are waiting in the queue
  static Future<int> queueLength() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_queueKey) ?? []).length;
  }

  /// Process all queued scans now (called when connectivity returns)
  static Future<void> drainQueue({VoidCallback? onItemProcessed}) async {
    if (_draining) return;
    _draining = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_queueKey) ?? [];
      if (raw.isEmpty) return;

      final remaining = <String>[];

      for (final s in raw) {
        try {
          final item = _QueueItem.fromMap(jsonDecode(s));
          final bytes = base64Decode(item.imageB64);
          final result = await AiService.analyseBytes(bytes, item.mediaType);

          // Replace the pending placeholder with the real result
          await HistoryService.updateResult(item.id, result);
          onItemProcessed?.call();
        } catch (e) {
          // Keep in queue if analysis failed (might be a transient error)
          remaining.add(s);
          debugPrint('OfflineQueue: failed to process item — $e');
        }
      }

      await prefs.setStringList(_queueKey, remaining);
    } finally {
      _draining = false;
    }
  }
}
