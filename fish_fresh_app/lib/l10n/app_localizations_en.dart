// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get clearAll => 'Clear all';

  @override
  String get navHome => 'Home';

  @override
  String get navScan => 'Scan';

  @override
  String get navVendors => 'Vendors';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get shellSubtitle => 'Freshness App';

  @override
  String get shellFooter => 'FishCheck ZM · Instant Analysis';

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get homeScansToday => 'Scans today';

  @override
  String get homeFreshRate => 'Fresh rate';

  @override
  String get homeTotalScans => 'Total scans';

  @override
  String get homeScanAFish => 'Scan a fish';

  @override
  String homeMostScanned(String species) {
    return 'Your most scanned: $species';
  }

  @override
  String get homeTakeOrUpload => 'Take or upload a photo';

  @override
  String get homeSpeciesGuide => 'Species guide';

  @override
  String get homeScanHistory => 'Scan history';

  @override
  String get homeRecentScans => 'Recent scans';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNoScansYet => 'No scans yet';

  @override
  String get homeScanFirstFish => 'Scan your first fish to get started';

  @override
  String get homeNoInternet => 'No internet connection';

  @override
  String homeOfflineQueued(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No internet · $count scans queued',
      one: 'No internet · $count scan queued',
    );
    return '$_temp0';
  }

  @override
  String homeOfflineReady(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offline scans ready to analyse',
      one: '$count offline scan ready to analyse',
    );
    return '$_temp0';
  }

  @override
  String get homeAnalyseNow => 'Analyse now';

  @override
  String get scanTitle => 'Scan a fish';

  @override
  String get scanSubtitle => 'Take a photo or upload from your gallery';

  @override
  String get scanTapToCamera => 'Tap to open camera';

  @override
  String get scanOrUseButtons => 'Or use the buttons below';

  @override
  String get scanWithCamera => 'Scan with Camera';

  @override
  String get scanSelectPicture => 'Select a Picture';

  @override
  String get scanAnalysing => 'Analysing freshness...';

  @override
  String get scanAnalyse => 'Analyse freshness';

  @override
  String get scanChooseDifferent => 'Choose a different photo';

  @override
  String scanErrorLoadImage(String error) {
    return 'Could not load image: $error';
  }

  @override
  String get scanErrorAnalysis =>
      'Analysis failed. Please try a clearer photo.';

  @override
  String get scanTipClearEyes => 'Clear eyes';

  @override
  String get scanTipShinySkin => 'Shiny skin';

  @override
  String get scanTipRedGills => 'Red gills';

  @override
  String get scanTipFirmFlesh => 'Firm flesh';

  @override
  String get resultFreshnessScore => 'Freshness score';

  @override
  String get resultVisualIndicators => 'Visual indicators';

  @override
  String get resultAdvice => 'Advice';

  @override
  String get resultSellBy => 'Sell by';

  @override
  String get resultSafeToEat => 'Safe to eat';

  @override
  String get resultDoNotEat => 'Do not eat';

  @override
  String get resultAnalysisPending => 'Analysis pending';

  @override
  String get resultPendingSubtitle => 'Saved — will analyse when reconnected.';

  @override
  String get resultEyes => 'Eyes';

  @override
  String get resultSkin => 'Skin';

  @override
  String get resultGills => 'Gills';

  @override
  String get resultFlesh => 'Flesh';

  @override
  String get resultOdour => 'Odour';

  @override
  String get resultScanAnother => 'Scan another fish';

  @override
  String get resultViewHistory => 'View scan history';

  @override
  String resultConfidentDesktop(int confidence) {
    return '$confidence% confident in species ID';
  }

  @override
  String resultConfidentMobile(int confidence) {
    return '$confidence% confident';
  }

  @override
  String resultShareSubject(String fishType) {
    return 'Freshness report — $fishType';
  }

  @override
  String resultShareBody(String fishType, String freshness, int score,
      String sellBy, String safe, String advice, String scanned) {
    return 'FishCheck ZM — Freshness Report\nFish: $fishType\nFreshness: $freshness ($score%)\nSell by: $sellBy\nSafe: $safe\nAdvice: $advice\nScanned: $scanned\nFishCheck ZM';
  }

  @override
  String get resultShareYes => 'Yes';

  @override
  String get resultShareNo => 'No';

  @override
  String resultPricePrefix(String impact) {
    return 'Price: $impact';
  }

  @override
  String get historyTitle => 'Scan history';

  @override
  String get historyClearAllTooltip => 'Clear all';

  @override
  String get historySearch => 'Search by fish name...';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterFresh => 'Fresh';

  @override
  String get historyFilterAcceptable => 'Acceptable';

  @override
  String get historyFilterPoor => 'Poor';

  @override
  String get historyFilterSpoiled => 'Spoiled';

  @override
  String get historyNoScansYet => 'No scans yet';

  @override
  String get historyNoScansSubtitle =>
      'Analyse a fish to see your history here';

  @override
  String historyNoResults(String filter) {
    return 'No $filter scans found';
  }

  @override
  String get historyScore => 'score';

  @override
  String get historyClearTitle => 'Clear all history';

  @override
  String get historyClearContent =>
      'This will delete all scan records. This cannot be undone.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsScansToCloud => 'Scans synced to cloud';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsHistoryOnDevice => 'History stays on this device';

  @override
  String get settingsSignIn => 'Sign in or create account';

  @override
  String get settingsSyncAcrossDevices => 'Sync scans across devices';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsEnableReminders => 'Enable reminders';

  @override
  String get settingsRemindersSubtitle =>
      'Get reminded to re-check fish after 24 hours';

  @override
  String get settingsNotificationsEnabled => 'Notifications enabled!';

  @override
  String get settingsNotificationsDisabled =>
      'Please enable notifications in device settings.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Choose light, dark, or follow system';

  @override
  String get settingsMachineLearning => 'Machine learning';

  @override
  String get settingsAiProgress => 'AI learning progress';

  @override
  String get settingsAiProgressSubtitle =>
      'View species corrections and model accuracy';

  @override
  String get settingsAnalysisEngine => 'Analysis engine';

  @override
  String get settingsAnalysisEngineSubtitle =>
      'On-device image analysis — works offline';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsClearHistory => 'Clear scan history';

  @override
  String get settingsClearHistorySubtitle =>
      'Remove all past fish scans from this device';

  @override
  String get settingsClearHistoryDialog => 'Clear history';

  @override
  String get settingsClearHistoryContent =>
      'Delete all scan history? This cannot be undone.';

  @override
  String get settingsClearHistorySuccess => 'Scan history cleared';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutApp => 'About FishCheck ZM';

  @override
  String get settingsAboutSubtitle => 'Version, mission, credits';

  @override
  String get settingsSpeciesSupported => 'Species supported';

  @override
  String get settingsSpeciesSubtitle =>
      'Kapenta · Bream · Tiger fish · Mpumbu · Chessa · Vundu';

  @override
  String get settingsFishVendors => 'Fish vendors';

  @override
  String get settingsVendorsSubtitle => 'Browse vendors near you';

  @override
  String get settingsFooter => 'FishCheck ZM · v1.0.0 · ';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose your preferred language';

  @override
  String get vendorsTitle => 'Fish vendors';

  @override
  String get vendorsRegisterTooltip => 'Register as vendor';

  @override
  String get vendorsSearch => 'Search vendors or markets...';

  @override
  String get vendorsNoVendors => 'No vendors found';

  @override
  String get vendorsNoVendorsSubtitle => 'Try a different city or search term';

  @override
  String get vendorsRefresh => 'Refresh';

  @override
  String get vendorsCall => 'Call';

  @override
  String get vendorsWhatsApp => 'WhatsApp';

  @override
  String vendorScans(int count) {
    return '$count scans';
  }

  @override
  String get vendorsRegisterSheet => 'Register as a vendor';

  @override
  String get vendorsRegisterDesc =>
      'List your fish stall so customers can find you on FishCheck ZM.';

  @override
  String get vendorsRegisterButton => 'Register my stall';

  @override
  String get vendorsNotNow => 'Not now';

  @override
  String get vendorsComingSoon => 'Vendor registration form coming soon!';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignUpSubtitle =>
      'Sign up to save your scans and sync across devices';

  @override
  String get authSignInSubtitle => 'Sign in to access your scan history';

  @override
  String get authEnterEmailFirst => 'Enter your email address first.';

  @override
  String get authPasswordResetSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get authFullName => 'Full name';

  @override
  String get authNameRequired => 'Name is required';

  @override
  String get authPhone => 'Phone (optional)';

  @override
  String get authEmail => 'Email address';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get authDontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get authContinueWithout => 'Continue without account';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboarding1Title => 'Know your fish is fresh';

  @override
  String get onboarding1Subtitle =>
      'Point your camera at any fish and get an instant AI-powered freshness report. Eyes, skin, gills — analysed in seconds.';

  @override
  String get onboarding2Title => 'Camera or gallery — your choice';

  @override
  String get onboarding2Subtitle =>
      'Take a live photo at the market or upload one from your gallery. Every image format supported. Results work even on slow internet.';

  @override
  String get onboarding3Title => 'Built for Zambian markets';

  @override
  String get onboarding3Subtitle =>
      'Kapenta, Bream, Tiger fish, Mpumbu, Chessa, Vundu — the app knows all local species with local names and fair price ranges.';

  @override
  String get speciesTitle => 'Fish directory';

  @override
  String get speciesSearch => 'Search species or local name...';

  @override
  String get speciesSignsOfFreshness => 'Signs of freshness';

  @override
  String get speciesSpoilageWarning => 'Spoilage warning signs';

  @override
  String get speciesCookingTip => 'Cooking tip';

  @override
  String get speciesHabitat => 'Habitat';

  @override
  String get speciesBestSeason => 'Best season';

  @override
  String get speciesMarketPrice => 'Market price';

  @override
  String get kapentaName => 'Kapenta';

  @override
  String get kapentaHabitat => 'Lakes Tanganyika & Kariba';

  @override
  String get kapentaSeason => 'Year-round';

  @override
  String get kapentaPriceRange =>
      'ZMW 20–60/kg (fresh) · ZMW 80–150/kg (dried)';

  @override
  String get kapentaDescription =>
      'Tiny freshwater sardines — the most commercially important fish in Zambia. Sold fresh or sun-dried. Dried kapenta is a staple across all provinces.';

  @override
  String get kapentaFreshIndicators =>
      'Fresh kapenta: silver sheen, clear eyes, mild sea smell. Dried kapenta: uniform light-brown colour, dry to touch, no mould, mild smell.';

  @override
  String get kapentaSpoilageWarning =>
      'Yellowish colour, strong fishy odour, or stickiness on fresh kapenta means it is no longer safe. Dried kapenta with dark patches or visible mould should be discarded.';

  @override
  String get kapentaCookingTip =>
      'Best fried crispy with onions and tomatoes, or simmered in groundnut relish (nshima accompaniment).';

  @override
  String get breamName => 'Bream (Tilapia)';

  @override
  String get breamHabitat => 'Most freshwater bodies';

  @override
  String get breamSeason => 'Year-round';

  @override
  String get breamPriceRange => 'ZMW 35–100/kg';

  @override
  String get breamDescription =>
      'The most widely consumed fish in Zambia. Found in rivers, dams and lakes nationwide. Available in nearly every market, often sold live.';

  @override
  String get breamFreshIndicators =>
      'Bright red or deep pink gills, clear bulging eyes, firm flesh that springs back when pressed, shiny silver-green skin with tight scales.';

  @override
  String get breamSpoilageWarning =>
      'Brown or grey gills, sunken or cloudy eyes, soft mushy flesh, and strong sour smell are all clear signs of deterioration.';

  @override
  String get breamCookingTip =>
      'Excellent grilled whole with tomatoes and onions, or fried. Commonly used in Zambian relish.';

  @override
  String get tigerName => 'Tiger fish';

  @override
  String get tigerHabitat => 'Zambezi River, Lake Kariba';

  @override
  String get tigerSeason => 'Best Aug–Oct';

  @override
  String get tigerPriceRange => 'ZMW 60–140/kg';

  @override
  String get tigerDescription =>
      'Fierce predatory fish from the Zambezi and Lake Kariba. Prized for its firm, white flesh. Popular with sport anglers and a delicacy at markets near Kariba.';

  @override
  String get tigerFreshIndicators =>
      'Distinctive silver body with black tiger stripes. Bright eyes, firm white flesh, and a mild fresh smell. Teeth remain prominent and jaw is well-defined.';

  @override
  String get tigerSpoilageWarning =>
      'Fading stripes, dull discoloured skin, loose scales and a strong ammonia-like smell indicate the fish is past its best.';

  @override
  String get tigerCookingTip =>
      'Best grilled or baked whole with lemon and herbs. The firm flesh holds well on a braai.';

  @override
  String get mpumbuName => 'Mpumbu';

  @override
  String get mpumbuHabitat => 'Lake Bangweulu';

  @override
  String get mpumbuSeason => 'Jun–Oct';

  @override
  String get mpumbuPriceRange => 'ZMW 50–120/kg';

  @override
  String get mpumbuDescription =>
      'A prized, large lake fish endemic to Lake Bangweulu. Highly valued by local communities and often dried or smoked. Scarcity makes it relatively expensive.';

  @override
  String get mpumbuFreshIndicators =>
      'Deep silver body with prominent scales. Clear eyes, bright red-pink gills, and firm iridescent flesh. Fresh specimens have almost no smell.';

  @override
  String get mpumbuSpoilageWarning =>
      'Any discolouration of the flesh from white to yellowish, combined with a sour or strong fishy odour, indicates spoilage.';

  @override
  String get mpumbuCookingTip =>
      'Wonderful smoked or grilled. The flavour is rich — pairs well with simple seasoning to let the fish shine.';

  @override
  String get chessaName => 'Chessa';

  @override
  String get chessaHabitat => 'Lakes Bangweulu & Mweru';

  @override
  String get chessaSeason => 'Year-round';

  @override
  String get chessaPriceRange => 'ZMW 25–70/kg';

  @override
  String get chessaDescription =>
      'A medium-sized lake fish common in Lake Bangweulu and Lake Mweru. Often sold dried in bulk. An important protein source in Northern and Luapula provinces.';

  @override
  String get chessaFreshIndicators =>
      'Silvery skin with firm texture. Clear eyes and tight intact scales. Fresh smell with no sourness. Dried chessa should be golden-brown and dry throughout.';

  @override
  String get chessaSpoilageWarning =>
      'Soft spots on the flesh, visible slime on the skin, cloudy eyes, or an ammonia-like odour are all signs to avoid.';

  @override
  String get chessaCookingTip =>
      'Usually fried or dried and powdered as a flavouring. Works well in stews and nshima relish.';

  @override
  String get vunduName => 'Vundu (Catfish)';

  @override
  String get vunduHabitat => 'Zambezi River & major rivers';

  @override
  String get vunduSeason => 'Year-round';

  @override
  String get vunduPriceRange => 'ZMW 40–100/kg';

  @override
  String get vunduDescription =>
      'Large freshwater catfish found in the Zambezi and Kafue rivers. Can grow very large — up to 50kg. Has no scales. Excellent firm white flesh, popular for smoking.';

  @override
  String get vunduFreshIndicators =>
      'Moist, slightly slimy skin (normal for catfish). Firm pale flesh, clear eyes, and mild fresh smell with no sourness.';

  @override
  String get vunduSpoilageWarning =>
      'Excessive stickiness, yellowing of the flesh, strong ammonia smell, or visibly soft flesh are warning signs.';

  @override
  String get vunduCookingTip =>
      'Superb smoked, grilled in large cuts, or curried. The thick flesh is very forgiving to cook.';
}
