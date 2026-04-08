import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../theme/themes.dart';
import 'today_state.dart';
import 'settings.dart';

class AppState extends ChangeNotifier {
  late Box<TodayState> todayBox;
  late Box<Settings> settingsBox;
  TodayState todayState = TodayState();
  Settings settings = Settings();

  AppState() {
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

    _applyDayBoundary();
    notifyListeners();
  }

  /// If the calendar day changed since last save, wipe [todayState].
  /// Empty [lastDayKey] means migration or first run: stamp today without wiping.
  void _applyDayBoundary() {
    final todayKey = TodayState.dayKeyFor(DateTime.now());
    if (todayState.lastDayKey.isEmpty) {
      todayState.lastDayKey = todayKey;
      todayBox.put('today', todayState);
    } else if (todayState.lastDayKey != todayKey) {
      todayState = TodayState()..lastDayKey = todayKey;
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

  void updateTodayState(void Function(TodayState) updater) {
    updater(todayState);
    todayBox.put('today', todayState);
    notifyListeners();
  }

  void updateSettings(void Function(Settings) updater) {
    updater(settings);
    settingsBox.put('settings', settings);
    notifyListeners();
  }

  ThemeData get currentTheme {
    switch (settings.theme) {
      case 'light1':
        return BaselineThemes.light1();
      case 'light2':
        return BaselineThemes.light2();
      case 'dark1':
        return BaselineThemes.dark1();
      case 'dark2':
        return BaselineThemes.dark2();
      default:
        return BaselineThemes.light1();
    }
  }
}
