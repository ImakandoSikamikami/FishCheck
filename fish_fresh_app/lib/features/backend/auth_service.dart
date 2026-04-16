import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  static SupabaseClient get _db => SupabaseConfig.client;

  // ─── Auth state ───────────────────────────────────────────────────────────

  static User? get currentUser => SupabaseConfig.currentUser;
  static bool get isLoggedIn => SupabaseConfig.isLoggedIn;

  static Stream<AuthState> get authStateChanges =>
      _db.auth.onAuthStateChange;

  // ─── Sign up ──────────────────────────────────────────────────────────────

  static Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final res = await _db.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );
      if (res.user == null) throw const AuthException('Sign up failed.');
      return res.user!;
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException(_friendly(e.toString()));
    }
  }

  // ─── Sign in ──────────────────────────────────────────────────────────────

  static Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _db.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) throw const AuthException('Sign in failed.');
      return res.user!;
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException(_friendly(e.toString()));
    }
  }

  // ─── Sign out ─────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _db.auth.signOut();
  }

  // ─── Password reset ───────────────────────────────────────────────────────

  static Future<void> resetPassword(String email) async {
    await _db.auth.resetPasswordForEmail(email);
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile() async {
    if (!isLoggedIn) return null;
    try {
      final data = await _db
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return data;
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? city,
    String? province,
  }) async {
    if (!isLoggedIn) return;
    await _db.from('profiles').update({
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (city != null) 'city': city,
      if (province != null) 'province': province,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  static String _friendly(String raw) {
    if (raw.contains('Invalid login')) return 'Wrong email or password.';
    if (raw.contains('already registered')) return 'An account with this email already exists.';
    if (raw.contains('weak')) return 'Password is too weak. Use at least 8 characters.';
    if (raw.contains('network') || raw.contains('socket')) return 'No internet connection.';
    debugPrint('AuthService error: $raw');
    return 'Something went wrong. Please try again.';
  }
}
