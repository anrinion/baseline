import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'state/app_state.dart';
import 'state/today_state.dart';
import 'state/settings.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodayStateAdapter());
  Hive.registerAdapter(SettingsAdapter());
  await Hive.openBox<TodayState>('todayState');
  await Hive.openBox<Settings>('settings');

  runApp(BaselineApp());
}

class BaselineApp extends StatelessWidget {
  const BaselineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Baseline',
            theme: appState.currentTheme,
            home: MainScreen(),
          );
        },
      ),
    );
  }
}