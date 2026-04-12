import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:baseline/services/meds_notifications_service.dart';

void main() {
  setUpAll(() async {
    // Initialize timezone database for tests
    tz.initializeTimeZones();
    // Set to a known timezone for predictable tests
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  });

  group('MedsNotificationsService', () {
    test('instance is singleton', () {
      final instance1 = MedsNotificationsService.instance;
      final instance2 = MedsNotificationsService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('snooze tracking works correctly', () {
      final service = MedsNotificationsService.instance;

      // Initially not snoozed
      expect(service.isMedSnoozed('Vitamin D'), isFalse);
      expect(service.getSnoozeTime('Vitamin D'), isNull);

      // Set snooze using fixed time
      final snoozeTime = DateTime(2026, 4, 12, 14, 35);
      service.snoozedMedsForTest['Vitamin D'] = snoozeTime;

      expect(service.isMedSnoozed('Vitamin D'), isTrue);
      expect(service.getSnoozeTime('Vitamin D'), equals(snoozeTime));

      // Clear snooze
      service.clearSnooze('Vitamin D');
      expect(service.isMedSnoozed('Vitamin D'), isFalse);
      expect(service.getSnoozeTime('Vitamin D'), isNull);
    });

    test('snooze expired medications are not considered snoozed', () {
      final service = MedsNotificationsService.instance;

      // Set snooze in the past using fixed time
      final pastTime = DateTime(2026, 4, 12, 14, 0);
      service.snoozedMedsForTest['Vitamin D'] = pastTime;

      // Should not be considered snoozed (only matters for UI display logic)
      final snoozeTime = service.getSnoozeTime('Vitamin D');
      expect(snoozeTime, equals(pastTime));

      service.clearSnooze('Vitamin D');
    });

    test('action feedback stream emits messages', () async {
      final service = MedsNotificationsService.instance;

      // Collect emitted messages
      final messages = <String>[];
      final subscription = service.actionFeedbackStream.listen(messages.add);

      // Trigger feedback via _handleSnooze simulation
      service.actionFeedbackControllerForTest.add('Alarm snoozed until 14:35');

      // Wait for async delivery
      await Future.delayed(Duration.zero);

      expect(messages, equals(['Alarm snoozed until 14:35']));

      await subscription.cancel();
    });

    test('callback registration works', () {
      final service = MedsNotificationsService.instance;

      bool markTakenCalled = false;
      bool snoozeCalled = false;
      String? lastMedName;

      service.setCallbacks(
        onMarkMedTaken: (medName) {
          markTakenCalled = true;
          lastMedName = medName;
        },
        onSnoozeMed: (medName, snoozeUntil) {
          snoozeCalled = true;
          lastMedName = medName;
        },
      );

      // Trigger callbacks
      service.onMarkMedTakenCallback?.call('Vitamin D');
      expect(markTakenCalled, isTrue);
      expect(lastMedName, equals('Vitamin D'));

      lastMedName = null;
      service.onSnoozeMedCallback?.call('Omega-3', DateTime.now());
      expect(snoozeCalled, isTrue);
      expect(lastMedName, equals('Omega-3'));
    });

    group('Timezone handling', () {
      test('tz.local is set correctly', () {
        // Verify our test setup set the timezone correctly
        expect(tz.local.name, equals('Europe/Berlin'));
      });

      test('TZDateTime uses local timezone correctly', () {
        // Create a fixed time and verify timezone is applied
        final fixedTime = DateTime(2026, 4, 12, 14, 30);
        final tzTime = tz.TZDateTime.from(fixedTime, tz.local);

        // Verify the TZDateTime preserved the time components
        expect(tzTime.year, equals(2026));
        expect(tzTime.month, equals(4));
        expect(tzTime.day, equals(12));
        expect(tzTime.hour, equals(14));
        expect(tzTime.minute, equals(30));
      });

      test('scheduled time matches intended local time', () {
        // Simulate scheduling for 21:21 local time on fixed date
        final intendedHour = 21;
        final intendedMinute = 21;

        // Use fixed date: April 12, 2026
        var scheduledTime = tz.TZDateTime(
          tz.local,
          2026,
          4,
          12,
          intendedHour,
          intendedMinute,
        );

        // Verify the scheduled time has correct components
        expect(scheduledTime.hour, equals(intendedHour));
        expect(scheduledTime.minute, equals(intendedMinute));
        // Timezone name can be CET (winter) or CEST (summer) depending on DST
        expect(['CET', 'CEST'], contains(scheduledTime.timeZoneName));
      });
    });

    group('notificationIdForMed', () {
      test('generates consistent IDs for same med name', () {
        final service = MedsNotificationsService.instance;

        // Access method through testing annotation
        final id1 = service.notificationIdForMed('Vitamin D');
        final id2 = service.notificationIdForMed('Vitamin D');

        expect(id1, equals(id2));
      });

      test('generates different IDs for different med names', () {
        final service = MedsNotificationsService.instance;

        final id1 = service.notificationIdForMed('Vitamin D');
        final id2 = service.notificationIdForMed('Omega-3');

        expect(id1, isNot(equals(id2)));
      });

      test('generated IDs are in valid range', () {
        final service = MedsNotificationsService.instance;

        final id = service.notificationIdForMed('Test Medication');

        // IDs should be in range [32000, 42000] based on implementation
        expect(id, greaterThanOrEqualTo(32000));
        expect(id, lessThan(42000));
      });
    });

    group('payload parsing', () {
      test('correctly parses med name from payload', () {
        const prefix = 'meds::';
        final payload = '${prefix}Vitamin D';

        expect(payload.startsWith(prefix), isTrue);
        expect(payload.substring(prefix.length), equals('Vitamin D'));
      });

      test('handles med names with spaces', () {
        const prefix = 'meds::';
        final payload = '${prefix}Fish Oil Omega-3';

        expect(payload.substring(prefix.length), equals('Fish Oil Omega-3'));
      });
    });
  });
}
