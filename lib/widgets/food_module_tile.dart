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
              final availableWidth = constraints.maxWidth;
              final itemCount = FoodCategoryDef.all.length;
              final spacePerItem = availableHeight / itemCount;
              final useUltraCompact = spacePerItem < 28; // Very tight space
              final hasExtraSpace = spacePerItem > 40;

              // If extremely tight width, hide labels to save space
              final hideLabels = availableWidth < 180;

              return Column(
                mainAxisAlignment: hasExtraSpace ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  for (final c in FoodCategoryDef.all)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: useUltraCompact ? 0 : 1,
                      ),
                      child: Row(
                        children: [
                          Icon(c.icon,
                              size: useUltraCompact ? 12 : 14,
                              color: scheme.primary),
                          const SizedBox(width: 6),
                          if (!hideLabels)
                            Expanded(
                              flex: 3,
                              child: Text(
                                c.title(l10n),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: useUltraCompact ? 10 : 11,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (!hideLabels) const SizedBox(width: 6),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: useUltraCompact ? 4 : 5,
                              child: BatteryIndicator(
                                current: c.countFrom(s),
                                max: c.maxPortions,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            width: useUltraCompact ? 18 : 20,
                            height: useUltraCompact ? 18 : 20,
                            child: IconButton(
                              icon: Icon(Icons.add_circle,
                                  size: useUltraCompact ? 14 : 16),
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

              // Use spaceEvenly if there's extra room, otherwise pack at top
              final hasExtraSpace = spacePerItem > 50;
              
              return Column(
                mainAxisAlignment: hasExtraSpace ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
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
    final s = appState.todayState;
    final scheme = Theme.of(context).colorScheme;

    // Extended mode is like medium mode but with food subtitles (labels) shown
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStandardHeader(context, appState, 0, 0, l10n, AdaptiveTileMode.expanded, availableWidth, availableHeight),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final itemCount = FoodCategoryDef.all.length;
              final spacePerItem = availableHeight / itemCount;
              final useCompact = spacePerItem < 50;

              final hasExtraSpace = spacePerItem > 60;

              return Column(
                mainAxisAlignment: hasExtraSpace ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  for (final c in FoodCategoryDef.all)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: useCompact ? 2 : 4,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(c.icon,
                              size: useCompact ? 18 : 20,
                              color: scheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.title(l10n),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: scheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: useCompact ? 13 : 14,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Show subtitle (food labels/comments) - this is the only difference from medium mode
                                Text(
                                  c.subtitle(l10n),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: useCompact ? 10 : 11,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: useCompact ? 6 : 8,
                              child: BatteryIndicator(
                                current: c.countFrom(s),
                                max: c.maxPortions,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: useCompact ? 28 : 32,
                            height: useCompact ? 28 : 32,
                            child: IconButton(
                              icon: Icon(Icons.add_circle,
                                  size: useCompact ? 20 : 22),
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
}
