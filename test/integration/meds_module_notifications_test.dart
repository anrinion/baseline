import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:baseline/modules/meds_module.dart';
import 'package:baseline/services/meds_notifications_service.dart';
import 'package:baseline/state/app_state.dart';
import 'package:baseline/state/settings.dart';
import 'package:baseline/state/today_state.dart';

import '../test_helpers.dart';

/// Mock adapter to capture notification interactions
class MockNotificationAdapter implements NotificationAdapter {
  final List<ScheduledNotification> scheduled = [];
  final List<int> cancelledIds = [];
  final List<ActiveNotification> activeNotifications = [];

  @override
  Future<void> initialize(
    InitializationSettings settings, {
    NotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {}

  @override
  Future<void> createNotificationChannel(AndroidNotificationChannel channel) async {}

  @override
  Future<bool?> requestAndroidNotificationPermission() async => true;

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    scheduled.removeWhere((s) => s.id == id);
    scheduled.add(ScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    ));
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    scheduled.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return scheduled
        .map((s) => PendingNotificationRequest(s.id, s.title, s.body, s.payload))
        .toList();
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => activeNotifications;

  @override
  Future<void> show(int id, String? title, String? body, NotificationDetails? notificationDetails) async {}

  void clear() {
    scheduled.clear();
    cancelledIds.clear();
    activeNotifications.clear();
  }

  bool isScheduled(int id) => scheduled.any((s) => s.id == id);
  tz.TZDateTime? getScheduledTime(int id) {
    try {
      return scheduled.firstWhere((s) => s.id == id).scheduledDate;
    } catch (e) {
      return null;
    }
  }
}

class ScheduledNotification {
  final int id;
  final String? title;
  final String? body;
  final tz.TZDateTime scheduledDate;
  final String? payload;

