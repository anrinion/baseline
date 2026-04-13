import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../modules/sleep_module.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import 'module_tile.dart';

class SleepModuleTile extends StatefulWidget {
  const SleepModuleTile({super.key});

  @override
  State<SleepModuleTile> createState() => _SleepModuleTileState();
}

class _SleepModuleTileState extends State<SleepModuleTile> {
  // Local state for smooth slider dragging
  double? _localBedTime;
  double? _localWakeTime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appState = Provider.of<AppState>(context);
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context)!;

        final bedTime = appState.todayState.sleepBedTimeMinutes;
        final wakeTime = appState.todayState.sleepWakeTimeMinutes;
        final duration = calculateSleepDuration(
          roundTo30Minutes(bedTime),
          roundTo30Minutes(wakeTime),
        );

        final availableWidth = constraints.maxWidth - 32;
        final availableHeight = constraints.maxHeight - 64;

        final mode = resolveStandardTileMode(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          thresholds: const AdaptiveTileThresholds(
            microHeight: 40,
            microWidth: 120,
            compactHeight: 100,
            compactWidth: 200,
            expandedHeight: 100,
            expandedWidth: 400,
          ),
        );

        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.sleep);
        }

        final isCompact = mode == AdaptiveTileMode.compact;
        final isExpanded = mode == AdaptiveTileMode.expanded;

        if (isExpanded) {
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with duration inline
                  Row(
                    children: [
                      Icon(
                        Icons.bedtime_outlined,
                        color: scheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          BaselineModuleId.localizedLabel(
                            l10n,
                            BaselineModuleId.sleep,
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      // Duration inline with header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isHealthySleep(duration)
                              ? scheme.primaryContainer
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formatDuration(duration),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isHealthySleep(duration)
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                      buildLayoutModeIndicator(
                        context,
                        AdaptiveTileMode.expanded,
                        enabled: appState.settings.developerModeEnabled,
                        availableWidth: availableWidth,
                        availableHeight: availableHeight,
                      ),
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
                            showModuleHelp(context, BaselineModuleId.sleep),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sliders side by side (with local state for smooth dragging)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildCompactSlider(
                          context,
                          l10n.sleepBedTimeLabel,
                          (_localBedTime ?? bedTime.toDouble()).round(),
                          (_localWakeTime ?? wakeTime.toDouble()).round(),
                          Icons.bedtime_outlined,
                          onChanged: (v) {
                            setState(() => _localBedTime = v);
                          },
                          onChangeEnd: (v) {
                            appState.updateTodayState((s) {
                              s.sleepBedTimeMinutes = roundTo30Minutes(
                                v.round(),
                              );
                            });
                            setState(() => _localBedTime = null);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCompactSlider(
                          context,
                          l10n.sleepWakeTimeLabel,
                          (_localWakeTime ?? wakeTime.toDouble()).round(),
                          (_localBedTime ?? bedTime.toDouble()).round(),
                          Icons.wb_sunny_outlined,
                          onChanged: (v) {
                            setState(() => _localWakeTime = v);
                          },
                          onChangeEnd: (v) {
                            appState.updateTodayState((s) {
                              s.sleepWakeTimeMinutes = roundTo30Minutes(
                                v.round(),
                              );
                            });
                            setState(() => _localWakeTime = null);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
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
          child: InkWell(
            onTap: () => showSleepModule(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OverflowBox(
                minHeight: 0,
                maxHeight: double.infinity,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(
                      context,
                      l10n,
                      scheme,
                      theme,
                      isCompact,
                      isExpanded,
                      mode,
                      availableWidth,
                      availableHeight,
                    ),
                    const SizedBox(height: 8),
                    _buildCompactContent(
                      context,
                      theme,
                      scheme,
                      duration,
                      isCompact,
                      bedTime,
                      wakeTime,
                      l10n,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
    ThemeData theme,
    bool isCompact,
    bool isExpanded,
    AdaptiveTileMode mode,
    double availableWidth,
    double availableHeight,
  ) {
    final appState = Provider.of<AppState>(context);
    return Row(
      children: [
        Icon(Icons.bedtime_outlined, color: scheme.primary, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            BaselineModuleId.localizedLabel(l10n, BaselineModuleId.sleep),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
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
          tooltip: l10n.dialogWhyThisHelps,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => showModuleHelp(context, BaselineModuleId.sleep),
        ),
      ],
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    Duration duration,
    bool isCompact,
    int bedTime,
    int wakeTime,
    AppLocalizations l10n,
  ) {
    final durationText = formatDuration(duration);
    final bedTimeStr = formatTimeFromMinutes(roundTo30Minutes(bedTime));
    final wakeTimeStr = formatTimeFromMinutes(roundTo30Minutes(wakeTime));

    if (isCompact) {
      // Compact: duration with inline bed/wake icons (wrap if space is tight)
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            durationText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              Icon(Icons.bedtime_outlined, size: 14, color: scheme.outline),
              Text(
                bedTimeStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.wb_sunny_outlined, size: 14, color: scheme.outline),
              Text(
                wakeTimeStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Medium: just the large duration
    return Center(
      child: Text(
        durationText,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.primary,
        ),
      ),
    );
  }

  Widget _buildCompactSlider(
    BuildContext context,
    String label,
    int minutes,
    int otherTime,
    IconData icon, {
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isBedTime = icon == Icons.bedtime_outlined;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              formatTimeFromMinutes(roundTo30Minutes(minutes)),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        buildSliderWithZones(
          context,
          minutes,
          otherTime,
          isBedTime: isBedTime,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '00:00',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                  fontSize: 9,
                ),
              ),
              Text(
                '12:00',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                  fontSize: 9,
                ),
              ),
              Text(
                '23:59',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
