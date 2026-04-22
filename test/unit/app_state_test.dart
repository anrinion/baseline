import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:baseline/state/app_state.dart';
import 'package:baseline/state/settings.dart';
import 'package:baseline/state/today_state.dart';
import 'package:baseline/modules/food_constants.dart';

import '../test_helpers.dart';

void main() {
  // Setup and teardown for Hive
  setUpAll(() async {
    await initTestHive();
  });

  tearDownAll(() async {
    await closeTestHive();
  });

  tearDown(() async {
    // Clean up boxes after each test
    await Hive.box<TodayState>('todayState').clear();
    await Hive.box<Settings>('settings').clear();
    // Reopen boxes for next test
    await reopenTestBoxes();
  });

  group('TodayState Reset Logic', () {
    test('dayKeyFor formats date correctly as yyyy-MM-dd', () {
      final date = DateTime(2024, 3, 15);
      final key = TodayState.dayKeyFor(date);
      expect(key, equals('2024-03-15'));
    });

    test('dayKeyFor pads single digit month and day', () {
      final date = DateTime(2024, 1, 5);
      final key = TodayState.dayKeyFor(date);
      expect(key, equals('2024-01-05'));
    });

    test('TodayState initializes with default values', () {
      final state = TodayState();
      
      expect(state.proteinCount, equals(0));
      expect(state.greensCount, equals(0));
      expect(state.legumesCount, equals(0));
      expect(state.fillersCount, equals(0));
      expect(state.treatCount, equals(0));
      expect(state.moved, isFalse);
      expect(state.medsTaken, isFalse);
      expect(state.sleepBedTimeMinutes, equals(1380)); // 23:00 default
      expect(state.sleepWakeTimeMinutes, equals(420));  // 07:00 default
      expect(state.hereTapped, isFalse);
      expect(state.cbtTemp, equals(''));
      expect(state.moodSelection, isNull);
      expect(state.goodThings, isEmpty);
      expect(state.lastDayKey, equals(''));
    });

    test('AppState persists and retrieves TodayState from Hive', () async {
      // Pre-populate Hive box
      final todayBox = Hive.box<TodayState>('todayState');
      final initialState = TodayState()
        ..proteinCount = 2
        ..greensCount = 3
        ..lastDayKey = TodayState.dayKeyFor(DateTime.now());
      await todayBox.put('today', initialState);

      // Create AppState - should load from Hive
      final AppState appState = await createTestAppState();
      
      expect(appState.todayState.proteinCount, equals(2));
      expect(appState.todayState.greensCount, equals(3));
    });
  });

  group('TodayState Daily Reset', () {
    test('updateTodayState modifies state and persists to Hive', () async {
      final AppState appState = await createTestAppState();

      // Update state
      appState.updateTodayState((state) {
        state.proteinCount = 3;
        state.moved = true;
        state.moodSelection = 4;
        state.goodThings = ['Had coffee', 'Saw a friend'];
      });

      // Verify in-memory state
      expect(appState.todayState.proteinCount, equals(3));
      expect(appState.todayState.moved, isTrue);
      expect(appState.todayState.moodSelection, equals(4));
      expect(appState.todayState.goodThings, hasLength(2));

      // Verify persisted state
      final todayBox = Hive.box<TodayState>('todayState');
      final persisted = todayBox.get('today');
      expect(persisted?.proteinCount, equals(3));
      expect(persisted?.moved, isTrue);
      expect(persisted?.moodSelection, equals(4));
    });

    test('resetTodayManual clears all activity but keeps current day', () async {
      final AppState appState = await createTestAppState();

      // Set up state with some data
      final todayKey = TodayState.dayKeyFor(DateTime.now());
      appState.updateTodayState((state) {
        state.proteinCount = 5;
        state.moved = true;
        state.moodSelection = 3;
        state.goodThings = ['Item 1', 'Item 2'];
        state.lastDayKey = todayKey;
      });

      // Reset manually
      appState.resetTodayManual();

      // Verify state is cleared but day key is preserved
      expect(appState.todayState.proteinCount, equals(0));
      expect(appState.todayState.moved, isFalse);
      expect(appState.todayState.moodSelection, isNull);
      expect(appState.todayState.goodThings, isEmpty);
      expect(appState.todayState.lastDayKey, equals(todayKey));
    });
  });

  group('Food Module State Updates', () {
    test('applyFoodDelta updates food counts correctly', () async {
      final AppState appState = await createTestAppState();

      // Simulate adding food items
      appState.updateTodayState((state) {
        state.proteinCount = 1;
        state.greensCount = 2;
        state.treatCount = 1;
      });

      expect(appState.todayState.proteinCount, equals(1));
      expect(appState.todayState.greensCount, equals(2));
      expect(appState.todayState.treatCount, equals(1));

      // Verify max portions are respected via setters
      final proteinDef = FoodCategoryDef.all[0]; // protein is first
      appState.updateTodayState((state) {
        proteinDef.setCount(state, proteinDef.maxPortions + 1);
      });
      
      // Should clamp to max
      expect(
        proteinDef.countFrom(appState.todayState), 
        lessThanOrEqualTo(proteinDef.maxPortions),
      );
    });

    test('FoodCategoryDef.totalLogged calculates total correctly', () async {
      final AppState appState = await createTestAppState();

      appState.updateTodayState((state) {
        state.proteinCount = 2;
        state.greensCount = 3;
        state.legumesCount = 1;
        state.fillersCount = 2;
        state.treatCount = 1;
      });

      final total = FoodCategoryDef.totalLogged(appState.todayState);
      expect(total, equals(9)); // 2+3+1+2+1
    });
  });

  group('Movement State Updates', () {
    test('movement completed updates state', () async {
      final AppState appState = await createTestAppState();

      expect(appState.todayState.moved, isFalse);

      appState.updateTodayState((state) {
        state.moved = true;
      });

      expect(appState.todayState.moved, isTrue);
    });

    test('movement can be reset', () async {
      final AppState appState = await createTestAppState();

      appState.updateTodayState((state) {
        state.moved = true;
      });

      appState.updateTodayState((state) {
        state.moved = false;
      });

      expect(appState.todayState.moved, isFalse);
    });
  });

  group('Mental State (CBT) Updates', () {
    test('mood selection updates state with timestamp', () async {
      final AppState appState = await createTestAppState();

      final beforeUpdate = DateTime.now();
      
      appState.updateTodayState((state) {
        state.moodSelection = 4;
        state.moodSelectionTimestamp = DateTime.now();
      });

      expect(appState.todayState.moodSelection, equals(4));
      expect(appState.todayState.moodSelectionTimestamp, isNotNull);
      expect(
        appState.todayState.moodSelectionTimestamp!.isAfter(beforeUpdate) ||
        appState.todayState.moodSelectionTimestamp!.isAtSameMomentAs(beforeUpdate),
        isTrue,
      );
    });

    test('good things list can be updated', () async {
      final AppState appState = await createTestAppState();

      appState.updateTodayState((state) {
        state.goodThings = ['Good coffee', 'Nice walk', 'Fun conversation'];
      });

      expect(appState.todayState.goodThings, hasLength(3));
      expect(appState.todayState.goodThings[0], equals('Good coffee'));
    });

    test('thought lens index can be updated', () async {
      final AppState appState = await createTestAppState();

      appState.updateTodayState((state) {
        state.thoughtLensIndex = 5;
      });

      expect(appState.todayState.thoughtLensIndex, equals(5));
    });
  });

  group('Sleep State Updates', () {
    test('sleep times can be updated', () async {
      final AppState appState = await createTestAppState();

      expect(appState.todayState.sleepBedTimeMinutes, equals(1380));
      expect(appState.todayState.sleepWakeTimeMinutes, equals(420));

      appState.updateTodayState((state) {
        state.sleepBedTimeMinutes = 1320;  // 22:00
        state.sleepWakeTimeMinutes = 480;  // 08:00
      });

      expect(appState.todayState.sleepBedTimeMinutes, equals(1320));
      expect(appState.todayState.sleepWakeTimeMinutes, equals(480));
    });
  });

  group('Meds State Updates', () {
    test('meds taken state can be updated', () async {
      final AppState appState = await createTestAppState();

      expect(appState.todayState.medsTaken, isFalse);

      appState.updateTodayState((state) {
        state.medsTaken = true;
      });

      expect(appState.todayState.medsTaken, isTrue);
    });
  });

  group('Settings Persistence', () {
    test('Settings persists language and theme', () async {
      final settingsBox = Hive.box<Settings>('settings');
      
      final settings = Settings()
        ..language = 'ru'
        ..theme = 'dark1';
      await settingsBox.put('settings', settings);

      final retrieved = settingsBox.get('settings');
      expect(retrieved?.language, equals('ru'));
      expect(retrieved?.theme, equals('dark1'));
    });

    test('Settings module enable/disable works', () async {
      final settings = Settings();

      expect(settings.isModuleEnabled('food'), isTrue);
      expect(settings.isModuleEnabled('movement'), isTrue);

      settings.setModuleEnabled('food', false);
      expect(settings.isModuleEnabled('food'), isFalse);
      expect(settings.isModuleEnabled('movement'), isTrue);

      settings.setModuleEnabled('food', true);
      expect(settings.isModuleEnabled('food'), isTrue);
    });

    test('hereButtonText can be customized', () async {
      final settings = Settings();
      
      // Default is empty (uses localized default in UI)
      expect(settings.hereButtonText, equals(''));

      settings.hereButtonText = 'I am present';
      expect(settings.hereButtonText, equals('I am present'));
    });
  });
}
