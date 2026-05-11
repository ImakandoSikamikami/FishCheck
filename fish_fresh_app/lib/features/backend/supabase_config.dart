import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase configuration for FishCheck ZM.
///
/// Build for physical device (cloud):
///   flutter build apk --debug --dart-define=USE_CLOUD=true
///
/// Run locally on laptop (local Supabase):
///   flutter run
class SupabaseConfig {

  // ── Cloud credentials (APK / physical device) ──────────────────────────────
  static const String _cloudUrl     = 'https://woqewayxbbjqkwzsxkty.supabase.co';
  static const String _cloudAnonKey = 'YOUR_CLOUD_ANON_KEY'; // replace from supabase.com → Settings → API

  // ── Local credentials (flutter run on laptop) ──────────────────────────────
  static const String _localUrl     = 'http://127.0.0.1:54321';
  static const String _localAnonKey = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

  // ── Environment switch ─────────────────────────────────────────────────────
  // Pass --dart-define=USE_CLOUD=true to select cloud; default is false (local).
  static const bool _useCloud = bool.fromEnvironment('USE_CLOUD', defaultValue: false);

  static String get supabaseUrl {
    if (kIsWeb) return _localUrl;
    return _useCloud ? _cloudUrl : _localUrl;
  }

  static String get anonKey {
    if (kIsWeb) return _localAnonKey;
    return _useCloud ? _cloudAnonKey : _localAnonKey;
  }

  // ── Other constants ────────────────────────────────────────────────────────
  static const String scanImagesBucket = 'scan-images';
  static const String analyseFunction  = 'analyse-fish';

  // ── Initialise ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    await Supabase.initialize(
      url:     supabaseUrl,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static SupabaseClient get client      => Supabase.instance.client;
  static User?          get currentUser => client.auth.currentUser;
  static bool           get isLoggedIn  => currentUser != null;
}
