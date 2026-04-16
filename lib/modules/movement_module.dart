import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../l10n/app_localizations.dart';
import 'module_help.dart';
import 'module_ids.dart';

/// A movement option with display text and selected icon.
class MovementOption {
  final String text;
  final String iconName;

  const MovementOption({required this.text, required this.iconName});

  Map<String, dynamic> toJson() => {'text': text, 'icon': iconName};

  factory MovementOption.fromJson(Map<String, dynamic> json) {
    return MovementOption(
      text: json['text'] as String? ?? '',
      iconName: json['icon'] as String? ?? 'fitness_center',
    );
  }
}

/// Curated list of available movement icons.
/// Keywords are loaded from AppLocalizations via [getIconKeywords].
const List<Map<String, dynamic>> _movementIcons = [
  {'name': 'directions_walk', 'icon': Icons.directions_walk, 'l10nKey': 'movementMagicWalk'},
  {'name': 'directions_run', 'icon': Icons.directions_run, 'l10nKey': 'movementMagicRun'},
  {'name': 'self_improvement', 'icon': Icons.self_improvement, 'l10nKey': 'movementMagicYoga'},
  {'name': 'directions_bike', 'icon': Icons.directions_bike, 'l10nKey': 'movementMagicBike'},
  {'name': 'pool', 'icon': Icons.pool, 'l10nKey': 'movementMagicSwim'},
  {'name': 'fitness_center', 'icon': Icons.fitness_center, 'l10nKey': 'movementMagicWorkout'},
  {'name': 'sports_basketball', 'icon': Icons.sports_basketball, 'l10nKey': 'movementMagicBasketball'},
  {'name': 'sports_tennis', 'icon': Icons.sports_tennis, 'l10nKey': 'movementMagicTennis'},
  {'name': 'hiking', 'icon': Icons.hiking, 'l10nKey': 'movementMagicHike'},
  {'name': 'sports_martial_arts', 'icon': Icons.sports_martial_arts, 'l10nKey': 'movementMagicMartial'},
  {'name': 'sports_handball', 'icon': Icons.sports_handball, 'l10nKey': 'movementMagicDance'},
  {'name': 'rowing', 'icon': Icons.rowing, 'l10nKey': 'movementMagicRow'},
  {'name': 'skateboarding', 'icon': Icons.skateboarding, 'l10nKey': 'movementMagicSkate'},
  {'name': 'snowboarding', 'icon': Icons.snowboarding, 'l10nKey': 'movementMagicSki'},
  {'name': 'sports_soccer', 'icon': Icons.sports_soccer, 'l10nKey': 'movementMagicSoccer'},
];

/// Gets localized keywords for an icon from AppLocalizations.
List<String> _getLocalizedKeywords(String l10nKey, AppLocalizations l10n) {
  final String keywordsString;
  switch (l10nKey) {
    case 'movementMagicWalk':
      keywordsString = l10n.movementMagicWalk;
      break;
    case 'movementMagicRun':
      keywordsString = l10n.movementMagicRun;
      break;
    case 'movementMagicYoga':
      keywordsString = l10n.movementMagicYoga;
      break;
    case 'movementMagicBike':
      keywordsString = l10n.movementMagicBike;
      break;
    case 'movementMagicSwim':
      keywordsString = l10n.movementMagicSwim;
      break;
    case 'movementMagicWorkout':
      keywordsString = l10n.movementMagicWorkout;
      break;
    case 'movementMagicBasketball':
      keywordsString = l10n.movementMagicBasketball;
      break;
    case 'movementMagicTennis':
      keywordsString = l10n.movementMagicTennis;
      break;
    case 'movementMagicHike':
      keywordsString = l10n.movementMagicHike;
      break;
    case 'movementMagicMartial':
      keywordsString = l10n.movementMagicMartial;
      break;
    case 'movementMagicDance':
      keywordsString = l10n.movementMagicDance;
      break;
    case 'movementMagicRow':
      keywordsString = l10n.movementMagicRow;
      break;
    case 'movementMagicSkate':
      keywordsString = l10n.movementMagicSkate;
      break;
    case 'movementMagicSki':
      keywordsString = l10n.movementMagicSki;
      break;
    case 'movementMagicSoccer':
      keywordsString = l10n.movementMagicSoccer;
      break;
    default:
      return [];
  }
  return keywordsString.split(',').map((s) => s.trim().toLowerCase()).toList();
}

