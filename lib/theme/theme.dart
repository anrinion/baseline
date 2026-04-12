import 'package:flutter/material.dart';

import '../state/settings.dart';
import 'themes.dart';

/// Theme selection logic based on [Settings].
abstract final class BaselineTheme {
  static ThemeData lightTheme(Settings settings) {
    return BaselineThemes.fromKey(settings.lightThemeKey);
  }

  static ThemeData darkTheme(Settings settings) {
    return BaselineThemes.fromKey(settings.darkThemeKey);
  }

  static ThemeMode materialThemeMode(Settings settings, {DateTime? now}) {
    switch (settings.themeMode) {
      case Settings.themeModeDevice:
        return ThemeMode.system;
      case Settings.themeModeSchedule:
        return isScheduledDarkAt(settings, now ?? DateTime.now())
            ? ThemeMode.dark
            : ThemeMode.light;
      case Settings.themeModeManual:
      default:
        return settings.usesDarkManualTheme ? ThemeMode.dark : ThemeMode.light;
    }
  }

  static String resolvedThemeKey(
    Settings settings, {
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
        return isScheduledDarkAt(settings, now ?? DateTime.now())
            ? settings.darkThemeKey
            : settings.lightThemeKey;
      case Settings.themeModeManual:
      default:
        return settings.theme;
    }
  }

  static ThemeData currentTheme(
    Settings settings, {
    DateTime? now,
    Brightness? platformBrightness,
  }) {
    return BaselineThemes.fromKey(
      resolvedThemeKey(
        settings,
        now: now,
        platformBrightness: platformBrightness,
      ),
    );
  }

  static bool isScheduledDarkAt(Settings settings, DateTime dateTime) {
    final nowMinutes = dateTime.hour * 60 + dateTime.minute;
    final lightStarts = settings.scheduleLightStartMinutes;
    final darkStarts = settings.scheduleDarkStartMinutes;
    return !_isInDailyRange(
      nowMinutes,
      startMinutes: lightStarts,
      endMinutes: darkStarts,
    );
  }

  static DateTime nextThemeBoundary(Settings settings, DateTime now) {
    final nextLight = _nextDailyOccurrence(
      now,
      settings.scheduleLightStartMinutes,
    );
    final nextDark = _nextDailyOccurrence(
      now,
      settings.scheduleDarkStartMinutes,
    );
    return nextLight.isBefore(nextDark) ? nextLight : nextDark;
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
