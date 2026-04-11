import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_ids.dart';
import '../state/app_state.dart';
import '../state/settings.dart';
import '../l10n/localization_service.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController? _hereButtonController;

  @override
  void dispose() {
    _hereButtonController?.dispose();
    _movementOptionsController?.dispose();
    super.dispose();
  }

  TextEditingController _hereCtrl(String currentText) {
    _hereButtonController ??= TextEditingController(text: currentText);
    return _hereButtonController!;
  }

  TextEditingController? _movementOptionsController;

  TextEditingController _movementCtrl(String currentText) {
    _movementOptionsController ??= TextEditingController(text: currentText);
    return _movementOptionsController!;
  }

  final List<String> languages = ['en', 'ru'];

  final List<Map<String, String>> themes = [
    {'key': 'light1', 'label': 'Light (Neutral)'},
    {'key': 'light2', 'label': 'Light (Warm)'},
    {'key': 'dark1', 'label': 'Dark (True)'},
    {'key': 'dark2', 'label': 'Dark (Soft)'},
  ];

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
          Text(l10n.languageLabel, style: Theme.of(context).textTheme.titleMedium),
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

          Text(l10n.themeLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Column(
            children: themes.map((theme) {
              final themeLabel = _getThemeLabel(l10n, theme['key']!);
              return RadioListTile<String>(
                title: Text(themeLabel),
                value: theme['key']!,
                groupValue: settings.theme,
                onChanged: (value) {
                  if (value != null) {
                    appState.updateSettings((s) {
                      s.theme = value;
                    });
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Text(l10n.modulesLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.modulesHelpText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

          for (final id in BaselineModuleId.all) _moduleCard(context, appState, settings, id, l10n),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              appState.resetTodayManual();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.todayReset)),
              );
            },
            child: Text(l10n.resetToday),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.appPrivacyText,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(AppLocalizations l10n, String themeKey) {
    switch (themeKey) {
      case 'light1':
        return l10n.themeLight1;
      case 'light2':
        return l10n.themeLight2;
      case 'dark1':
        return l10n.themeDark1;
      case 'dark2':
        return l10n.themeDark2;
      default:
        return themeKey;
    }
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

  Widget _moduleCard(
    BuildContext context,
    AppState appState,
    Settings settings,
    String id,
    AppLocalizations l10n,
  ) {
    final enabled = settings.isModuleEnabled(id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(BaselineModuleId.localizedLabel(l10n, id)),
              value: enabled,
              onChanged: (on) {
                appState.updateSettings((s) {
                  s.setModuleEnabled(id, on);
                });
              },
            ),
            if (enabled && id == BaselineModuleId.here)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _hereCtrl(settings.hereButtonText),
                  decoration: InputDecoration(
                    labelText: l10n.hereModuleCustomizeLabel,
                    border: const OutlineInputBorder(),
                    hintText: l10n.hereButtonHint,
                  ),
                  onChanged: (value) {
                    appState.updateSettings((s) {
                      s.setModuleSetting(
                        BaselineModuleId.here,
                        'buttonText',
                        value,
                      );
                    });
                  },
                ),
              ),
            if (enabled && id == BaselineModuleId.movement)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _movementCtrl(
                    settings.getModuleSetting(
                      BaselineModuleId.movement,
                      'options',
                      l10n.movementDefaultOptions,
                    ),
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.movementChoicesLabel,
                    border: const OutlineInputBorder(),
                    hintText: l10n.movementDefaultOptions,
                  ),
                  onChanged: (value) {
                    appState.updateSettings((s) {
                      s.setModuleSetting(
                        BaselineModuleId.movement,
                        'options',
                        value,
                      );
                    });
                  },
                ),
              ),
            if (enabled && id == BaselineModuleId.mentalState)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cbtModeSettingDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(l10n.cbtModeRightNow),
                          value: 'rightNow',
                          groupValue: settings.mentalStateMode,
                          onChanged: (value) {
                            if (value != null) {
                              appState.updateSettings((s) {
                                s.mentalStateMode = value;
                              });
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.cbtModeGoodThings),
                          value: 'goodThings',
                          groupValue: settings.mentalStateMode,
                          onChanged: (value) {
                            if (value != null) {
                              appState.updateSettings((s) {
                                s.mentalStateMode = value;
                              });
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.cbtModeThoughtLens),
                          value: 'thoughtLens',
                          groupValue: settings.mentalStateMode,
                          onChanged: (value) {
                            if (value != null) {
                              appState.updateSettings((s) {
                                s.mentalStateMode = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
