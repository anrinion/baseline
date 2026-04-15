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
            final availableWidth = constraints.maxWidth - 24;
            final availableHeight = constraints.maxHeight - 24;

            final mode = resolveStandardTileMode(
              availableWidth: availableWidth,
              availableHeight: availableHeight,
              thresholds: const AdaptiveTileThresholds(
                microHeight: 120,
                microWidth: 100,
                compactHeight: 160,
                compactWidth: 200,
                expandedHeight: 250,
                expandedWidth: 200,
              ),
            );

            // Micro mode delegates to a separate tile.
            if (mode == AdaptiveTileMode.micro) {
              return const ModuleTile(moduleId: BaselineModuleId.food);
            }

            final bool isExtended = mode == AdaptiveTileMode.expanded;
            final Widget content = _FoodModuleContent(
              mode: mode,
              total: total,
              maxTotal: maxTotal,
              availableWidth: availableWidth,
              availableHeight: availableHeight,
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
}

// ----------------------------------------------------------------------
// Private widget that builds the entire module content.
// This separates the layout logic from the outer tile structure.
// ----------------------------------------------------------------------
class _FoodModuleContent extends StatelessWidget {
  const _FoodModuleContent({
    required this.mode,
    required this.total,
    required this.maxTotal,
    required this.availableWidth,
    required this.availableHeight,
  });

  final AdaptiveTileMode mode;
  final int total;
  final int maxTotal;
  final double availableWidth;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;

    final hideHeader = availableHeight < 140;

    return Padding(
      padding: EdgeInsets.all(hideHeader ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hideHeader) ...[
            _Header(
              mode: mode,
              total: total,
              maxTotal: maxTotal,
              availableWidth: availableWidth,
              availableHeight: availableHeight,
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: _CategoryList(
              mode: mode,
              hideHeader: hideHeader,
              appState: appState,
              l10n: l10n,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Header row with title, counter, help button, and optional debug indicator.
// ----------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({
    required this.mode,
    required this.total,
    required this.maxTotal,
    required this.availableWidth,
    required this.availableHeight,
  });

  final AdaptiveTileMode mode;
  final int total;
  final int maxTotal;
  final double availableWidth;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();

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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
        ),
        IconButton(
          icon: Icon(
            Icons.help_outline,
            size: mode == AdaptiveTileMode.compact ? 18 : 20,
            color: scheme.outline,
          ),
          tooltip: l10n.dialogWhyThisWorks,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => showFoodSourcesHelp(context),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// List of food categories. Adapts spacing and content based on available
// height and the chosen mode (compact / medium / expanded).
// ----------------------------------------------------------------------
class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.mode,
    required this.hideHeader,
    required this.appState,
    required this.l10n,
  });

  final AdaptiveTileMode mode;
  final bool hideHeader;
  final AppState appState;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = FoodCategoryDef.all.length;
        final spacePerItem = constraints.maxHeight / itemCount;

        // Determine compactness and whether extra space exists.
        final bool useUltraCompact;
        final bool useCompact;

        switch (mode) {
          case AdaptiveTileMode.compact:
            useUltraCompact = hideHeader || spacePerItem < 28;
            useCompact = true;
            break;
          case AdaptiveTileMode.medium:
            useUltraCompact = hideHeader;
            useCompact = spacePerItem < 40;
            break;
          case AdaptiveTileMode.expanded:
            useUltraCompact = false;
            useCompact = spacePerItem < 50;
            break;
          case AdaptiveTileMode.micro:
            // Not used; handled earlier.
            return const SizedBox.shrink();
        }

        // Hide labels if extremely narrow (only in compact mode).
        final hideLabels = mode == AdaptiveTileMode.compact && constraints.maxWidth < 180;

        return ClipRect(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              for (final category in FoodCategoryDef.all)
                Flexible(
                  child: _CategoryRow(
                    category: category,
                    mode: mode,
                    useCompact: useCompact,
                    useUltraCompact: useUltraCompact,
                    hideLabels: hideLabels,
                    appState: appState,
                    l10n: l10n,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// Single row for a food category: icon, title (and optional subtitle),
// battery indicator, and add button.
// ----------------------------------------------------------------------
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.mode,
    required this.useCompact,
    required this.useUltraCompact,
    required this.hideLabels,
    required this.appState,
    required this.l10n,
  });

  final FoodCategoryDef category;
  final AdaptiveTileMode mode;
  final bool useCompact;
  final bool useUltraCompact;
  final bool hideLabels;
  final AppState appState;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentCount = category.countFrom(appState.todayState);
    final maxPortions = category.maxPortions;
    final bool isMaxReached = currentCount >= maxPortions;

    // Sizing based on compactness.
    final double iconSize = useUltraCompact ? 12 : (useCompact ? (mode == AdaptiveTileMode.compact ? 14 : 16) : (mode == AdaptiveTileMode.expanded ? 20 : 18));
    final double batteryHeight = useUltraCompact ? 4 : (useCompact ? (mode == AdaptiveTileMode.compact ? 5 : 6) : 8);
    final double buttonSize = useUltraCompact ? 18 : (useCompact ? (mode == AdaptiveTileMode.compact ? 20 : 24) : 32);
    final double buttonIconSize = useUltraCompact ? 14 : (useCompact ? (mode == AdaptiveTileMode.compact ? 16 : 18) : 22);

    final titleFontSize = useUltraCompact ? 10.0 : (useCompact ? (mode == AdaptiveTileMode.compact ? 11.0 : 12.0) : 14.0);
    final subtitleFontSize = useCompact ? 10.0 : 11.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: useUltraCompact ? 0.0 : (useCompact ? 2.0 : 4.0)),
      child: Row(
        crossAxisAlignment: mode == AdaptiveTileMode.expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(category.icon, size: iconSize, color: scheme.primary),
          const SizedBox(width: 6),
          if (!hideLabels) ...[
            Expanded(
              flex: 3,
              child: mode == AdaptiveTileMode.expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title(l10n),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: titleFontSize,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          category.subtitle(l10n),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: subtitleFontSize,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : Text(
                      category.title(l10n),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: titleFontSize,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            flex: 4,
            child: SizedBox(
              height: batteryHeight,
              child: BatteryIndicator(
                current: currentCount,
                max: maxPortions,
              ),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: IconButton(
              icon: Icon(Icons.add_circle, size: buttonIconSize),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: isMaxReached ? scheme.outline : scheme.primary,
              onPressed: isMaxReached ? null : () => applyFoodDelta(appState, category, 1),
            ),
          ),
        ],
      ),
    );
  }
}