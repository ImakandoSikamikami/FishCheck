import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase configuration for FishCheck ZM
///
/// CURRENT SETUP: Local Supabase (running on your computer)
/// Studio:     http://127.0.0.1:54323
/// API URL:    http://127.0.0.1:54321
///
/// TO SWITCH BACK TO CLOUD: replace projectUrl and anonKey
/// with your cloud credentials from supabase.com

class SupabaseConfig {
  // Local Supabase credentials
  static const String projectUrl = 'http://127.0.0.1:54321';
  static const String anonKey   = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

  // Storage bucket name (created by the SQL migration)
  static const String scanImagesBucket = 'scan-images';

  // Edge Function names (for API key proxy - Phase 5b)
  static const String analyseFunction = 'analyse-fish';

  /// Initialise Supabase — called once in main()
  static Future<void> init() async {
    await Supabase.initialize(
      url: projectUrl,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Quick access to the Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  /// Current authenticated user (null if not logged in)
  static User? get currentUser => client.auth.currentUser;

  /// Whether a user is currently logged in
  static bool get isLoggedIn => currentUser != null;
}