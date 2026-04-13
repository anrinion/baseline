import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/food_constants.dart';
import '../modules/food_module.dart';
import '../modules/module_ids.dart';
import '../state/app_state.dart';
import '../l10n/app_localizations.dart';
import '../utils/adaptive_layout.dart';
import 'module_tile.dart';

class FoodModuleTile extends StatelessWidget {
  const FoodModuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final total = FoodCategoryDef.totalLogged(appState.todayState);
        final maxTotal = FoodCategoryDef.totalMaxPortions();
        final scheme = Theme.of(context).colorScheme;

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth - 24; // 12 padding each side
            final availableHeight = constraints.maxHeight - 24; // 12 padding each side
            final l10n = AppLocalizations.of(context)!;

            final mode = resolveStandardTileMode(
              availableWidth: availableWidth,
              availableHeight: availableHeight,
              thresholds: const AdaptiveTileThresholds(
                microHeight: 60,
                microWidth: 120,
                compactHeight: 200,
                compactWidth: 200,
                expandedHeight: 400,
                expandedWidth: 320,
              ),
            );

            if (mode == AdaptiveTileMode.micro) {
              return const ModuleTile(moduleId: BaselineModuleId.food);
            }

            final isExtended = mode == AdaptiveTileMode.expanded;

            final content = Padding(
              padding: const EdgeInsets.all(12),
              child: () {
                switch (mode) {
                  case AdaptiveTileMode.expanded:
                    return _buildExtended(context, appState, l10n, availableWidth, availableHeight);
                  case AdaptiveTileMode.medium:
                    return _buildRegular(context, appState, total, maxTotal, l10n, mode, availableWidth, availableHeight);
                  case AdaptiveTileMode.compact:
                    return _buildSmall(context, appState, total, maxTotal, l10n, mode, availableWidth, availableHeight);
                  case AdaptiveTileMode.micro:
                    return const SizedBox.shrink(); // unreachable
                }
              }(),
            );