  ScheduledNotification({required this.id, this.title, this.body, required this.scheduledDate, this.payload});
}

void main() {
  setUpAll(() async {
    await initTestHive();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Meds Module + Notifications Integration', () {
    late AppState appState;
    late MockNotificationAdapter mockAdapter;
    late MedsNotificationsService service;

    setUp(() async {
      appState = await createTestAppState();
      mockAdapter = MockNotificationAdapter();
      service = MedsNotificationsService.instance;
      service.setAdapterForTest(mockAdapter);
      service.forceAvailableForTest();
      service.setTestTimezone('Europe/Berlin');
      service.setCallbacks(
        onMarkMedTaken: (medName) => setMedTakenToday(appState, medName, true),
        onSnoozeMed: (medName, snoozeUntil) {},
      );
      mockAdapter.clear();
    });

    tearDown(() {
      service.setAdapterForTest(FlutterNotificationAdapter(FlutterLocalNotificationsPlugin()));
    });

    test('1. Set alarm -> mark med as taken -> alarm cancelled', () async {
      final medName = 'Vitamin D';
      final medId = service.notificationIdForMed(medName);

      // Set up medication with reminder
      setMedsList(appState, [medName]);
      setMedsReminderMinutesForMedOnSettings(appState.settings, medName, 480); // 8:00 AM

      // Sync to schedule alarm
      await service.syncFromSettings(
        appState.settings,
        isMedTaken: (m) => isMedTakenToday(appState, m),
      );

      // Verify alarm scheduled
      expect(mockAdapter.isScheduled(medId), isTrue, reason: 'Alarm should be scheduled');

      // Mark med as taken via module
      setMedTakenToday(appState, medName, true);

      // Wait for async cancel to complete
      await Future.delayed(Duration.zero);

      // Verify alarm was cancelled
      expect(mockAdapter.cancelledIds.contains(medId), isTrue, reason: 'Alarm should be cancelled when taken');
      expect(mockAdapter.isScheduled(medId), isFalse, reason: 'Alarm should not be in scheduled list');
    });

    test('2. Set alarm -> snooze -> mark taken -> no snooze, alarm cancelled', () async {
      final medName = 'Omega-3';
      final medId = service.notificationIdForMed(medName);

      // Set up medication
      setMedsList(appState, [medName]);
      setMedsReminderMinutesForMedOnSettings(appState.settings, medName, 480);

      // Schedule
      await service.syncFromSettings(
        appState.settings,
        isMedTaken: (m) => isMedTakenToday(appState, m),
      );
      expect(mockAdapter.isScheduled(medId), isTrue);

      // Simulate snooze
      service.snoozedMedsForTest[medName] = DateTime.now().add(const Duration(minutes: 10));
      expect(service.isMedSnoozed(medName), isTrue);

      // Mark as taken
      setMedTakenToday(appState, medName, true);

      // Wait for async cancel to complete
      await Future.delayed(Duration.zero);

      // Verify snooze cleared and alarm cancelled
      expect(service.isMedSnoozed(medName), isFalse, reason: 'Snooze should be cleared');
      expect(mockAdapter.cancelledIds.contains(medId), isTrue, reason: 'Alarm should be cancelled');
    });

    test('4. Mark taken -> reschedule alarm for later today -> no alarm today', () async {
      final medName = 'B12';
      final medId = service.notificationIdForMed(medName);

      // Set up and mark as taken
      setMedsList(appState, [medName]);
      setMedsReminderMinutesForMedOnSettings(appState.settings, medName, 480);
      setMedTakenToday(appState, medName, true);
      expect(isMedTakenToday(appState, medName), isTrue);

      // Sync (simulates user modifying alarm time after marking taken)
      await service.syncFromSettings(
        appState.settings,
        isMedTaken: (m) => isMedTakenToday(appState, m),
      );

      // Verify alarm scheduled for tomorrow, not today
      final scheduledTime = mockAdapter.getScheduledTime(medId);
      expect(scheduledTime, isNotNull);

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(scheduledTime!.day, equals(tomorrow.day), reason: 'Should schedule for tomorrow, not today');
    });

    test('5. Taken -> set alarm for later today -> no alarm today', () async {
      final medName = 'Iron';
      final medId = service.notificationIdForMed(medName);

      // Mark as taken first
      setMedsList(appState, [medName]);
      setMedTakenToday(appState, medName, true);

      // Now set alarm for today (in the future)
      final now = DateTime.now();
      final futureMinutes = now.hour * 60 + now.minute + 30; // 30 min from now
      setMedsReminderMinutesForMedOnSettings(appState.settings, medName, futureMinutes);

      // Sync
      await service.syncFromSettings(
        appState.settings,
        isMedTaken: (m) => isMedTakenToday(appState, m),
      );

      // Should schedule for tomorrow since already taken
      final scheduledTime = mockAdapter.getScheduledTime(medId);
      expect(scheduledTime, isNotNull);
      expect(scheduledTime!.day, isNot(equals(now.day)), reason: 'Should not schedule for today when already taken');
    });

    test('6. Alarm -> snooze -> reschedule for later -> snooze preserved -> mark taken -> all cleared', () async {
      final medName = 'Magnesium';
      final medId = service.notificationIdForMed(medName);

      // Set up and schedule
      setMedsList(appState, [medName]);
      setMedsReminderMinutesForMedOnSettings(appState.settings, medName, 480);
      await service.syncFromSettings(
        appState.settings,
        isMedTaken: (m) => isMedTakenToday(appState, m),
      );

      // Snooze
      service.snoozedMedsForTest[medName] = DateTime.now().add(const Duration(minutes: 10));
      expect(service.isMedSnoozed(medName), isTrue);

      // Reschedule alarm for later time
      final now = DateTime.now();
      final laterMinutes = now.hour * 60 + now.minute + 60; // 1 hour from now
      setMedsReminderMinutesForMedOnSettings(appState.settings, medName, laterMinutes);

      // Re-sync (this should preserve snooze and reschedule)
      await service.syncFromSettings(
        appState.settings,
        isMedTaken: (m) => isMedTakenToday(appState, m),
      );

      // Snooze should still be active
      expect(service.isMedSnoozed(medName), isTrue, reason: 'Snooze should be preserved after reschedule');

      // Mark as taken
      setMedTakenToday(appState, medName, true);

      // Wait for async cancel to complete
      await Future.delayed(Duration.zero);

      // Both snooze and alarm should be cleared
      expect(service.isMedSnoozed(medName), isFalse, reason: 'Snooze should be cleared');
      expect(mockAdapter.cancelledIds.contains(medId), isTrue, reason: 'Alarm should be cancelled');
    });
  });
}
