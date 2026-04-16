import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/module_ids.dart';
import '../modules/movement_module.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import '../utils/layout_constants.dart';
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

        final available = calculateModuleTileAvailableSpace(constraints);

        final mode = resolveStandardTileMode(
          availableWidth: available.width,
          availableHeight: available.height,
          thresholds: standardModuleTileThresholds,
        );

        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.movement);
        }

        return TileCard(
          isCompact: mode.isCompact,
          child: Padding(
            padding: EdgeInsets.all(TilePadding.forMode(mode)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header remains unchanged
                Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: scheme.primary,
                      size: TileIconSizes.forMode(mode),
                    ),
                    const SizedBox(width: TileSpacing.medium),
                    Expanded(
                      child: Text(
                        BaselineModuleId.localizedLabel(
                          l10n,
                          BaselineModuleId.movement,
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          fontSize: mode.isCompact
                              ? TileFontSizes.compactHeader
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    TileModeIndicator(mode: mode),
                    TileHelpButton(
                      moduleId: BaselineModuleId.movement,
                      compact: mode.isCompact,
                    ),
                  ],
                ),
                const SizedBox(height: TileSpacing.small),
                Expanded(
                  child: Center(
                    child: hasMoved
                        ? _buildCompletedState(context, appState, mode, l10n)
                        : _buildChoicesState(context, appState, options, mode),
                  ),
                ),
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
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
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
              borderRadius: BorderRadius.circular(TileBorderRadius.button),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context)!;

        if (mode == AdaptiveTileMode.compact || constraints.maxHeight < 80) {
          // Compact: icon buttons with optional overflow chip
          final limit = 3;
          final visibleOptions = options.take(limit).toList();
          final hiddenCount = options.length - visibleOptions.length;

          final buttonHeight = constraints.maxHeight.clamp(32.0, 56.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...visibleOptions.map((option) {
                final iconForOpt = getMovementIconByName(option.iconName);
                return Expanded(
                  child: TileAdaptiveIconButton(
                    onTap: () => completeMovementExercise(appState),
                    maxHeight: buttonHeight,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(iconForOpt, color: scheme.onPrimaryContainer),
                  ),
                );
              }),
              if (hiddenCount > 0)
                Expanded(
                  child: TileAdaptiveIconButton(
                    onTap: () => showMovementModule(context),
                    maxHeight: buttonHeight,
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Text(
                      '+$hiddenCount',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
            ],
          );
        }

        // Medium or Expanded: show buttons with text, adapt to available width
        // Determine how many options to show based on width
        final availableWidth = constraints.maxWidth;
        int limit;
        if (mode == AdaptiveTileMode.expanded) {
          limit = availableWidth > 350 ? 5 : (availableWidth > 250 ? 4 : 3);
        } else {
          limit = availableWidth > 250 ? 3 : 2;
        }

        final visibleOptions = options.take(limit).toList();
        final hiddenCount = options.length - visibleOptions.length;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mode == AdaptiveTileMode.expanded) ...[
              Text(
                l10n.movementChoose,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontSize: TileFontSizes.labelSmall,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: TileSpacing.small),
            ],
            Wrap(
              spacing: TileSpacing.normal,
              runSpacing: TileSpacing.small,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                ...visibleOptions.map((option) {
                  return _ChoiceButton(
                    option: option,
                    onPressed: () => completeMovementExercise(appState),
                  );
                }),
                if (hiddenCount > 0)
                  ActionChip(
                    label: Text(
                      '+$hiddenCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => showMovementModule(context),
                    backgroundColor: scheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: TilePadding.small,
                      vertical: 2,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// A button that displays an icon + label, with text overflow handling.
class _ChoiceButton extends StatelessWidget {
  final MovementOption option;
  final VoidCallback onPressed;

  const _ChoiceButton({required this.option, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = getMovementIconByName(option.iconName);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: TileIconSizes.small),
        label: Text(
          option.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: TileFontSizes.labelSmall),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: TilePadding.small,
            vertical: TilePadding.compact,
          ),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TileBorderRadius.chip),
          ),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
