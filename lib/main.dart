import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'state/app_state.dart';
import 'state/today_state.dart';
import 'state/settings.dart';
import 'screens/main_screen.dart';
import 'screens/initial_screen.dart';
import 'l10n/localization_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodayStateAdapter());
  Hive.registerAdapter(SettingsAdapter());
  await Hive.openBox<TodayState>('todayState');
  final settingsBox = await Hive.openBox<Settings>('settings');

  // Initialize default settings if they don't exist
  if (settingsBox.isEmpty) {
    final defaultSettings = Settings();
    await settingsBox.put('settings', defaultSettings);
  }

  // Initialize localization service
  final localizationService = LocalizationService();
  await localizationService.initialize(settingsBox);

  runApp(BaselineApp(localizationService: localizationService));
}

class BaselineApp extends StatelessWidget {
  final LocalizationService localizationService;

  const BaselineApp({
    required this.localizationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider<LocalizationService>.value(
          value: localizationService,
        ),
      ],
      child: Consumer2<AppState, LocalizationService>(
        builder: (context, appState, localizationService, _) {
          // Check if this is first launch using dedicated flag
          final isFirstLaunch = appState.settings.isFirstLaunch;
          
          return MaterialApp(
            title: 'Baseline',
            theme: appState.lightTheme,
            darkTheme: appState.darkTheme,
            themeMode: appState.materialThemeMode,
            locale: localizationService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocalizationService.getSupportedLocales(),
            home: isFirstLaunch ? const InitialScreen() : const MainScreen(),
          );
        },
      ),
    );
  }
}
