import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'core/theme_notifier.dart';
import 'features/backend/supabase_config.dart';
import 'services/offline_queue_service.dart';
import 'services/tflite_freshness_service.dart';
import 'features/ml/ml_feedback_service.dart';
import 'features/notifications/notification_service.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;

  // Remove the # from web URLs
  usePathUrlStrategy();

  // Portrait lock on mobile only
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS)) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialise all services
  await SupabaseConfig.init();
  await NotificationService.init();
  OfflineQueueService.init();
  await MlFeedbackService.init();

  // Load TFLite fish freshness model
  await TfliteAnalysisService.loadModel();

  runApp(const FishCheckApp());
}

class FishCheckApp extends StatelessWidget {
  const FishCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeNotifier, LocaleProvider>(
        builder: (_, themeNotifier, localeProvider, __) => MaterialApp.router(
          title: 'FishCheck ZM',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeNotifier.mode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}