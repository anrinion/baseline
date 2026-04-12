import 'package:baseline/state/settings.dart';
import 'package:baseline/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaselineTheme', () {
    test('resolvedThemeKey uses manual theme in manual mode', () {
      final settings = Settings()
        ..setManualTheme('dark1')
        ..themeMode = Settings.themeModeManual;

      expect(BaselineTheme.resolvedThemeKey(settings), equals('dark1'));
    });

    test('resolvedThemeKey uses platform brightness in device mode', () {
      final settings = Settings()
        ..lightThemeKey = 'light2'
        ..darkThemeKey = 'dark2'
        ..themeMode = Settings.themeModeDevice;

      expect(
        BaselineTheme.resolvedThemeKey(
          settings,
          platformBrightness: Brightness.light,
        ),
        equals('light2'),
      );
      expect(
        BaselineTheme.resolvedThemeKey(
          settings,
          platformBrightness: Brightness.dark,
        ),
        equals('dark2'),
      );
    });

    test('schedule mode resolves light and dark windows', () {
      final settings = Settings()
        ..lightThemeKey = 'light1'
        ..darkThemeKey = 'dark1'
        ..themeMode = Settings.themeModeSchedule
        ..scheduleLightStartMinutes = 7 * 60
        ..scheduleDarkStartMinutes = 21 * 60;

      expect(
        BaselineTheme.resolvedThemeKey(
          settings,
          now: DateTime(2026, 1, 1, 12, 0),
        ),
        equals('light1'),
      );
      expect(
        BaselineTheme.resolvedThemeKey(
          settings,
          now: DateTime(2026, 1, 1, 22, 0),
        ),
        equals('dark1'),
      );
    });

    test('nextThemeBoundary returns nearest upcoming boundary', () {
      final settings = Settings()
        ..scheduleLightStartMinutes = 7 * 60
        ..scheduleDarkStartMinutes = 21 * 60;

      final evening = BaselineTheme.nextThemeBoundary(
        settings,
        DateTime(2026, 1, 1, 20, 30),
      );
      expect(evening, equals(DateTime(2026, 1, 1, 21, 0)));

      final night = BaselineTheme.nextThemeBoundary(
        settings,
        DateTime(2026, 1, 1, 23, 0),
      );
      expect(night, equals(DateTime(2026, 1, 2, 7, 0)));
    });
  });
}
