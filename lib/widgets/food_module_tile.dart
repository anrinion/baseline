import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../modules/food_constants.dart';
import '../modules/food_module.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import 'module_tile.dart';

class FoodModuleTile extends StatelessWidget {
  const FoodModuleTile({super.key});

  void _resetAll(AppState app) {
    app.updateTodayState((st) {
      for (final c in FoodCategoryDef.all) {
        c.setCount(st, 0);
      }
    });
    HapticFeedback.lightImpact();
  }

  double measureExtendedModeHeight(BuildContext context, double w) {
    final innerW = w - 48;
    if (innerW <= 0) return double.infinity;

    final textW = innerW - 32 - 24 - 12;
    if (textW <= 0) return double.infinity;

    double contentH = 60 + 24 + 1;
    final tStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final sStyle = Theme.of(context).textTheme.bodySmall;

    for (final c in FoodCategoryDef.all) {
      double titleH = AdaptiveSizing.measureTextHeight(
        context,
        c.title,
        tStyle,
        textW,
      );
      double subH = AdaptiveSizing.measureTextHeight(
        context,
        c.subtitle,
        sStyle,
        textW,
      );

      double row1H = (titleH + 2 + subH);
      if (row1H < 24.0) row1H = 24.0;

      double cardH = 32.0 + row1H + 16.0 + 36.0;
      contentH += cardH + 10.0;
    }

    return 48 + contentH;
  }

  double measureRegularModeHeight(BuildContext context, double w) {
    final innerW = w - 48;
    if (innerW <= 0) return double.infinity;

    final textW = innerW - 32 - 24 - 12;
    if (textW <= 0) return double.infinity;

    double contentH = 36 + 12;
    final tStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    for (final c in FoodCategoryDef.all) {
      double titleH = AdaptiveSizing.measureTextHeight(
        context,
        c.title,
        tStyle,
        textW,
      );
      double row1H = titleH < 24.0 ? 24.0 : titleH;

      double cardH = 32.0 + row1H + 16.0 + 36.0;
      contentH += cardH + 8.0;
    }

    return 48 + contentH;
  }

  double measureSmallModeHeight(BuildContext context, double w) {
    final innerW = w - 48;
    if (innerW <= 0) return double.infinity;

    final availableForExpanded = innerW - 32 - 28; // 28 = plus button + gap
    final textW = availableForExpanded * 3 / 7;
    if (textW <= 0) return double.infinity;

    double contentH = 36 + 8;

    final tStyle = Theme.of(context).textTheme.labelMedium;
    for (final c in FoodCategoryDef.all) {
      double titleH = AdaptiveSizing.measureTextHeight(
        context,
        c.title,
        tStyle,
        textW,
      );
      contentH += (titleH < 16.0 ? 16.0 : titleH) + 8.0;
    }

    return 48 + contentH;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final total = FoodCategoryDef.totalLogged(appState.todayState);
        final maxTotal = FoodCategoryDef.totalMaxPortions();
        final scheme = Theme.of(context).colorScheme;

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            AdaptiveTileMode mode = AdaptiveTileMode.micro;

            final extendedH = measureExtendedModeHeight(
              context,
              availableWidth,
            );
            final regularH = measureRegularModeHeight(context, availableWidth);
            final smallH = measureSmallModeHeight(context, availableWidth);

            if (availableHeight >= extendedH && availableWidth >= 320) {
              mode = AdaptiveTileMode.expanded;
            } else if (availableHeight >= regularH && availableWidth >= 280) {
              mode = AdaptiveTileMode.medium;
            } else if (availableHeight >= smallH && availableWidth >= 160) {
              mode = AdaptiveTileMode.compact;
            }

            final isExtended = mode == AdaptiveTileMode.expanded;

            final content = Padding(
              padding: const EdgeInsets.all(12),
              child: () {
                switch (mode) {
                  case AdaptiveTileMode.expanded:
                    return _buildExtended(context, appState);
                  case AdaptiveTileMode.medium:
                    return _buildRegular(context, appState, total, maxTotal);
                  case AdaptiveTileMode.compact:
                    return _buildSmall(context, appState, total, maxTotal);
                  case AdaptiveTileMode.micro:
                    return _buildMicro(context, scheme, total, maxTotal);
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

  Widget _buildStandardHeader(BuildContext context, int total, int maxTotal) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.restaurant, color: scheme.primary, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Food',
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
        IconButton(
          icon: Icon(Icons.help_outline, size: 20, color: scheme.outline),
          tooltip: 'Why this works',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => showFoodSourcesHelp(context),
        ),
      ],
    );
  }

  Widget _buildMicro(
    BuildContext context,
    ColorScheme scheme,
    int total,
    int maxTotal,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.restaurant, color: scheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          '$total/$maxTotal',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSmall(
    BuildContext context,
    AppState appState,
    int total,
    int maxTotal,
  ) {
    final s = appState.todayState;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStandardHeader(context, total, maxTotal),
        const SizedBox(height: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final c in FoodCategoryDef.all)
                Row(
                  children: [
                    Icon(c.icon, size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        c.title,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 6,
                        child: _BatteryIndicator(
                          current: c.countFrom(s),
                          max: c.maxPortions,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        icon: const Icon(Icons.add_circle, size: 18),
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
            ],
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStandardHeader(context, total, maxTotal),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final def in FoodCategoryDef.all)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CategoryCard(
                      category: def,
                      current: def.countFrom(appState.todayState),
                      onDelta: (d) => applyFoodDelta(appState, def, d),
                      mode: AdaptiveTileMode.medium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtended(BuildContext context, AppState appState) {
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
            Text(
              'Nourishment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.help_outline, size: 22, color: scheme.outline),
              tooltip: 'Why this works',
              onPressed: () => showFoodSourcesHelp(context),
            ),
            TextButton(
              onPressed: () => _resetAll(appState),
              style: TextButton.styleFrom(
                foregroundColor: scheme.onSurfaceVariant,
              ),
              child: const Text('Reset all'),
            ),
          ],
        ),
        Divider(height: 1, color: scheme.outlineVariant),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final def in FoodCategoryDef.all)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CategoryCard(
                      category: def,
                      current: def.countFrom(appState.todayState),
                      onDelta: (d) => applyFoodDelta(appState, def, d),
                      mode: AdaptiveTileMode.expanded,
                    ),
                  ),
              ],
            ),
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
                        category.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (isExtended) ...[
                        const SizedBox(height: 2),
                        Text(
                          category.subtitle,
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
                  child: _BatteryIndicator(current: current, max: max),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    if (isExtended) ...[
                      _StepperButton(
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
                      _StepperButton(
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

class _BatteryIndicator extends StatelessWidget {
  final int current;
  final int max;

  const _BatteryIndicator({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = scheme.outlineVariant;

    return Row(
      children: List.generate(max, (index) {
        final filled = index < current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 8,
            decoration: BoxDecoration(
              color: filled ? scheme.primary : empty,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(30),
        splashColor: scheme.primary.withValues(alpha: 0.2),
        highlightColor: scheme.primary.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? scheme.primary : scheme.outline,
          ),
        ),
      ),
    );
  }
}
