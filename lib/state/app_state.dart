import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

    _resetIfNewDay();
    notifyListeners();
  }

  void _resetIfNewDay() {
    final now = DateTime.now();
    final lastSaved = todayState.key as DateTime?;
    // Always reset for simplicity; adjust logic if you track lastSaved
    todayState = TodayState();
    todayBox.put('today', todayState);
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
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
        );
      case 'light2':
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.orange.shade50,
        );
      case 'dark1':
        return ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black);
      case 'dark2':
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.grey.shade900,
        );
      default:
        return ThemeData.light();
    }
  }
}
