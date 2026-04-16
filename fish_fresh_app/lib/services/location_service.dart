// Location service - stubbed until Phase 5 backend is built
// geolocator will be added back when vendor location features are implemented

class LocationService {
  static Future<Map<String, double>?> getCurrentPosition() async {
    // Will be implemented in Phase 5 with geolocator
    return null;
  }

  static double distanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    // Simple placeholder - will use geolocator in Phase 5
    return 0.0;
  }
}
