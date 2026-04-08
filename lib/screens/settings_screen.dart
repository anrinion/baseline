import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_ids.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

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
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Language
          Text('Language', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
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

          SizedBox(height: 24),

          // Theme
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
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

          SizedBox(height: 24),

          // "I'm here" text
          Text('"I’m here" button text',
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          TextField(
            controller:
                TextEditingController(text: settings.hereButtonText),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "I'm here",
            ),
            onChanged: (value) {
              appState.updateSettings((s) {
                s.hereButtonText = value;
              });
            },
          ),

          SizedBox(height: 24),

          // Modules on main screen
          Text('Modules', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 4),
          Text(
            'Turn off anything you do not need. The layout keeps room for what stays on.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 8),
          for (final id in BaselineModuleId.all)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(BaselineModuleId.label(id)),
              value: settings.isModuleEnabled(id),
              onChanged: (on) {
                appState.updateSettings((s) {
                  s.setModuleEnabled(id, on);
                });
              },
            ),

          SizedBox(height: 24),

          // Reset button
          ElevatedButton(
            onPressed: () {
              appState.resetTodayManual();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Today reset')),
              );
            },
            child: Text('Reset today'),
          ),

          SizedBox(height: 24),

          // About
          Text(
            'Baseline is a private, present-moment self-care app.\n'
            'No history. No tracking. Just today.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}