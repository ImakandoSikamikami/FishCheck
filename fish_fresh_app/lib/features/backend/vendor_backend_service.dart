import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/vendor.dart';
import 'supabase_config.dart';

/// Vendor directory backed by Supabase
class VendorBackendService {
  static SupabaseClient get _db => SupabaseConfig.client;

  // ─── Read ──────────────────────────────────────────────────────────────────

  /// Fetch all active vendors, optionally filtered by city
  static Future<List<Vendor>> getVendors({String? city}) async {
    try {
      var query = _db
          .from('vendors')
          .select()
          .eq('is_active', true);

      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }

      final data = await query.order('is_verified', ascending: false)
          .order('average_rating', ascending: false);

      return (data as List)
          .map((m) => _fromRow(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('VendorBackend: getVendors failed — $e');
      return [];
    }
  }

  /// Search vendors by name, market, or species
  static Future<List<Vendor>> search(String query) async {
    try {
      final data = await _db
          .from('vendors')
          .select()
          .eq('is_active', true)
          .or('name.ilike.%$query%,market_name.ilike.%$query%');
      return (data as List)
          .map((m) => _fromRow(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('VendorBackend: search failed — $e');
      return [];
    }
  }

  /// Find vendors within [radiusKm] of a location using PostGIS
  static Future<List<Vendor>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    try {
      // PostGIS ST_DWithin query via RPC
      final data = await _db.rpc('vendors_within_radius', params: {
        'lat': latitude,
        'lng': longitude,
        'radius_km': radiusKm,
      });
      return (data as List)
          .map((m) => _fromRow(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('VendorBackend: getNearby failed — $e');
      // Fallback to all vendors if PostGIS not available
      return getVendors();
    }
  }

  // ─── Write ─────────────────────────────────────────────────────────────────

  /// Register as a new vendor
  static Future<Vendor?> createVendor({
    required String name,
    required String phone,
    required String whatsapp,
    required String marketName,
    required String city,
    required String province,
    required List<String> fishSpecies,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    if (!SupabaseConfig.isLoggedIn) return null;
    try {
      final data = await _db.from('vendors').insert({
        'user_id':      SupabaseConfig.currentUser!.id,
        'name':         name,
        'phone':        phone,
        'whatsapp':     whatsapp,
        'market_name':  marketName,
        'city':         city,
        'province':     province,
        'fish_species': fishSpecies,
        'description':  description,
        'latitude':     latitude,
        'longitude':    longitude,
      }).select().single();
      return _fromRow(data);
    } catch (e) {
      debugPrint('VendorBackend: createVendor failed — $e');
      return null;
    }
  }

  /// Update own vendor listing
  static Future<void> updateVendor(String id, Map<String, dynamic> updates) async {
    if (!SupabaseConfig.isLoggedIn) return;
    try {
      await _db.from('vendors').update(updates).eq('id', id)
          .eq('user_id', SupabaseConfig.currentUser!.id);
    } catch (e) {
      debugPrint('VendorBackend: updateVendor failed — $e');
    }
  }

  // ─── Convert ───────────────────────────────────────────────────────────────

  static Vendor _fromRow(Map<String, dynamic> row) => Vendor(
    id:            row['id'] ?? '',
    name:          row['name'] ?? '',
    phone:         row['phone'] ?? '',
    whatsapp:      row['whatsapp'] ?? '',
    marketName:    row['market_name'] ?? '',
    city:          row['city'] ?? '',
    province:      row['province'] ?? '',
    latitude:      (row['latitude'] as num?)?.toDouble(),
    longitude:     (row['longitude'] as num?)?.toDouble(),
    fishSpecies:   List<String>.from(row['fish_species'] ?? []),
    description:   row['description'],
    isVerified:    row['is_verified'] == true,
    createdAt:     DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
    averageRating: (row['average_rating'] as num?)?.toDouble(),
    totalScans:    row['total_scans'] ?? 0,
  );
}
