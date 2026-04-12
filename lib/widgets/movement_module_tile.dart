import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context)!;

        final hasMoved = appState.todayState.moved;
        final options = getMovementOptions(appState, l10n);

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
          mode = resolveStandardTileMode(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            thresholds: const AdaptiveTileThresholds(
              microHeight: 40,
              microWidth: 120,
              compactHeight: 100,
              compactWidth: 220,
              expandedHeight: 140,
              expandedWidth: 400,
            ),
          );
        } else {
          final List<double> textItemWidths = options.map((opt) {
            // roughly padding (16*2) + icon (18) + gap (8) = 58
            return 58.0 + AdaptiveSizing.measureTextWidth(context, opt.text, buttonTextStyle);
          }).toList();

          final expandedTextH = AdaptiveSizing.measureTextHeight(
            context,
            l10n.movementChoose,
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
                        Icon(
                          Icons.directions_walk,
                          color: scheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            BaselineModuleId.localizedLabel(l10n, BaselineModuleId.movement),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (kDebugMode) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              mode.name.substring(0, 1).toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onTertiaryContainer,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
                          onPressed: () =>
                              showModuleHelp(context, BaselineModuleId.movement),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (hasMoved)
                      _buildCompletedState(context, appState, mode, l10n)
                    else
                      _buildChoicesState(context, appState, options, mode),
                  ],
                ),
              ),
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
    AppLocalizations l10n,
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
            l10n.movementDone,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF059669),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => resetMovementExercise(appState),
            icon: const Icon(Icons.undo, size: 20),
            tooltip: l10n.dialogReset,
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
                  l10n.movementCompleted,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              Text(l10n.movementGreatJob, style: theme.textTheme.bodyMedium),
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
          child: Text(l10n.dialogReset),
        ),
      ],
    );
  }

  Widget _buildChoicesState(
    BuildContext context,
    AppState appState,
    List<MovementOption> options,
    AdaptiveTileMode mode,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mode == AdaptiveTileMode.expanded) ...[
          Text(
            l10n.movementChoose,
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
            final iconForOpt = getMovementIconByName(option.iconName);
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
                label: Text(option.text),
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
