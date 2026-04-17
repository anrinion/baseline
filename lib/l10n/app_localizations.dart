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
  /// **'The Baseline'**
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
  /// **'Light (neutral)'**
  String get themeLight1;

  /// Light theme option - warm
  ///
  /// In en, this message translates to:
  /// **'Light (warm)'**
  String get themeLight2;

  /// Dark theme option - true black
  ///
  /// In en, this message translates to:
  /// **'Dark (true black)'**
  String get themeDark1;

  /// Dark theme option - soft contrast
  ///
  /// In en, this message translates to:
  /// **'Dark (dark grey)'**
  String get themeDark2;

  /// Help text for theme behavior settings
  ///
  /// In en, this message translates to:
  /// **'Choose how Baseline moves between light and dark.'**
  String get themeBehaviorHelp;

  /// Theme behavior option: manual
  ///
  /// In en, this message translates to:
  /// **'Choose here'**
  String get themeModeManual;

  /// Description for manual theme behavior
  ///
  /// In en, this message translates to:
  /// **'You pick light or dark yourself.'**
  String get themeModeManualDescription;

  /// Theme behavior option: follow device
  ///
  /// In en, this message translates to:
  /// **'As device'**
  String get themeModeDevice;

  /// Description for device theme behavior
  ///
  /// In en, this message translates to:
  /// **'Baseline follows your phone\'s light and dark setting.'**
  String get themeModeDeviceDescription;

  /// Theme behavior option: scheduled
  ///
  /// In en, this message translates to:
  /// **'On schedule'**
  String get themeModeSchedule;

  /// Description for scheduled theme behavior
  ///
  /// In en, this message translates to:
  /// **'Baseline switches at the times you choose.'**
  String get themeModeScheduleDescription;

  /// Label for manual light/dark choice
  ///
  /// In en, this message translates to:
  /// **'When you choose here:'**
  String get themeManualChoiceLabel;

  /// Manual theme option: use light theme
  ///
  /// In en, this message translates to:
  /// **'Use light theme'**
  String get themeUseLight;

  /// Manual theme option: use dark theme
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get themeUseDark;

  /// Section label for light theme palette selection
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLightSectionLabel;

  /// Section label for dark theme palette selection
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDarkSectionLabel;

  /// Section label for scheduled theme settings
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get themeScheduleLabel;

  /// Label for scheduled light theme start time
  ///
  /// In en, this message translates to:
  /// **'Light starts'**
  String get themeScheduleLightStarts;

  /// Label for scheduled dark theme start time
  ///
  /// In en, this message translates to:
  /// **'Dark starts'**
  String get themeScheduleDarkStarts;

  /// Label for modules settings section
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modulesLabel;

  /// Label for the grounding module
  ///
  /// In en, this message translates to:
  /// **'Grounding'**
  String get hereModuleLabel;

  /// Label for customizing the grounding button text
  ///
  /// In en, this message translates to:
  /// **'Customize button text'**
  String get hereModuleCustomizeLabel;

  /// Label for the Food module
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
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
  /// **'Fillers'**
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

  /// Detailed explanation of why the food categories work (HTML with numbered citations)
  ///
  /// In en, this message translates to:
  /// **'<p><b>Protein</b> from plant sources and animal sources other than red meat is associated with lower risk of all‑cause and cardiovascular disease mortality <a href=\'#ref-1\'>[1]</a><a href=\'#ref-2\'>[2]</a>.</p><p><b>Greens</b> (fruits &amp; vegetables): each additional 200g/day is associated with ~8–16% lower risk of cardiovascular disease, cancer, and all‑cause mortality. Benefits increase up to ~800g/day (about 5 portions), after which risk reduction plateaus <a href=\'#ref-3\'>[3]</a>. Additionally, higher vegetable intake is linked to slower cognitive decline and lower dementia risk <a href=\'#ref-4\'>[4]</a>.</p><p><b>Beans and chickpeas</b> (legumes): rich in fiber and plant protein. Current evidence (low certainty) suggests they may reduce risk of cardiovascular disease and hypertension <a href=\'#ref-5\'>[5]</a>.</p><p><b>Fillers</b> (carbohydrates): moderate intake (50–55% of energy) is associated with lowest mortality risk. Very low (&lt;40%) or very high (&gt;70%) carbohydrate intake increases mortality – especially when carbs are replaced with animal fat/protein <a href=\'#ref-6\'>[6]</a>. Whole grains are a preferable source <a href=\'#ref-7\'>[7]</a>.</p><p>A small piece of <b>chocolate</b> can improve mood and reduce negative feelings, possibly due to its orosensory pleasure or bioactive compounds like flavanols and methylxanthine <a href=\'#ref-8\'>[8]</a>.</p><p style=\'margin-top:16px\'><i>Flexible eating patterns</i> (intuitive and mindful eating) are associated with lower depressive symptoms, less disordered eating, better body image, and greater self‑compassion – without strict rules or guilt <a href=\'#ref-9\'>[9]</a>.</p>'**
  String get foodSourcesContent;

  /// Full references for food sources citations (HTML)
  ///
  /// In en, this message translates to:
  /// **'<p id=\'ref-1\' style=\'margin-bottom:8px\'><b>[1]</b> Naghshi S, et al. Dietary intake of total, animal, and plant proteins and risk of all cause, cardiovascular, and cancer mortality: systematic review and dose-response meta-analysis. BMJ. 2020;370:m2412.</p><p id=\'ref-2\' style=\'margin-bottom:8px\'><b>[2]</b> Kitada M, et al. The impact of dietary protein intake on longevity and metabolic health. EBioMedicine. 2019;43:632-640.</p><p id=\'ref-3\' style=\'margin-bottom:8px\'><b>[3]</b> Aune D, et al. Fruit and vegetable intake and the risk of cardiovascular disease, total cancer and all-cause mortality. Int J Epidemiol. 2017;46(3):1029-1056.</p><p id=\'ref-4\' style=\'margin-bottom:8px\'><b>[4]</b> Loef M, Walach H. Fruit, vegetables and prevention of cognitive decline or dementia: a systematic review of cohort studies. J Nutr Health Aging. 2012;16(7):626-630.</p><p id=\'ref-5\' style=\'margin-bottom:8px\'><b>[5]</b> Viguiliouk E, et al. Associations between dietary pulses alone or with other legumes and cardiometabolic disease outcomes: an umbrella review and updated systematic review and meta-analysis. Adv Nutr. 2019;10(Suppl 4):S308-S319.</p><p id=\'ref-6\' style=\'margin-bottom:8px\'><b>[6]</b> Seidelmann SB, et al. Dietary carbohydrate intake and mortality: a prospective cohort study and meta-analysis. Lancet Public Health. 2018;3(9):e419-e428.</p><p id=\'ref-7\' style=\'margin-bottom:8px\'><b>[7]</b> World Health Organization. Carbohydrate intake for adults and children: WHO guideline summary. Geneva: WHO; 2023.</p><p id=\'ref-8\' style=\'margin-bottom:8px\'><b>[8]</b> Scholey A, Owen L. Effects of chocolate on cognitive function and mood: a systematic review. Nutr Rev. 2013;71(10):665-681.</p><p id=\'ref-9\'><b>[9]</b> Eaton M, et al. Intuitive eating and mindful eating: associations with mental health and eating behaviours. Appetite. 2024;192:107070.</p>'**
  String get foodSourcesReferences;

  /// Label for the Movement module
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movementModuleLabel;

  /// Default movement options
  ///
  /// In en, this message translates to:
  /// **'Go for a walk\nA workout'**
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

  /// Label indicating sleep duration is ongoing
  ///
  /// In en, this message translates to:
  /// **'so far'**
  String get sleepDurationSoFar;

  /// Message when sleep session is complete
  ///
  /// In en, this message translates to:
  /// **'Sleep recorded'**
  String get sleepCompleted;

  /// Label for sleep start time
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get sleepStartLabel;

  /// Label for sleep end time
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get sleepEndLabel;

  /// Prompt for starting sleep tracking
  ///
  /// In en, this message translates to:
  /// **'Track your sleep session:'**
  String get sleepPrompt;

  /// Label for bedtime slider
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get sleepBedTimeLabel;

  /// Label for wake up time slider
  ///
  /// In en, this message translates to:
  /// **'Wake up'**
  String get sleepWakeTimeLabel;

  /// Label for calculated sleep duration
  ///
  /// In en, this message translates to:
  /// **'Sleep duration'**
  String get sleepDurationLabel;

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

  /// Button to open medication list editor
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get medsEditListButtonLabel;

  /// Title for medication list editor dialog
  ///
  /// In en, this message translates to:
  /// **'Medication list'**
  String get medsEditListTitle;

  /// Hint for medication list editor text field
  ///
  /// In en, this message translates to:
  /// **'One medication per line'**
  String get medsEditListHint;

  /// Settings label for meds list input
  ///
  /// In en, this message translates to:
  /// **'Medication list (one per line)'**
  String get medsListSettingsLabel;

  /// Default medication list. Keep empty for a clean first state.
  ///
  /// In en, this message translates to:
  /// **''**
  String get medsDefaultList;

  /// Empty state text for meds module
  ///
  /// In en, this message translates to:
  /// **'No medications listed yet. Add the ones you want to track today.'**
  String get medsEmptyState;

  /// Compact empty state text for meds module tile
  ///
  /// In en, this message translates to:
  /// **'No meds yet'**
  String get medsEmptyCompact;

  /// Progress text for meds taken today
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} marked for today'**
  String medsTodayProgress(int taken, int total);

  /// Text indicating more medications exist than shown in tile
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String medsMoreCount(int count);

  /// Toggle label for enabling daily meds reminder notifications
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get medsReminderToggleLabel;

  /// Help text for meds reminder toggle
  ///
  /// In en, this message translates to:
  /// **'If enabled, Baseline sends one local reminder per day.'**
  String get medsReminderToggleHelp;

  /// Label for meds reminder time picker
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get medsReminderTimeLabel;

  /// Message shown when notification permission is denied while enabling reminders
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. Enable permissions to use reminders.'**
  String get medsReminderPermissionDenied;

  /// Tooltip for enabling reminder on a medication row
  ///
  /// In en, this message translates to:
  /// **'Enable reminder for this medication'**
  String get medsReminderEnableTooltip;

  /// Tooltip for disabling reminder on a medication row
  ///
  /// In en, this message translates to:
  /// **'Disable reminder for this medication'**
  String get medsReminderDisableTooltip;

  /// Label for the Mental state module
  ///
  /// In en, this message translates to:
  /// **'Mental state'**
  String get mentalStateModuleLabel;

  /// Mental state section: current mood
  ///
  /// In en, this message translates to:
  /// **'Current mood'**
  String get mentalStateRightNow;

  /// Mental state section: daily positives
  ///
  /// In en, this message translates to:
  /// **'Daily positives'**
  String get mentalStateGoodThing;

  /// Mental state section: cognitive distortions
  ///
  /// In en, this message translates to:
  /// **'Cognitive distortions'**
  String get mentalStateThoughtLens;

  /// Description for mental state tracking settings
  ///
  /// In en, this message translates to:
  /// **'Choose what to track in the Mental state module'**
  String get mentalStateSettingDescription;

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
  /// **'You completed an activity today. Good.'**
  String get movementCompleted;

  /// Instruction text for choosing a movement activity
  ///
  /// In en, this message translates to:
  /// **'Choose one gentle activity for today:'**
  String get movementChoose;

  /// Congratulation message for movement
  ///
  /// In en, this message translates to:
  /// **'Good.'**
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

  /// Label for developer mode toggle
  ///
  /// In en, this message translates to:
  /// **'Developer mode'**
  String get developerModeLabel;

  /// Help text for developer mode toggle
  ///
  /// In en, this message translates to:
  /// **'Shows tools for testing and full local resets.'**
  String get developerModeHelp;

  /// Button label for developer full reset
  ///
  /// In en, this message translates to:
  /// **'Complete state reset'**
  String get developerResetAllDataLabel;

  /// Confirmation text for developer full reset
  ///
  /// In en, this message translates to:
  /// **'This clears today\'s state, app settings, and returns to the initial setup screen.'**
  String get developerResetAllDataHelp;

  /// Label for notification service status shown in developer mode
  ///
  /// In en, this message translates to:
  /// **'Medication notifications service'**
  String get developerNotificationsServiceLabel;

  /// Developer status for notifications when service has not initialized
  ///
  /// In en, this message translates to:
  /// **'Status: not initialized'**
  String get developerNotificationsStatusNotInitialized;

  /// Developer status for notifications when service is ready and no reminders are currently scheduled
  ///
  /// In en, this message translates to:
  /// **'Status: ready (no reminders scheduled)'**
  String get developerNotificationsStatusReady;

  /// Developer status for notifications when reminders are scheduled
  ///
  /// In en, this message translates to:
  /// **'Status: active (reminders scheduled)'**
  String get developerNotificationsStatusActive;

  /// Developer status for notifications when reminders are disabled in settings
  ///
  /// In en, this message translates to:
  /// **'Status: disabled (no reminders configured)'**
  String get developerNotificationsStatusDisabled;

  /// Developer status for notifications when current platform does not support the notifications service
  ///
  /// In en, this message translates to:
  /// **'Status: unsupported platform'**
  String get developerNotificationsStatusUnsupportedPlatform;

  /// Developer status for notifications when local notifications plugin is unavailable
  ///
  /// In en, this message translates to:
  /// **'Status: plugin unavailable'**
  String get developerNotificationsStatusPluginMissing;

  /// Developer status for notifications when notification permission is denied
  ///
  /// In en, this message translates to:
  /// **'Status: permission denied'**
  String get developerNotificationsStatusPermissionDenied;

  /// Developer status for notifications when an unexpected error occurs
  ///
  /// In en, this message translates to:
  /// **'Status: error'**
  String get developerNotificationsStatusError;

  /// Privacy statement in settings
  ///
  /// In en, this message translates to:
  /// **'Baseline is a private self-care app:\\nNo history, no sync, no data collection.\\n'**
  String get appPrivacyText;

  /// Food category portion guide: Protein
  ///
  /// In en, this message translates to:
  /// **'1-2 portions'**
  String get foodProteinSubtitle;

  /// Food category portion guide: Greens
  ///
  /// In en, this message translates to:
  /// **'3-5 portions (fruits & veggies)'**
  String get foodGreensSubtitle;

  /// Food category portion guide: Beans
  ///
  /// In en, this message translates to:
  /// **'1-2 portions'**
  String get foodBeansSubtitle;

  /// Food category portion guide: Fillers
  ///
  /// In en, this message translates to:
  /// **'1-3 portions (rice, pasta, bread)'**
  String get foodFillersSubtitle;

  /// Food category portion guide: Treat
  ///
  /// In en, this message translates to:
  /// **'1 portion (chocolate, dessert)'**
  String get foodTreatSubtitle;

  /// Help text for mental state module (HTML with numbered citations)
  ///
  /// In en, this message translates to:
  /// **'<p>The evidence for these techniques is not definitive — different approaches work for different people. Baseline offers three distinct modes so you can try them and see what fits.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>Current mood</h3><p>A simple check of your current mood.</p><p>A systematic review and meta‑analysis of randomised controlled trials found that <b>journaling interventions (including simple expressive writing) led to a 5% greater reduction in mental health symptom scores</b> compared to control groups, with more pronounced effects for <b>anxiety (9%)</b> and <b>PTSD (6%)</b>. However, the authors note high statistical heterogeneity and methodological flaws across studies, limiting definitive conclusions about the effect size <a href=\'#ref-1\'>[1]</a>.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>Daily positives</h3><p>A reflection on positive moments.</p><p>One preliminary 12‑week randomised controlled trial of online Positive Affect Journaling (PAJ) in general medical patients with elevated anxiety found that <b>PAJ was associated with decreased mental distress, increased well‑being, fewer depressive symptoms, reduced anxiety</b> after one month, and greater resilience after the first and second months, compared to usual care. As a single trial with moderate adherence, these results require replication <a href=\'#ref-2\'>[2]</a>.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>Cognitive distortions</h3><p>This mode is purely educational. It is based on established cognitive‑behavioural therapy concepts of identifying cognitive distortions as a first step toward restructuring.</p>'**
  String get mentalStateHelp;

  /// Full references for mental state citations (HTML)
  ///
  /// In en, this message translates to:
  /// **'<h3 style=\'margin-top:24px;margin-bottom:12px\'>References</h3><p id=\'ref-1\' style=\'margin-bottom:12px\'><b>[1]</b> Sohal, M., Singh, P., Dhillon, B. S., &amp; Gill, H. S. (2022). Efficacy of journaling in the management of mental illness: a systematic review and meta‑analysis. <i>Family Medicine and Community Health</i>, 10(1), e001154. <a href=\'https://doi.org/10.1136/fmch-2021-001154\'>https://doi.org/10.1136/fmch-2021-001154</a></p><p id=\'ref-2\'><b>[2]</b> Smyth, J. M., Johnson, J. A., Auer, B. J., Lehman, E., Talamo, G., &amp; Sciamanna, C. N. (2018). Online Positive Affect Journaling in the Improvement of Mental Distress and Well‑Being in General Medical Patients With Elevated Anxiety Symptoms: A Preliminary Randomized Controlled Trial. <i>JMIR Mental Health</i>, 5(4), e11290. <a href=\'https://doi.org/10.2196/11290\'>https://doi.org/10.2196/11290</a></p>'**
  String get mentalStateReferences;

  /// Help text for sleep module (HTML with numbered citations)
  ///
  /// In en, this message translates to:
  /// **'<p>Baseline does not track sleep stages or offer analysis – it simply asks you to notice when you sleep and for how long. Paying gentle attention to your own sleep duration is the first step toward better rest.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>Core Sleep Recommendation for Adults (18–60 Years)</h3><p>For optimal physical and mental health, adults should obtain <b>7 or more hours of sleep per night on a regular basis</b> <a href=\'#ref-1\'>[1]</a>. The evidence is clear that sleeping less than 7 hours on a habitual basis is not merely a matter of feeling tired—it is associated with measurable, negative changes in cardiovascular, metabolic, and emotional function.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>Key Health Outcomes Associated with Insufficient Sleep</h3><p><b>Cardiovascular and Mortality Risk</b></p><p>Large-scale population data indicate a strong and consistent association between short sleep and increased health risks. Compared to those sleeping 7–9 hours, individuals with insufficient sleep face a 6% to 15% higher risk of death from any cause, with the highest risk observed in those sleeping fewer than 5 hours <a href=\'#ref-3\'>[3]</a>. Specific cardiovascular impacts include a 20% to 61% increased likelihood of developing hypertension and an 11% higher risk of coronary heart disease for every hour of sleep lost below the recommended threshold <a href=\'#ref-3\'>[3]</a>.</p><p><b>Metabolic Health and Weight Regulation</b></p><p>Sleep loss disrupts the balance of hunger-regulating hormones (leptin and ghrelin), leading to increased caloric intake and reduced energy expenditure. The data show that short sleepers are approximately 45% to 55% more likely to be obese and have a 9% elevated risk of developing type 2 diabetes compared to those with adequate sleep duration <a href=\'#ref-3\'>[3]</a>.</p><p><b>Mental Health and Emotional Regulation</b></p><p>Sleep is causally linked to mental well-being. Interventions that successfully improve sleep quality yield <b>moderate-to-large reductions in depressive symptoms and anxiety</b> <a href=\'#ref-2\'>[2]</a>. Furthermore, even acute sleep loss has a significant and reliable anxiety-increasing effect, impairing the brain\'s ability to regulate emotional responses and leading to heightened irritability and stress sensitivity <a href=\'#ref-3\'>[3]</a>.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>A Note on Sleeping More Than 9 Hours</h3><p>Sleeping more than 9 hours per night may be appropriate and restorative for young adults, individuals recovering from significant sleep debt, or those managing specific illnesses. However, for the general healthy adult population, the relationship between sleeping over 9 hours and health risk is not fully understood and may reflect underlying health issues rather than a direct cause of harm <a href=\'#ref-1\'>[1]</a>. Consultation with a healthcare provider is recommended for those concerned about excessive sleep duration.</p>'**
  String get sleepHelp;

  /// Full references for sleep help citations (HTML)
  ///
  /// In en, this message translates to:
  /// **'<h3 style=\'margin-top:24px;margin-bottom:12px\'>References</h3><p id=\'ref-1\' style=\'margin-bottom:12px\'><b>[1]</b> Watson, N. F., Badr, M. S., Belenky, G., Bliwise, D. L., Buxton, O. M., Buysse, D., Dinges, D. F., Gangwisch, J., Grandner, M. A., Kushida, C., Malhotra, R. K., Martin, J. L., Patel, S. R., Quan, S. F., &amp; Tasali, E. (2015). Recommended Amount of Sleep for a Healthy Adult: A Joint Consensus Statement of the American Academy of Sleep Medicine and Sleep Research Society. <i>Sleep</i>, 38(6), 843–844. <a href=\'https://doi.org/10.5665/sleep.4716\'>https://doi.org/10.5665/sleep.4716</a></p><p id=\'ref-2\' style=\'margin-bottom:12px\'><b>[2]</b> Scott, A. J., Webb, T. L., Martyn-St James, M., Rowse, G., &amp; Weich, S. (2021). Improving sleep quality leads to better mental health: A meta-analysis of randomised controlled trials. <i>Sleep Medicine Reviews</i>, 60, 101556. <a href=\'https://doi.org/10.1016/j.smrv.2021.101556\'>https://doi.org/10.1016/j.smrv.2021.101556</a></p><p id=\'ref-3\'><b>[3]</b> Shah, A. S., Pant, M. R., Bommasamudram, T., Nayak, K. R., Roberts, S. S. H., Gallagher, C., Vaishali, K., Edwards, B. J., Tod, D., Davis, F., &amp; Pullinger, S. A. (2025). Effects of Sleep Deprivation on Physical and Mental Health Outcomes: An Umbrella Review. <i>American Journal of Lifestyle Medicine</i>, Advance online publication. <a href=\'https://doi.org/10.1177/15598276251346752\'>https://doi.org/10.1177/15598276251346752</a></p>'**
  String get sleepHelpReferences;

  /// Help text for meds module (HTML with numbered citations)
  ///
  /// In en, this message translates to:
  /// **'<p>Track medications for today only. No scores, no history, just a gentle checklist you can reset anytime.</p><p><i>Detailed information with research references will be added soon.</i></p>'**
  String get medsHelp;

  /// Full references for meds citations (HTML)
  ///
  /// In en, this message translates to:
  /// **'<h3 style=\'margin-top:24px;margin-bottom:12px\'>References</h3><p><i>References will be added when research is complete.</i></p>'**
  String get medsReferences;

  /// Help text for movement module (HTML with numbered citations)
  ///
  /// In en, this message translates to:
  /// **'<p>Baseline suggests two default movement options – <b>\"Go for a walk\"</b> and <b>\"Do a workout\"</b> – but you can add any activity you prefer.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>Walking (daily steps)</h3><p>Higher daily steps are associated with <b>lower risk of all-cause mortality and cardiovascular events</b>. Adding <b>500–1000 steps per day</b> to your current baseline is linked to reduced risk – for example, going from 3000 to 4000 steps <a href=\'#ref-1\'>[1]</a>.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>Workouts – resistance (strength) training</h3><p>Resistance training <b>consistently increases skeletal muscle mass, strength, and physical function</b> <a href=\'#ref-2\'>[2]</a>.</p><h3 style=\'margin-top:20px;margin-bottom:12px\'>User‑defined activities</h3><p>You can add your own movement types. <b>Any movement counts</b> toward care and activation. No intensity or duration is required – a small nudge beats \"all or nothing.\"</p>'**
  String get movementHelp;

  /// Full references for movement citations (HTML)
  ///
  /// In en, this message translates to:
  /// **'<h3 style=\'margin-top:24px;margin-bottom:12px\'>References</h3><p id=\'ref-1\' style=\'margin-bottom:12px\'><b>[1]</b> Xu, C., Jia, J., Zhao, B., Yuan, M., Luo, N., Zhang, F., &amp; Wang, H. (2024). Objectively measured daily steps and health outcomes: an umbrella review. <i>BMJ Open</i>, 14(10), e086254. <a href=\'https://doi.org/10.1136/bmjopen-2024-086254\'>https://doi.org/10.1136/bmjopen-2024-086254</a></p><p id=\'ref-2\'><b>[2]</b> McLeod, J. C., Currier, B. S., Lowisz, C. V., &amp; Phillips, S. M. (2024). The influence of resistance exercise training prescription variables on skeletal muscle mass, strength, and physical function in healthy adults: An umbrella review. <i>Journal of Sport and Health Science</i>, 13(1), 47–60. <a href=\'https://doi.org/10.1016/j.jshs.2023.10.005\'>https://doi.org/10.1016/j.jshs.2023.10.005</a></p>'**
  String get movementReferences;

  /// Help text for grounding/here module (HTML with numbered citations)
  ///
  /// In en, this message translates to:
  /// **'<p>A single tap to anchor yourself in the present. This helps to reduce stress. Similar to Gestalt\'s \"here and now\" approach.</p><p><i>Detailed information with research references will be added soon.</i></p>'**
  String get groundingHelp;

  /// Full references for grounding citations (HTML)
  ///
  /// In en, this message translates to:
  /// **'<h3 style=\'margin-top:24px;margin-bottom:12px\'>References</h3><p><i>References will be added when research is complete.</i></p>'**
  String get groundingReferences;

  /// Hint text for the here module button customization field
  ///
  /// In en, this message translates to:
  /// **'I\'m here. I\'m alive.'**
  String get hereButtonHint;

  /// Label for movement choices field
  ///
  /// In en, this message translates to:
  /// **'Movement choices'**
  String get movementChoicesLabel;

  /// Message shown when a movement item is deleted
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get movementItemDeleted;

  /// Hint text for movement item input field
  ///
  /// In en, this message translates to:
  /// **'e.g. Go for a walk'**
  String get movementItemHint;

  /// Button label to add a new movement activity
  ///
  /// In en, this message translates to:
  /// **'New activity'**
  String get movementAddNewItem;

  /// Compact movement completed label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get movementDone;

  /// Magic keywords for walk icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'walk,stroll'**
  String get movementMagicWalk;

  /// Magic keywords for run icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'run,jog'**
  String get movementMagicRun;

  /// Magic keywords for yoga icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'yoga,stretch'**
  String get movementMagicYoga;

  /// Magic keywords for bike icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'bike,cycle'**
  String get movementMagicBike;

  /// Magic keywords for swim icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'swim,pool'**
  String get movementMagicSwim;

  /// Magic keywords for workout icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'workout,gym'**
  String get movementMagicWorkout;

  /// Magic keywords for basketball icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'basketball,ball'**
  String get movementMagicBasketball;

  /// Magic keywords for tennis icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'tennis,racket'**
  String get movementMagicTennis;

  /// Magic keywords for hike icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'hike,trek'**
  String get movementMagicHike;

  /// Magic keywords for martial arts icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'martial,karate'**
  String get movementMagicMartial;

  /// Magic keywords for dance icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'dance,dancing'**
  String get movementMagicDance;

  /// Magic keywords for rowing icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'row,kayak'**
  String get movementMagicRow;

  /// Magic keywords for skateboard icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'skate,skateboard'**
  String get movementMagicSkate;

  /// Magic keywords for ski icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'ski,snowboard'**
  String get movementMagicSki;

  /// Magic keywords for soccer icon (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'soccer,football'**
  String get movementMagicSoccer;

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

  /// Title of the initial setup screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Baseline'**
  String get initialScreenTitle;

  /// Welcome message on initial screen
  ///
  /// In en, this message translates to:
  /// **'No tracking. No pressure. Just today.'**
  String get initialScreenMessage;

  /// Title for language selection section
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get initialScreenLanguageTitle;

  /// Title for theme selection section
  ///
  /// In en, this message translates to:
  /// **'Choose your theme'**
  String get initialScreenThemeTitle;

  /// Button to continue to main app
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get initialScreenContinue;

  /// Question for right now mood selection
  ///
  /// In en, this message translates to:
  /// **'How are you feeling right now?'**
  String get cbtRightNowQuestion;

  /// Mood option: Very sad
  ///
  /// In en, this message translates to:
  /// **'Very sad'**
  String get cbtMoodVerySad;

  /// Mood option: Sad
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get cbtMoodSad;

  /// Mood option: Neutral
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get cbtMoodNeutral;

  /// Mood option: Good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get cbtMoodGood;

  /// Mood option: Very good
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get cbtMoodVeryGood;

  /// Message when mood is recorded
  ///
  /// In en, this message translates to:
  /// **'Mood recorded'**
  String get cbtMoodRecorded;

  /// Question for good things exercise
  ///
  /// In en, this message translates to:
  /// **'What good things happened today?'**
  String get cbtGoodThingsQuestion;

  /// Label for a good thing input
  ///
  /// In en, this message translates to:
  /// **'Good thing'**
  String get cbtGoodThing;

  /// Hint text for good things exercise
  ///
  /// In en, this message translates to:
  /// **'Small things count. A good coffee, a kind word, sunshine...'**
  String get cbtGoodThingsHint;

  /// Title for thought lens section
  ///
  /// In en, this message translates to:
  /// **'Thought lens'**
  String get cbtThoughtLensTitle;

  /// Label for thought lens example
  ///
  /// In en, this message translates to:
  /// **'Example:'**
  String get cbtThoughtLensExample;

  /// Button to show previous thought lens
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get cbtThoughtLensPrevious;

  /// Button to show next thought lens
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get cbtThoughtLensNext;

  /// Label indicating today's random thought distortion
  ///
  /// In en, this message translates to:
  /// **'Today\'s thought distortion'**
  String get cbtThoughtLensDaily;
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
