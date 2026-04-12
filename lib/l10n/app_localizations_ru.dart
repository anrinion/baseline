// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Baseline';

  @override
  String get settingsButtonLabel => 'Настройки';

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get languageLabel => 'Язык';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeLight1 => 'Светлая (нейтральная)';

  @override
  String get themeLight2 => 'Светлая (тёплая)';

  @override
  String get themeDark1 => 'Тёмная (чёрная)';

  @override
  String get themeDark2 => 'Тёмная (тёмно-серая)';

  @override
  String get themeBehaviorHelp =>
      'Выбери, как Baseline переключается между светлой и тёмной темой.';

  @override
  String get themeModeManual => 'Выбирать вручную';

  @override
  String get themeModeManualDescription =>
      'Светлую или тёмную тему выбираешь ты.';

  @override
  String get themeModeDevice => 'Как на устройстве';

  @override
  String get themeModeDeviceDescription =>
      'Baseline следует настройке светлой и тёмной темы на телефоне.';

  @override
  String get themeModeSchedule => 'По расписанию';

  @override
  String get themeModeScheduleDescription =>
      'Baseline переключается в выбранное тобой время.';

  @override
  String get themeManualChoiceLabel => 'Если выбирать вручную:';

  @override
  String get themeUseLight => 'Использовать светлую';

  @override
  String get themeUseDark => 'Использовать тёмную';

  @override
  String get themeLightSectionLabel => 'Светлая тема';

  @override
  String get themeDarkSectionLabel => 'Тёмная тема';

  @override
  String get themeScheduleLabel => 'Расписание';

  @override
  String get themeScheduleLightStarts => 'Светлая с';

  @override
  String get themeScheduleDarkStarts => 'Тёмная с';

  @override
  String get modulesLabel => 'Модули';

  @override
  String get hereModuleLabel => 'Большая зелённая кнопка';

  @override
  String get hereModuleCustomizeLabel => 'Изменить текст кнопки';

  @override
  String get foodModuleLabel => 'Питание';

  @override
  String get foodProteinLabel => 'Белок';

  @override
  String get foodGreensLabel => 'Зелень';

  @override
  String get foodBeansLabel => 'Бобовые';

  @override
  String get foodFillersLabel => 'Сытное';

  @override
  String get foodTreatLabel => 'Что-то вкусное';

  @override
  String get foodSourcesTitle => 'Почему это работает';

  @override
  String get foodSourcesContent =>
      '• Белок: обеспечивает чувство насыщения и стабильную энергию (PLACEHOLDER, 2030).\n• Зелень: клетчатка, витамины и растительное разнообразие (PLACEHOLDER, 2030).\n• Бобовые: клетчатка и растительный белок (PLACEHOLDER, 2030).\n• Сытное: для доступной энергии (PLACEHOLDER, 2030).\n• Что-то вкусное: небольшое лакомство может способствовать поведенческой активации (PLACEHOLDER, 2030).\n\nПодходы, которые подчёркивают гибкость и заботу о себе перед строгими правилами, могут помочь избежать чувства вины (PLACEHOLDER, 2030).';

  @override
  String get movementModuleLabel => 'Движение';

  @override
  String get movementDefaultOptions => 'Выйти погулять\nТренировка';

  @override
  String get movementAnyCountsHint => 'любое движение считается';

  @override
  String get sleepModuleLabel => 'Сон';

  @override
  String get sleepGoingToSleep => 'Я иду спать';

  @override
  String get sleepAwake => 'Я встаю';

  @override
  String get sleepDurationSoFar => 'пока что';

  @override
  String get sleepCompleted => 'Сон записан';

  @override
  String get sleepStartLabel => 'Начало';

  @override
  String get sleepEndLabel => 'Конец';

  @override
  String get sleepPrompt => 'Запишите свой сон:';

  @override
  String get sleepBedTimeLabel => 'Отбой';

  @override
  String get sleepWakeTimeLabel => 'Подъем';

  @override
  String get sleepDurationLabel => 'Длительность сна';

  @override
  String get medsModuleLabel => 'Лекарства';

  @override
  String get medsAddButtonLabel => 'Добавить лекарство';

  @override
  String get medsEditListButtonLabel => 'Изменить список';

  @override
  String get medsEditListTitle => 'Список лекарств';

  @override
  String get medsEditListHint => 'По одному лекарству на строку';

  @override
  String get medsListSettingsLabel => 'Список лекарств (по одному на строку)';

  @override
  String get medsDefaultList => '';

  @override
  String get medsEmptyState =>
      'Список лекарств пока пуст. Добавь то, что хочешь отмечать сегодня.';

  @override
  String get medsEmptyCompact => 'Пока нет лекарств';

  @override
  String medsTodayProgress(int taken, int total) {
    return 'Отмечено на сегодня: $taken из $total';
  }

  @override
  String medsMoreCount(int count) {
    return '+ещё $count';
  }

  @override
  String get medsReminderToggleLabel => 'Ежедневное напоминание';

  @override
  String get medsReminderToggleHelp =>
      'Если включено, Baseline присылает одно локальное напоминание в день.';

  @override
  String get medsReminderTimeLabel => 'Время напоминания';

  @override
  String get medsReminderPermissionDenied =>
      'Уведомления отключены. Разреши их, чтобы включить напоминания.';

  @override
  String get medsReminderEnableTooltip =>
      'Включить напоминание для этого лекарства';

  @override
  String get medsReminderDisableTooltip =>
      'Выключить напоминание для этого лекарства';

  @override
  String get mentalStateModuleLabel => 'Психическое состояние';

  @override
  String get mentalStateRightNow => 'Прямо сейчас';

  @override
  String get mentalStateGoodThing => 'Что-то хорошее';

  @override
  String get mentalStateThoughtLens => 'Фильтр когнитивных искажений';

  @override
  String get dialogGotIt => 'Хорошо';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogSave => 'Сохранить';

  @override
  String get dialogDelete => 'Удалить';

  @override
  String get dialogClose => 'Закрыть';

  @override
  String get dialogReset => 'Очистить';

  @override
  String get dialogWhyThisWorks => 'Почему это работает';

  @override
  String get dialogWhyThisHelps => 'Почему это помогает';

  @override
  String get nourishment => 'Питание';

  @override
  String get resetAll => 'Очистить всё';

  @override
  String get grounding => 'Осознанность';

  @override
  String get groundingAffirmation1 => 'Хорошо. Ты здесь.';

  @override
  String get groundingAffirmation2 => 'Привет!';

  @override
  String get groundingAffirmation3 => 'Одной проблемой меньше.';

  @override
  String get groundingAffirmation4 => 'Ты здесь. Это важно.';

  @override
  String get groundingAffirmation5 => 'Здесь и сейчас.';

  @override
  String get movementTitle => 'Движение';

  @override
  String get movementCompleted => 'Ты завершил(а) активность сегодня. Хорошо.';

  @override
  String get movementChoose => 'Выбери одну лёгкую активность на сегодня:';

  @override
  String get movementGreatJob => 'Хорошо.';

  @override
  String get tapToOpen => 'Нажми чтобы открыть';

  @override
  String get placeholderModuleText => 'Это тестовый модуль.';

  @override
  String get simulateAction => 'Имитировать действие';

  @override
  String get modulesHelpText =>
      'Включи или выключи модули. Дополнительные настройки появятся под каждым.';

  @override
  String get resetToday => 'Сбросить прогресс';

  @override
  String get todayReset => 'Прогресс сброшен';

  @override
  String get developerModeLabel => 'Режим разработчика';

  @override
  String get developerModeHelp =>
      'Показывает инструменты для тестов и полного локального сброса.';

  @override
  String get developerResetAllDataLabel => 'Полный сброс состояния';

  @override
  String get developerResetAllDataHelp =>
      'Это очистит состояние на сегодня, настройки приложения и вернёт тебя на начальный экран.';

  @override
  String get developerNotificationsServiceLabel =>
      'Сервис уведомлений о лекарствах';

  @override
  String get developerNotificationsStatusNotInitialized =>
      'Статус: не инициализирован';

  @override
  String get developerNotificationsStatusReady =>
      'Статус: готов (напоминания не запланированы)';

  @override
  String get developerNotificationsStatusActive =>
      'Статус: активен (напоминания запланированы)';

  @override
  String get developerNotificationsStatusDisabled =>
      'Статус: выключен (напоминания не настроены)';

  @override
  String get developerNotificationsStatusUnsupportedPlatform =>
      'Статус: платформа не поддерживается';

  @override
  String get developerNotificationsStatusPluginMissing =>
      'Статус: плагин недоступен';

  @override
  String get developerNotificationsStatusPermissionDenied =>
      'Статус: доступ запрещён';

  @override
  String get developerNotificationsStatusError => 'Статус: ошибка';

  @override
  String get appPrivacyText =>
      'Baseline — приватное приложение для заботы о себе:\\nМы не собираем и не храним данные.';

  @override
  String get foodProteinSubtitle => '1–2 порции';

  @override
  String get foodGreensSubtitle => '3–5 порций (фрукты и овощи)';

  @override
  String get foodBeansSubtitle => '1–2 порции';

  @override
  String get foodFillersSubtitle => '1–3 порции (рис, паста, хлеб)';

  @override
  String get foodTreatSubtitle => '1 порция (шоколад, десерт)';

  @override
  String get mentalStateHelp =>
      'Это место только для сейчас: назови своё чувство, немного благодарности или якоря, и мягкие подсказки \"фильтра мышления\" вдохновлённые когнитивными подходами (PLACEHOLDER, 2030).';

  @override
  String get sleepHelp =>
      'Сон влияет на настроение, энергию и саморегуляцию (PLACEHOLDER, 2030).';

  @override
  String get medsHelp =>
      'Отмечай лекарства только на сегодня. Без оценок и истории, просто спокойный чек-лист.';

  @override
  String get movementHelp =>
      'Любое движение намного лучше, чем ничего (PLACEHOLDER, 2030).';

  @override
  String get groundingHelp =>
      'Просто кнопка, чтобы показаться своё присутствие. Обращение внимания на текущий момент помогает снизить стресс (PLACEHOLDER, 2030). Что-то вроде \"здесь и сейчас\" из гештальта (PLACEHOLDER, 2030).';

  @override
  String get hereButtonHint => 'Я здесь. Я живой(ая).';

  @override
  String get movementChoicesLabel => 'Выбор движений (по одному на строку)';

  @override
  String get movementDone => 'Готово';

  @override
  String get stateLabel => 'Состояние:';

  @override
  String simulateActionResult(Object module) {
    return 'Прикоснулся к $module';
  }

  @override
  String get initialScreenTitle => 'Добро пожаловать в Baseline';

  @override
  String get initialScreenMessage => 'Никакого давления. Только то, что нужно.';

  @override
  String get initialScreenLanguageTitle => 'Выберите язык';

  @override
  String get initialScreenThemeTitle => 'Выберите тему';

  @override
  String get initialScreenContinue => 'Продолжить';

  @override
  String get cbtModeLabel => 'Режим';

  @override
  String get cbtModeRightNow => 'Прямо сейчас';

  @override
  String get cbtModeGoodThings => 'Хорошие вещи';

  @override
  String get cbtModeThoughtLens => 'Мыслительная линза';

  @override
  String get cbtModeSettingDescription =>
      'Выберите, какой подмодуль КПТ использовать';

  @override
  String get cbtRightNowQuestion => 'Как вы себя чувствуете прямо сейчас?';

  @override
  String get cbtMoodVerySad => 'Очень грустно';

  @override
  String get cbtMoodSad => 'Грустно';

  @override
  String get cbtMoodNeutral => 'Нейтрально';

  @override
  String get cbtMoodGood => 'Хорошо';

  @override
  String get cbtMoodVeryGood => 'Очень хорошо';

  @override
  String get cbtMoodRecorded => 'Настроение записано';

  @override
  String get cbtGoodThingsQuestion => 'Что хорошего произошло сегодня?';

  @override
  String get cbtGoodThing => 'Что-то хорошее';

  @override
  String get cbtGoodThingsHint =>
      'Мелочи имеют значение. Хороший кофе, доброе слово, солнце...';

  @override
  String get cbtThoughtLensTitle => 'Мыслительная линза';

  @override
  String get cbtThoughtLensExample => 'Пример:';

  @override
  String get cbtThoughtLensPrevious => 'Назад';

  @override
  String get cbtThoughtLensNext => 'Вперёд';

  @override
  String get cbtThoughtLensDaily => 'Когнитивное искажение дня';
}
