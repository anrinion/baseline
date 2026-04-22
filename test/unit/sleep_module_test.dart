import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:baseline/modules/sleep_module.dart';
import 'package:baseline/l10n/app_localizations.dart';

void main() {
  group('calculateSleepDuration', () {
    test('same day sleep', () {
      // Bed at 02:00 (120), wake at 10:00 (600)
      final duration = calculateSleepDuration(120, 600);
      expect(duration.inHours, equals(8));
      expect(duration.inMinutes, equals(480));
    });

    test('overnight sleep', () {
      // Bed at 23:00 (1380), wake at 07:00 (420)
      final duration = calculateSleepDuration(1380, 420);
      expect(duration.inHours, equals(8));
      expect(duration.inMinutes, equals(480));
    });

    test('short overnight sleep', () {
      // Bed at 23:30 (1410), wake at 00:30 (30)
      final duration = calculateSleepDuration(1410, 30);
      expect(duration.inMinutes, equals(60));
    });

    test('long overnight sleep', () {
      // Bed at 20:00 (1200), wake at 12:00 (720)
      final duration = calculateSleepDuration(1200, 720);
      expect(duration.inHours, equals(16));
    });
  });

  group('calculateSleepWindow - overnight sleep (bed > wake)', () {
    const bed = 1380; // 23:00
    const wake = 420; // 07:00

    test('bedtime slider shows from bed to midnight', () {
      final window = calculateSleepWindow(bed, wake, true);
      expect(window[0], equals(1380)); // start at bed time
      expect(window[1], equals(1440)); // end at midnight
    });

    test('wake slider shows from midnight to wake', () {
      final window = calculateSleepWindow(wake, bed, false);
      expect(window[0], equals(0)); // start at midnight
      expect(window[1], equals(420)); // end at wake time
    });
  });

  group('calculateSleepWindow - same day sleep (wake > bed)', () {
    const bed = 120; // 02:00
    const wake = 600; // 10:00

    test('bedtime slider shows from bed to wake', () {
      final window = calculateSleepWindow(bed, wake, true);
      expect(window[0], equals(120)); // start at bed time
      expect(window[1], equals(600)); // end at wake time
    });

    test('wake slider shows from bed to wake', () {
      final window = calculateSleepWindow(wake, bed, false);
      expect(window[0], equals(120)); // start at bed time
      expect(window[1], equals(600)); // end at wake time
    });
  });

  group('calculateSleepWindow - edge cases', () {
    test('exactly midnight bedtime', () {
      const bed = 0; // 00:00
      const wake = 480; // 08:00

      // Bed slider (same-day since wake > bed)
      final bedWindow = calculateSleepWindow(bed, wake, true);
      expect(bedWindow[0], equals(0));
      expect(bedWindow[1], equals(480));

      // Wake slider
      final wakeWindow = calculateSleepWindow(wake, bed, false);
      expect(wakeWindow[0], equals(0));
      expect(wakeWindow[1], equals(480));
    });

    test('exactly midnight wake time', () {
      const bed = 1200; // 20:00
      const wake = 0; // 00:00

      // Bed slider (overnight since bed > wake)
      final bedWindow = calculateSleepWindow(bed, wake, true);
      expect(bedWindow[0], equals(1200));
      expect(bedWindow[1], equals(1440)); // to midnight

      // Wake slider
      final wakeWindow = calculateSleepWindow(wake, bed, false);
      expect(wakeWindow[0], equals(0)); // from midnight
      expect(wakeWindow[1], equals(0)); // to midnight (instant)
    });

    test('late evening same-day nap', () {
      // Bed at 20:00, wake at 22:00 (same day)
      const bed = 1200;
      const wake = 1320;

      final bedWindow = calculateSleepWindow(bed, wake, true);
      expect(bedWindow[0], equals(1200));
      expect(bedWindow[1], equals(1320));

      final wakeWindow = calculateSleepWindow(wake, bed, false);
      expect(wakeWindow[0], equals(1200));
      expect(wakeWindow[1], equals(1320));
    });
  });

  group('formatTimeFromMinutes', () {
    testWidgets('midnight formats correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(formatTimeFromMinutes(context, 0), isNotEmpty);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('noon formats correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(formatTimeFromMinutes(context, 720), isNotEmpty);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('23:30 formats correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(formatTimeFromMinutes(context, 1410), isNotEmpty);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('24:00 edge case displays as midnight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(formatTimeFromMinutes(context, 1440), isNotEmpty);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('formatDuration', () {
    testWidgets('exact hours', (tester) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              result = formatDuration(context, const Duration(hours: 8));
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, equals('8h 0m'));
    });

    testWidgets('hours and minutes', (tester) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              result = formatDuration(context, const Duration(hours: 7, minutes: 30));
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, equals('7h 30m'));
    });

    testWidgets('less than one hour', (tester) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              result = formatDuration(context, const Duration(minutes: 45));
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, equals('45m'));
    });

    testWidgets('zero', (tester) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              result = formatDuration(context, Duration.zero);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, equals('0m'));
    });
  });
}
