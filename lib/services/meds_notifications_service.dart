import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../modules/meds_module.dart';
import '../state/settings.dart';

class MedsNotificationsService {
  MedsNotificationsService._();

  static final MedsNotificationsService instance = MedsNotificationsService._();

  static const String _medsPayloadPrefix = 'meds::';
  static const String _channelId = 'baseline_meds_reminders';
  static const String _channelName = 'Medication alarms';
  static const String _channelDescription =
      'Daily alarm-like reminders for medication check-ins.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _isAvailable = true;
  String _statusCode = 'not_initialized';
  final ValueNotifier<String> _statusNotifier = ValueNotifier<String>(
    'not_initialized',
  );

  String get statusCode => _statusCode;
  ValueListenable<String> get statusListenable => _statusNotifier;

  bool get isAvailable => _isAvailable;

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

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(initializationSettings);

      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
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
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final androidGranted = await androidImplementation
          ?.requestNotificationsPermission();
      if (androidGranted != null) {
        granted = granted && androidGranted;
      }
      await androidImplementation?.requestExactAlarmsPermission();

      final iosImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final iosGranted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosGranted != null) {
        granted = granted && iosGranted;
      }

      final macImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final macGranted = await macImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (macGranted != null) {
        granted = granted && macGranted;
      }
    } on MissingPluginException {
      _isAvailable = false;
      _setStatus('plugin_missing');
      return false;
    } on PlatformException {
      _isAvailable = false;
      _setStatus('platform_error');
      return false;
    } catch (_) {
      _isAvailable = false;
      _setStatus('error');
      return false;
    }

    _setStatus(granted ? 'ready' : 'permission_denied');
    return granted;
  }

  Future<void> syncFromSettings(Settings settings) async {
    await ensureInitialized();
    if (!_isAvailable) return;

    try {
      await _cancelAllMedsNotifications();

      final reminders = medsReminderMinutesByMedFromSettings(settings);
      if (reminders.isEmpty) {
        _setStatus('disabled');
        return;
      }

      for (final entry in reminders.entries) {
        final medName = entry.key;
        final minutes = entry.value;
        final now = tz.TZDateTime.now(tz.local);
        var nextSchedule = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          minutes ~/ 60,
          minutes % 60,
        );
        if (!nextSchedule.isAfter(now)) {
          nextSchedule = nextSchedule.add(const Duration(days: 1));
        }

        await _plugin.zonedSchedule(
          _notificationIdForMed(medName),
          _titleForLanguage(settings.language, medName),
          _bodyForLanguage(settings.language),
          nextSchedule,
          const NotificationDetails(
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
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: '$_medsPayloadPrefix$medName',
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
    final pending = await _plugin.pendingNotificationRequests();
    for (final req in pending) {
      final payload = req.payload ?? '';
      if (payload.startsWith(_medsPayloadPrefix)) {
        await _plugin.cancel(req.id);
      }
    }
  }

  int _notificationIdForMed(String medName) {
    const base = 32000;
    const spread = 10000;
    var hash = 5381;
    for (final code in medName.codeUnits) {
      hash = ((hash << 5) + hash) + code;
    }
    return base + (hash.abs() % spread);
  }

  String _titleForLanguage(String languageCode, String medName) {
    if (languageCode == 'ru') {
      return 'Лекарство: $medName';
    }
    return 'Medication: $medName';
  }

  String _bodyForLanguage(String languageCode) {
    if (languageCode == 'ru') {
      return 'Пора отметить это лекарство на сегодня.';
    }
    return 'Time to mark this medication for today.';
  }
}
