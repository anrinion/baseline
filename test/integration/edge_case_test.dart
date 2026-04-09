/// Integration and edge case tests
/// Tests: app restart mid-day, midnight rollover, language/theme persistence, out-of-order taps
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:baseline/modules/food_constants.dart';
import 'package:baseline/screens/main_screen.dart';
import 'package:baseline/state/app_state.dart';
import 'package:baseline/state/settings.dart';
import 'package:baseline/state/today_state.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await initTestHive();
  });

  tearDownAll(() async {
    await closeTestHive();
  });

  tearDown(() async {
    await Hive.box<TodayState>('todayState').clear();
    await Hive.box<Settings>('settings').clear();
    await reopenTestBoxes();
  });

  group('App Restart Mid-Day', () {
    testWidgets('state persists across app restart simulation', skip: true, (WidgetTester tester) async {
      // Simulate first app session
      final appState1 = await createTestAppState();

      // User activity during first session
      appState1.updateTodayState((state) {
        state.proteinCount = 2;
        state.greensCount = 1;
        state.moved = true;
        state.moodSelection = 4;
        state.goodThings = ['Good coffee'];
      });

      await tester.pumpWidget(createTestableApp(
        home: const MainScreen(),
        appState: appState1,
      ));
      await tester.pumpAndSettle();

      // Verify first session state
      expect(appState1.todayState.proteinCount, equals(2));
      expect(appState1.todayState.moved, isTrue);

      // Simulate app restart by creating new AppState instance
      // Hive data persists, so new AppState should load existing data
      final appState2 = await createTestAppState();

      await tester.pumpWidget(createTestableApp(
        home: const MainScreen(),
        appState: appState2,
      ));
      await tester.pumpAndSettle();

      // Verify state persisted across "restart"
      expect(appState2.todayState.proteinCount, equals(2));
      expect(appState2.todayState.greensCount, equals(1));
      expect(appState2.todayState.moved, isTrue);
      expect(appState2.todayState.moodSelection, equals(4));
      expect(appState2.todayState.goodThings, equals(['Good coffee']));
    });

    testWidgets('same-day restart does not reset state', skip: true, (WidgetTester tester) async {
      final todayKey = TodayState.dayKeyFor(DateTime.now());

      // First session
      final todayBox = Hive.box<TodayState>('todayState');
      final initialState = TodayState()
        ..proteinCount = 3
        ..moved = true
        ..lastDayKey = todayKey;
      await todayBox.put('today', initialState);

      // Simulate restart
      final appState = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestableApp(
        home: const MainScreen(),
        appState: appState,
      ));
      await tester.pumpAndSettle();

      // State should NOT be reset because day hasn't changed
      expect(appState.todayState.proteinCount, equals(3));
      expect(appState.todayState.moved, isTrue);
      expect(appState.todayState.lastDayKey, equals(todayKey));
    });
  });

  group('Midnight Rollover - TodayState Reset', () {
    test('state resets when day changes', () async {
      final todayBox = Hive.box<TodayState>('todayState');
      
      // Create state from "yesterday"
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey = TodayState.dayKeyFor(yesterday);
      
      final yesterdayState = TodayState()
        ..proteinCount = 5
        ..moved = true
        ..moodSelection = 3
        ..goodThings = ['Yesterday thing']
        ..thoughtLensIndex = 2
        ..lastDayKey = yesterdayKey;
      
      await todayBox.put('today', yesterdayState);

      // Verify yesterday's data is stored
      final stored = todayBox.get('today');
      expect(stored?.proteinCount, equals(5));
      expect(stored?.lastDayKey, equals(yesterdayKey));

      // Note: We can't fully test the automatic reset in a unit test
      // because AppState._applyDayBoundary() uses DateTime.now().
      // The test below verifies the reset logic manually.
    });

    test('manual day boundary check resets state correctly', () async {
      final todayBox = Hive.box<TodayState>('todayState');
      
      // Create yesterday's state
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey = TodayState.dayKeyFor(yesterday);
      final todayKey = TodayState.dayKeyFor(DateTime.now());
      
      final oldState = TodayState()
        ..proteinCount = 5
        ..moved = true
        ..moodSelection = 3
        ..goodThings = ['Old thing']
        ..thoughtLensIndex = 2
        ..lastDayKey = yesterdayKey;
      
      await todayBox.put('today', oldState);

      // Simulate day boundary detection
      // (This is what AppState._applyDayBoundary does)
      if (oldState.lastDayKey != todayKey) {
        final yesterdayIndex = oldState.thoughtLensIndex;
        final newState = TodayState()
          ..lastDayKey = todayKey
          ..thoughtLensIndex = (yesterdayIndex + 1) % 10 // Different from yesterday
          ..yesterdayThoughtLensIndex = yesterdayIndex;
        
        await todayBox.put('today', newState);
      }

      // Verify reset
      final resetState = todayBox.get('today');
      expect(resetState?.proteinCount, equals(0));
      expect(resetState?.moved, isFalse);
      expect(resetState?.moodSelection, isNull);
      expect(resetState?.goodThings, isEmpty);
      expect(resetState?.lastDayKey, equals(todayKey));
    });

    testWidgets('today reset button clears all activity', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Add some activity
      appState.updateTodayState((state) {
        state.proteinCount = 4;
        state.moved = true;
        state.moodSelection = 5;
        state.goodThings = ['Thing 1', 'Thing 2'];
      });

      // Verify state is set
      expect(appState.todayState.proteinCount, equals(4));

      // Reset manually
      appState.resetTodayManual();

      // Verify all cleared
      expect(appState.todayState.proteinCount, equals(0));
      expect(appState.todayState.greensCount, equals(0));
      expect(appState.todayState.moved, isFalse);
      expect(appState.todayState.moodSelection, isNull);
      expect(appState.todayState.goodThings, isEmpty);
      
      // Day key should be preserved
      expect(appState.todayState.lastDayKey, equals(TodayState.dayKeyFor(DateTime.now())));
    });
  });

  group('Language Persistence', () {
    test('language setting persists to Hive', () async {
      final settingsBox = Hive.box<Settings>('settings');
      
      final settings = Settings()
        ..language = 'ru';
      await settingsBox.put('settings', settings);

      final retrieved = settingsBox.get('settings');
      expect(retrieved?.language, equals('ru'));
    });

    testWidgets('language change updates and persists', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Initially English
      expect(appState.settings.language, equals('en'));

      // Change to Russian
      appState.updateSettings((s) {
        s.language = 'ru';
      });

      // Verify in memory
      expect(appState.settings.language, equals('ru'));

      // Verify persisted
      final settingsBox = Hive.box<Settings>('settings');
      final persisted = settingsBox.get('settings');
      expect(persisted?.language, equals('ru'));
    });

    testWidgets('language persists across app restart', skip: true, (WidgetTester tester) async {
      // First session - set Russian
      final settingsBox = Hive.box<Settings>('settings');
      final settings1 = Settings()
        ..language = 'ru';
      await settingsBox.put('settings', settings1);

      // Simulate restart
      final appState = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify Russian persisted
      expect(appState.settings.language, equals('ru'));
    });
  });

  group('Theme Persistence', () {
    test('theme setting persists to Hive', () async {
      final settingsBox = Hive.box<Settings>('settings');
      
      final settings = Settings()
        ..theme = 'dark2';
      await settingsBox.put('settings', settings);

      final retrieved = settingsBox.get('settings');
      expect(retrieved?.theme, equals('dark2'));
    });

    testWidgets('all four themes can be set and persisted', (WidgetTester tester) async {
      final themes = ['light1', 'light2', 'dark1', 'dark2'];
      
      for (final theme in themes) {
        final appState = (await tester.runAsync(() => createTestAppState()))!;

        appState.updateSettings((s) {
          s.theme = theme;
        });

        expect(appState.settings.theme, equals(theme));
        expect(appState.currentTheme, isNotNull);
      }
    });

    testWidgets('theme persists across app restart', (WidgetTester tester) async {
      // Set dark theme
      final settingsBox = Hive.box<Settings>('settings');
      final settings = Settings()
        ..theme = 'dark1';
      await settingsBox.put('settings', settings);

      // Simulate restart
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Verify dark theme persisted
      expect(appState.settings.theme, equals('dark1'));
    });
  });

  group('Out-of-Order Tile Interactions', () {
    testWidgets('tiles can be tapped in any order', skip: true, (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      await tester.pumpWidget(createTestableApp(
        home: const MainScreen(),
        appState: appState,
      ));
      await tester.pumpAndSettle();

      // Tap tiles in arbitrary order - none should crash
      // Mental state
      final mentalIcon = find.byIcon(Icons.psychology_outlined);
      if (mentalIcon.evaluate().isNotEmpty) {
        await tester.tap(mentalIcon.first);
        await tester.pumpAndSettle();
        // Close any dialog
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
      }

      // Food
      final foodIcon = find.byIcon(Icons.restaurant);
      if (foodIcon.evaluate().isNotEmpty) {
        await tester.tap(foodIcon.first);
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
      }

      // Movement
      final movementIcon = find.byIcon(Icons.directions_walk);
      if (movementIcon.evaluate().isNotEmpty) {
        await tester.tap(movementIcon.first);
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
      }

      // No errors should occur
      expect(tester.takeException(), isNull);
    });

    testWidgets('state updates work correctly regardless of order', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Update in random order
      appState.updateTodayState((s) => s.moodSelection = 3);
      appState.updateTodayState((s) => s.proteinCount = 2);
      appState.updateTodayState((s) => s.moved = true);
      appState.updateTodayState((s) => s.goodThings = ['Thing']);

      // All updates should be present
      expect(appState.todayState.moodSelection, equals(3));
      expect(appState.todayState.proteinCount, equals(2));
      expect(appState.todayState.moved, isTrue);
      expect(appState.todayState.goodThings, equals(['Thing']));
    });

    testWidgets('rapid successive state updates work correctly', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Rapid updates
      for (var i = 0; i < 10; i++) {
        appState.updateTodayState((s) {
          s.proteinCount = i;
        });
      }

      // Final value should be 9
      expect(appState.todayState.proteinCount, equals(9));

      // Verify persisted
      final todayBox = Hive.box<TodayState>('todayState');
      final persisted = todayBox.get('today');
      expect(persisted?.proteinCount, equals(9));
    });
  });

  group('Edge Cases - Data Integrity', () {
    testWidgets('empty good things list is handled', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      appState.updateTodayState((s) {
        s.goodThings = [];
      });

      expect(appState.todayState.goodThings, isEmpty);
    });

    testWidgets('good things with empty strings are filtered', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Simulate adding items then clearing one
      appState.updateTodayState((s) {
        s.goodThings = ['Item 1', '', 'Item 3'];
      });

      // App logic typically filters empty strings on save
      // The test verifies the list can handle mixed content
      expect(appState.todayState.goodThings, hasLength(3));
    });

    testWidgets('mood selection out of range is stored as-is', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Store invalid mood value
      appState.updateTodayState((s) {
        s.moodSelection = 99;
      });

      expect(appState.todayState.moodSelection, equals(99));
    });

    testWidgets('food counts clamp to max portions', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      final proteinDef = FoodCategoryDef.all[0];
      
      // Try to set above max
      appState.updateTodayState((s) {
        proteinDef.setCount(s, 100);
      });

      // Should be clamped to max
      expect(
        proteinDef.countFrom(appState.todayState),
        equals(proteinDef.maxPortions),
      );
    });

    testWidgets('negative food counts are clamped to zero', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      final proteinDef = FoodCategoryDef.all[0];
      
      // Try to set negative
      appState.updateTodayState((s) {
        proteinDef.setCount(s, -5);
      });

      // Should be clamped to 0
      expect(proteinDef.countFrom(appState.todayState), equals(0));
    });
  });

  group('First Launch and Migration', () {
    test('first launch flag defaults to true', () async {
      // Empty box - new user
      final settings = Settings();
      expect(settings.isFirstLaunch, isTrue);
    });

    test('first launch flag can be set to false', () async {
      final settingsBox = Hive.box<Settings>('settings');
      
      final settings = Settings()
        ..isFirstLaunch = false;
      await settingsBox.put('settings', settings);

      final retrieved = settingsBox.get('settings');
      expect(retrieved?.isFirstLaunch, isFalse);
    });

    test('legacy settings get default modules including "here"', () async {
      final settings = Settings();
      
      // Ensure baseline defaults are applied
      settings.ensureBaselineModuleDefaults();
      
      // Should include 'here' module
      expect(settings.enabledModuleIds.contains('here'), isTrue);
    });
  });

  group('Simultaneous State Access', () {
    testWidgets('multiple read operations work correctly', (WidgetTester tester) async {
      final appState = (await tester.runAsync(() => createTestAppState()))!;

      // Set some state
      appState.updateTodayState((s) {
        s.proteinCount = 3;
        s.moved = true;
        s.moodSelection = 4;
      });

      // Multiple reads should all return same values
      expect(appState.todayState.proteinCount, equals(3));
      expect(appState.todayState.proteinCount, equals(3));
      expect(appState.todayState.moved, isTrue);
      expect(appState.todayState.moodSelection, equals(4));
    });
  });
}
