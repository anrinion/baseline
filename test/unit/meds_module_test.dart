import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:baseline/l10n/app_localizations_en.dart';
import 'package:baseline/modules/meds_module.dart';
import 'package:baseline/modules/module_ids.dart';
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

  group('Meds Module', () {
    test('getMedsList trims and de-duplicates list entries', () async {
      final AppState appState = await createTestAppState();
      final l10n = AppLocalizationsEn();

      appState.updateSettings((settings) {
        settings.setModuleSetting(
          BaselineModuleId.meds,
          'list',
          'Vitamin D\n\n  vitamin d  \nOmega-3\n ',
        );
      });

      final meds = getMedsList(appState, l10n);
      expect(meds, equals(['Vitamin D', 'Omega-3']));
    });

    test('setMedsList persists meds list in settings', () async {
      final AppState appState = await createTestAppState();
      final l10n = AppLocalizationsEn();

      setMedsList(appState, const ['Magnesium', 'B12']);

      final meds = getMedsList(appState, l10n);
      expect(meds, equals(['Magnesium', 'B12']));
    });

    test(
      'syncMedsChecksWithList keeps relevant checks and removes stale ones',
      () async {
        final AppState appState = await createTestAppState();

        appState.updateTodayState((state) {
          state.medsChecked = {
            'Vitamin D': true,
            'Magnesium': false,
            'Old Med': true,
          };
          state.medsTaken = true;
        });

        syncMedsChecksWithList(appState, const [
          'Vitamin D',
          'Magnesium',
          'B12',
        ]);

        expect(
          appState.todayState.medsChecked,
          equals({'Vitamin D': true, 'Magnesium': false, 'B12': false}),
        );
        expect(appState.todayState.medsTaken, isTrue);
      },
    );

    test(
      'syncMedsChecksWithList clears medsTaken when none are checked',
      () async {
        final AppState appState = await createTestAppState();

        appState.updateTodayState((state) {
          state.medsChecked = {'Old Med': true};
          state.medsTaken = true;
        });

        syncMedsChecksWithList(appState, const ['New Med']);

        expect(appState.todayState.medsChecked, equals({'New Med': false}));
        expect(appState.todayState.medsTaken, isFalse);
      },
    );

    test('per-med reminder helpers read and write values', () async {
      final AppState appState = await createTestAppState();

      appState.updateSettings((settings) {
        setMedsReminderMinutesForMedOnSettings(
          settings,
          'Magnesium',
          22 * 60 + 15,
        );
      });

      expect(
        medsReminderMinutesForMed(appState.settings, 'Magnesium'),
        equals(1335),
      );
      expect(
        medsReminderMinutesByMedFromSettings(appState.settings),
        equals({'Magnesium': 1335}),
      );
    });

    test('per-med reminder helper normalizes out-of-range values', () async {
      final AppState appState = await createTestAppState();

      appState.updateSettings((settings) {
        setMedsReminderMinutesForMedOnSettings(settings, 'B12', -1);
      });

      expect(
        medsReminderMinutesForMed(appState.settings, 'B12'),
        equals((24 * 60) - 1),
      );
    });

    test(
      'setMedsList removes reminders for medications no longer in list',
      () async {
        final AppState appState = await createTestAppState();

        appState.updateSettings((settings) {
          setMedsReminderMinutesForMedOnSettings(settings, 'A', 500);
          setMedsReminderMinutesForMedOnSettings(settings, 'B', 600);
        });

        setMedsList(appState, const ['B', 'C']);

        expect(
          medsReminderMinutesByMedFromSettings(appState.settings),
          equals({'B': 600}),
        );
      },
    );
  });
}
