import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../services/meds_notifications_service.dart';
import '../services/timer_service.dart';
import '../services/real_timer_service.dart';
import '../theme/theme.dart';
import '../modules/mental_state_constants.dart';
import '../modules/meds_module.dart' as meds_module;
import 'today_state.dart';
import 'settings.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  late Box<TodayState> todayBox;
  late Box<Settings> settingsBox;
  TodayState todayState = TodayState();
  Settings settings = Settings();

  final TimerService _timerService;
  TimerHandle? _themeScheduleTimerHandle;
  TimerHandle? _dayBoundaryTimerHandle;

  // Guard against concurrent day boundary resets.
  bool _isApplyingBoundary = false;
  // Used for detecting large system clock jumps.
  DateTime? _lastSeenNow;

  AppState({TimerService? timerService})
      : _timerService = timerService ?? RealTimerService() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      todayBox = Hive.box<TodayState>('todayState');
      settingsBox = Hive.box<Settings>('settings');

      if (todayBox.isEmpty) {
        todayState = TodayState();
        await todayBox.put('today', todayState);
      } else {
        todayState = todayBox.get('today')!;
      }

      if (settingsBox.isEmpty) {
        settings = Settings();
        await settingsBox.put('settings', settings);
      } else {
        settings = settingsBox.get('settings')!;
      }

      if (settings.ensureBaselineModuleDefaults()) {
        await settingsBox.put('settings', settings);
      }
    } catch (e, stack) {
      debugPrint('AppState initialization error: $e\n$stack');
      // Fallback: use in-memory defaults if Hive fails.
      todayState = TodayState();
      settings = Settings();
    }

    await _applyBackgroundPending();

    _applyDayBoundary();
    _scheduleThemeTimer();
    _scheduleDayBoundaryCheck();

    // Register notification action callbacks.
    MedsNotificationsService.instance.setCallbacks(
      onMarkMedTaken: (medName) {
        todayState.medsChecked[medName] = true;
        todayState.medsSnoozeEpochs.remove(medName);
        _saveTodayState();
        notifyListeners();
      },
      onSnoozeMed: (medName, snoozeUntil) {
        todayState.medsSnoozeEpochs[medName] =
            snoozeUntil.millisecondsSinceEpoch;
        _saveTodayState();
        notifyListeners();
      },
    );

    unawaited(_syncNotifications());
    notifyListeners();
  }

  // Helper to persist todayState with error handling.
  void _saveTodayState() {
    try {
      // Guard against uninitialized boxes if _init() failed
      if (!Hive.isBoxOpen('todayState')) return;
      todayBox.put('today', todayState);
    } catch (e) {
      debugPrint('Failed to save todayState: $e');
    }
  }

  // Helper to persist settings with error handling.
  void _saveSettings() {
    try {
      // Guard against uninitialized boxes if _init() failed
      if (!Hive.isBoxOpen('settings')) return;
      settingsBox.put('settings', settings);
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  // Synchronizes medication notifications with the service.
  Future<void> _syncNotifications() async {
    try {
      await MedsNotificationsService.instance.syncFromSettings(
        settings,
        isMedTaken: (medName) => meds_module.isMedTakenToday(this, medName),
        getMedSnoozeTime: (medName) {
          final epoch = todayState.medsSnoozeEpochs[medName];
          return epoch == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(epoch);
        },
      );
    } catch (e) {
      debugPrint('Failed to sync notifications: $e');
    }
  }

  /// Returns the reset time to use for day boundary calculations.
  /// Currently uses the constant placeholder; replace with settings.dayResetTime
  /// once UI is ready.
  TimeOfDay _effectiveDayResetTime() {
    return kDefaultDayResetTime;
  }

  /// Calculates the next DateTime when the day reset should occur.
  /// Preserves the timezone of the input to handle DST transitions correctly.
  DateTime _nextResetDateTime(DateTime from) {
    final resetTime = _effectiveDayResetTime();
    // Use from.toLocal() to ensure we work in local time, preserving timezone
    final localFrom = from.toLocal();
    var candidate = DateTime(
      localFrom.year,
      localFrom.month,
      localFrom.day,
      resetTime.hour,
      resetTime.minute,
    );
    if (!candidate.isAfter(localFrom)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Checks if the day has changed relative to the configured reset time and
  /// resets [todayState] accordingly. Notifies listeners when a reset occurs.
  void _applyDayBoundary() {
    if (_isApplyingBoundary) return;
    _isApplyingBoundary = true;
    try {
      final now = clock.now();
      final todayKey = TodayState.dayKeyFor(now, resetTime: _effectiveDayResetTime());

      if (todayState.lastDayKey.isEmpty) {
        todayState.lastDayKey = todayKey;
        todayState.thoughtLensIndex =
            MentalStateConstants.getRandomDistortionIndex(-1);
        _saveTodayState();
      } else if (todayState.lastDayKey != todayKey) {
        final yesterdayIndex = todayState.thoughtLensIndex;
        todayState = TodayState()..lastDayKey = todayKey;
        todayState.thoughtLensIndex =
            MentalStateConstants.getRandomDistortionIndex(yesterdayIndex);
        todayState.yesterdayThoughtLensIndex = yesterdayIndex;
        _saveTodayState();
        // Notify listeners and sync notifications after a day change.
        notifyListeners();
        unawaited(_syncNotifications());
      }
      _lastSeenNow = now;
    } finally {
      _isApplyingBoundary = false;
    }
  }

  /// Schedules a one-shot timer that fires exactly at the next day reset time,
  /// then reschedules itself for the following day.
  void _scheduleDayBoundaryCheck() {
    _dayBoundaryTimerHandle?.cancel();

    final now = clock.now();
    final nextReset = _nextResetDateTime(now);
    final delay = nextReset.difference(now);

    _dayBoundaryTimerHandle = _timerService.createOneShot(
      // If delay is zero or negative (should rarely happen), fire in 1 second.
      delay <= Duration.zero ? const Duration(seconds: 1) : delay,
      () {
        // Ensure next check is always scheduled even if processing fails
        try {
          // Check for large clock jumps before applying boundary.
          // _checkForClockJump may call _applyDayBoundary if clock jump detected.
          _checkForClockJump();
          // Only apply boundary if not already applied by clock jump check
          if (!_isApplyingBoundary) {
            _applyDayBoundary();
          }
        } finally {
          // Always schedule the next day's reset, even on error
          _scheduleDayBoundaryCheck();
        }
      },
    );
  }

  /// Detects jumps in system time (e.g., manual clock change, timezone shift)
  /// and forces a day boundary check if a significant jump is detected.
  void _checkForClockJump() {
    final now = clock.now();
    if (_lastSeenNow != null) {
      final difference = now.difference(_lastSeenNow!).abs();
      if (difference > const Duration(minutes: 5)) {
        debugPrint('Detected clock jump of $difference; forcing day boundary check.');
        _applyDayBoundary();
      }
    }
    _lastSeenNow = now;
  }

  /// Clears all of today's activity but keeps the current calendar day bucket.
  void resetTodayManual() {
    final todayKey = TodayState.dayKeyFor(clock.now(), resetTime: _effectiveDayResetTime());
    todayState = TodayState()..lastDayKey = todayKey;
    _saveTodayState();
    notifyListeners();
  }

  void resetAllData() {
    settings = Settings();
    todayState = TodayState();
    _saveSettings();
    _saveTodayState();

    // Cancel and reschedule timers.
    _scheduleThemeTimer();
    _scheduleDayBoundaryCheck();

    // Reset clock jump detection.
    _lastSeenNow = null;
    _applyDayBoundary();

    unawaited(_syncNotifications());
    notifyListeners();
  }

  void updateTodayState(void Function(TodayState) updater) {
    updater(todayState);
    _saveTodayState();
    notifyListeners();
  }

  void updateSettings(void Function(Settings) updater) {
    updater(settings);
    _saveSettings();
    _scheduleThemeTimer();
    // If dayResetTime changes in the future, this will reschedule correctly.
    _scheduleDayBoundaryCheck();
    unawaited(_syncNotifications());
    notifyListeners();
  }

  ThemeData get lightTheme => BaselineTheme.lightTheme(settings);

  ThemeData get darkTheme => BaselineTheme.darkTheme(settings);

  ThemeMode get materialThemeMode {
    return BaselineTheme.materialThemeMode(settings, now: clock.now());
  }

  String resolvedThemeKey({DateTime? now, Brightness? platformBrightness}) {
    return BaselineTheme.resolvedThemeKey(
      settings,
      now: now,
      platformBrightness: platformBrightness,
    );
  }

  ThemeData get currentTheme {
    return BaselineTheme.currentTheme(settings, now: clock.now());
  }

  @override
  void didChangePlatformBrightness() {
    if (settings.themeMode == Settings.themeModeDevice) {
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onResumed());
    }
  }

  Future<void> _onResumed() async {
    // Apply any actions handled by the background notification isolate.
    await _applyBackgroundPending();
    // Day may have changed while suspended.
    _applyDayBoundary();
    unawaited(_syncNotifications());
  }

  Future<void> _applyBackgroundPending() async {
    try {
      final box = await Hive.openBox<String>('bgPending');
      bool changed = false;

      final rawTaken = box.get('markTaken');
      if (rawTaken != null && rawTaken.isNotEmpty) {
        await box.delete('markTaken');
        final meds = List<String>.from(jsonDecode(rawTaken));
        for (final med in meds) {
          if (med.isNotEmpty) {
            todayState.medsChecked[med] = true;
            todayState.medsSnoozeEpochs.remove(med);
          }
        }
        if (meds.isNotEmpty) {
          todayState.medsTaken = todayState.medsChecked.values.any((v) => v);
          changed = true;
        }
      }

      final rawSnooze = box.get('snoozedMeds');
      if (rawSnooze != null && rawSnooze.isNotEmpty) {
        await box.delete('snoozedMeds');
        final map = Map<String, dynamic>.from(jsonDecode(rawSnooze));
        for (final entry in map.entries) {
          final epoch = entry.value as int?;
          if (epoch != null) todayState.medsSnoozeEpochs[entry.key] = epoch;
        }
        changed = true;
      }

      if (changed) {
        _saveTodayState();
        notifyListeners();
      }

      // Close so the next open reads fresh from disk (skip for in-memory test boxes).
      if (box.path != null) await box.close();
    } catch (e) {
      debugPrint('Failed to apply background pending: $e');
    }
  }

  @override
  void dispose() {
    _themeScheduleTimerHandle?.cancel();
    _dayBoundaryTimerHandle?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleThemeTimer() {
    _themeScheduleTimerHandle?.cancel();
    if (settings.themeMode != Settings.themeModeSchedule) {
      return;
    }

    final now = clock.now();
    final nextBoundary = BaselineTheme.nextThemeBoundary(settings, now);
    final delay = nextBoundary.difference(now);

    _themeScheduleTimerHandle = _timerService.createOneShot(
      delay <= Duration.zero ? const Duration(minutes: 1) : delay,
      () {
        _scheduleThemeTimer();
        notifyListeners();
      },
    );
  }
}