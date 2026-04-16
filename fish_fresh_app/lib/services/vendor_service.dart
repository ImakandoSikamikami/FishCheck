import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vendor.dart';

class VendorService {
  static const _key = 'vendors';
  static const _myVendorKey = 'my_vendor_id';
  static bool _seeded = false;

  static Future<List<Vendor>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    if (!_seeded && (prefs.getStringList(_key) ?? []).isEmpty) {
      await _seed(prefs);
    }
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) {
      try { return Vendor.fromMap(jsonDecode(s)); } catch (_) { return null; }
    }).whereType<Vendor>().toList();
  }

  static Future<void> _seed(SharedPreferences prefs) async {
    _seeded = true;
    final encoded = sampleVendors.map((v) => jsonEncode(v.toMap())).toList();
    await prefs.setStringList(_key, encoded);
  }

  static Future<void> save(Vendor vendor) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    final idx = existing.indexWhere((v) => v.id == vendor.id);
    if (idx >= 0) existing[idx] = vendor; else existing.add(vendor);
    await prefs.setStringList(_key, existing.map((v) => jsonEncode(v.toMap())).toList());
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    existing.removeWhere((v) => v.id == id);
    await prefs.setStringList(_key, existing.map((v) => jsonEncode(v.toMap())).toList());
  }

  static Future<String?> getMyVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_myVendorKey);
  }

  static Future<void> setMyVendorId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_myVendorKey, id);
  }

  static Future<Vendor?> getById(String id) async {
    final all = await getAll();
    try { return all.firstWhere((v) => v.id == id); } catch (_) { return null; }
  }

  static Future<List<Vendor>> search(String query) async {
    final all = await getAll();
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((v) =>
      v.name.toLowerCase().contains(q) ||
      v.marketName.toLowerCase().contains(q) ||
      v.city.toLowerCase().contains(q) ||
      v.fishSpecies.any((s) => s.toLowerCase().contains(q))
    ).toList();
  }

  static Future<List<Vendor>> getNearby(double lat, double lng, {double radiusKm = 50}) async {
    final all = await getAll();
    return all.where((v) {
      if (v.latitude == null || v.longitude == null) return false;
      final dist = _haversine(lat, lng, v.latitude!, v.longitude!);
      return dist <= radiusKm;
    }).toList()
      ..sort((a, b) {
        final da = _haversine(lat, lng, a.latitude!, a.longitude!);
        final db = _haversine(lat, lng, b.latitude!, b.longitude!);
        return da.compareTo(db);
      });
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = _sin2(dLat / 2) + _cos(_rad(lat1)) * _cos(_rad(lat2)) * _sin2(dLon / 2);
    return r * 2 * _asin(a < 1 ? a : 1);
  }

  static double _rad(double d) => d * 3.141592653589793 / 180;
  static double _sin2(double x) { final s = _sin(x); return s * s; }
  static double _sin(double x) => (x - x * x * x / 6 + x * x * x * x * x / 120);
  static double _cos(double x) => (1 - x * x / 2 + x * x * x * x / 24);
  static double _asin(double x) => x + x * x * x / 6;
}
