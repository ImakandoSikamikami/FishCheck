import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get navVendors;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @shellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Freshness App'**
  String get shellSubtitle;

  /// No description provided for @shellFooter.
  ///
  /// In en, this message translates to:
  /// **'FishCheck ZM · Instant Analysis'**
  String get shellFooter;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @homeScansToday.
  ///
  /// In en, this message translates to:
  /// **'Scans today'**
  String get homeScansToday;

  /// No description provided for @homeFreshRate.
  ///
  /// In en, this message translates to:
  /// **'Fresh rate'**
  String get homeFreshRate;

  /// No description provided for @homeTotalScans.
  ///
  /// In en, this message translates to:
  /// **'Total scans'**
  String get homeTotalScans;

  /// No description provided for @homeScanAFish.
  ///
  /// In en, this message translates to:
  /// **'Scan a fish'**
  String get homeScanAFish;

  /// No description provided for @homeMostScanned.
  ///
  /// In en, this message translates to:
  /// **'Your most scanned: {species}'**
  String homeMostScanned(String species);

  /// No description provided for @homeTakeOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Take or upload a photo'**
  String get homeTakeOrUpload;

  /// No description provided for @homeSpeciesGuide.
  ///
  /// In en, this message translates to:
  /// **'Species guide'**
  String get homeSpeciesGuide;

  /// No description provided for @homeScanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get homeScanHistory;

  /// No description provided for @homeRecentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent scans'**
  String get homeRecentScans;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeNoScansYet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get homeNoScansYet;

  /// No description provided for @homeScanFirstFish.
  ///
  /// In en, this message translates to:
  /// **'Scan your first fish to get started'**
  String get homeScanFirstFish;

  /// No description provided for @homeNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get homeNoInternet;

  /// No description provided for @homeOfflineQueued.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{No internet · {count} scan queued} other{No internet · {count} scans queued}}'**
  String homeOfflineQueued(num count);

  /// No description provided for @homeOfflineReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} offline scan ready to analyse} other{{count} offline scans ready to analyse}}'**
  String homeOfflineReady(num count);

  /// No description provided for @homeAnalyseNow.
  ///
  /// In en, this message translates to:
  /// **'Analyse now'**
  String get homeAnalyseNow;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a fish'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or upload from your gallery'**
  String get scanSubtitle;

  /// No description provided for @scanTapToCamera.
  ///
  /// In en, this message translates to:
  /// **'Tap to open camera'**
  String get scanTapToCamera;

  /// No description provided for @scanOrUseButtons.
  ///
  /// In en, this message translates to:
  /// **'Or use the buttons below'**
  String get scanOrUseButtons;

  /// No description provided for @scanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with Camera'**
  String get scanWithCamera;

  /// No description provided for @scanSelectPicture.
  ///
  /// In en, this message translates to:
  /// **'Select a Picture'**
  String get scanSelectPicture;

  /// No description provided for @scanAnalysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing freshness...'**
  String get scanAnalysing;

  /// No description provided for @scanAnalyse.
  ///
  /// In en, this message translates to:
  /// **'Analyse freshness'**
  String get scanAnalyse;

  /// No description provided for @scanChooseDifferent.
  ///
  /// In en, this message translates to:
  /// **'Choose a different photo'**
  String get scanChooseDifferent;

  /// No description provided for @scanErrorLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Could not load image: {error}'**
  String scanErrorLoadImage(String error);

  /// No description provided for @scanErrorAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed. Please try a clearer photo.'**
  String get scanErrorAnalysis;

  /// No description provided for @scanTipClearEyes.
  ///
  /// In en, this message translates to:
  /// **'Clear eyes'**
  String get scanTipClearEyes;

  /// No description provided for @scanTipShinySkin.
  ///
  /// In en, this message translates to:
  /// **'Shiny skin'**
  String get scanTipShinySkin;

  /// No description provided for @scanTipRedGills.
  ///
  /// In en, this message translates to:
  /// **'Red gills'**
  String get scanTipRedGills;

  /// No description provided for @scanTipFirmFlesh.
  ///
  /// In en, this message translates to:
  /// **'Firm flesh'**
  String get scanTipFirmFlesh;

  /// No description provided for @resultFreshnessScore.
  ///
  /// In en, this message translates to:
  /// **'Freshness score'**
  String get resultFreshnessScore;

  /// No description provided for @resultVisualIndicators.
  ///
  /// In en, this message translates to:
  /// **'Visual indicators'**
  String get resultVisualIndicators;

  /// No description provided for @resultAdvice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get resultAdvice;

  /// No description provided for @resultSellBy.
  ///
  /// In en, this message translates to:
  /// **'Sell by'**
  String get resultSellBy;

  /// No description provided for @resultSafeToEat.
  ///
  /// In en, this message translates to:
  /// **'Safe to eat'**
  String get resultSafeToEat;

  /// No description provided for @resultDoNotEat.
  ///
  /// In en, this message translates to:
  /// **'Do not eat'**
  String get resultDoNotEat;

  /// No description provided for @resultAnalysisPending.
  ///
  /// In en, this message translates to:
  /// **'Analysis pending'**
  String get resultAnalysisPending;

  /// No description provided for @resultPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved — will analyse when reconnected.'**
  String get resultPendingSubtitle;

  /// No description provided for @resultEyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get resultEyes;

  /// No description provided for @resultSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get resultSkin;

  /// No description provided for @resultGills.
  ///
  /// In en, this message translates to:
  /// **'Gills'**
  String get resultGills;

  /// No description provided for @resultFlesh.
  ///
  /// In en, this message translates to:
  /// **'Flesh'**
  String get resultFlesh;

  /// No description provided for @resultOdour.
  ///
  /// In en, this message translates to:
  /// **'Odour'**
  String get resultOdour;

  /// No description provided for @resultScanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan another fish'**
  String get resultScanAnother;

  /// No description provided for @resultViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View scan history'**
  String get resultViewHistory;

  /// No description provided for @resultConfidentDesktop.
  ///
  /// In en, this message translates to:
  /// **'{confidence}% confident in species ID'**
  String resultConfidentDesktop(int confidence);

  /// No description provided for @resultConfidentMobile.
  ///
  /// In en, this message translates to:
  /// **'{confidence}% confident'**
  String resultConfidentMobile(int confidence);

  /// No description provided for @resultShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Freshness report — {fishType}'**
  String resultShareSubject(String fishType);

  /// No description provided for @resultShareBody.
  ///
  /// In en, this message translates to:
  /// **'FishCheck ZM — Freshness Report\nFish: {fishType}\nFreshness: {freshness} ({score}%)\nSell by: {sellBy}\nSafe: {safe}\nAdvice: {advice}\nScanned: {scanned}\nFishCheck ZM'**
  String resultShareBody(String fishType, String freshness, int score,
      String sellBy, String safe, String advice, String scanned);

  /// No description provided for @resultShareYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get resultShareYes;

  /// No description provided for @resultShareNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get resultShareNo;

  /// No description provided for @resultPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Price: {impact}'**
  String resultPricePrefix(String impact);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get historyTitle;

  /// No description provided for @historyClearAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get historyClearAllTooltip;

  /// No description provided for @historySearch.
  ///
  /// In en, this message translates to:
  /// **'Search by fish name...'**
  String get historySearch;

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// No description provided for @historyFilterFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get historyFilterFresh;

  /// No description provided for @historyFilterAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Acceptable'**
  String get historyFilterAcceptable;

  /// No description provided for @historyFilterPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get historyFilterPoor;

  /// No description provided for @historyFilterSpoiled.
  ///
  /// In en, this message translates to:
  /// **'Spoiled'**
  String get historyFilterSpoiled;

  /// No description provided for @historyNoScansYet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get historyNoScansYet;

  /// No description provided for @historyNoScansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyse a fish to see your history here'**
  String get historyNoScansSubtitle;

  /// No description provided for @historyNoResults.
  ///
  /// In en, this message translates to:
  /// **'No {filter} scans found'**
  String historyNoResults(String filter);

  /// No description provided for @historyScore.
  ///
  /// In en, this message translates to:
  /// **'score'**
  String get historyScore;

  /// No description provided for @historyClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all history'**
  String get historyClearTitle;

  /// No description provided for @historyClearContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete all scan records. This cannot be undone.'**
  String get historyClearContent;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsScansToCloud.
  ///
  /// In en, this message translates to:
  /// **'Scans synced to cloud'**
  String get settingsScansToCloud;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsHistoryOnDevice.
  ///
  /// In en, this message translates to:
  /// **'History stays on this device'**
  String get settingsHistoryOnDevice;

  /// No description provided for @settingsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create account'**
  String get settingsSignIn;

  /// No description provided for @settingsSyncAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync scans across devices'**
  String get settingsSyncAcrossDevices;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsEnableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders'**
  String get settingsEnableReminders;

  /// No description provided for @settingsRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded to re-check fish after 24 hours'**
  String get settingsRemindersSubtitle;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled!'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications in device settings.'**
  String get settingsNotificationsDisabled;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose light, dark, or follow system'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsMachineLearning.
  ///
  /// In en, this message translates to:
  /// **'Machine learning'**
  String get settingsMachineLearning;

  /// No description provided for @settingsAiProgress.
  ///
  /// In en, this message translates to:
  /// **'AI learning progress'**
  String get settingsAiProgress;

  /// No description provided for @settingsAiProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View species corrections and model accuracy'**
  String get settingsAiProgressSubtitle;

  /// No description provided for @settingsAnalysisEngine.
  ///
  /// In en, this message translates to:
  /// **'Analysis engine'**
  String get settingsAnalysisEngine;

  /// No description provided for @settingsAnalysisEngineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-device image analysis — works offline'**
  String get settingsAnalysisEngineSubtitle;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear scan history'**
  String get settingsClearHistory;

  /// No description provided for @settingsClearHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all past fish scans from this device'**
  String get settingsClearHistorySubtitle;

  /// No description provided for @settingsClearHistoryDialog.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get settingsClearHistoryDialog;

  /// No description provided for @settingsClearHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'Delete all scan history? This cannot be undone.'**
  String get settingsClearHistoryContent;

  /// No description provided for @settingsClearHistorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Scan history cleared'**
  String get settingsClearHistorySuccess;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About FishCheck ZM'**
  String get settingsAboutApp;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, mission, credits'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsSpeciesSupported.
  ///
  /// In en, this message translates to:
  /// **'Species supported'**
  String get settingsSpeciesSupported;

  /// No description provided for @settingsSpeciesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kapenta · Bream · Tiger fish · Mpumbu · Chessa · Vundu'**
  String get settingsSpeciesSubtitle;

  /// No description provided for @settingsFishVendors.
  ///
  /// In en, this message translates to:
  /// **'Fish vendors'**
  String get settingsFishVendors;

  /// No description provided for @settingsVendorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse vendors near you'**
  String get settingsVendorsSubtitle;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'FishCheck ZM · v1.0.0 · '**
  String get settingsFooter;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @vendorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fish vendors'**
  String get vendorsTitle;

  /// No description provided for @vendorsRegisterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Register as vendor'**
  String get vendorsRegisterTooltip;

  /// No description provided for @vendorsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search vendors or markets...'**
  String get vendorsSearch;

  /// No description provided for @vendorsNoVendors.
  ///
  /// In en, this message translates to:
  /// **'No vendors found'**
  String get vendorsNoVendors;

  /// No description provided for @vendorsNoVendorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different city or search term'**
  String get vendorsNoVendorsSubtitle;

  /// No description provided for @vendorsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get vendorsRefresh;

  /// No description provided for @vendorsCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get vendorsCall;

  /// No description provided for @vendorsWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get vendorsWhatsApp;

  /// No description provided for @vendorScans.
  ///
  /// In en, this message translates to:
  /// **'{count} scans'**
  String vendorScans(int count);

  /// No description provided for @vendorsRegisterSheet.
  ///
  /// In en, this message translates to:
  /// **'Register as a vendor'**
  String get vendorsRegisterSheet;

  /// No description provided for @vendorsRegisterDesc.
  ///
  /// In en, this message translates to:
  /// **'List your fish stall so customers can find you on FishCheck ZM.'**
  String get vendorsRegisterDesc;

  /// No description provided for @vendorsRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register my stall'**
  String get vendorsRegisterButton;

  /// No description provided for @vendorsNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get vendorsNotNow;

  /// No description provided for @vendorsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Vendor registration form coming soon!'**
  String get vendorsComingSoon;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to save your scans and sync across devices'**
  String get authSignUpSubtitle;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your scan history'**
  String get authSignInSubtitle;

  /// No description provided for @authEnterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address first.'**
  String get authEnterEmailFirst;

  /// No description provided for @authPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get authPasswordResetSent;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get authNameRequired;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get authPhone;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmail;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEmailInvalid;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authDontHaveAccount;

  /// No description provided for @authContinueWithout.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get authContinueWithout;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Know your fish is fresh'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at any fish and get an instant AI-powered freshness report. Eyes, skin, gills — analysed in seconds.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Camera or gallery — your choice'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a live photo at the market or upload one from your gallery. Every image format supported. Results work even on slow internet.'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Built for Zambian markets'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Kapenta, Bream, Tiger fish, Mpumbu, Chessa, Vundu — the app knows all local species with local names and fair price ranges.'**
  String get onboarding3Subtitle;

  /// No description provided for @speciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Fish directory'**
  String get speciesTitle;

  /// No description provided for @speciesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search species or local name...'**
  String get speciesSearch;

  /// No description provided for @speciesSignsOfFreshness.
  ///
  /// In en, this message translates to:
  /// **'Signs of freshness'**
  String get speciesSignsOfFreshness;

  /// No description provided for @speciesSpoilageWarning.
  ///
  /// In en, this message translates to:
  /// **'Spoilage warning signs'**
  String get speciesSpoilageWarning;

  /// No description provided for @speciesCookingTip.
  ///
  /// In en, this message translates to:
  /// **'Cooking tip'**
  String get speciesCookingTip;

  /// No description provided for @speciesHabitat.
  ///
  /// In en, this message translates to:
  /// **'Habitat'**
  String get speciesHabitat;

  /// No description provided for @speciesBestSeason.
  ///
  /// In en, this message translates to:
  /// **'Best season'**
  String get speciesBestSeason;

  /// No description provided for @speciesMarketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market price'**
  String get speciesMarketPrice;

  /// No description provided for @kapentaName.
  ///
  /// In en, this message translates to:
  /// **'Kapenta'**
  String get kapentaName;

  /// No description provided for @kapentaHabitat.
  ///
  /// In en, this message translates to:
  /// **'Lakes Tanganyika & Kariba'**
  String get kapentaHabitat;

  /// No description provided for @kapentaSeason.
  ///
  /// In en, this message translates to:
  /// **'Year-round'**
  String get kapentaSeason;

  /// No description provided for @kapentaPriceRange.
  ///
  /// In en, this message translates to:
  /// **'ZMW 20–60/kg (fresh) · ZMW 80–150/kg (dried)'**
  String get kapentaPriceRange;

  /// No description provided for @kapentaDescription.
  ///
  /// In en, this message translates to:
  /// **'Tiny freshwater sardines — the most commercially important fish in Zambia. Sold fresh or sun-dried. Dried kapenta is a staple across all provinces.'**
  String get kapentaDescription;

  /// No description provided for @kapentaFreshIndicators.
  ///
  /// In en, this message translates to:
  /// **'Fresh kapenta: silver sheen, clear eyes, mild sea smell. Dried kapenta: uniform light-brown colour, dry to touch, no mould, mild smell.'**
  String get kapentaFreshIndicators;

  /// No description provided for @kapentaSpoilageWarning.
  ///
  /// In en, this message translates to:
  /// **'Yellowish colour, strong fishy odour, or stickiness on fresh kapenta means it is no longer safe. Dried kapenta with dark patches or visible mould should be discarded.'**
  String get kapentaSpoilageWarning;

  /// No description provided for @kapentaCookingTip.
  ///
  /// In en, this message translates to:
  /// **'Best fried crispy with onions and tomatoes, or simmered in groundnut relish (nshima accompaniment).'**
  String get kapentaCookingTip;

  /// No description provided for @breamName.
  ///
  /// In en, this message translates to:
  /// **'Bream (Tilapia)'**
  String get breamName;

  /// No description provided for @breamHabitat.
  ///
  /// In en, this message translates to:
  /// **'Most freshwater bodies'**
  String get breamHabitat;

  /// No description provided for @breamSeason.
  ///
  /// In en, this message translates to:
  /// **'Year-round'**
  String get breamSeason;

  /// No description provided for @breamPriceRange.
  ///
  /// In en, this message translates to:
  /// **'ZMW 35–100/kg'**
  String get breamPriceRange;

  /// No description provided for @breamDescription.
  ///
  /// In en, this message translates to:
  /// **'The most widely consumed fish in Zambia. Found in rivers, dams and lakes nationwide. Available in nearly every market, often sold live.'**
  String get breamDescription;

  /// No description provided for @breamFreshIndicators.
  ///
  /// In en, this message translates to:
  /// **'Bright red or deep pink gills, clear bulging eyes, firm flesh that springs back when pressed, shiny silver-green skin with tight scales.'**
  String get breamFreshIndicators;

  /// No description provided for @breamSpoilageWarning.
  ///
  /// In en, this message translates to:
  /// **'Brown or grey gills, sunken or cloudy eyes, soft mushy flesh, and strong sour smell are all clear signs of deterioration.'**
  String get breamSpoilageWarning;

  /// No description provided for @breamCookingTip.
  ///
  /// In en, this message translates to:
  /// **'Excellent grilled whole with tomatoes and onions, or fried. Commonly used in Zambian relish.'**
  String get breamCookingTip;

  /// No description provided for @tigerName.
  ///
  /// In en, this message translates to:
  /// **'Tiger fish'**
  String get tigerName;

  /// No description provided for @tigerHabitat.
  ///
  /// In en, this message translates to:
  /// **'Zambezi River, Lake Kariba'**
  String get tigerHabitat;

  /// No description provided for @tigerSeason.
  ///
  /// In en, this message translates to:
  /// **'Best Aug–Oct'**
  String get tigerSeason;

  /// No description provided for @tigerPriceRange.
  ///
  /// In en, this message translates to:
  /// **'ZMW 60–140/kg'**
  String get tigerPriceRange;

  /// No description provided for @tigerDescription.
  ///
  /// In en, this message translates to:
  /// **'Fierce predatory fish from the Zambezi and Lake Kariba. Prized for its firm, white flesh. Popular with sport anglers and a delicacy at markets near Kariba.'**
  String get tigerDescription;

  /// No description provided for @tigerFreshIndicators.
  ///
  /// In en, this message translates to:
  /// **'Distinctive silver body with black tiger stripes. Bright eyes, firm white flesh, and a mild fresh smell. Teeth remain prominent and jaw is well-defined.'**
  String get tigerFreshIndicators;

  /// No description provided for @tigerSpoilageWarning.
  ///
  /// In en, this message translates to:
  /// **'Fading stripes, dull discoloured skin, loose scales and a strong ammonia-like smell indicate the fish is past its best.'**
  String get tigerSpoilageWarning;

  /// No description provided for @tigerCookingTip.
  ///
  /// In en, this message translates to:
  /// **'Best grilled or baked whole with lemon and herbs. The firm flesh holds well on a braai.'**
  String get tigerCookingTip;

  /// No description provided for @mpumbuName.
  ///
  /// In en, this message translates to:
  /// **'Mpumbu'**
  String get mpumbuName;

  /// No description provided for @mpumbuHabitat.
  ///
  /// In en, this message translates to:
  /// **'Lake Bangweulu'**
  String get mpumbuHabitat;

  /// No description provided for @mpumbuSeason.
  ///
  /// In en, this message translates to:
  /// **'Jun–Oct'**
  String get mpumbuSeason;

  /// No description provided for @mpumbuPriceRange.
  ///
  /// In en, this message translates to:
  /// **'ZMW 50–120/kg'**
  String get mpumbuPriceRange;

  /// No description provided for @mpumbuDescription.
  ///
  /// In en, this message translates to:
  /// **'A prized, large lake fish endemic to Lake Bangweulu. Highly valued by local communities and often dried or smoked. Scarcity makes it relatively expensive.'**
  String get mpumbuDescription;

  /// No description provided for @mpumbuFreshIndicators.
  ///
  /// In en, this message translates to:
  /// **'Deep silver body with prominent scales. Clear eyes, bright red-pink gills, and firm iridescent flesh. Fresh specimens have almost no smell.'**
  String get mpumbuFreshIndicators;

  /// No description provided for @mpumbuSpoilageWarning.
  ///
  /// In en, this message translates to:
  /// **'Any discolouration of the flesh from white to yellowish, combined with a sour or strong fishy odour, indicates spoilage.'**
  String get mpumbuSpoilageWarning;

  /// No description provided for @mpumbuCookingTip.
  ///
  /// In en, this message translates to:
  /// **'Wonderful smoked or grilled. The flavour is rich — pairs well with simple seasoning to let the fish shine.'**
  String get mpumbuCookingTip;

  /// No description provided for @chessaName.
  ///
  /// In en, this message translates to:
  /// **'Chessa'**
  String get chessaName;

  /// No description provided for @chessaHabitat.
  ///
  /// In en, this message translates to:
  /// **'Lakes Bangweulu & Mweru'**
  String get chessaHabitat;

  /// No description provided for @chessaSeason.
  ///
  /// In en, this message translates to:
  /// **'Year-round'**
  String get chessaSeason;

  /// No description provided for @chessaPriceRange.
  ///
  /// In en, this message translates to:
  /// **'ZMW 25–70/kg'**
  String get chessaPriceRange;

  /// No description provided for @chessaDescription.
  ///
  /// In en, this message translates to:
  /// **'A medium-sized lake fish common in Lake Bangweulu and Lake Mweru. Often sold dried in bulk. An important protein source in Northern and Luapula provinces.'**
  String get chessaDescription;

  /// No description provided for @chessaFreshIndicators.
  ///
  /// In en, this message translates to:
  /// **'Silvery skin with firm texture. Clear eyes and tight intact scales. Fresh smell with no sourness. Dried chessa should be golden-brown and dry throughout.'**
  String get chessaFreshIndicators;

  /// No description provided for @chessaSpoilageWarning.
  ///
  /// In en, this message translates to:
  /// **'Soft spots on the flesh, visible slime on the skin, cloudy eyes, or an ammonia-like odour are all signs to avoid.'**
  String get chessaSpoilageWarning;

  /// No description provided for @chessaCookingTip.
  ///
  /// In en, this message translates to:
  /// **'Usually fried or dried and powdered as a flavouring. Works well in stews and nshima relish.'**
  String get chessaCookingTip;

  /// No description provided for @vunduName.
  ///
  /// In en, this message translates to:
  /// **'Vundu (Catfish)'**
  String get vunduName;

  /// No description provided for @vunduHabitat.
  ///
  /// In en, this message translates to:
  /// **'Zambezi River & major rivers'**
  String get vunduHabitat;

  /// No description provided for @vunduSeason.
  ///
  /// In en, this message translates to:
  /// **'Year-round'**
  String get vunduSeason;

  /// No description provided for @vunduPriceRange.
  ///
  /// In en, this message translates to:
  /// **'ZMW 40–100/kg'**
  String get vunduPriceRange;

  /// No description provided for @vunduDescription.
  ///
  /// In en, this message translates to:
  /// **'Large freshwater catfish found in the Zambezi and Kafue rivers. Can grow very large — up to 50kg. Has no scales. Excellent firm white flesh, popular for smoking.'**
  String get vunduDescription;

  /// No description provided for @vunduFreshIndicators.
  ///
  /// In en, this message translates to:
  /// **'Moist, slightly slimy skin (normal for catfish). Firm pale flesh, clear eyes, and mild fresh smell with no sourness.'**
  String get vunduFreshIndicators;

  /// No description provided for @vunduSpoilageWarning.
  ///
  /// In en, this message translates to:
  /// **'Excessive stickiness, yellowing of the flesh, strong ammonia smell, or visibly soft flesh are warning signs.'**
  String get vunduSpoilageWarning;

  /// No description provided for @vunduCookingTip.
  ///
  /// In en, this message translates to:
  /// **'Superb smoked, grilled in large cuts, or curried. The thick flesh is very forgiving to cook.'**
  String get vunduCookingTip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
