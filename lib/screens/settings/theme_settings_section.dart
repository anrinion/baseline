import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../state/settings.dart';
import '../../l10n/app_localizations.dart';

/// Theme settings section including mode selection, manual/dark variants,
/// and schedule time pickers.
class ThemeSettingsSection extends StatelessWidget {
  final AppState appState;
  final Settings settings;
  final AppLocalizations l10n;

  const ThemeSettingsSection({
    super.key,
    required this.appState,
    required this.settings,
    required this.l10n,
  });

  static const List<String> lightThemes = ['light1', 'light2'];
  static const List<String> darkThemes = ['dark1', 'dark2'];
  static const List<String> themeModes = [
    Settings.themeModeManual,
    Settings.themeModeDevice,
    Settings.themeModeSchedule,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.themeLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.themeBehaviorHelp,
          style: theme.textTheme.bodySmall,
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
            style: theme.textTheme.bodyMedium,
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
          style: theme.textTheme.titleSmall,
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
          style: theme.textTheme.titleSmall,
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
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.themeScheduleLightStarts),
            subtitle: Text(
              MaterialLocalizations.of(context).formatTimeOfDay(
                _timeOfDayFromMinutes(settings.scheduleLightStartMinutes),
                alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
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
                alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
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
      ],
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
}
