import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baseline/main.dart';

void main() {
  setUp(() async {
    // Omit 'last_date' to simulate no saved date (null is not allowed)
    SharedPreferences.setMockInitialValues({
      'food_data': ['0', '0', '0', '0', '0'],
      'exercise_completed': false,
    });
  });

  group('The Baseline App', () {
    testWidgets('initial state loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const BaselineDemoApp());
      await tester.pumpAndSettle();

      expect(find.text('The Baseline', skipOffstage: false), findsOneWidget);
      expect(find.text('Nourishment', skipOffstage: false), findsOneWidget);
      expect(find.text('Movement', skipOffstage: false), findsOneWidget);
      expect(find.text('Go for a walk', skipOffstage: false), findsOneWidget);
      expect(find.text('Light workout', skipOffstage: false), findsOneWidget);
    });

    testWidgets('protein counter increments and decrements', (WidgetTester tester) async {
      await tester.pumpWidget(const BaselineDemoApp());
      await tester.pumpAndSettle();

      // Locate Protein card by its title
      final proteinTitle = find.text('Protein', skipOffstage: false);
      await tester.ensureVisible(proteinTitle);
      await tester.pumpAndSettle();

      final proteinCard = find.ancestor(of: proteinTitle, matching: find.byType(Card)).first;
      final plusButton = find.descendant(of: proteinCard, matching: find.byIcon(Icons.add));
      final minusButton = find.descendant(of: proteinCard, matching: find.byIcon(Icons.remove));

      expect(find.descendant(of: proteinCard, matching: find.text('0/2')), findsOneWidget);

      await tester.tap(plusButton);
      await tester.pumpAndSettle();
      expect(find.descendant(of: proteinCard, matching: find.text('1/2')), findsOneWidget);

      await tester.tap(plusButton);
      await tester.pumpAndSettle();
      expect(find.descendant(of: proteinCard, matching: find.text('2/2')), findsOneWidget);

      await tester.tap(minusButton);
      await tester.pumpAndSettle();
      expect(find.descendant(of: proteinCard, matching: find.text('1/2')), findsOneWidget);
    });

    testWidgets('exercise completion and reset', (WidgetTester tester) async {
      await tester.pumpWidget(const BaselineDemoApp());
      await tester.pumpAndSettle();

      final walkText = find.text('Go for a walk', skipOffstage: false);
      await tester.ensureVisible(walkText);
      await tester.pumpAndSettle();
      await tester.tap(walkText);
      await tester.pumpAndSettle();

      expect(find.text('You took a walk today. That’s wonderful! 🚶', skipOffstage: false), findsOneWidget);
      expect(find.text('Walk done', skipOffstage: false), findsOneWidget);

      final resetText = find.text('Reset', skipOffstage: false);
      await tester.ensureVisible(resetText);
      await tester.pumpAndSettle();
      await tester.tap(resetText);
      await tester.pumpAndSettle();

      expect(find.text('Choose one gentle activity for today:', skipOffstage: false), findsOneWidget);
      expect(find.text('Go for a walk', skipOffstage: false), findsOneWidget);
    });

    testWidgets('help dialog appears and closes', (WidgetTester tester) async {
      await tester.pumpWidget(const BaselineDemoApp());
      await tester.pumpAndSettle();

      final helpIcons = find.byIcon(Icons.help_outline, skipOffstage: false);
      expect(helpIcons, findsAtLeastNWidgets(1));
      await tester.ensureVisible(helpIcons.first);
      await tester.pumpAndSettle();
      await tester.tap(helpIcons.first);
      await tester.pumpAndSettle();

      expect(find.text('Why this works', skipOffstage: false), findsOneWidget);
      expect(find.text('Got it', skipOffstage: false), findsOneWidget);
      await tester.tap(find.text('Got it', skipOffstage: false));
      await tester.pumpAndSettle();
      expect(find.text('Why this works', skipOffstage: false), findsNothing);
    });

    testWidgets('daily reset clears state on new day', (WidgetTester tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      // Properly set mock values – 'last_date' as a string, no null
      SharedPreferences.setMockInitialValues({
        'last_date': yesterday,
        'food_data': ['2', '3', '1', '2', '1'],
        'exercise_completed': true,
        'exercise_type': 'walk',
      });

      await tester.pumpWidget(const BaselineDemoApp());
      await tester.pumpAndSettle();

      final proteinTitle = find.text('Protein', skipOffstage: false);
      await tester.ensureVisible(proteinTitle);
      await tester.pumpAndSettle();
      final proteinCard = find.ancestor(of: proteinTitle, matching: find.byType(Card)).first;
      expect(find.descendant(of: proteinCard, matching: find.text('0/2')), findsOneWidget);
      
      final exerciseHeader = find.text('Movement', skipOffstage: false);
      await tester.ensureVisible(exerciseHeader);
      await tester.pumpAndSettle();
      expect(find.text('Choose one gentle activity for today:', skipOffstage: false), findsOneWidget);
      expect(find.text('Walk done', skipOffstage: false), findsNothing);
    });
  });
}