import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/home/home_screen.dart';
import '../screens/result_screen.dart';
import '../features/ml/ml_insights_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/vendors/vendors_screen.dart';
import '../features/launch/about_screen.dart';
import '../models/freshness_result.dart';
import '../screens/scan_screen.dart';
import '../screens/history_screen.dart';
import '../screens/species_screen.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const auth        = '/auth';
  static const home        = '/home';
  static const scan        = '/scan';
  static const result      = '/result';
  static const history     = '/history';
  static const species     = '/species';
  static const vendors     = '/vendors';
  static const settings    = '/settings';
  static const mlInsights  = '/ml-insights';
  static const about       = '/about';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash,     builder: (_, __) => const SplashScreen()),
      GoRoute(path: onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: auth,       builder: (_, __) => const AuthScreen()),

      GoRoute(
        path: result,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final r = extra['result'] as FreshnessResult?;
          final bytes = extra['bytes'] as Uint8List?;
          if (r == null) return const _NotFound();
          return ResultScreen(result: r, imageBytes: bytes);
        },
      ),

      GoRoute(path: mlInsights, builder: (_, __) => const MlInsightsScreen()),
      GoRoute(path: about,      builder: (_, __) => const AboutScreen()),

      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: home,     builder: (_, __) => const HomeScreen()),
          GoRoute(path: scan,     builder: (_, __) => const ScanScreen()),
          GoRoute(path: history,  builder: (_, __) => const HistoryScreen()),
          GoRoute(path: species,  builder: (_, __) => const SpeciesScreen()),
          GoRoute(path: vendors,  builder: (_, __) => const VendorsScreen()),
          GoRoute(path: settings, builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Page not found',
        style: Theme.of(context).textTheme.bodyLarge)),
  );
}
