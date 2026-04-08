// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baseline';

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
  String get themeLight1 => 'Light (Neutral)';

  @override
  String get themeLight2 => 'Light (Warm)';

  @override
  String get themeDark1 => 'Dark (True)';

  @override
  String get themeDark2 => 'Dark (Soft)';

  @override
  String get modulesLabel => 'Modules';

  @override
  String get hereModuleLabel => 'I\'m here';

  @override
  String get hereModuleCustomizeLabel => 'Customize button text';

  @override
  String get foodModuleLabel => 'Food';

  @override
  String get foodProteinLabel => 'Protein';

  @override
  String get foodGreensLabel => 'Greens';

  @override
  String get foodBeansLabel => 'Beans & Chickpeas';

  @override
  String get foodFillersLabel => 'Fillers (Carbs)';

  @override
  String get foodTreatLabel => 'Treat';

  @override
  String get foodSourcesTitle => 'Why this works';

  @override
  String get foodSourcesContent =>
      '• Protein: supports satiety and steady energy.\n• Greens: fiber, vitamins, and plant variety.\n• Beans and chickpeas: fiber and plant protein.\n• Fillers: complex carbs for accessible energy.\n• Sweet treat: a small enjoyable bite can support behavioral activation — pleasure without \"earning\" it.\n\nThis is about balance, not restriction. Non-restrictive approaches favor flexibility and self-care over rules or guilt. For personalized guidance, ask a qualified professional.';

  @override
  String get movementModuleLabel => 'Movement';

  @override
  String get movementDefaultOptions => 'Go for a walk\nLight workout';

  @override
  String get movementAnyCountsHint => 'any movement counts';

  @override
  String get sleepModuleLabel => 'Sleep';

  @override
  String get sleepGoingToSleep => 'I\'m going to sleep';

  @override
  String get sleepAwake => 'I\'m awake';

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
  String get movementCompleted =>
      'You completed an activity today. That\'s wonderful! 💪';

  @override
  String get movementChoose => 'Choose one gentle activity for today:';

  @override
  String get movementGreatJob => 'Great job! 💪';

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
  String get appPrivacyText =>
      'Baseline is a private, present-moment self-care app.\\nNo history. No tracking. Just today.';

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
      'This area is for right now only: naming how you feel, a tiny bit of gratitude or grounding, and gentle \"thought lens\" prompts inspired by cognitive approaches. It is not a substitute for care from a qualified professional when you need it.';

  @override
  String get sleepHelp =>
      'Sleep affects mood, energy, and regulation. Logging \"going to sleep\" and \"awake\" with simple duration (today only) supports awareness without tracking streaks or judging rest.';

  @override
  String get medsHelp =>
      'A minimal today-only checklist can reduce mental load. This is not medical advice; use your clinician\'s plan and seek help for urgent concerns.';

  @override
  String get movementHelp =>
      'Any movement counts toward care and activation. No intensity or duration — a small nudge beats \"all or nothing.\"';

  @override
  String get groundingHelp =>
      'A single tap to anchor yourself in the present — Gestalt \"here and now\". No tracking, no memory, no score: the smallest possible caring action.';

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
}
