import 'package:flutter/material.dart';

import '../../modules/module_ids.dart';
import '../../state/app_state.dart';
import '../../state/settings.dart';
import '../../l10n/app_localizations.dart';
import 'movement_options_editor.dart';

/// Module settings section with toggle cards for each module.
/// Shows module-specific settings when a module is enabled.
class ModuleSettingsSection extends StatelessWidget {
  final AppState appState;
  final Settings settings;
  final AppLocalizations l10n;
  final TextEditingController? hereButtonController;
  final TextEditingController? medsListController;
  final ValueChanged<TextEditingController> onHereControllerCreated;
  final ValueChanged<TextEditingController> onMedsControllerCreated;

  const ModuleSettingsSection({
    super.key,
    required this.appState,
    required this.settings,
    required this.l10n,
    this.hereButtonController,
    this.medsListController,
    required this.onHereControllerCreated,
    required this.onMedsControllerCreated,
  });

  TextEditingController _getHereCtrl(String currentText) {
    if (hereButtonController == null) {
      final controller = TextEditingController(text: currentText);
      onHereControllerCreated(controller);
      return controller;
    }
    return hereButtonController!;
  }

  TextEditingController _getMedsCtrl(String currentText) {
    if (medsListController == null) {
      final controller = TextEditingController(text: currentText);
      onMedsControllerCreated(controller);
      return controller;
    }
    return medsListController!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
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
                  controller: _getHereCtrl(settings.hereButtonText),
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
                  controller: _getMedsCtrl(
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
                      l10n.mentalStateSettingDescription,
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
                            title: Text(l10n.mentalStateRightNow),
                            value: 'rightNow',
                          ),
                          RadioListTile<String>(
                            title: Text(l10n.mentalStateGoodThing),
                            value: 'goodThings',
                          ),
                          RadioListTile<String>(
                            title: Text(l10n.mentalStateThoughtLens),
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
