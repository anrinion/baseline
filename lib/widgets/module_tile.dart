import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/mental_state_module.dart';
import '../modules/meds_module.dart';
import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../modules/movement_module.dart';
import '../modules/sleep_module.dart';
import '../state/app_state.dart';

class ModuleTile extends StatelessWidget {
  final String moduleId;

  const ModuleTile({super.key, required this.moduleId});

  static IconData iconFor(String id) {
    switch (id) {
      case BaselineModuleId.mentalState:
        return Icons.psychology_outlined;
      case BaselineModuleId.sleep:
        return Icons.bedtime_outlined;
      case BaselineModuleId.meds:
        return Icons.medication_outlined;
      case BaselineModuleId.movement:
        return Icons.directions_walk;
      case BaselineModuleId.here:
        return Icons.center_focus_strong_outlined;
      case BaselineModuleId.food:
        return Icons.restaurant;
      default:
        return Icons.widgets_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final label = BaselineModuleId.localizedLabel(l10n, moduleId);

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _openModule(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: ClipRect(
            child: OverflowBox(
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(iconFor(moduleId), color: scheme.primary, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.help_outline,
                          size: 20,
                          color: scheme.outline,
                        ),
                        tooltip: l10n.dialogWhyThisHelps,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed: () => showModuleHelp(context, moduleId),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tapToOpen,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openModule(BuildContext context) {
    if (moduleId == BaselineModuleId.movement) {
      showMovementModule(context);
      return;
    }

    if (moduleId == BaselineModuleId.mentalState) {
      showMentalStateModule(context);
      return;
    }

    if (moduleId == BaselineModuleId.sleep) {
      showSleepModule(context);
      return;
    }
    if (moduleId == BaselineModuleId.meds) {
      showMedsModule(context);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => _ModulePlaceholderModal(moduleId: moduleId),
    );
  }
}

class _ModulePlaceholderModal extends StatelessWidget {
  final String moduleId;

  const _ModulePlaceholderModal({required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final label = BaselineModuleId.localizedLabel(l10n, moduleId);

    return AlertDialog(
      title: Text(label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.help_outline, size: 18),
              label: Text(l10n.dialogWhyThisHelps),
              onPressed: () => showModuleHelp(context, moduleId),
            ),
          ),
          Text(l10n.placeholderModuleText),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              appState.updateTodayState((state) {
                state.cbtTemp = l10n.simulateActionResult(label);
              });
            },
            child: Text(l10n.simulateAction),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.stateLabel} ${appState.todayState.cbtTemp}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogClose),
        ),
      ],
    );
  }
}
