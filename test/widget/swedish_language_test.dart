import 'package:baseline/l10n/app_localizations.dart';
import 'package:baseline/l10n/localization_service.dart';
import 'package:baseline/screens/initial_screen.dart';
import 'package:baseline/screens/settings_screen.dart';
import 'package:baseline/state/app_state.dart';
import 'package:baseline/state/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(initTestHive);
  tearDownAll(closeTestHive);

  testWidgets('Swedish can be selected during setup and changed in Settings', (
    tester,
  ) async {
    final box = Hive.box<Settings>('settings');
    final languages = LocalizationService();
    await languages.initialize(box);
    final state = (await tester.runAsync(createTestAppState))!;
    PackageInfo.setMockInitialValues(
      appName: 'Baseline',
      packageName: 'baseline',
      version: '1',
      buildNumber: '1',
      buildSignature: '',
    );

    Future<void> show(Widget screen) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: state),
            ChangeNotifierProvider<LocalizationService>.value(value: languages),
          ],
          child: ListenableBuilder(
            listenable: languages,
            builder: (_, _) => MaterialApp(
              locale: languages.currentLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: LocalizationService.getSupportedLocales(),
              home: screen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await show(const InitialScreen());
    await tester.tap(find.text('Svenska'));
    await tester.pumpAndSettle();
    expect(find.text('Välj språk'), findsOneWidget);

    final restored = LocalizationService();
    await restored.initialize(box);
    expect(restored.currentLanguageCode, 'sv');

    await show(const SettingsScreen());
    expect(find.text('Inställningar'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(box.get('settings')!.language, 'en');
  });
}
