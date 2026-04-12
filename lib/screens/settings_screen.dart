import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../l10n/localization_service.dart';
import '../l10n/app_localizations.dart';
import 'settings/theme_settings_section.dart';
import 'settings/module_settings_section.dart';
import 'settings/developer_settings_section.dart';

/// Settings screen orchestrator that delegates to specialized section widgets.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController? _hereButtonController;
  TextEditingController? _medsListController;

  @override
  void dispose() {
    _hereButtonController?.dispose();
    _medsListController?.dispose();
    super.dispose();
  }

  void _setHereController(TextEditingController controller) {
    _hereButtonController = controller;
  }

  void _setMedsController(TextEditingController controller) {
    _medsListController = controller;
  }

  final List<String> languages = ['en', 'ru'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizationService = Provider.of<LocalizationService>(context);
    final settings = appState.settings;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          Text(
            l10n.languageLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: localizationService.currentLanguageCode,
            isExpanded: true,
            items: languages.map((langCode) {
              return DropdownMenuItem(
                value: langCode,
                child: Text(_getLanguageLabel(l10n, langCode)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                localizationService.setLanguage(value);
                appState.updateSettings((s) {
                  s.language = value;
                });
              }
            },
          ),

          const SizedBox(height: 24),

          // Theme Section
          ThemeSettingsSection(
            appState: appState,
            settings: settings,
            l10n: l10n,
          ),

          const SizedBox(height: 24),

          // Modules Section
          ModuleSettingsSection(
            appState: appState,
            settings: settings,
            l10n: l10n,
            hereButtonController: _hereButtonController,
            medsListController: _medsListController,
            onHereControllerCreated: _setHereController,
            onMedsControllerCreated: _setMedsController,
          ),

          const SizedBox(height: 24),

          // Reset Today Button
          ElevatedButton(
            onPressed: () {
              appState.resetTodayManual();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.todayReset)));
            },
            child: Text(l10n.resetToday),
          ),

          const SizedBox(height: 24),

          // Developer Section
          DeveloperSettingsSection(
            appState: appState,
            settings: settings,
            l10n: l10n,
          ),

          const SizedBox(height: 24),

          // Privacy Footer
          Text(l10n.appPrivacyText, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _getLanguageLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case 'en':
        return l10n.languageEnglish;
      case 'ru':
        return l10n.languageRussian;
      default:
        return code;
    }
  }
}
