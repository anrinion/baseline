import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../modules/movement_module.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import 'module_tile.dart';

class MovementModuleTile extends StatelessWidget {
  const MovementModuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appState = Provider.of<AppState>(context);
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

        final hasMoved = appState.todayState.moved;
        final options = getMovementOptions(appState);

        final availableWidth =
            constraints.maxWidth - 32; // 16 padding on each side
        final availableHeight =
            constraints.maxHeight - 64; // rough header/margins

        AdaptiveTileMode mode = AdaptiveTileMode.medium;
        final buttonTextStyle =
            theme.textTheme.labelLarge ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

        if (hasMoved) {
          // Standard check for "completed" state space since it's quite fixed.
          if (availableHeight < 40 || availableWidth < 120) {
            mode = AdaptiveTileMode.micro;
          } else if (availableHeight < 100 || availableWidth < 220) {
            mode = AdaptiveTileMode.compact;
          } else if (availableWidth >= 400 && availableHeight >= 140) {
            mode = AdaptiveTileMode.expanded;
          }
        } else {
          final List<double> textItemWidths = options.map((opt) {
            // roughly padding (16*2) + icon (18) + gap (8) = 58
            return 58.0 + AdaptiveSizing.measureTextWidth(context, opt, buttonTextStyle);
          }).toList();

          final expandedTextH = AdaptiveSizing.measureTextHeight(
            context,
            'Choose one gentle activity for today:',
            theme.textTheme.bodyMedium,
            availableWidth,
          );

          // Wrap requires constraints
          final requiredExpandedHeight =
              expandedTextH +
              12 +
              AdaptiveSizing.calculateWrapHeight(textItemWidths, availableWidth, 40, 8, 8);
          final requiredMediumHeight = AdaptiveSizing.calculateWrapHeight(
            textItemWidths,
            availableWidth,
            40,
            8,
            8,
          );
          final requiredCompactHeight = AdaptiveSizing.calculateWrapHeight(
            List.filled(options.length, 48.0),
            availableWidth,
            48,
            8,
            8,
          );

          bool anyItemTooWide = textItemWidths.any((w) => w > availableWidth);

          if (!anyItemTooWide &&
              availableHeight >= requiredExpandedHeight &&
              availableWidth >= 350) {
            mode = AdaptiveTileMode.expanded;
          } else if (!anyItemTooWide &&
              availableHeight >= requiredMediumHeight &&
              availableWidth >= 200) {
            // Medium mode (Textual buttons, no extra expanded heading) fits nicely
            mode = AdaptiveTileMode.medium;
          } else if (availableHeight >= requiredCompactHeight &&
              availableWidth >= 48) {
            // Only icons
            mode = AdaptiveTileMode.compact;
          } else {
            // Absolute emergency fallback
            mode = AdaptiveTileMode.micro;
          }
        }

        if (mode == AdaptiveTileMode.micro) {
          // Micro: use standard tile that opens a popup.
          return const ModuleTile(moduleId: BaselineModuleId.movement);
        }

        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: scheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: scheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        BaselineModuleId.label(BaselineModuleId.movement),
                        style: theme.textTheme.titleSmall?.copyWith(
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
                      onPressed: () =>
                          showModuleHelp(context, BaselineModuleId.movement),
                    ),
                  ],
                ),
                const Expanded(child: SizedBox(height: 8)),
                if (hasMoved)
                  _buildCompletedState(context, appState, mode)
                else
                  _buildChoicesState(context, appState, options, mode),
                const Expanded(child: SizedBox(height: 8)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    AppState appState,
    AdaptiveTileMode mode,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (mode == AdaptiveTileMode.compact) {
      // Compact: check icon with text and undo button
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 24, color: Color(0xFF059669)),
          const SizedBox(width: 8),
          Text(
            'Done',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF059669),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => resetMovementExercise(appState),
            icon: const Icon(Icons.undo, size: 20),
            tooltip: 'Reset',
          ),
        ],
      );
    }

    // Medium or Expanded
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 32, color: Color(0xFF059669)),
            const SizedBox(width: 12),
            if (mode == AdaptiveTileMode.expanded)
              Expanded(
                child: Text(
                  'You completed an activity today. That’s wonderful! 💪',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              Text('Great job! 💪', style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
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
    );
  }

  Widget _buildChoicesState(
    BuildContext context,
    AppState appState,
    List<String> options,
    AdaptiveTileMode mode,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mode == AdaptiveTileMode.expanded) ...[
          Text(
            'Choose one gentle activity for today:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: options.map((option) {
            final iconForOpt = iconForMovementOption(option);
            if (mode == AdaptiveTileMode.compact) {
              return Material(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => completeMovementExercise(appState),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(iconForOpt, color: scheme.onPrimaryContainer),
                  ),
                ),
              );
            } else {
              return ElevatedButton.icon(
                onPressed: () => completeMovementExercise(appState),
                icon: Icon(iconForOpt, size: 18),
                label: Text(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  elevation: 0,
                ),
              );
            }
          }).toList(),
        ),
      ],
    );
  }
}
