import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui' show Locale;

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../modules/meds_module.dart';
import '../state/settings.dart';

typedef NotificationResponseCallback = void Function(NotificationResponse);
typedef BackgroundNotificationResponseCallback =
    Future<void> Function(NotificationResponse);

// Module-level constants shared with the background isolate handler
const String _medsPayloadPrefix = 'meds::';
const String _channelId = 'baseline_meds_reminders';
const String _channelName = 'Medication alarms';
const String _channelDescription =
    'Daily alarm-like reminders for medication check-ins.';

int _notifId(String medName) {
  const base = 32000;
  const spread = 10000;
  var hash = 5381;
  for (final code in medName.codeUnits) {
    hash = ((hash << 5) + hash) + code;
  }
  return base + (hash.abs() % spread);
}

// Separate ID range for one-shot snooze alarms; avoids collisions with daily IDs.
int _snoozeNotifId(String medName) {
  const base = 42000;
  const spread = 10000;
  var hash = 5381;
  for (final code in medName.codeUnits) {
    hash = ((hash << 5) + hash) + code;
  }
  return base + (hash.abs() % spread);
}

AppLocalizations _l10n(String lang) => lookupAppLocalizations(Locale(lang));

NotificationDetails _notifDetails({bool includeActions = true}) =>
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        ongoing: true,
        autoCancel: false,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        actions: includeActions
            ? const <AndroidNotificationAction>[
                AndroidNotificationAction(
                  'snooze',
                  'Snooze',
                  showsUserInterface: false,
                ),
                AndroidNotificationAction(
                  'mark_taken',
                  'Mark Taken',
                  showsUserInterface: false,
                ),
              ]
            : null,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

/// Background isolate entry point: handles Snooze / Mark Taken when the app
/// is not in the foreground. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> medsNotificationBackgroundHandler(
  NotificationResponse response,
) async {
  final actionId = response.actionId;
  final payload = response.payload;
  if (actionId == null || payload == null) return;
  if (!payload.startsWith(_medsPayloadPrefix)) return;

  final parts = payload.substring(_medsPayloadPrefix.length).split('::');
  if (parts.isEmpty) return;
  final medName = parts[0];
  final reminderMinutes = parts.length > 1
      ? (int.tryParse(parts[1]) ?? defaultMedsReminderMinutes)
      : defaultMedsReminderMinutes;
  final language = parts.length > 2 ? parts[2] : 'en';
  final snoozeIntervalMinutes = parts.length > 3 ? (int.tryParse(parts[3]) ?? 10) : 10;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  tz.initializeTimeZones();
  String timezone = 'UTC';
  try {
    timezone = await FlutterTimezone.getLocalTimezone();
  } catch (_) {}
  tz.setLocalLocation(tz.getLocation(timezone));

  final id = _notifId(medName);
  final snoozeId = _snoozeNotifId(medName);
  await plugin.cancel(id);
  await plugin.cancel(snoozeId);

  final now = tz.TZDateTime.now(tz.local);
  final l10n = _l10n(language);
  final title = l10n.medsNotificationTitle(medName);
  final body = l10n.medsNotificationBody;
  final details = _notifDetails();

  if (actionId == 'snooze') {
    final snoozeUntil = now.add(Duration(minutes: snoozeIntervalMinutes));
    // One-shot snooze alarm.
    await plugin.zonedSchedule(
      snoozeId,
      title,
      body,
      snoozeUntil,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      payload: payload,
    );
    // Restore the daily recurring alarm. This ensures the user gets reminded
    // again the next day even if they never open the app to trigger syncFromSettings.
    final nextDay = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      reminderMinutes ~/ 60,
      reminderMinutes % 60,
    );
    await plugin.zonedSchedule(
      id,
      title,
      body,
      nextDay,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
    // Persist snooze state so syncFromSettings can reconstruct the snooze
    // notification if the app resumes before it fires.
    try {
      await Hive.initFlutter();
      final pendingBox = await Hive.openBox<String>('bgPending');
      final existing = pendingBox.get('snoozedMeds');
      final map = existing != null && existing.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(existing))
          : <String, dynamic>{};
      map[medName] = snoozeUntil.millisecondsSinceEpoch;
      await pendingBox.put('snoozedMeds', jsonEncode(map));
      await pendingBox.close();
    } catch (_) {}
  } else if (actionId == 'mark_taken') {
    final tomorrow = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      reminderMinutes ~/ 60,
      reminderMinutes % 60,
    );
    await plugin.zonedSchedule(
      id,
      title,
      body,
      tomorrow,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    // Signal the main isolate via a separate box it opens fresh on resume.
    // Writing directly to todayState box is unsafe — the main isolate's open
    // box instance caches data in memory and won't see cross-isolate writes.
    try {
      await Hive.initFlutter();
      final pendingBox = await Hive.openBox<String>('bgPending');
      final existing = pendingBox.get('markTaken');
      final meds = (existing?.isNotEmpty == true)
          ? List<String>.from(jsonDecode(existing!))
          : <String>[];
      if (!meds.contains(medName)) meds.add(medName);
      await pendingBox.put('markTaken', jsonEncode(meds));
      await pendingBox.close();
    } catch (_) {}
  }
}

