import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:baseline/l10n/app_localizations.dart';
import 'package:baseline/l10n/localization_service.dart';
import 'package:baseline/state/app_state.dart';
import 'package:baseline/state/settings.dart';
import 'package:baseline/state/today_state.dart';
import 'package:baseline/services/timer_service.dart';

import 'fake_timer_service.dart';

/// Initialize Hive for testing (in-memory)
Future<void> initTestHive() async {
  // Ensure Flutter binding is initialized for widget tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register adapters if not already registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TodayStateAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(SettingsAdapter());
  }

  // Open boxes in-memory (no file backend)
  await Hive.openBox<TodayState>('todayState', bytes: Uint8List(0));
  await Hive.openBox<Settings>('settings', bytes: Uint8List(0));
}

/// Close all Hive boxes after tests
Future<void> closeTestHive() async {
  await Hive.close();
}

/// Reopen boxes for next test (call in setUp or after clearing)
Future<void> reopenTestBoxes() async {
  if (!Hive.isBoxOpen('todayState')) {
    await Hive.openBox<TodayState>('todayState', bytes: Uint8List(0));
  }
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox<Settings>('settings', bytes: Uint8List(0));
  }
}

/// Create and fully initialize an AppState for testing
/// This ensures boxes are opened and state is loaded before returning
/// 
/// For widget tests, wrap the call in tester.runAsync():
///   final appState = await tester.runAsync(() => createTestAppState());
///
/// Optionally pass a [TimerService] for controlling timers in tests.
/// Defaults to [FakeTimerService] for test isolation.
Future<AppState> createTestAppState({TimerService? timerService}) async {
  // Ensure boxes are open
  await reopenTestBoxes();

  // Verify boxes are actually open
  if (!Hive.isBoxOpen('todayState') || !Hive.isBoxOpen('settings')) {
    throw StateError('Hive boxes not open');
  }

  // Create AppState with optional timer service (defaults to FakeTimerService)
  final appState = AppState(timerService: timerService ?? FakeTimerService());

  // Wait for async _init() to complete
  // _init() does: box assignment, data loading, _applyDayBoundary(), callback setup, notifyListeners()
  // Need enough time for full initialization including MedsNotificationsService callbacks
  await Future.delayed(const Duration(milliseconds: 300));

  return appState;
}

/// Create a testable widget wrapped with all necessary providers
Widget createTestableWidget({
  required Widget child,
  AppState? appState,
  LocalizationService? localizationService,
  Locale locale = const Locale('en'),
}) {
  // Use FakeTimerService by default for test isolation if no appState provided
  final effectiveAppState = appState ?? AppState(timerService: FakeTimerService());
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(
        value: effectiveAppState,
      ),
      ChangeNotifierProvider<LocalizationService>.value(
        value: localizationService ?? _createMockLocalizationService(locale),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      home: child,
    ),
  );
}

/// Create a fully configured MaterialApp for widget tests
Widget createTestableApp({
  required Widget home,
  AppState? appState,
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) {
  final mockLocalizationService = _createMockLocalizationService(locale);
  
  // Use FakeTimerService by default for test isolation if no appState provided
  final effectiveAppState = appState ?? AppState(timerService: FakeTimerService());
  
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(
        value: effectiveAppState,
      ),
      ChangeNotifierProvider<LocalizationService>.value(
        value: mockLocalizationService,
      ),
    ],
    child: MaterialApp(
      title: 'Baseline Test',
      theme: theme ?? ThemeData(fontFamily: 'Roboto'),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      home: home,
    ),
  );
}

LocalizationService _createMockLocalizationService(Locale locale) {
  final service = LocalizationService();
  // Initialize with test settings box
  return service;
}

/// Pump a widget and wait for all animations to settle
Future<void> pumpAndSettleWithDelay(
  WidgetTester tester, 
  Widget widget, {
  Duration delay = const Duration(milliseconds: 100),
}) async {
  await tester.pumpWidget(widget);
  await tester.pump(delay);
  await tester.pumpAndSettle();
}

/// Helper to find text by substring
Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains(text) == true,
  );
}

/// Helper to simulate a screen size
Future<void> setScreenSize(
  WidgetTester tester, 
  Size size, {
  double pixelDensity = 1.0,
}) async {
  final window = tester.view;
  window.physicalSize = size * pixelDensity;
  window.devicePixelRatio = pixelDensity;
  addTearDown(() {
    window.resetPhysicalSize();
    window.resetDevicePixelRatio();
  });
}

/// Common screen sizes for responsive testing
class TestScreenSizes {
  /// Square/split screen (e.g., half of regular phone)
  static const Size square = Size(400, 400);
  
  /// Small phone (e.g., iPhone SE, small Android)
  static const Size smallPhone = Size(375, 667);
  
  /// Standard phone (e.g., iPhone 14, Pixel 7)
  static const Size standardPhone = Size(390, 844);
  
  /// Tablet (e.g., iPad mini, small Android tablet)
  static const Size tablet = Size(768, 1024);
  
  /// Large tablet (e.g., iPad Pro)
  static const Size largeTablet = Size(1024, 1366);
}

/// Wait for a condition to become true with timeout
Future<bool> waitForCondition(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final startTime = DateTime.now();
  while (!condition()) {
    if (DateTime.now().difference(startTime) > timeout) {
      return false;
    }
    await Future.delayed(interval);
  }
  return true;
}
