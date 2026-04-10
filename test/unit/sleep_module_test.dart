/// Unit tests for Sleep Module logic
import 'package:flutter_test/flutter_test.dart';
import 'package:baseline/modules/sleep_module.dart';

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
    test('midnight', () {
      expect(formatTimeFromMinutes(0), equals('00:00'));
    });

    test('noon', () {
      expect(formatTimeFromMinutes(720), equals('12:00'));
    });

    test('23:30', () {
      expect(formatTimeFromMinutes(1410), equals('23:30'));
    });

    test('with minutes', () {
      expect(formatTimeFromMinutes(630), equals('10:30'));
    });

    test('24:00 edge case displays as 00:00', () {
      expect(formatTimeFromMinutes(1440), equals('00:00'));
    });

    test('beyond 24:00 wraps to 00:00', () {
      expect(formatTimeFromMinutes(1450), equals('00:00'));
    });
  });

  group('formatDuration', () {
    test('exact hours', () {
      expect(formatDuration(const Duration(hours: 8)), equals('8h 0m'));
    });

    test('hours and minutes', () {
      expect(formatDuration(const Duration(hours: 7, minutes: 30)), equals('7h 30m'));
    });

    test('less than one hour', () {
      expect(formatDuration(const Duration(minutes: 45)), equals('45m'));
    });

    test('zero', () {
      expect(formatDuration(Duration.zero), equals('0m'));
    });
  });
}
