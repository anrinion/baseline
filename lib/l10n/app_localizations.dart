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
    Locale('ru'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get appTitle;

  /// Label for the settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButtonLabel;

  /// Title of the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Language option label for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option label for Russian
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// Label for theme selection
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// Light theme option - neutral
  ///
  /// In en, this message translates to:
  /// **'Light (Neutral)'**
  String get themeLight1;

  /// Light theme option - warm
  ///
  /// In en, this message translates to:
  /// **'Light (Warm)'**
  String get themeLight2;

  /// Dark theme option - true black
  ///
  /// In en, this message translates to:
  /// **'Dark (True)'**
  String get themeDark1;

  /// Dark theme option - soft contrast
  ///
  /// In en, this message translates to:
  /// **'Dark (Soft)'**
  String get themeDark2;

  /// Label for modules settings section
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modulesLabel;

  /// Label for the 'I'm here' module
  ///
  /// In en, this message translates to:
  /// **'I\'m here'**
  String get hereModuleLabel;

  /// Label for customizing the 'I'm here' button text
  ///
  /// In en, this message translates to:
  /// **'Customize button text'**
  String get hereModuleCustomizeLabel;

  /// Label for the Food module
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodModuleLabel;

  /// Food category: Protein
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get foodProteinLabel;

  /// Food category: Greens
  ///
  /// In en, this message translates to:
  /// **'Greens'**
  String get foodGreensLabel;

  /// Food category: Beans and Chickpeas
  ///
  /// In en, this message translates to:
  /// **'Beans & Chickpeas'**
  String get foodBeansLabel;

  /// Food category: Fillers / Carbs
  ///
  /// In en, this message translates to:
  /// **'Fillers (Carbs)'**
  String get foodFillersLabel;

  /// Food category: Small enjoyable treat
  ///
  /// In en, this message translates to:
  /// **'Treat'**
  String get foodTreatLabel;

  /// Title for food module sources/help
  ///
  /// In en, this message translates to:
  /// **'Why this works'**
  String get foodSourcesTitle;

  /// Detailed explanation of why the food categories work
  ///
  /// In en, this message translates to:
  /// **'• Protein: supports satiety and steady energy.\n• Greens: fiber, vitamins, and plant variety.\n• Beans and chickpeas: fiber and plant protein.\n• Fillers: complex carbs for accessible energy.\n• Sweet treat: a small enjoyable bite can support behavioral activation — pleasure without \"earning\" it.\n\nThis is about balance, not restriction. Non-restrictive approaches favor flexibility and self-care over rules or guilt. For personalized guidance, ask a qualified professional.'**
  String get foodSourcesContent;

  /// Label for the Movement module
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movementModuleLabel;

  /// Default movement options
  ///
  /// In en, this message translates to:
  /// **'Go for a walk\nLight workout'**
  String get movementDefaultOptions;

  /// Hint text for movement module
  ///
  /// In en, this message translates to:
  /// **'any movement counts'**
  String get movementAnyCountsHint;

  /// Label for the Sleep module
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepModuleLabel;

  /// Action: going to sleep
  ///
  /// In en, this message translates to:
  /// **'I\'m going to sleep'**
  String get sleepGoingToSleep;

  /// Action: woke up
  ///
  /// In en, this message translates to:
  /// **'I\'m awake'**
  String get sleepAwake;

  /// Label for the Meds module
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get medsModuleLabel;

  /// Button to add a medication
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get medsAddButtonLabel;

  /// Label for the Mental state module
  ///
  /// In en, this message translates to:
  /// **'Mental state'**
  String get mentalStateModuleLabel;

  /// Mental state section: current feeling
  ///
  /// In en, this message translates to:
  /// **'Right now'**
  String get mentalStateRightNow;

  /// Mental state section: one good thing
  ///
  /// In en, this message translates to:
  /// **'One small good thing'**
  String get mentalStateGoodThing;

  /// Mental state section: cognitive distortion tool
  ///
  /// In en, this message translates to:
  /// **'Thought lens'**
  String get mentalStateThoughtLens;

  /// Dialog action button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get dialogGotIt;

  /// Dialog action button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// Dialog action button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// Dialog action button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDelete;

  /// Dialog close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// Dialog reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get dialogReset;

  /// Tooltip to show help/sources
  ///
  /// In en, this message translates to:
  /// **'Why this works'**
  String get dialogWhyThisWorks;

  /// Tooltip to show module help
  ///
  /// In en, this message translates to:
  /// **'Why this helps'**
  String get dialogWhyThisHelps;

  /// Title for the food module dialog
  ///
  /// In en, this message translates to:
  /// **'Nourishment'**
  String get nourishment;

  /// Button to reset all food categories
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;

  /// Label for the grounding/here module
  ///
  /// In en, this message translates to:
  /// **'Grounding'**
  String get grounding;

  /// Grounding affirmation phrase
  ///
  /// In en, this message translates to:
  /// **'Good. You\'re here.'**
  String get groundingAffirmation1;

  /// Grounding affirmation phrase
  ///
  /// In en, this message translates to:
  /// **'Hello there!'**
  String get groundingAffirmation2;

  /// Grounding affirmation phrase
  ///
  /// In en, this message translates to:
  /// **'One moment at a time.'**
  String get groundingAffirmation3;

  /// Grounding affirmation phrase
  ///
  /// In en, this message translates to:
  /// **'You showed up. That matters.'**
  String get groundingAffirmation4;

  /// Grounding affirmation phrase
  ///
  /// In en, this message translates to:
  /// **'Right here, right now.'**
  String get groundingAffirmation5;

  /// Title for the movement module dialog
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movementTitle;

  /// Message shown after completing movement activity
  ///
  /// In en, this message translates to:
  /// **'You completed an activity today. That\'s wonderful! 💪'**
  String get movementCompleted;

  /// Instruction text for choosing a movement activity
  ///
  /// In en, this message translates to:
  /// **'Choose one gentle activity for today:'**
  String get movementChoose;

  /// Congratulation message for movement
  ///
  /// In en, this message translates to:
  /// **'Great job! 💪'**
  String get movementGreatJob;

  /// Instruction on module tile
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get tapToOpen;

  /// Message for placeholder modules
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder module.'**
  String get placeholderModuleText;

  /// Button for placeholder module
  ///
  /// In en, this message translates to:
  /// **'Simulate action'**
  String get simulateAction;

  /// Help text in settings for modules section
  ///
  /// In en, this message translates to:
  /// **'Turn modules on or off. Optional settings appear under each one.'**
  String get modulesHelpText;

  /// Button to reset today's data
  ///
  /// In en, this message translates to:
  /// **'Reset today'**
  String get resetToday;

  /// Confirmation message when today is reset
  ///
  /// In en, this message translates to:
  /// **'Today reset'**
  String get todayReset;

  /// Privacy statement in settings
  ///
  /// In en, this message translates to:
  /// **'Baseline is a private, present-moment self-care app.\\nNo history. No tracking. Just today.'**
  String get appPrivacyText;

  /// Food category portion guide: Protein
  ///
  /// In en, this message translates to:
  /// **'1–2 portions'**
  String get foodProteinSubtitle;

  /// Food category portion guide: Greens
  ///
  /// In en, this message translates to:
  /// **'3–5 portions (fruits & veggies)'**
  String get foodGreensSubtitle;

  /// Food category portion guide: Beans
  ///
  /// In en, this message translates to:
  /// **'1–2 portions'**
  String get foodBeansSubtitle;

  /// Food category portion guide: Fillers
  ///
  /// In en, this message translates to:
  /// **'1–3 portions (rice, pasta, bread)'**
  String get foodFillersSubtitle;

  /// Food category portion guide: Treat
  ///
  /// In en, this message translates to:
  /// **'1 portion (chocolate, dessert)'**
  String get foodTreatSubtitle;

  /// Help text for mental state module
  ///
  /// In en, this message translates to:
  /// **'This area is for right now only: naming how you feel, a tiny bit of gratitude or grounding, and gentle \"thought lens\" prompts inspired by cognitive approaches. It is not a substitute for care from a qualified professional when you need it.'**
  String get mentalStateHelp;

  /// Help text for sleep module
  ///
  /// In en, this message translates to:
  /// **'Sleep affects mood, energy, and regulation. Logging \"going to sleep\" and \"awake\" with simple duration (today only) supports awareness without tracking streaks or judging rest.'**
  String get sleepHelp;

  /// Help text for meds module
  ///
  /// In en, this message translates to:
  /// **'A minimal today-only checklist can reduce mental load. This is not medical advice; use your clinician\'s plan and seek help for urgent concerns.'**
  String get medsHelp;

  /// Help text for movement module
  ///
  /// In en, this message translates to:
  /// **'Any movement counts toward care and activation. No intensity or duration — a small nudge beats \"all or nothing.\"'**
  String get movementHelp;

  /// Help text for grounding/here module
  ///
  /// In en, this message translates to:
  /// **'A single tap to anchor yourself in the present — Gestalt \"here and now\". No tracking, no memory, no score: the smallest possible caring action.'**
  String get groundingHelp;

  /// Hint text for the here module button customization field
  ///
  /// In en, this message translates to:
  /// **'I\'m here. I\'m alive.'**
  String get hereButtonHint;

  /// Label for movement choices field
  ///
  /// In en, this message translates to:
  /// **'Movement choices (one per line)'**
  String get movementChoicesLabel;

  /// Compact movement completed label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get movementDone;

  /// Label prefix for current state display
  ///
  /// In en, this message translates to:
  /// **'State:'**
  String get stateLabel;

  /// Template text for simulated action result
  ///
  /// In en, this message translates to:
  /// **'Touched {module}'**
  String simulateActionResult(Object module);
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
    'that was used.',
  );
}
