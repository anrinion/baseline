import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../theme/themes.dart';
import '../modules/mental_state_constants.dart';
import 'today_state.dart';
import 'settings.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  late Box<TodayState> todayBox;
  late Box<Settings> settingsBox;
  TodayState todayState = TodayState();
  Settings settings = Settings();
  Timer? _themeScheduleTimer;

  AppState() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    todayBox = Hive.box<TodayState>('todayState');
    settingsBox = Hive.box<Settings>('settings');

    if (todayBox.isEmpty) {
      todayState = TodayState();
      todayBox.put('today', todayState);
    } else {
      todayState = todayBox.get('today')!;
    }

    if (settingsBox.isEmpty) {
      settings = Settings();
      settingsBox.put('settings', settings);
    } else {
      settings = settingsBox.get('settings')!;
    }

    if (settings.ensureBaselineModuleDefaults()) {
      settingsBox.put('settings', settings);
    }

    _applyDayBoundary();
    _scheduleThemeTimer();
    notifyListeners();
  }

  /// If the calendar day changed since last save, wipe [todayState].
  /// Empty [lastDayKey] means migration or first run: stamp today without wiping.
  void _applyDayBoundary() {
    final todayKey = TodayState.dayKeyFor(DateTime.now());
    if (todayState.lastDayKey.isEmpty) {
      todayState.lastDayKey = todayKey;
      // Initialize with a random distortion for first run
      todayState.thoughtLensIndex = MentalStateConstants.getRandomDistortionIndex(-1);
      todayBox.put('today', todayState);
    } else if (todayState.lastDayKey != todayKey) {
      // Store yesterday's index before resetting
      final yesterdayIndex = todayState.thoughtLensIndex;
      todayState = TodayState()..lastDayKey = todayKey;
      // Select a new random distortion different from yesterday's
      todayState.thoughtLensIndex = MentalStateConstants.getRandomDistortionIndex(yesterdayIndex);
      todayState.yesterdayThoughtLensIndex = yesterdayIndex;
      todayBox.put('today', todayState);
    }
  }

  /// Clears all of today's activity but keeps the current calendar day bucket.
  void resetTodayManual() {
    final todayKey = TodayState.dayKeyFor(DateTime.now());
    todayState = TodayState()..lastDayKey = todayKey;
    todayBox.put('today', todayState);
    notifyListeners();
  }

  void resetAllData() {
    settings = Settings();
    todayState = TodayState();
    settingsBox.put('settings', settings);
    todayBox.put('today', todayState);
    _applyDayBoundary();
    _scheduleThemeTimer();
    notifyListeners();
  }

  void updateTodayState(void Function(TodayState) updater) {
    updater(todayState);
    todayBox.put('today', todayState);
    notifyListeners();
  }

  void updateSettings(void Function(Settings) updater) {
    updater(settings);
    settingsBox.put('settings', settings);
    _scheduleThemeTimer();
    notifyListeners();
  }

  ThemeData get lightTheme =>
      BaselineThemes.fromKey(settings.lightThemeKey);

  ThemeData get darkTheme =>
      BaselineThemes.fromKey(settings.darkThemeKey);

  ThemeMode get materialThemeMode {
    switch (settings.themeMode) {
      case Settings.themeModeDevice:
        return ThemeMode.system;
      case Settings.themeModeSchedule:
        return isScheduledDarkAt(DateTime.now())
            ? ThemeMode.dark
            : ThemeMode.light;
      case Settings.themeModeManual:
      default:
        return settings.usesDarkManualTheme ? ThemeMode.dark : ThemeMode.light;
    }
  }

  String resolvedThemeKey({
    DateTime? now,
    Brightness? platformBrightness,
  }) {
    switch (settings.themeMode) {
      case Settings.themeModeDevice:
        final brightness =
            platformBrightness ??
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark
            ? settings.darkThemeKey
            : settings.lightThemeKey;
      case Settings.themeModeSchedule:
        return isScheduledDarkAt(now ?? DateTime.now())
            ? settings.darkThemeKey
            : settings.lightThemeKey;
      case Settings.themeModeManual:
      default:
        return settings.theme;
    }
  }

  ThemeData get currentTheme {
    return BaselineThemes.fromKey(resolvedThemeKey(now: DateTime.now()));
  }

  bool isScheduledDarkAt(DateTime dateTime) {
    final nowMinutes = dateTime.hour * 60 + dateTime.minute;
    final lightStarts = settings.scheduleLightStartMinutes;
    final darkStarts = settings.scheduleDarkStartMinutes;
    return !_isInDailyRange(
      nowMinutes,
      startMinutes: lightStarts,
      endMinutes: darkStarts,
    );
  }

  @override
  void didChangePlatformBrightness() {
    if (settings.themeMode == Settings.themeModeDevice) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _themeScheduleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleThemeTimer() {
    _themeScheduleTimer?.cancel();
    if (settings.themeMode != Settings.themeModeSchedule) {
      return;
    }

    final now = DateTime.now();
    final nextLight = _nextDailyOccurrence(
      now,
      settings.scheduleLightStartMinutes,
    );
    final nextDark = _nextDailyOccurrence(
      now,
      settings.scheduleDarkStartMinutes,
    );
    final nextBoundary = nextLight.isBefore(nextDark) ? nextLight : nextDark;
    final delay = nextBoundary.difference(now);

    _themeScheduleTimer = Timer(
      delay <= Duration.zero ? const Duration(minutes: 1) : delay,
      () {
        _scheduleThemeTimer();
        notifyListeners();
      },
    );
  }

  static bool _isInDailyRange(
    int nowMinutes, {
    required int startMinutes,
    required int endMinutes,
  }) {
    if (startMinutes == endMinutes) {
      return true;
    }
    if (startMinutes < endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
    return nowMinutes >= startMinutes || nowMinutes < endMinutes;
  }

  static DateTime _nextDailyOccurrence(DateTime now, int minutesOfDay) {
    final candidate = DateTime(
      now.year,
      now.month,
      now.day,
      minutesOfDay ~/ 60,
      minutesOfDay % 60,
    );
    if (candidate.isAfter(now)) {
      return candidate;
    }
    return candidate.add(const Duration(days: 1));
  }
}