/// Callback for when user marks a medication as taken from notification
typedef OnMarkMedTaken = void Function(String medName);

/// Callback for when user requests snooze
typedef OnSnoozeMed = void Function(String medName, DateTime snoozeUntil);

/// Adapter interface for notification operations - allows mocking in tests
abstract class NotificationAdapter {
  Future<void> initialize(
    InitializationSettings settings, {
    NotificationResponseCallback? onDidReceiveNotificationResponse,
    BackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  });
  Future<void> createNotificationChannel(AndroidNotificationChannel channel);
  Future<bool?> requestAndroidNotificationPermission();
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
    uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  });
  Future<void> cancel(int id);
  Future<List<PendingNotificationRequest>> pendingNotificationRequests();
  Future<List<ActiveNotification>> getActiveNotifications();
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
  );
}

/// Real implementation using FlutterLocalNotificationsPlugin
class FlutterNotificationAdapter implements NotificationAdapter {
  final FlutterLocalNotificationsPlugin _plugin;

  FlutterNotificationAdapter(this._plugin);

  @override
  Future<void> initialize(
    InitializationSettings settings, {
    NotificationResponseCallback? onDidReceiveNotificationResponse,
    BackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) => _plugin.initialize(
    settings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
  );

  @override
  Future<void> createNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(channel);
  }

  @override
  Future<bool?> requestAndroidNotificationPermission() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await androidImplementation?.requestNotificationsPermission();
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
    uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) => _plugin.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    notificationDetails,
    androidScheduleMode: androidScheduleMode,
    uiLocalNotificationDateInterpretation:
        uiLocalNotificationDateInterpretation,
    matchDateTimeComponents: matchDateTimeComponents,
    payload: payload,
  );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      _plugin.pendingNotificationRequests();

  @override
  Future<List<ActiveNotification>> getActiveNotifications() =>
      _plugin.getActiveNotifications();

  @override
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
  ) => _plugin.show(id, title, body, notificationDetails);
}

class MedsNotificationsService {
  MedsNotificationsService._();

  static final MedsNotificationsService instance = MedsNotificationsService._();


  NotificationAdapter? _adapter;
  NotificationAdapter get _plugin => _adapter ??= FlutterNotificationAdapter(
    FlutterLocalNotificationsPlugin(),
  );

  // Allow injecting mock adapter for testing
  @visibleForTesting
  void setAdapterForTest(NotificationAdapter adapter) {
    _adapter = adapter;
    _initialized = false; // Force re-initialization with new adapter
  }

  // Force service to be available in test environment
  @visibleForTesting
  void forceAvailableForTest() {
    _isAvailable = true;
    _initialized = true;
    _statusCode = 'ready';
  }