            return Card(
              margin: const EdgeInsets.all(12),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: scheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: isExtended
                  ? content
                  : InkWell(
                      onTap: () => showFoodModule(context),
                      borderRadius: BorderRadius.circular(20),
                      child: content,
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildStandardHeader(BuildContext context, AppState appState, int total, int maxTotal, AppLocalizations l10n, AdaptiveTileMode mode, double availableWidth, double availableHeight) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.restaurant, color: scheme.primary, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.foodModuleLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
        Text(
          '$total/$maxTotal',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.primary,
          ),
        ),
        buildLayoutModeIndicator(
          context,
          mode,
          enabled: appState.settings.developerModeEnabled,
          availableWidth: availableWidth,
          availableHeight: availableHeight,
        ),
        IconButton(
          icon: Icon(Icons.help_outline, size: 20, color: scheme.outline),
          tooltip: l10n.dialogWhyThisWorks,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => showFoodSourcesHelp(context),
        ),
      ],
    );
  }

  Widget _buildSmall(
    BuildContext context,
    AppState appState,
    int total,
    int maxTotal,
    AppLocalizations l10n,
    AdaptiveTileMode mode,
    double availableWidth,
    double availableHeight,
  ) {
    final s = appState.todayState;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStandardHeader(context, appState, total, maxTotal, l10n, mode, availableWidth, availableHeight),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate if we need ultra-compact layout
              final availableHeight = constraints.maxHeight;
              final itemCount = FoodCategoryDef.all.length;
              final spacePerItem = availableHeight / itemCount;
              final useUltraCompact = spacePerItem < 32; // Very tight space

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in FoodCategoryDef.all)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: useUltraCompact ? 1 : 2,
                      ),
                      child: Row(
                        children: [
                          Icon(c.icon,
                              size: useUltraCompact ? 14 : 16,
                              color: scheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              c.title(l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: useUltraCompact ? 11 : null,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 6,
                              child: BatteryIndicator(
                                current: c.countFrom(s),
                                max: c.maxPortions,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: useUltraCompact ? 20 : 24,
                            height: useUltraCompact ? 20 : 24,
                            child: IconButton(
                              icon: Icon(Icons.add_circle,
                                  size: useUltraCompact ? 16 : 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: c.countFrom(s) >= c.maxPortions
                                  ? scheme.outline
                                  : scheme.primary,
                              onPressed: c.countFrom(s) >= c.maxPortions
                                  ? null
                                  : () => applyFoodDelta(appState, c, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegular(
    BuildContext context,
    AppState appState,
    int total,
    int maxTotal,
    AppLocalizations l10n,
    AdaptiveTileMode mode,
    double availableWidth,
    double availableHeight,
  ) {
    final s = appState.todayState;
    final scheme = Theme.of(context).colorScheme;

    // Medium mode uses compact rows (like _buildSmall) but with slightly more spacing
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStandardHeader(context, appState, total, maxTotal, l10n, mode, availableWidth, availableHeight),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final itemCount = FoodCategoryDef.all.length;
              final spacePerItem = availableHeight / itemCount;
              final useCompact = spacePerItem < 40;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in FoodCategoryDef.all)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: useCompact ? 2 : 4,
                      ),
                      child: Row(
                        children: [
                          Icon(c.icon,
                              size: useCompact ? 16 : 18,
                              color: scheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              c.title(l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: useCompact ? 12 : 13,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 6,
                              child: BatteryIndicator(
                                current: c.countFrom(s),
                                max: c.maxPortions,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: useCompact ? 24 : 28,
                            height: useCompact ? 24 : 28,
                            child: IconButton(
                              icon: Icon(Icons.add_circle,
                                  size: useCompact ? 18 : 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: c.countFrom(s) >= c.maxPortions
                                  ? scheme.outline
                                  : scheme.primary,
                              onPressed: c.countFrom(s) >= c.maxPortions
                                  ? null
                                  : () => applyFoodDelta(appState, c, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExtended(BuildContext context, AppState appState, AppLocalizations l10n, double availableWidth, double availableHeight) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant, color: scheme.primary, size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.nourishment,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: scheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            buildLayoutModeIndicator(
              context,
              AdaptiveTileMode.expanded,
              enabled: appState.settings.developerModeEnabled,
              availableWidth: availableWidth,
              availableHeight: availableHeight,
            ),
            IconButton(
              icon: Icon(Icons.help_outline, size: 22, color: scheme.outline),
              tooltip: l10n.dialogWhyThisWorks,
              onPressed: () => showFoodSourcesHelp(context),
            ),
            TextButton(
              onPressed: () => resetAllFood(appState),
              style: TextButton.styleFrom(
                foregroundColor: scheme.onSurfaceVariant,
              ),
              child: Text(l10n.resetAll),
            ),
          ],
        ),
        Divider(height: 1, color: scheme.outlineVariant),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final itemCount = FoodCategoryDef.all.length;
              final spacePerItem = availableHeight / itemCount;
              final useCompact = spacePerItem < 90; // CategoryCards need more space

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final def in FoodCategoryDef.all)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: useCompact ? 4 : 8,
                      ),
                      child: _CategoryCard(
                        category: def,
                        current: def.countFrom(appState.todayState),
                        onDelta: (d) => applyFoodDelta(appState, def, d),
                        mode: useCompact
                            ? AdaptiveTileMode.medium
                            : AdaptiveTileMode.expanded,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final FoodCategoryDef category;
  final int current;
  final void Function(int) onDelta;
  final AdaptiveTileMode mode;

  const _CategoryCard({
    required this.category,
    required this.current,
    required this.onDelta,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final max = category.maxPortions;
    final isMin = current == 0;
    final isMax = current >= max;

    final bool isExtended = mode == AdaptiveTileMode.expanded;

    return Card(
      elevation: 0,
      color: isExtended
          ? scheme.surfaceContainerLow
          : scheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, size: 24, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title(l10n),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (isExtended) ...[
                        const SizedBox(height: 2),
                        Text(
                          category.subtitle(l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BatteryIndicator(current: current, max: max),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    if (isExtended) ...[
                      StepperButton(
                        icon: Icons.remove,
                        enabled: !isMin,
                        onPressed: () => onDelta(-1),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (isExtended || mode == AdaptiveTileMode.medium) ...[
                      SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            '$current/$max',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      StepperButton(
                        icon: Icons.add,
                        enabled: !isMax,
                        onPressed: () => onDelta(1),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
