import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/food_module.dart';
import '../modules/mental_state_module.dart';
import '../modules/meds_module.dart';
import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../modules/movement_module.dart';
import '../modules/sleep_module.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import '../utils/layout_constants.dart';

class ModuleTile extends StatelessWidget {
  final String moduleId;

  const ModuleTile({super.key, required this.moduleId});

  static IconData iconFor(String id) {
    switch (id) {
      case BaselineModuleId.mentalState:
        return Icons.psychology_outlined;
      case BaselineModuleId.sleep:
        return Icons.bedtime_outlined;
      case BaselineModuleId.meds:
        return Icons.medication_outlined;
      case BaselineModuleId.movement:
        return Icons.directions_walk;
      case BaselineModuleId.here:
        return Icons.center_focus_strong_outlined;
      case BaselineModuleId.food:
        return Icons.restaurant;
      default:
        return Icons.widgets_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scheme = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context)!;
        final label = BaselineModuleId.localizedLabel(l10n, moduleId);
        final appState = Provider.of<AppState>(context);

        final availableWidth = TileAvailableSpace.width(constraints.maxWidth);
        final availableHeight = TileAvailableSpace.height(constraints.maxHeight);

        final mode = resolveStandardTileMode(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          thresholds: const AdaptiveTileThresholds(
            microHeight: 50,
            microWidth: 80,
            compactHeight: 70,
            compactWidth: 140,
            expandedHeight: 100,
            expandedWidth: 200,
          ),
        );

        return TileCard(
          isCompact: mode.isCompact,
          child: InkWell(
          onTap: () => _openModule(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: mode.isMicro
                      ? _buildMicroLayout(
                          context,
                          scheme,
                          label,
                          availableWidth,
                          availableHeight,
                        )
                      : _buildStandardLayout(
                          context,
                          scheme,
                          l10n,
                          label,
                          mode.isCompact,
                          appState,
                          mode,
                          availableWidth,
                          availableHeight,
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicroLayout(
    BuildContext context,
    ColorScheme scheme,
    String label,
    double availableWidth,
    double availableHeight,
  ) {
    // Dynamic icon sizing: min 16, max 24, scales with available space
    final iconSize = availableHeight < 32
        ? (availableHeight * 0.6).clamp(16.0, 24.0)
        : TileIconSizes.normal + 4;

    // Check if we can fit text at all (need at least ~14px for labelSmall)
    final canShowText = availableHeight >= 32;

    // Check if horizontal layout makes sense: plenty of width, limited height
    final useHorizontalLayout =
        canShowText && availableWidth >= 80 && availableHeight < 50;

    if (useHorizontalLayout) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconFor(moduleId), color: scheme.primary, size: iconSize),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
                fontSize: TileFontSizes.small,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconFor(moduleId), color: scheme.primary, size: iconSize),
        if (canShowText) ...[
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              fontSize: TileFontSizes.small,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStandardLayout(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
    String label,
    bool isCompact,
    AppState appState,
    AdaptiveTileMode mode,
    double availableWidth,
    double availableHeight,
  ) {
    final showIndicator =
        appState.settings.developerModeEnabled && availableWidth > 250;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              iconFor(moduleId),
              color: scheme.primary,
              size: isCompact ? TileIconSizes.compact : TileIconSizes.normal,
            ),
            const SizedBox(width: TileSpacing.medium),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                  fontSize: isCompact ? TileFontSizes.compactHeader : null,
                ),
              ),
            ),
            if (showIndicator)
              buildLayoutModeIndicator(context, mode, enabled: true),
            TileHelpButton(moduleId: moduleId, compact: isCompact),
          ],
        ),
        if (!isCompact) ...[
          const SizedBox(height: TileSpacing.normal),
          Text(
            l10n.tapToOpen,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: TileFontSizes.small,
            ),
          ),
        ],
      ],
    );
  }

  void _openModule(BuildContext context) {
    if (moduleId == BaselineModuleId.movement) {
      showMovementModule(context);
      return;
    }

    if (moduleId == BaselineModuleId.mentalState) {
      showMentalStateModule(context);
      return;
    }

    if (moduleId == BaselineModuleId.sleep) {
      showSleepModule(context);
      return;
    }
    if (moduleId == BaselineModuleId.meds) {
      showMedsModule(context);
      return;
    }
    if (moduleId == BaselineModuleId.food) {
      showFoodModule(context);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => _ModulePlaceholderModal(moduleId: moduleId),
    );
  }
}

class _ModulePlaceholderModal extends StatelessWidget {
  final String moduleId;

  const _ModulePlaceholderModal({required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final label = BaselineModuleId.localizedLabel(l10n, moduleId);

    return AlertDialog(
      title: Text(label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.help_outline, size: 18),
              label: Text(l10n.dialogWhyThisHelps),
              onPressed: () => showModuleHelp(context, moduleId),
            ),
          ),
          Text(l10n.placeholderModuleText),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              appState.updateTodayState((state) {
                state.cbtTemp = l10n.simulateActionResult(label);
              });
            },
            child: Text(l10n.simulateAction),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.stateLabel} ${appState.todayState.cbtTemp}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogClose),
        ),
      ],
    );
  }
}