/// Get icon data by name.
IconData getMovementIconByName(String name) {
  final found = _movementIcons.firstWhere(
    (m) => m['name'] == name,
    orElse: () => {'icon': Icons.fitness_center},
  );
  return found['icon'] as IconData;
}

/// Get all available movement icon names.
List<String> get availableMovementIconNames =>
    _movementIcons.map((m) => m['name'] as String).toList();

/// Get icon widget for a dropdown (showing the actual icon).
Widget getMovementIconWidget(String name, {double size = 24, Color? color}) {
  return Icon(getMovementIconByName(name), size: size, color: color);
}

/// Suggest an icon based on text input and localized keywords.
/// Returns the icon name that best matches, or 'fitness_center' as default.
String suggestIconForMovement(String text, AppLocalizations l10n) {
  if (text.isEmpty) return 'fitness_center';
  final lower = text.toLowerCase();

  // Check against curated icon keywords from localization
  for (final iconData in _movementIcons) {
    final l10nKey = iconData['l10nKey'] as String;
    final keywords = _getLocalizedKeywords(l10nKey, l10n);
    for (final keyword in keywords) {
      if (lower.contains(keyword)) {
        return iconData['name'] as String;
      }
    }
  }

  return 'fitness_center';
}

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

@Deprecated('Use MovementOption.iconName with getMovementIconByName instead')
IconData iconForMovementOption(String option) {
  final lower = option.toLowerCase();
  if (lower.contains('walk') || lower.contains('stroll')) return Icons.directions_walk;
  if (lower.contains('run') || lower.contains('jog')) return Icons.directions_run;
  if (lower.contains('yoga') || lower.contains('stretch')) return Icons.self_improvement;
  if (lower.contains('bike') || lower.contains('cycle')) return Icons.directions_bike;
  if (lower.contains('swim')) return Icons.pool;
  return Icons.fitness_center;
}

/// Parse movement options from settings JSON.
/// Falls back to legacy newline-separated format if JSON parsing fails.
List<MovementOption> getMovementOptions(AppState appState, AppLocalizations l10n) {
  final optionsJson = appState.settings.getModuleSetting(
    BaselineModuleId.movement,
    'options_v2',
    '',
  );

  // Try to parse as JSON first
  if (optionsJson.isNotEmpty) {
    try {
      final decoded = jsonDecode(optionsJson);
      if (decoded is List) {
        return decoded
            .map((item) => MovementOption.fromJson(item as Map<String, dynamic>))
            .where((option) => option.text.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Fall through to legacy parsing
    }
  }

  // Legacy fallback: newline-separated text with auto-detected icons
  final optionsString = appState.settings.getModuleSetting(
    BaselineModuleId.movement,
    'options',
    l10n.movementDefaultOptions,
  );
  final lines = optionsString
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    lines.addAll(l10n.movementDefaultOptions.split('\n'));
  }

  return lines.map((text) => MovementOption(
    text: text,
    iconName: suggestIconForMovement(text, l10n),
  )).toList();
}

/// Serialize movement options to JSON for storage.
String movementOptionsToJson(List<MovementOption> options) {
  return jsonEncode(options.map((o) => o.toJson()).toList());
}

/// Get default movement options with suggested icons.
List<MovementOption> getDefaultMovementOptions(AppLocalizations l10n) {
  return l10n.movementDefaultOptions
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map((text) => MovementOption(
            text: text,
            iconName: suggestIconForMovement(text, l10n),
          ))
      .toList();
}

@Deprecated('Use getMovementOptions which returns MovementOption objects')
List<String> getMovementOptionsLegacy(AppState appState, AppLocalizations l10n) {
  return getMovementOptions(appState, l10n).map((o) => o.text).toList();
}

class _MovementEditorDialog extends StatelessWidget {
  const _MovementEditorDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
            final options = getMovementOptions(appState, l10n);

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
                        l10n.movementTitle,
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
                        tooltip: l10n.dialogWhyThisHelps,
                        onPressed: () => showModuleHelp(context, BaselineModuleId.movement),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
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
                                    l10n.movementCompleted,
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
                                    child: Text(l10n.dialogReset),
                                  ),
                                ],
                              )
                            : Column(
                                key: const ValueKey('choices'),
                                children: [
                                  Text(
                                    l10n.movementChoose,
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
                                            icon: Icon(getMovementIconByName(option.iconName), size: 20),
                                            label: Text(option.text),
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
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.dialogClose),
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
