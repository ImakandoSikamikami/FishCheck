import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/freshness_result.dart';
import 'supabase_config.dart';

/// Handles two-way sync of scan results between device and Supabase
class CloudSyncService {
  static SupabaseClient get _db => SupabaseConfig.client;

  // ─── Upload scan ──────────────────────────────────────────────────────────

  /// Upload a completed scan result to Supabase.
  /// Also uploads the image thumbnail to Storage if bytes are available.
  static Future<String?> uploadScan(FreshnessResult result) async {
    if (!SupabaseConfig.isLoggedIn) return null;

    try {
      String? imageUrl;

      // Upload thumbnail to storage if we have bytes
      if (result.imageBytes != null &&
          result.imageBytes!.length <= 500000) {
        imageUrl = await _uploadImage(result.id, result.imageBytes!);
      }

      final data = await _db.from('scans').insert({
        'id':           result.id,
        'user_id':      SupabaseConfig.currentUser!.id,
        'fish_type':    result.fishType,
        'freshness':    result.freshnessLabel,
        'score':        result.score,
        'confidence':   result.confidence,
        'eyes':         result.eyes,
        'skin':         result.skin,
        'gills':        result.gills,
        'flesh':        result.flesh,
        'odour_guess':  result.odourGuess,
        'safe_to_eat':  result.safeToEat,
        'advice':       result.advice,
        'sell_by':      result.sellBy,
        'storage_tip':  result.storageTip,
        'price_impact': result.priceImpact,
        'image_url':    imageUrl,
        'is_pending':   result.isPending,
        'analysed_at':  result.analysedAt.toIso8601String(),
      }).select('id').single();

      return data['id'] as String?;
    } catch (e) {
      debugPrint('CloudSync: uploadScan failed — $e');
      return null;
    }
  }

  /// Update a pending scan with real results after offline queue is drained
  static Future<void> updateScan(String id, FreshnessResult result) async {
    if (!SupabaseConfig.isLoggedIn) return;
    try {
      await _db.from('scans').update({
        'fish_type':    result.fishType,
        'freshness':    result.freshnessLabel,
        'score':        result.score,
        'confidence':   result.confidence,
        'eyes':         result.eyes,
        'skin':         result.skin,
        'gills':        result.gills,
        'flesh':        result.flesh,
        'odour_guess':  result.odourGuess,
        'safe_to_eat':  result.safeToEat,
        'advice':       result.advice,
        'sell_by':      result.sellBy,
        'storage_tip':  result.storageTip,
        'price_impact': result.priceImpact,
        'is_pending':   false,
      }).eq('id', id);
    } catch (e) {
      debugPrint('CloudSync: updateScan failed — $e');
    }
  }

  // ─── Fetch scans ──────────────────────────────────────────────────────────

  /// Fetch the user's scan history from Supabase (most recent first)
  static Future<List<Map<String, dynamic>>> fetchScans({
    int limit = 50,
    int offset = 0,
  }) async {
    if (!SupabaseConfig.isLoggedIn) return [];
    try {
      final data = await _db
          .from('scans')
          .select()
          .eq('user_id', SupabaseConfig.currentUser!.id)
          .order('analysed_at', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('CloudSync: fetchScans failed — $e');
      return [];
    }
  }

  /// Delete a scan from the cloud
  static Future<void> deleteScan(String id) async {
    if (!SupabaseConfig.isLoggedIn) return;
    try {
      await _db.from('scans').delete().eq('id', id);
    } catch (e) {
      debugPrint('CloudSync: deleteScan failed — $e');
    }
  }

  // ─── Image storage ────────────────────────────────────────────────────────

  static Future<String?> _uploadImage(String scanId, Uint8List bytes) async {
    try {
      final userId = SupabaseConfig.currentUser!.id;
      final path = '$userId/$scanId.jpg';
      await _db.storage
          .from(SupabaseConfig.scanImagesBucket)
          .uploadBinary(path, bytes,
              fileOptions: const FileOptions(
                  contentType: 'image/jpeg', upsert: true));
      return _db.storage
          .from(SupabaseConfig.scanImagesBucket)
          .getPublicUrl(path);
    } catch (e) {
      debugPrint('CloudSync: image upload failed — $e');
      return null;
    }
  }

  /// Get a signed URL for a stored scan image
  static Future<String?> getImageUrl(String scanId) async {
    if (!SupabaseConfig.isLoggedIn) return null;
    try {
      final userId = SupabaseConfig.currentUser!.id;
      final path = '$userId/$scanId.jpg';
      return await _db.storage
          .from(SupabaseConfig.scanImagesBucket)
          .createSignedUrl(path, 3600); // 1 hour expiry
    } catch (_) {
      return null;
    }
  }

  // ─── ML corrections ───────────────────────────────────────────────────────

  static Future<void> uploadCorrection({
    required String scanId,
    required String predicted,
    required String corrected,
    required int confidence,
  }) async {
    if (!SupabaseConfig.isLoggedIn) return;
    try {
      await _db.from('ml_corrections').insert({
        'user_id':             SupabaseConfig.currentUser!.id,
        'scan_id':             scanId,
        'predicted_species':   predicted,
        'corrected_species':   corrected,
        'original_confidence': confidence,
      });
    } catch (e) {
      debugPrint('CloudSync: uploadCorrection failed — $e');
    }
  }
}
