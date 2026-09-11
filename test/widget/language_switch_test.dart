import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:baseline/l10n/app_localizations.dart';
import 'package:baseline/l10n/app_localizations_de.dart';
import 'package:baseline/l10n/app_localizations_fr.dart';
import 'package:baseline/l10n/app_localizations_es.dart';
import 'package:baseline/l10n/localization_service.dart';
import 'package:baseline/screens/initial_screen.dart';
import 'package:baseline/state/settings.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await initTestHive();
  });

  tearDownAll(() async {
    await closeTestHive();
  });

  tearDown(() async {
    await Hive.box<Settings>('settings').clear();
    await reopenTestBoxes();
  });

  group('LocalizationService', () {
    test('supports en, ru, de, fr, es', () {
      final codes = LocalizationService.getSupportedLocales().map((l) => l.languageCode);
      expect(codes, containsAll(['en', 'ru', 'de', 'fr', 'es']));
    });

    test('getLanguageName returns a native display name for new locales', () {
      expect(LocalizationService.getLanguageName('de'), 'Deutsch');
      expect(LocalizationService.getLanguageName('fr'), 'Français');
      expect(LocalizationService.getLanguageName('es'), 'Español');
    });
  });

  group('Generated AppLocalizations for new locales', () {
    test('German language-name strings resolve', () {
      final l10n = AppLocalizationsDe();
      expect(l10n.languageGerman, 'Deutsch');
      expect(l10n.languageFrench, 'Französisch');
      expect(l10n.languageSpanish, 'Spanisch');
      expect(l10n.languageEnglish, 'Englisch');
      expect(l10n.languageRussian, 'Russisch');
    });

    test('French language-name strings resolve', () {
      final l10n = AppLocalizationsFr();
      expect(l10n.languageFrench, 'Français');
      expect(l10n.languageGerman, 'Allemand');
      expect(l10n.languageSpanish, 'Espagnol');
    });

    test('Spanish language-name strings resolve', () {
      final l10n = AppLocalizationsEs();
      expect(l10n.languageSpanish, 'Español');
      expect(l10n.languageGerman, 'Alemán');
      expect(l10n.languageFrench, 'Francés');
    });
  });

  group('InitialScreen language picker', () {
    testWidgets('renders a button for all 5 supported languages and switches on tap',
        (WidgetTester tester) async {
      final localizationService = await tester.runAsync(() async {
        final service = LocalizationService();
        await service.initialize(Hive.box<Settings>('settings'));
        return service;
      });

      await tester.pumpWidget(createTestableApp(
        home: const InitialScreen(),
        localizationService: localizationService,
      ));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(InitialScreen)))!;

      // All five language buttons are present.
      expect(find.text(l10n.languageEnglish), findsOneWidget);
      expect(find.text(l10n.languageRussian), findsOneWidget);
      expect(find.text(l10n.languageGerman), findsOneWidget);
      expect(find.text(l10n.languageFrench), findsOneWidget);
      expect(find.text(l10n.languageSpanish), findsOneWidget);

      // Tapping German selects it (button becomes the primary/selected style).
      await tester.tap(find.text(l10n.languageGerman));
      await tester.pumpAndSettle();

      final germanButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(l10n.languageGerman),
          matching: find.byType(ElevatedButton),
        ),
      );
      final style = germanButton.style!;
      final selectedBg = style.backgroundColor?.resolve({});
      expect(selectedBg, isNotNull);
    });
  });
}
