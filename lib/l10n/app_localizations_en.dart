// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Baseline';

  @override
  String get settingsButtonLabel => 'Settings';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight1 => 'Light (neutral)';

  @override
  String get themeLight2 => 'Light (warm)';

  @override
  String get themeDark1 => 'Dark (true black)';

  @override
  String get themeDark2 => 'Dark (dark grey)';

  @override
  String get themeBehaviorHelp =>
      'Choose how Baseline moves between light and dark.';

  @override
  String get themeModeManual => 'Choose here';

  @override
  String get themeModeManualDescription => 'You pick light or dark yourself.';

  @override
  String get themeModeDevice => 'As device';

  @override
  String get themeModeDeviceDescription =>
      'Baseline follows your phone\'s light and dark setting.';

  @override
  String get themeModeSchedule => 'On schedule';

  @override
  String get themeModeScheduleDescription =>
      'Baseline switches at the times you choose.';

  @override
  String get themeManualChoiceLabel => 'When you choose here:';

  @override
  String get themeUseLight => 'Use light theme';

  @override
  String get themeUseDark => 'Use dark theme';

  @override
  String get themeLightSectionLabel => 'Light theme';

  @override
  String get themeDarkSectionLabel => 'Dark theme';

  @override
  String get themeScheduleLabel => 'Schedule';

  @override
  String get themeScheduleLightStarts => 'Light starts';

  @override
  String get themeScheduleDarkStarts => 'Dark starts';

  @override
  String get modulesLabel => 'Modules';

  @override
  String get hereModuleLabel => 'Grounding button';

  @override
  String get hereModuleCustomizeLabel => 'Customize button text';

  @override
  String get foodModuleLabel => 'Nutrition';

  @override
  String get foodProteinLabel => 'Protein';

  @override
  String get foodGreensLabel => 'Greens';

  @override
  String get foodBeansLabel => 'Beans & Chickpeas';

  @override
  String get foodFillersLabel => 'Fillers';

  @override
  String get foodTreatLabel => 'Treat';

  @override
  String get foodSourcesTitle => 'Why this works';

  @override
  String get foodSourcesContent =>
      '• Protein: supports satiety and steady energy (PLACEHOLDER, 2030).\n• Greens: fiber, vitamins, and plant variety (PLACEHOLDER, 2030).\n• Beans and chickpeas: fiber and plant protein (PLACEHOLDER, 2030).\n• Fillers: complex carbs for accessible energy (PLACEHOLDER, 2030).\n• Treat: a small enjoyable bite can support behavioral activation (PLACEHOLDER, 2030).\n\nApproaches that emphasize flexibility and self-care over strict rules may help avoid guilt (PLACEHOLDER, 2030).';

  @override
  String get movementModuleLabel => 'Movement';

  @override
  String get movementDefaultOptions => 'Go for a walk\nA workout';

  @override
  String get movementAnyCountsHint => 'any movement counts';

  @override
  String get sleepModuleLabel => 'Sleep';

  @override
  String get sleepGoingToSleep => 'I\'m going to sleep';

  @override
  String get sleepAwake => 'I\'m awake';

  @override
  String get sleepDurationSoFar => 'so far';

  @override
  String get sleepCompleted => 'Sleep recorded';

  @override
  String get sleepStartLabel => 'Start';

  @override
  String get sleepEndLabel => 'End';

  @override
  String get sleepPrompt => 'Track your sleep session:';

  @override
  String get sleepBedTimeLabel => 'Bedtime';

  @override
  String get sleepWakeTimeLabel => 'Wake up';

  @override
  String get sleepDurationLabel => 'Sleep duration';

  @override
  String get medsModuleLabel => 'Meds';

  @override
  String get medsAddButtonLabel => 'Add medication';

  @override
  String get mentalStateModuleLabel => 'Mental state';

  @override
  String get mentalStateRightNow => 'Right now';

  @override
  String get mentalStateGoodThing => 'One small good thing';

  @override
  String get mentalStateThoughtLens => 'Thought lens';

  @override
  String get dialogGotIt => 'Got it';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogSave => 'Save';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get dialogClose => 'Close';

  @override
  String get dialogReset => 'Reset';

  @override
  String get dialogWhyThisWorks => 'Why this works';

  @override
  String get dialogWhyThisHelps => 'Why this helps';

  @override
  String get nourishment => 'Nourishment';

  @override
  String get resetAll => 'Reset all';

  @override
  String get grounding => 'Grounding';

  @override
  String get groundingAffirmation1 => 'Good. You\'re here.';

  @override
  String get groundingAffirmation2 => 'Hello there!';

  @override
  String get groundingAffirmation3 => 'One moment at a time.';

  @override
  String get groundingAffirmation4 => 'You showed up. That matters.';

  @override
  String get groundingAffirmation5 => 'Right here, right now.';

  @override
  String get movementTitle => 'Movement';

  @override
  String get movementCompleted => 'You completed an activity today. Good.';

  @override
  String get movementChoose => 'Choose one gentle activity for today:';

  @override
  String get movementGreatJob => 'Good.';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get placeholderModuleText => 'This is a placeholder module.';

  @override
  String get simulateAction => 'Simulate action';

  @override
  String get modulesHelpText =>
      'Turn modules on or off. Optional settings appear under each one.';

  @override
  String get resetToday => 'Reset today';

  @override
  String get todayReset => 'Today reset';

  @override
  String get developerModeLabel => 'Developer mode';

  @override
  String get developerModeHelp =>
      'Shows tools for testing and full local resets.';

  @override
  String get developerResetAllDataLabel => 'Complete state reset';

  @override
  String get developerResetAllDataHelp =>
      'This clears today\'s state, app settings, and returns to the initial setup screen.';

  @override
  String get appPrivacyText =>
      'Baseline is a private self-care app:\\nNo history, no sync, no data collection.\\n';

  @override
  String get foodProteinSubtitle => '1–2 portions';

  @override
  String get foodGreensSubtitle => '3–5 portions (fruits & veggies)';

  @override
  String get foodBeansSubtitle => '1–2 portions';

  @override
  String get foodFillersSubtitle => '1–3 portions (rice, pasta, bread)';

  @override
  String get foodTreatSubtitle => '1 portion (chocolate, dessert)';

  @override
  String get mentalStateHelp =>
      'This area is for right now only: naming how you feel, a tiny bit of gratitude or grounding, and gentle \"thought lens\" prompts inspired by cognitive approaches (PLACEHOLDER, 2030). It is not a substitute for care from a qualified professional when you need it.';

  @override
  String get sleepHelp =>
      'Sleep affects mood, energy, and regulation (PLACEHOLDER, 2030).';

  @override
  String get medsHelp =>
      'Just a tracker for your medications. It is really beneficial to not forget them (no, there will be no source for that).';

  @override
  String get movementHelp =>
      'Any movement counts toward care and activation (PLACEHOLDER, 2030). No intensity or duration — a small nudge beats \"all or nothing.\"';

  @override
  String get groundingHelp =>
      'A single tap to anchor yourself in the present. This helps to reduce stress (PLACEHOLDER, 2030). Similar to Gestalt\'s \"here and now\"';

  @override
  String get hereButtonHint => 'I\'m here. I\'m alive.';

  @override
  String get movementChoicesLabel => 'Movement choices (one per line)';

  @override
  String get movementDone => 'Done';

  @override
  String get stateLabel => 'State:';

  @override
  String simulateActionResult(Object module) {
    return 'Touched $module';
  }

  @override
  String get initialScreenTitle => 'Welcome to Baseline';

  @override
  String get initialScreenMessage => 'No tracking. No pressure. Just today.';

  @override
  String get initialScreenLanguageTitle => 'Choose your language';

  @override
  String get initialScreenThemeTitle => 'Choose your theme';

  @override
  String get initialScreenContinue => 'Continue';

  @override
  String get cbtModeLabel => 'Mode';

  @override
  String get cbtModeRightNow => 'Right now';

  @override
  String get cbtModeGoodThings => 'Good things';

  @override
  String get cbtModeThoughtLens => 'Thought lens';

  @override
  String get cbtModeSettingDescription => 'Choose which CBT submodule to use';

  @override
  String get cbtRightNowQuestion => 'How are you feeling right now?';

  @override
  String get cbtMoodVerySad => 'Very sad';

  @override
  String get cbtMoodSad => 'Sad';

  @override
  String get cbtMoodNeutral => 'Neutral';

  @override
  String get cbtMoodGood => 'Good';

  @override
  String get cbtMoodVeryGood => 'Very good';

  @override
  String get cbtMoodRecorded => 'Mood recorded';

  @override
  String get cbtGoodThingsQuestion => 'What good things happened today?';

  @override
  String get cbtGoodThing => 'Good thing';

  @override
  String get cbtGoodThingsHint =>
      'Small things count. A good coffee, a kind word, sunshine...';

  @override
  String get cbtThoughtLensTitle => 'Thought lens';

  @override
  String get cbtThoughtLensExample => 'Example:';

  @override
  String get cbtThoughtLensPrevious => 'Previous';

  @override
  String get cbtThoughtLensNext => 'Next';

  @override
  String get cbtThoughtLensDaily => 'Today\'s thought distortion';
}
