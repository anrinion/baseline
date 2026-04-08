import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/main_module_layout.dart';
import '../l10n/app_localizations.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: MainModuleLayout(appState: appState),
      ),
    );
  }
}
