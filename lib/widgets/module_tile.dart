import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_help.dart';
import '../modules/module_ids.dart';
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
      case BaselineModuleId.food:
        return Icons.restaurant;
      default:
        return Icons.widgets_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = BaselineModuleId.label(moduleId);

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _openModule(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                    tooltip: 'Why this helps',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: () => showModuleHelp(context, moduleId),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Tap to open',
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
    );
  }

  void _openModule(BuildContext context) {
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
    final label = BaselineModuleId.label(moduleId);

    return AlertDialog(
      title: Text(label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Why this helps'),
              onPressed: () => showModuleHelp(context, moduleId),
            ),
          ),
          const Text('This is a placeholder module.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              appState.updateTodayState((state) {
                state.cbtTemp = 'Touched $label';
              });
            },
            child: const Text('Simulate action'),
          ),
          const SizedBox(height: 8),
          Text(
            'State: ${appState.todayState.cbtTemp}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        )
      ],
    );
  }
}
