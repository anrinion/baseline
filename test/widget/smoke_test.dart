import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  group('Smoke Tests', () {
    testWidgets('basic widget test works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hello Test'),
          ),
        ),
      );

      expect(find.text('Hello Test'), findsOneWidget);
    });

    testWidgets('AppState initializes', (WidgetTester tester) async {
      final appState = await tester.runAsync(() async {
        return await createTestAppState();
      });
      expect(appState, isNotNull);
    });
  });
}