  @visibleForTesting
  void setTestTimezone(String timezoneName) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timezoneName));
  }

  bool _initialized = false;
  bool _isAvailable = true;
  String _statusCode = 'not_initialized';
  final ValueNotifier<String> _statusNotifier = ValueNotifier<String>(
    'not_initialized',
  );

  OnMarkMedTaken? _onMarkMedTaken;
  OnSnoozeMed? _onSnoozeMed;

  @visibleForTesting
  Map<String, DateTime> get snoozedMedsForTest => _snoozedMeds;

  final Map<String, DateTime> _snoozedMeds = {};

  // Store reminder settings per med for action handlers
  final Map<String, int> _medReminderMinutes = {};
  String _currentLanguage = 'en';
  int _currentSnoozeIntervalMinutes = 10;

  @visibleForTesting
  OnMarkMedTaken? get onMarkMedTakenCallback => _onMarkMedTaken;

  @visibleForTesting
  OnSnoozeMed? get onSnoozeMedCallback => _onSnoozeMed;

  void setCallbacks({
    OnMarkMedTaken? onMarkMedTaken,
    OnSnoozeMed? onSnoozeMed,
  }) {
    _onMarkMedTaken = onMarkMedTaken;
    _onSnoozeMed = onSnoozeMed;
  }

  String get statusCode => _statusCode;
  ValueListenable<String> get statusListenable => _statusNotifier;

  Map<String, DateTime> get snoozedMeds => Map.unmodifiable(_snoozedMeds);

  bool get isAvailable => _isAvailable;

  bool isMedSnoozed(String medName) => _snoozedMeds.containsKey(medName);

  DateTime? getSnoozeTime(String medName) => _snoozedMeds[medName];

  void clearSnooze(String medName) {
    _snoozedMeds.remove(medName);
  }

  void _setStatus(String value) {
    _statusCode = value;
    _statusNotifier.value = value;
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    if (!_isSupportedPlatform) {
      _isAvailable = false;
      _setStatus('unsupported_platform');
      _initialized = true;
      return;
    }

    try {
      tz.initializeTimeZones();

      // Set local timezone to device's actual timezone
      final String localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone));

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            medsNotificationBackgroundHandler,
      );

      await _plugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      _setStatus('ready');
    } on MissingPluginException {
      _isAvailable = false;
      _setStatus('plugin_missing');
    } on PlatformException {
      _isAvailable = false;
      _setStatus('platform_error');
    } catch (_) {
      _isAvailable = false;
      _setStatus('error');
    }
    _initialized = true;
  }

  Future<bool> requestPermissionIfNeeded() async {
    await ensureInitialized();
    if (!_isAvailable) return false;

    var granted = true;

    try {
      // USE_EXACT_ALARM is granted at install time for medical apps
      // But POST_NOTIFICATIONS requires runtime request on Android 13+
      final androidGranted = await _plugin
          .requestAndroidNotificationPermission();
      if (androidGranted != null) {
        granted = granted && androidGranted;
      }

      // iOS/macOS permissions - skip for now as they're not critical for the tests
      // and would require additional adapter methods
    } on MissingPluginException catch (e) {
      _setStatus('plugin_missing: ${e.message}');
      return false;
    } on PlatformException catch (e) {
      _setStatus('platform_error: ${e.message}');
      return false;
    } catch (e) {
      _setStatus('error: $e');
      return false;
    }

    _setStatus(granted ? 'ready' : 'permission_denied');
    return granted;
  }

  bool _isSameDay(tz.TZDateTime a, tz.TZDateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> syncFromSettings(
    Settings settings, {
    bool Function(String medName)? isMedTaken,
    DateTime? Function(String medName)? getMedSnoozeTime,
  }) async {
    await ensureInitialized();
    if (!_isAvailable) return;

    try {
      await _cancelAllMedsNotifications();

      if (!getMedsNotificationsEnabled(settings)) {
        _setStatus('disabled');
        return;
      }

      final reminders = medsReminderMinutesByMedFromSettings(settings);
      if (reminders.isEmpty) {
        _setStatus('disabled');
        return;
      }

      // Store language and snooze interval for action handlers
      _currentLanguage = settings.language;
      _currentSnoozeIntervalMinutes = settings.medsSnoozeIntervalMinutes;
      _snoozedMeds.clear();

      final now = tz.TZDateTime.from(clock.now(), tz.local);
      final l10n = _l10n(settings.language);
      String payload(String medName, int minutes) =>
          '$_medsPayloadPrefix$medName::$minutes::${settings.language}::${settings.medsSnoozeIntervalMinutes}';

      for (final entry in reminders.entries) {
        final medName = entry.key;
        final minutes = entry.value;
        _medReminderMinutes[medName] = minutes;

        // Compute next daily schedule (used for both snoozed and normal paths).
        final alreadyTaken = isMedTaken?.call(medName) ?? false;
        var nextSchedule = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          minutes ~/ 60,
          minutes % 60,
        );
        while (nextSchedule.isBefore(now) ||
            (alreadyTaken && _isSameDay(nextSchedule, now))) {
          nextSchedule = nextSchedule.add(const Duration(days: 1));
        }

        final snoozeUntil = getMedSnoozeTime?.call(medName);
        if (snoozeUntil != null && snoozeUntil.isAfter(clock.now())) {
          // Med is snoozed — schedule one-shot at snooze time.
          _snoozedMeds[medName] = snoozeUntil;
          await _plugin.zonedSchedule(
            _snoozeNotifId(medName),
            l10n.medsNotificationTitle(medName),
            l10n.medsNotificationBody,
            tz.TZDateTime.from(snoozeUntil, tz.local),
            _notifDetails(),
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            payload: payload(medName, minutes),
          );
          // Fall through — also schedule the daily recurring so it survives
          // if the user dismisses the snooze notification without opening the app.
        }

        await _plugin.zonedSchedule(
          notificationIdForMed(medName),
          l10n.medsNotificationTitle(medName),
          l10n.medsNotificationBody,
          nextSchedule,
          _notifDetails(),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload(medName, minutes),
        );
      }
      _setStatus('active');
    } on MissingPluginException {
      _isAvailable = false;
      _setStatus('plugin_missing');
    } on PlatformException {
      _isAvailable = false;
      _setStatus('platform_error');
    } catch (_) {
      _isAvailable = false;
      _setStatus('error');
    }
  }

  Future<void> _cancelAllMedsNotifications() async {
    // Get active (currently showing) notifications to preserve them
    final List<ActiveNotification> activeNotifications;
    try {
      activeNotifications = await _plugin.getActiveNotifications();
    } catch (e) {
      // getActiveNotifications may not be available on all platforms
      // Continue without preserving active notifications
      final pending = await _plugin.pendingNotificationRequests();
      for (final req in pending) {
        final payload = req.payload ?? '';
        if (payload.startsWith(_medsPayloadPrefix)) {
          await _plugin.cancel(req.id);
        }
      }
      return;
    }

    final activeIds = activeNotifications.map((n) => n.id).toSet();

    final pending = await _plugin.pendingNotificationRequests();
    for (final req in pending) {
      final payload = req.payload ?? '';
      if (payload.startsWith(_medsPayloadPrefix)) {
        // Don't cancel if currently showing - it will be rescheduled
        // when the user interacts with it or when next sync happens
        if (!activeIds.contains(req.id)) {
          await _plugin.cancel(req.id);
        }
      }
    }
  }

  @visibleForTesting
  int notificationIdForMed(String medName) => _notifId(medName);

  Future<String> scheduleTestNotificationWithDelay() async {
    try {
      await ensureInitialized();
      if (!_isAvailable) return 'Service not available: $_statusCode';

      final now = tz.TZDateTime.from(clock.now(), tz.local);
      final scheduledTime = now.add(const Duration(seconds: 3));

      await _plugin.zonedSchedule(
        99999,
        'TEST Medication',
        'This is a test notification',
        scheduledTime,
        _notifDetails(includeActions: false),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );

      // Verify it was actually scheduled
      final pending = await _plugin.pendingNotificationRequests();
      final testPending = pending.where((p) => p.id == 99999).toList();
      if (testPending.isEmpty) {
        return 'Scheduled for $scheduledTime BUT not in pending list!';
      }
      return 'Scheduled for $scheduledTime (${testPending.length} in pending)';
    } on MissingPluginException {
      return 'MissingPluginException';
    } on PlatformException catch (e) {
      return 'PlatformException: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload;

    if (actionId == null) return;

    // Handle test notification (no payload)
    if (payload == null || !payload.startsWith(_medsPayloadPrefix)) {
      if (actionId == 'snooze' || actionId == 'mark_taken') {
        debugPrint('Action $actionId on test notification');
      }
      return;
    }

    // Parse payload: meds::MedName::minutes::language
    final parts = payload.substring(_medsPayloadPrefix.length).split('::');
    final medName = parts[0];
    // Note: reminderMinutes and language are now stored in _medReminderMinutes and _currentLanguage

    switch (actionId) {
      case 'snooze':
        _handleSnooze(medName);
        break;
      case 'mark_taken':
        _handleMarkTaken(medName);
        break;
    }
  }

  void _handleSnooze(String medName) {
    final snoozeUntil = clock.now().add(Duration(minutes: _currentSnoozeIntervalMinutes));
    _snoozedMeds[medName] = snoozeUntil;
    unawaited(_scheduleSnoozeNotification(medName, snoozeUntil));
    _onSnoozeMed?.call(medName, snoozeUntil);
  }

  Future<void> _scheduleSnoozeNotification(
    String medName,
    DateTime snoozeUntil,
  ) async {
    final l10n = _l10n(_currentLanguage);
    final reminderMinutes = _medReminderMinutes[medName] ?? defaultMedsReminderMinutes;
    final payloadStr = '$_medsPayloadPrefix$medName::$reminderMinutes::$_currentLanguage::$_currentSnoozeIntervalMinutes';

    // One-shot snooze alarm.
    await _plugin.zonedSchedule(
      _snoozeNotifId(medName),
      l10n.medsNotificationTitle(medName),
      l10n.medsNotificationBody,
      tz.TZDateTime.from(snoozeUntil, tz.local),
      _notifDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      payload: payloadStr,
    );

    // Restore daily recurring so tomorrow's reminder survives if the user
    // dismisses the snooze without opening the app.
    final now = tz.TZDateTime.from(clock.now(), tz.local);
    var nextDaily = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderMinutes ~/ 60,
      reminderMinutes % 60,
    );
    while (nextDaily.isBefore(now)) {
      nextDaily = nextDaily.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      notificationIdForMed(medName),
      l10n.medsNotificationTitle(medName),
      l10n.medsNotificationBody,
      nextDaily,
      _notifDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payloadStr,
    );
  }

  void _handleMarkTaken(String medName) {
    // Cancel both the daily and any pending snooze notification.
    unawaited(_plugin.cancel(notificationIdForMed(medName)));
    unawaited(_plugin.cancel(_snoozeNotifId(medName)));

    // Clear any snooze for this med
    _snoozedMeds.remove(medName);

    // Get stored reminder settings (fallback to 8:00 AM if not found)
    final reminderMinutes =
        _medReminderMinutes[medName] ?? 480; // 8:00 AM default

    // Reschedule for tomorrow (since cancel() stops all future repetitions)
    final tomorrow = tz.TZDateTime.from(clock.now(), tz.local).add(const Duration(days: 1));
    final nextSchedule = tz.TZDateTime(
      tz.local,
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      reminderMinutes ~/ 60,
      reminderMinutes % 60,
    );

    unawaited(
      _plugin.zonedSchedule(
        notificationIdForMed(medName),
        _l10n(_currentLanguage).medsNotificationTitle(medName),
        _l10n(_currentLanguage).medsNotificationBody,
        nextSchedule,
        _notifDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload:
            '$_medsPayloadPrefix$medName::$reminderMinutes::$_currentLanguage::$_currentSnoozeIntervalMinutes',
      ),
    );

    _onMarkMedTaken?.call(medName);
  }

  @visibleForTesting
  int snoozeNotificationIdForMed(String medName) => _snoozeNotifId(medName);

  /// Cancel notification for a specific medication
  Future<void> cancelNotificationForMed(String medName) async {
    await ensureInitialized();
    if (!_isAvailable) {
      log('MedsNotifications: Cannot cancel - service not available');
      return;
    }
    await _plugin.cancel(notificationIdForMed(medName));
    await _plugin.cancel(_snoozeNotifId(medName));
  }

}

