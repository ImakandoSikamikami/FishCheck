// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get cancel => 'Отмена';

  @override
  String get clearAll => 'Очистить';

  @override
  String get navHome => 'Главная';

  @override
  String get navScan => 'Сканировать';

  @override
  String get navVendors => 'Продавцы';

  @override
  String get navHistory => 'История';

  @override
  String get navSettings => 'Настройки';

  @override
  String get shellSubtitle => 'Анализ свежести';

  @override
  String get shellFooter => 'FishCheck ZM · Мгновенный анализ';

  @override
  String get homeGoodMorning => 'Доброе утро';

  @override
  String get homeGoodAfternoon => 'Добрый день';

  @override
  String get homeGoodEvening => 'Добрый вечер';

  @override
  String get homeScansToday => 'Сканов сегодня';

  @override
  String get homeFreshRate => 'Доля свежих';

  @override
  String get homeTotalScans => 'Всего сканов';

  @override
  String get homeScanAFish => 'Сканировать рыбу';

  @override
  String homeMostScanned(String species) {
    return 'Чаще всего: $species';
  }

  @override
  String get homeTakeOrUpload => 'Сфотографируйте или загрузите';

  @override
  String get homeSpeciesGuide => 'Справочник видов';

  @override
  String get homeScanHistory => 'История сканов';

  @override
  String get homeRecentScans => 'Недавние сканы';

  @override
  String get homeSeeAll => 'Все';

  @override
  String get homeNoScansYet => 'Нет сканов';

  @override
  String get homeScanFirstFish => 'Отсканируйте рыбу, чтобы начать';

  @override
  String get homeNoInternet => 'Нет интернета';

  @override
  String homeOfflineQueued(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Нет интернета · $count сканов в очереди',
      many: 'Нет интернета · $count сканов в очереди',
      few: 'Нет интернета · $count скана в очереди',
      one: 'Нет интернета · $count скан в очереди',
    );
    return '$_temp0';
  }

  @override
  String homeOfflineReady(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count оффлайн-сканов готовы к анализу',
      many: '$count оффлайн-сканов готовы к анализу',
      few: '$count оффлайн-скана готовы к анализу',
      one: '$count оффлайн-скан готов к анализу',
    );
    return '$_temp0';
  }

  @override
  String get homeAnalyseNow => 'Анализировать';

  @override
  String get scanTitle => 'Сканировать рыбу';

  @override
  String get scanSubtitle => 'Сфотографируйте или загрузите из галереи';

  @override
  String get scanTapToCamera => 'Нажмите для камеры';

  @override
  String get scanOrUseButtons => 'Или используйте кнопки ниже';

  @override
  String get scanWithCamera => 'Камера';

  @override
  String get scanSelectPicture => 'Выбрать фото';

  @override
  String get scanAnalysing => 'Анализ свежести...';

  @override
  String get scanAnalyse => 'Анализировать свежесть';

  @override
  String get scanChooseDifferent => 'Выбрать другое фото';

  @override
  String scanErrorLoadImage(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get scanErrorAnalysis =>
      'Ошибка анализа. Попробуйте более чёткое фото.';

  @override
  String get scanTipClearEyes => 'Чистые глаза';

  @override
  String get scanTipShinySkin => 'Блестящая кожа';

  @override
  String get scanTipRedGills => 'Красные жабры';

  @override
  String get scanTipFirmFlesh => 'Упругое мясо';

  @override
  String get resultFreshnessScore => 'Оценка свежести';

  @override
  String get resultVisualIndicators => 'Визуальные показатели';

  @override
  String get resultAdvice => 'Совет';

  @override
  String get resultSellBy => 'Продать до';

  @override
  String get resultSafeToEat => 'Можно есть';

  @override
  String get resultDoNotEat => 'Нельзя есть';

  @override
  String get resultAnalysisPending => 'Анализ ожидает';

  @override
  String get resultPendingSubtitle => 'Сохранено — анализ при подключении.';

  @override
  String get resultEyes => 'Глаза';

  @override
  String get resultSkin => 'Кожа';

  @override
  String get resultGills => 'Жабры';

  @override
  String get resultFlesh => 'Мясо';

  @override
  String get resultOdour => 'Запах';

  @override
  String get resultScanAnother => 'Сканировать ещё';

  @override
  String get resultViewHistory => 'История сканов';

  @override
  String resultConfidentDesktop(int confidence) {
    return '$confidence% уверенность в определении вида';
  }

  @override
  String resultConfidentMobile(int confidence) {
    return '$confidence% уверен';
  }

  @override
  String resultShareSubject(String fishType) {
    return 'Отчёт о свежести — $fishType';
  }

  @override
  String resultShareBody(String fishType, String freshness, int score,
      String sellBy, String safe, String advice, String scanned) {
    return 'FishCheck ZM — Отчёт о свежести\nРыба: $fishType\nСвежесть: $freshness ($score%)\nПродать до: $sellBy\nБезопасно: $safe\nСовет: $advice\nОтсканировано: $scanned\nFishCheck ZM';
  }

  @override
  String get resultShareYes => 'Да';

  @override
  String get resultShareNo => 'Нет';

  @override
  String resultPricePrefix(String impact) {
    return 'Цена: $impact';
  }

  @override
  String get historyTitle => 'История сканов';

  @override
  String get historyClearAllTooltip => 'Очистить';

  @override
  String get historySearch => 'Поиск по названию рыбы...';

  @override
  String get historyFilterAll => 'Все';

  @override
  String get historyFilterFresh => 'Свежая';

  @override
  String get historyFilterAcceptable => 'Приемлемая';

  @override
  String get historyFilterPoor => 'Плохая';

  @override
  String get historyFilterSpoiled => 'Испорченная';

  @override
  String get historyNoScansYet => 'Нет сканов';

  @override
  String get historyNoScansSubtitle => 'Отсканируйте рыбу для истории';

  @override
  String historyNoResults(String filter) {
    return 'Нет сканов «$filter»';
  }

  @override
  String get historyScore => 'оценка';

  @override
  String get historyClearTitle => 'Очистить историю';

  @override
  String get historyClearContent =>
      'Все записи будут удалены. Это нельзя отменить.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsScansToCloud => 'Сканы в облаке';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsHistoryOnDevice => 'История на устройстве';

  @override
  String get settingsSignIn => 'Войти или зарегистрироваться';

  @override
  String get settingsSyncAcrossDevices => 'Синхронизация устройств';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsEnableReminders => 'Включить напоминания';

  @override
  String get settingsRemindersSubtitle =>
      'Напоминание о проверке через 24 часа';

  @override
  String get settingsNotificationsEnabled => 'Уведомления включены!';

  @override
  String get settingsNotificationsDisabled =>
      'Включите уведомления в настройках устройства.';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSubtitle => 'Светлая, тёмная или системная';

  @override
  String get settingsMachineLearning => 'Машинное обучение';

  @override
  String get settingsAiProgress => 'Прогресс ИИ';

  @override
  String get settingsAiProgressSubtitle =>
      'Исправления видов и точность модели';

  @override
  String get settingsAnalysisEngine => 'Движок анализа';

  @override
  String get settingsAnalysisEngineSubtitle =>
      'Анализ на устройстве — работает офлайн';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsClearHistory => 'Очистить историю';

  @override
  String get settingsClearHistorySubtitle => 'Удалить все сканы с устройства';

  @override
  String get settingsClearHistoryDialog => 'Очистить историю';

  @override
  String get settingsClearHistoryContent =>
      'Удалить всю историю? Это нельзя отменить.';

  @override
  String get settingsClearHistorySuccess => 'История очищена';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsAboutApp => 'О FishCheck ZM';

  @override
  String get settingsAboutSubtitle => 'Версия, миссия, авторы';

  @override
  String get settingsSpeciesSupported => 'Поддерживаемые виды';

  @override
  String get settingsSpeciesSubtitle =>
      'Kapenta · Bream · Tiger fish · Mpumbu · Chessa · Vundu';

  @override
  String get settingsFishVendors => 'Рыбные продавцы';

  @override
  String get settingsVendorsSubtitle => 'Продавцы рядом с вами';

  @override
  String get settingsFooter => 'FishCheck ZM · v1.0.0 · ';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Выберите язык интерфейса';

  @override
  String get vendorsTitle => 'Рыбные продавцы';

  @override
  String get vendorsRegisterTooltip => 'Стать продавцом';

  @override
  String get vendorsSearch => 'Поиск продавцов и рынков...';

  @override
  String get vendorsNoVendors => 'Продавцы не найдены';

  @override
  String get vendorsNoVendorsSubtitle => 'Попробуйте другой город или запрос';

  @override
  String get vendorsRefresh => 'Обновить';

  @override
  String get vendorsCall => 'Позвонить';

  @override
  String get vendorsWhatsApp => 'WhatsApp';

  @override
  String vendorScans(int count) {
    return '$count сканов';
  }

  @override
  String get vendorsRegisterSheet => 'Стать продавцом';

  @override
  String get vendorsRegisterDesc =>
      'Зарегистрируйтесь, чтобы покупатели могли найти вас на FishCheck ZM.';

  @override
  String get vendorsRegisterButton => 'Зарегистрироваться';

  @override
  String get vendorsNotNow => 'Не сейчас';

  @override
  String get vendorsComingSoon => 'Регистрация продавцов скоро!';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authWelcomeBack => 'С возвращением';

  @override
  String get authSignUpSubtitle =>
      'Зарегистрируйтесь для сохранения и синхронизации сканов';

  @override
  String get authSignInSubtitle => 'Войдите для доступа к истории сканов';

  @override
  String get authEnterEmailFirst => 'Сначала введите email.';

  @override
  String get authPasswordResetSent => 'Письмо отправлено. Проверьте почту.';

  @override
  String get authFullName => 'Полное имя';

  @override
  String get authNameRequired => 'Имя обязательно';

  @override
  String get authPhone => 'Телефон (необязательно)';

  @override
  String get authEmail => 'Эл. почта';

  @override
  String get authEmailRequired => 'Email обязателен';

  @override
  String get authEmailInvalid => 'Введите корректный email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authPasswordRequired => 'Пароль обязателен';

  @override
  String get authPasswordTooShort => 'Пароль не менее 8 символов';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authAlreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get authDontHaveAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authContinueWithout => 'Продолжить без аккаунта';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboarding1Title => 'Знайте, что рыба свежая';

  @override
  String get onboarding1Subtitle =>
      'Наведите камеру на рыбу и получите мгновенный AI-отчёт. Глаза, кожа, жабры — анализ за секунды.';

  @override
  String get onboarding2Title => 'Камера или галерея — ваш выбор';

  @override
  String get onboarding2Subtitle =>
      'Сфотографируйте на рынке или загрузите из галереи. Любой формат. Работает даже на медленном интернете.';

  @override
  String get onboarding3Title => 'Создан для замбийских рынков';

  @override
  String get onboarding3Subtitle =>
      'Kapenta, Bream, Tiger fish, Mpumbu, Chessa, Vundu — приложение знает все местные виды с местными названиями и ценами.';

  @override
  String get speciesTitle => 'Справочник рыб';

  @override
  String get speciesSearch => 'Поиск видов или местных названий...';

  @override
  String get speciesSignsOfFreshness => 'Признаки свежести';

  @override
  String get speciesSpoilageWarning => 'Признаки порчи';

  @override
  String get speciesCookingTip => 'Совет по приготовлению';

  @override
  String get speciesHabitat => 'Среда обитания';

  @override
  String get speciesBestSeason => 'Лучший сезон';

  @override
  String get speciesMarketPrice => 'Рыночная цена';

  @override
  String get kapentaName => 'Капента';

  @override
  String get kapentaHabitat => 'Озёра Танганьика и Кариба';

  @override
  String get kapentaSeason => 'Круглый год';

  @override
  String get kapentaPriceRange =>
      'ZMW 20–60/кг (свежая) · ZMW 80–150/кг (сушёная)';

  @override
  String get kapentaDescription =>
      'Маленькие пресноводные сардины — самая важная рыба в Замбии. Продаётся свежей или сушёной. Сушёная капента — основной продукт по всей стране.';

  @override
  String get kapentaFreshIndicators =>
      'Свежая: серебристый блеск, ясные глаза, лёгкий морской запах. Сушёная: равномерный светло-коричневый цвет, сухая на ощупь, без плесени.';

  @override
  String get kapentaSpoilageWarning =>
      'Желтоватый цвет, сильный рыбный запах или липкость — признаки несвежей рыбы. Сушёная с тёмными пятнами или плесенью должна быть выброшена.';

  @override
  String get kapentaCookingTip =>
      'Лучше всего жарить с луком и помидорами, или тушить в арахисовом соусе (гарнир к нсима).';

  @override
  String get breamName => 'Брим (Тиляпия)';

  @override
  String get breamHabitat => 'Большинство пресных водоёмов';

  @override
  String get breamSeason => 'Круглый год';

  @override
  String get breamPriceRange => 'ZMW 35–100/кг';

  @override
  String get breamDescription =>
      'Самая популярная рыба в Замбии. Водится в реках, водохранилищах и озёрах. Есть почти на каждом рынке, часто продаётся живой.';

  @override
  String get breamFreshIndicators =>
      'Ярко-красные жабры, ясные выпуклые глаза, плотное мясо, которое пружинит при нажатии, блестящая кожа с плотной чешуёй.';

  @override
  String get breamSpoilageWarning =>
      'Коричневые или серые жабры, запавшие или мутные глаза, мягкое мясо и кислый запах — признаки порчи.';

  @override
  String get breamCookingTip =>
      'Отлично готовить целиком на гриле с помидорами и луком, или жарить. Часто используется в замбийском соусе к нсима.';

  @override
  String get tigerName => 'Тигровая рыба';

  @override
  String get tigerHabitat => 'Река Замбези, озеро Кариба';

  @override
  String get tigerSeason => 'Лучше авг–окт';

  @override
  String get tigerPriceRange => 'ZMW 60–140/кг';

  @override
  String get tigerDescription =>
      'Хищная рыба из Замбези и озера Кариба. Ценится за твёрдое белое мясо. Популярна среди рыболовов и как деликатес на рынках у Карибы.';

  @override
  String get tigerFreshIndicators =>
      'Характерное серебристое тело с чёрными полосами. Ясные глаза, твёрдое белое мясо, лёгкий свежий запах. Зубы заметны, челюсть чётко очерчена.';

  @override
  String get tigerSpoilageWarning =>
      'Блёклые полосы, тусклая кожа, рыхлая чешуя и запах аммиака — признаки несвежести.';

  @override
  String get tigerCookingTip =>
      'Лучше запекать или жарить на гриле с лимоном и травами. Твёрдое мясо хорошо держит форму.';

  @override
  String get mpumbuName => 'Мпумбу';

  @override
  String get mpumbuHabitat => 'Озеро Бангвеулу';

  @override
  String get mpumbuSeason => 'Июн–окт';

  @override
  String get mpumbuPriceRange => 'ZMW 50–120/кг';

  @override
  String get mpumbuDescription =>
      'Редкая крупная рыба, эндемик озера Бангвеулу. Высоко ценится местными жителями, часто сушится или коптится. Дефицит делает её относительно дорогой.';

  @override
  String get mpumbuFreshIndicators =>
      'Серебристое тело с заметной чешуёй. Ясные глаза, ярко-розовые жабры, плотное переливающееся мясо. Свежая рыба почти без запаха.';

  @override
  String get mpumbuSpoilageWarning =>
      'Пожелтение мяса и кислый или сильный рыбный запах — признаки порчи.';

  @override
  String get mpumbuCookingTip =>
      'Прекрасно коптится или жарится на гриле. Насыщенный вкус — лучше с простыми приправами.';

  @override
  String get chessaName => 'Чесса';

  @override
  String get chessaHabitat => 'Озёра Бангвеулу и Мверу';

  @override
  String get chessaSeason => 'Круглый год';

  @override
  String get chessaPriceRange => 'ZMW 25–70/кг';

  @override
  String get chessaDescription =>
      'Рыба среднего размера, распространена в озёрах Бангвеулу и Мверу. Часто продаётся сушёной оптом. Важный источник белка на севере Замбии.';

  @override
  String get chessaFreshIndicators =>
      'Серебристая кожа с плотной текстурой. Ясные глаза и целая чешуя. Свежий запах без кислоты. Сушёная — золотисто-коричневая и сухая.';

  @override
  String get chessaSpoilageWarning =>
      'Мягкие пятна, слизь на коже, мутные глаза или запах аммиака — повод отказаться.';

  @override
  String get chessaCookingTip =>
      'Обычно жарится или сушится в порошок как приправа. Подходит для тушёных блюд и соуса к нсима.';

  @override
  String get vunduName => 'Вунду (Сом)';

  @override
  String get vunduHabitat => 'Замбези и другие крупные реки';

  @override
  String get vunduSeason => 'Круглый год';

  @override
  String get vunduPriceRange => 'ZMW 40–100/кг';

  @override
  String get vunduDescription =>
      'Крупный пресноводный сом из рек Замбези и Кафуэ. Может достигать 50 кг. Без чешуи. Отличное твёрдое белое мясо, популярен для копчения.';

  @override
  String get vunduFreshIndicators =>
      'Влажная, слегка скользкая кожа (нормально для сома). Плотное бледное мясо, ясные глаза, лёгкий свежий запах без кислоты.';

  @override
  String get vunduSpoilageWarning =>
      'Сильная липкость, пожелтение мяса, запах аммиака или мягкость мяса — предупреждающие признаки.';

  @override
  String get vunduCookingTip =>
      'Превосходно коптится, жарится крупными кусками или тушится в карри. Густое мясо очень прощает ошибки при готовке.';
}
