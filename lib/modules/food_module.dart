import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'food_constants.dart';

/// Opens the Food module editor: portion steppers + battery indicators (demo-style).
void showFoodModule(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => const _FoodEditorDialog(),
  );
}

void _showFoodSources(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Why this works'),
      content: SingleChildScrollView(
        child: Text(
          '• Protein: supports satiety and steady energy.\n'
          '• Greens: fiber, vitamins, and plant variety.\n'
          '• Beans and chickpeas: fiber and plant protein.\n'
          '• Fillers: complex carbs for accessible energy.\n'
          '• Sweet treat: a small enjoyable bite can support behavioral activation — '
          'pleasure without “earning” it.\n\n'
          'This is about balance, not restriction. Non-restrictive approaches favor '
          'flexibility and self-care over rules or guilt. For personalized guidance, '
          'ask a qualified professional.',
          style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _FoodEditorDialog extends StatelessWidget {
  const _FoodEditorDialog();

  void _applyDelta(AppState app, FoodCategoryDef def, int delta) {
    app.updateTodayState((st) {
      final next = def.countFrom(st) + delta;
      def.setCount(st, next);
    });
    HapticFeedback.selectionClick();
  }

  void _resetAll(AppState app) {
    app.updateTodayState((st) {
      for (final c in FoodCategoryDef.all) {
        c.setCount(st, 0);
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final theme = Theme.of(context);

    final scheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: screenH * 0.88,
        ),
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant,
                          color: scheme.primary, size: 26),
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
                        icon: Icon(Icons.help_outline,
                            size: 22, color: scheme.outline),
                        tooltip: 'Why this works',
                        onPressed: () => _showFoodSources(context),
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
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                    child: Column(
                      children: [
                        for (final def in FoodCategoryDef.all)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FoodCategoryCard(
                              category: def,
                              current: def.countFrom(appState.todayState),
                              onDelta: (d) => _applyDelta(appState, def, d),
                            ),
                          ),
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

class _FoodCategoryCard extends StatelessWidget {
  final FoodCategoryDef category;
  final int current;
  final void Function(int delta) onDelta;

  const _FoodCategoryCard({
    required this.category,
    required this.current,
    required this.onDelta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = category.maxPortions;
    final isMin = current == 0;
    final isMax = current >= max;

    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      const SizedBox(height: 2),
                      Text(
                        category.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
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
                    _StepperButton(
                      icon: Icons.remove,
                      enabled: !isMin,
                      onPressed: () => onDelta(-1),
                    ),
                    const SizedBox(width: 10),
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
