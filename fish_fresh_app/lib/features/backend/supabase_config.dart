import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase configuration for FishCheck ZM
///
/// HOW TO SET UP:
/// 1. Go to https://supabase.com and create a free project
/// 2. Choose Africa (Cape Town) region for lowest latency from Zambia
/// 3. Copy your Project URL and anon key from:
///    Dashboard → Settings → API → Project URL & Project API keys
/// 4. Replace the values below with your actual credentials
/// 5. Run the SQL in supabase/migrations/001_initial_schema.sql
///    in your Supabase SQL editor

class SupabaseConfig {
  // ⚠️  Replace these with your actual Supabase project values
  static const String projectUrl = 'https://woqewayxbbjqkwzsxkty.supabase.co';
  static const String anonKey   = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvcWV3YXl4YmJqcWt3enN4a3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNzczNDEsImV4cCI6MjA5MTY1MzM0MX0.B-zDHsrQjXYBNdYdTeP6QpzYB5iquDTLVMPD82XbBy8';

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
