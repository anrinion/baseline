import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_ids.dart';
import '../modules/movement_module.dart';
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
    _medsListController?.dispose();
    super.dispose();
  }

  TextEditingController _hereCtrl(String currentText) {
    _hereButtonController ??= TextEditingController(text: currentText);
    return _hereButtonController!;
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
                child: MovementOptionsEditor(
                  appState: appState,
                  l10n: l10n,
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

/// Editor for movement options with icon selection.
/// Shows a list where each row has a text field and icon dropdown,
/// with a trash icon to delete. New items can be added at the bottom.
class MovementOptionsEditor extends StatefulWidget {
  final AppState appState;
  final AppLocalizations l10n;

  const MovementOptionsEditor({
    super.key,
    required this.appState,
    required this.l10n,
  });

  @override
  State<MovementOptionsEditor> createState() => _MovementOptionsEditorState();
}

class _MovementOptionsEditorState extends State<MovementOptionsEditor> {
  late List<MovementOption> _options;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  late List<bool> _userOverrodeIcon;
  MovementOption? _lastDeleted;
  int? _lastDeletedIndex;
  bool _isAddingNewItem = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _loadOptions() {
    _options = getMovementOptions(widget.appState, widget.l10n);
    _syncControllers();
    _userOverrodeIcon = List.generate(_options.length, (_) => false);
  }

  void _syncControllers() {
    // Dispose old controllers
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();

    // Create new controllers
    for (final option in _options) {
      _controllers.add(TextEditingController(text: option.text));
      _focusNodes.add(FocusNode());
    }
  }

  void _saveOptions() {
    final json = movementOptionsToJson(_options);
    widget.appState.updateSettings((s) {
      s.setModuleSetting(BaselineModuleId.movement, 'options_v2', json);
    });
  }

  void _updateText(int index, String text) {
    setState(() {
      _options[index] = MovementOption(
        text: text,
        iconName: _options[index].iconName,
      );

      // Auto-suggest icon if user hasn't manually overridden
      if (!_userOverrodeIcon[index] && text.isNotEmpty) {
        final suggested = suggestIconForMovement(text, widget.l10n);
        if (suggested != _options[index].iconName) {
          _options[index] = MovementOption(
            text: text,
            iconName: suggested,
          );
        }
      }
    });
    _saveOptions();
  }

  void _updateIcon(int index, String iconName) {
    setState(() {
      _userOverrodeIcon[index] = true;
      _options[index] = MovementOption(
        text: _options[index].text,
        iconName: iconName,
      );
    });
    _saveOptions();
  }

  void _deleteOption(int index) {
    setState(() {
      _lastDeleted = _options[index];
      _lastDeletedIndex = index;

      _options.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _focusNodes[index].dispose();
      _focusNodes.removeAt(index);
      _userOverrodeIcon.removeAt(index);
    });
    _saveOptions();
    _showUndoSnackbar();
  }

  void _showUndoSnackbar() {
    final l10n = widget.l10n;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.movementItemDeleted),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.dialogCancel, // Use "Cancel" as "Undo"
          onPressed: () {
            if (_lastDeleted != null && _lastDeletedIndex != null) {
              setState(() {
                final index = _lastDeletedIndex!;
                _options.insert(index, _lastDeleted!);
                _controllers.insert(
                  index,
                  TextEditingController(text: _lastDeleted!.text),
                );
                _focusNodes.insert(index, FocusNode());
                _userOverrodeIcon.insert(index, false);
                _lastDeleted = null;
                _lastDeletedIndex = null;
              });
              _saveOptions();
            }
          },
        ),
      ),
    );
  }

  void _addNewItem() {
    _isAddingNewItem = true;
    setState(() {
      _options.add(const MovementOption(text: '', iconName: 'fitness_center'));
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _userOverrodeIcon.add(false);
    });

    // Focus the new field after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.last.requestFocus();
      }
      // Reset flag after the focus change settles
      _isAddingNewItem = false;
    });
  }

  void _commitNewItem(int index) {
    // Skip if we're explicitly adding a new item (prevents double-add)
    if (_isAddingNewItem) return;

    final text = _controllers[index].text.trim();
    if (text.isEmpty) {
      // Remove empty row if it loses focus and has no text
      if (_options.length > 1 || _options[index].text.isNotEmpty) {
        setState(() {
          _options.removeAt(index);
          _controllers[index].dispose();
          _controllers.removeAt(index);
          _focusNodes[index].dispose();
          _focusNodes.removeAt(index);
          _userOverrodeIcon.removeAt(index);
        });
        _saveOptions();
      }
    } else {
      _updateText(index, text);
      // Add another empty row if this was the last one
      if (index == _options.length - 1) {
        _addNewItem();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = widget.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.movementChoicesLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        // List of existing items
        ...List.generate(_options.length, (index) {
          return _buildOptionRow(index, theme, scheme);
        }),
        // Add new item button
        _buildNewItemRow(theme, scheme, l10n),
      ],
    );
  }

  Widget _buildOptionRow(int index, ThemeData theme, ColorScheme scheme) {
    final option = _options[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Icon dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: option.iconName,
                icon: const SizedBox.shrink(),
                isDense: true,
                items: availableMovementIconNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        getMovementIconByName(name),
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateIcon(index, value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              decoration: InputDecoration(
                hintText: widget.l10n.movementItemHint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              onChanged: (value) => _updateText(index, value),
              onSubmitted: (value) {
                _commitNewItem(index);
              },
              onTapOutside: (_) => _commitNewItem(index),
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, color: scheme.error, size: 20),
            onPressed: () => _deleteOption(index),
            tooltip: widget.l10n.dialogDelete,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildNewItemRow(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: _addNewItem,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: scheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.movementAddNewItem,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
