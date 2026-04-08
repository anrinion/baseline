import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_ids.dart';
import '../state/app_state.dart';
import '../state/settings.dart';

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

  final List<Map<String, String>> languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ru', 'label': 'Русский'},
    {'code': 'es', 'label': 'Español'},
    {'code': 'de', 'label': 'Deutsch'},
    {'code': 'fr', 'label': 'Français'},
    {'code': 'pl', 'label': 'Polski'}, // placeholder, adjustable
  ];

  final List<Map<String, String>> themes = [
    {'key': 'light1', 'label': 'Light (Neutral)'},
    {'key': 'light2', 'label': 'Light (Warm)'},
    {'key': 'dark1', 'label': 'Dark (True)'},
    {'key': 'dark2', 'label': 'Dark (Soft)'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final settings = appState.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: settings.language,
            isExpanded: true,
            items: languages.map((lang) {
              return DropdownMenuItem(
                value: lang['code'],
                child: Text(lang['label']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                appState.updateSettings((s) {
                  s.language = value;
                });
              }
            },
          ),

          const SizedBox(height: 24),

          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Column(
            children: themes.map((theme) {
              return RadioListTile<String>(
                title: Text(theme['label']!),
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

          Text('Modules', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Turn modules on or off. Optional settings appear under each one.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

          for (final id in BaselineModuleId.all) _moduleCard(context, appState, settings, id),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              appState.resetTodayManual();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Today reset')),
              );
            },
            child: const Text('Reset today'),
          ),

          const SizedBox(height: 24),

          const Text(
            'Baseline is a private, present-moment self-care app.\n'
            'No history. No tracking. Just today.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    AppState appState,
    Settings settings,
    String id,
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
              title: Text(BaselineModuleId.label(id)),
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
                  decoration: const InputDecoration(
                    labelText: 'Button label',
                    border: OutlineInputBorder(),
                    hintText: "I'm here. I'm alive.",
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
                      'Go for a walk\nLight workout',
                    ),
                  ),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Movement choices (one per line)',
                    border: OutlineInputBorder(),
                    hintText: 'Go for a walk\nLight workout',
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
          ],
        ),
      ),
    );
  }
}
