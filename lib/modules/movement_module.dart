import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'module_help.dart';
import 'module_ids.dart';

/// Opens the Movement module editor.
void showMovementModule(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => const _MovementEditorDialog(),
  );
}

void completeMovementExercise(AppState appState) {
  appState.updateTodayState((state) {
    state.moved = true;
  });
  HapticFeedback.selectionClick();
}

void resetMovementExercise(AppState appState) {
  appState.updateTodayState((state) {
    state.moved = false;
  });
  HapticFeedback.lightImpact();
}

IconData iconForMovementOption(String option) {
  final lower = option.toLowerCase();
  if (lower.contains('walk') || lower.contains('stroll')) return Icons.directions_walk;
  if (lower.contains('run') || lower.contains('jog')) return Icons.directions_run;
  if (lower.contains('yoga') || lower.contains('stretch')) return Icons.self_improvement;
  if (lower.contains('bike') || lower.contains('cycle')) return Icons.directions_bike;
  if (lower.contains('swim')) return Icons.pool;
  return Icons.fitness_center;
}

List<String> getMovementOptions(AppState appState) {
  final optionsString = appState.settings.getModuleSetting(
    BaselineModuleId.movement,
    'options',
    'Go for a walk\nLight workout',
  );
  final options = optionsString
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (options.isEmpty) {
    options.addAll(['Go for a walk', 'Light workout']);
  }
  return options;
}

class _MovementEditorDialog extends StatelessWidget {
  const _MovementEditorDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            final hasMoved = appState.todayState.moved;
            final options = getMovementOptions(appState);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk,
                          color: scheme.primary, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        'Movement',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.help_outline,
                            size: 22, color: scheme.outline),
                        tooltip: 'Why this works',
                        onPressed: () => showModuleHelp(context, BaselineModuleId.movement),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: hasMoved
                        ? Column(
                            key: const ValueKey('completed'),
                            children: [
                              const Icon(Icons.celebration,
                                  size: 48, color: Color(0xFF059669)),
                              const SizedBox(height: 12),
                              Text(
                                'You completed an activity today. That’s wonderful! 💪',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton(
                                onPressed: () => resetMovementExercise(appState),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: scheme.onSurfaceVariant,
                                  side: BorderSide(color: scheme.outlineVariant),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: const Text('Reset'),
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey('choices'),
                            children: [
                              Text(
                                'Choose one gentle activity for today:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: scheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ...options.map((option) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            completeMovementExercise(appState),
                                        icon: Icon(iconForMovementOption(option), size: 20),
                                        label: Text(option),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          backgroundColor:
                                              scheme.primaryContainer,
                                          foregroundColor:
                                              scheme.onPrimaryContainer,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
