import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_ids.dart';
import '../state/app_state.dart';
import '../state/settings.dart';
import '../l10n/localization_service.dart';
import '../l10n/app_localizations.dart';
import '../services/meds_notifications_service.dart';
import 'initial_screen.dart';

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
    _medsListController?.dispose();
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

  TextEditingController? _medsListController;

  TextEditingController _medsCtrl(String currentText) {
    _medsListController ??= TextEditingController(text: currentText);
    return _medsListController!;
  }

  final List<String> languages = ['en', 'ru'];

  final List<String> lightThemes = ['light1', 'light2'];
  final List<String> darkThemes = ['dark1', 'dark2'];
  final List<String> themeModes = [
    Settings.themeModeManual,
    Settings.themeModeDevice,
    Settings.themeModeSchedule,
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

          Text(l10n.themeLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.themeBehaviorHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) {
                appState.updateSettings((s) {
                  s.themeMode = value;
                });
              }
            },
            child: Column(
              children: themeModes.map((mode) {
                return RadioListTile<String>(
                  title: Text(_getThemeModeLabel(l10n, mode)),
                  subtitle: Text(_getThemeModeDescription(l10n, mode)),
                  value: mode,
                );
              }).toList(),
            ),
          ),
          if (settings.themeMode == Settings.themeModeManual) ...[
            const SizedBox(height: 8),
            Text(
              l10n.themeManualChoiceLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            RadioGroup<String>(
              groupValue: settings.usesDarkManualTheme ? 'dark' : 'light',
              onChanged: (value) {
                if (value == null) return;
                appState.updateSettings((s) {
                  s.setManualTheme(
                    value == 'dark' ? s.darkThemeKey : s.lightThemeKey,
                  );
                });
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.themeUseLight),
                    value: 'light',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.themeUseDark),
                    value: 'dark',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.themeLightSectionLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          RadioGroup<String>(
            groupValue: settings.lightThemeKey,
            onChanged: (value) {
              if (value == null) return;
              appState.updateSettings((s) {
                s.lightThemeKey = value;
                if (!s.usesDarkManualTheme) {
                  s.theme = value;
                }
              });
            },
            child: Column(
              children: lightThemes.map((themeKey) {
                return RadioListTile<String>(
                  title: Text(_getThemeLabel(l10n, themeKey)),
                  value: themeKey,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.themeDarkSectionLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          RadioGroup<String>(
            groupValue: settings.darkThemeKey,
            onChanged: (value) {
              if (value == null) return;
              appState.updateSettings((s) {
                s.darkThemeKey = value;
                if (s.usesDarkManualTheme) {
                  s.theme = value;
                }
              });
            },
            child: Column(
              children: darkThemes.map((themeKey) {
                return RadioListTile<String>(
                  title: Text(_getThemeLabel(l10n, themeKey)),
                  value: themeKey,
                );
              }).toList(),
            ),
          ),
          if (settings.themeMode == Settings.themeModeSchedule) ...[
            const SizedBox(height: 8),
            Text(
              l10n.themeScheduleLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.themeScheduleLightStarts),
              subtitle: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  _timeOfDayFromMinutes(settings.scheduleLightStartMinutes),
                ),
              ),
              trailing: const Icon(Icons.schedule),
              onTap: () => _pickThemeTime(
                context,
                initialMinutes: settings.scheduleLightStartMinutes,
                onSelected: (minutes) {
                  appState.updateSettings((s) {
                    s.scheduleLightStartMinutes = minutes;
                  });
                },
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.themeScheduleDarkStarts),
              subtitle: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  _timeOfDayFromMinutes(settings.scheduleDarkStartMinutes),
                ),
              ),
              trailing: const Icon(Icons.schedule),
              onTap: () => _pickThemeTime(
                context,
                initialMinutes: settings.scheduleDarkStartMinutes,
                onSelected: (minutes) {
                  appState.updateSettings((s) {
                    s.scheduleDarkStartMinutes = minutes;
                  });
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          Text(
            l10n.modulesLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.modulesHelpText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

          for (final id in BaselineModuleId.all)
            _moduleCard(context, appState, settings, id, l10n),

          const SizedBox(height: 24),

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

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.developerModeLabel),
            subtitle: Text(l10n.developerModeHelp),
            value: settings.developerModeEnabled,
            onChanged: (value) {
              if (value == null) return;
              appState.updateSettings((s) {
                s.developerModeEnabled = value;
              });
            },
          ),

          if (settings.developerModeEnabled) ...[
            const SizedBox(height: 12),
            FutureBuilder<void>(
              future: MedsNotificationsService.instance.ensureInitialized(),
              builder: (context, snapshot) => ValueListenableBuilder<String>(
                valueListenable:
                    MedsNotificationsService.instance.statusListenable,
                builder: (context, statusCode, child) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.developerNotificationsServiceLabel),
                    subtitle: Text(
                      _notificationsStatusLabel(l10n, statusCode),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.developerResetAllDataLabel),
                    content: Text(l10n.developerResetAllDataHelp),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(l10n.dialogCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(l10n.dialogReset),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;

                appState.resetAllData();
                await localizationService.setLanguage('en');
                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const InitialScreen(),
                  ),
                  (route) => false,
                );
              },
              child: Text(l10n.developerResetAllDataLabel),
            ),
          ],

          const SizedBox(height: 24),

          Text(l10n.appPrivacyText, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _notificationsStatusLabel(AppLocalizations l10n, String statusCode) {
    switch (statusCode) {
      case 'active':
        return l10n.developerNotificationsStatusActive;
      case 'disabled':
        return l10n.developerNotificationsStatusDisabled;
      case 'unsupported_platform':
        return l10n.developerNotificationsStatusUnsupportedPlatform;
      case 'plugin_missing':
        return l10n.developerNotificationsStatusPluginMissing;
      case 'permission_denied':
        return l10n.developerNotificationsStatusPermissionDenied;
      case 'platform_error':
      case 'error':
        return l10n.developerNotificationsStatusError;
      case 'ready':
        return l10n.developerNotificationsStatusReady;
      case 'not_initialized':
      default:
        return l10n.developerNotificationsStatusNotInitialized;
    }
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

  String _getThemeModeLabel(AppLocalizations l10n, String mode) {
    switch (mode) {
      case Settings.themeModeDevice:
        return l10n.themeModeDevice;
      case Settings.themeModeSchedule:
        return l10n.themeModeSchedule;
      case Settings.themeModeManual:
      default:
        return l10n.themeModeManual;
    }
  }

  String _getThemeModeDescription(AppLocalizations l10n, String mode) {
    switch (mode) {
      case Settings.themeModeDevice:
        return l10n.themeModeDeviceDescription;
      case Settings.themeModeSchedule:
        return l10n.themeModeScheduleDescription;
      case Settings.themeModeManual:
      default:
        return l10n.themeModeManualDescription;
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

  TimeOfDay _timeOfDayFromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  Future<void> _pickThemeTime(
    BuildContext context, {
    required int initialMinutes,
    required ValueChanged<int> onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDayFromMinutes(initialMinutes),
    );
    if (picked == null) return;
    onSelected(picked.hour * 60 + picked.minute);
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
            if (enabled && id == BaselineModuleId.meds)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _medsCtrl(
                    settings.getModuleSetting(
                      BaselineModuleId.meds,
                      'list',
                      l10n.medsDefaultList,
                    ),
                  ),
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l10n.medsListSettingsLabel,
                    border: const OutlineInputBorder(),
                    hintText: l10n.medsEditListHint,
                  ),
                  onChanged: (value) {
                    appState.updateSettings((s) {
                      s.setModuleSetting(BaselineModuleId.meds, 'list', value);
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
                    RadioGroup<String>(
                      groupValue: settings.mentalStateMode,
                      onChanged: (value) {
                        if (value != null) {
                          appState.updateSettings((s) {
                            s.mentalStateMode = value;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text(l10n.cbtModeRightNow),
                            value: 'rightNow',
                          ),
                          RadioListTile<String>(
                            title: Text(l10n.cbtModeGoodThings),
                            value: 'goodThings',
                          ),
                          RadioListTile<String>(
                            title: Text(l10n.cbtModeThoughtLens),
                            value: 'thoughtLens',
                          ),
                        ],
                      ),
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
