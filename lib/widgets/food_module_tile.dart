import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/food_constants.dart';
import '../modules/food_module.dart';
import '../state/app_state.dart';

/// Main-grid tile: at-a-glance food portions; tap opens the full editor.
class FoodModuleTile extends StatelessWidget {
  const FoodModuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final s = appState.todayState;
        final total = FoodCategoryDef.totalLogged(s);
        final maxTotal = FoodCategoryDef.totalMaxPortions();

        final scheme = Theme.of(context).colorScheme;

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
            onTap: () => showFoodModule(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        color: scheme.primary,
                        size: 20,
                      ),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final c in FoodCategoryDef.all)
                          _GlanceBatteryRow(
                            icon: c.icon,
                            current: c.countFrom(s),
                            max: c.maxPortions,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Tap to log',
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
      },
    );
  }
}

class _GlanceBatteryRow extends StatelessWidget {
  final IconData icon;
  final int current;
  final int max;

  const _GlanceBatteryRow({
    required this.icon,
    required this.current,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = scheme.outlineVariant;

    return Row(
      children: [
        Icon(icon, size: 14, color: scheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: List.generate(max, (index) {
              final filled = index < current;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? scheme.primary : empty,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
