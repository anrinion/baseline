import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../modules/sleep_module.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import 'module_tile.dart';

// ==================== Extensions ====================

extension SleepTimeFormatting on int {
  String toTimeString() {
    final hours = this ~/ 60;
    final minutes = this % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Duration toDuration() => Duration(minutes: this);
}

extension SleepDurationFormatting on Duration {
  String format() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes}m';
    }
    return '${minutes}m';
  }

  bool get isHealthy => inHours >= 7 && inHours <= 9;
}

// ==================== Main Widget ====================

class SleepModuleTile extends StatefulWidget {
  const SleepModuleTile({super.key});

  @override
  State<SleepModuleTile> createState() => _SleepModuleTileState();
}

class _SleepModuleTileState extends State<SleepModuleTile> {
  double? _localBedTime;
  double? _localWakeTime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = _resolveTileMode(constraints);
        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.sleep);
        }
        return _SleepTileContent(
          mode: mode,
          localBedTime: _localBedTime,
          localWakeTime: _localWakeTime,
          onBedTimeChanged: (v) => setState(() => _localBedTime = v),
          onWakeTimeChanged: (v) => setState(() => _localWakeTime = v),
          onBedTimeChangeEnd: () => setState(() => _localBedTime = null),
          onWakeTimeChangeEnd: () => setState(() => _localWakeTime = null),
          tileWidth: constraints.maxWidth,
          tileHeight: constraints.maxHeight,
        );
      },
    );
  }

  AdaptiveTileMode _resolveTileMode(BoxConstraints constraints) {
    const horizontalPadding = 32.0;
    const verticalMargin = 36.0; // reduced to give more usable height
    return resolveStandardTileMode(
      availableWidth: constraints.maxWidth - horizontalPadding,
      availableHeight: constraints.maxHeight - verticalMargin,
      thresholds: const AdaptiveTileThresholds(
        microHeight: 90,
        microWidth: 100,
        compactHeight: 120,
        compactWidth: 200,
        expandedHeight: 250,
        expandedWidth: 250,
      ),
    );
  }
}

// ==================== Content Wrapper ====================

class _SleepTileContent extends StatelessWidget {
  final AdaptiveTileMode mode;
  final double? localBedTime;
  final double? localWakeTime;
  final ValueChanged<double> onBedTimeChanged;
  final ValueChanged<double> onWakeTimeChanged;
  final VoidCallback onBedTimeChangeEnd;
  final VoidCallback onWakeTimeChangeEnd;
  final double tileWidth;
  final double tileHeight;

  const _SleepTileContent({
    required this.mode,
    this.localBedTime,
    this.localWakeTime,
    required this.onBedTimeChanged,
    required this.onWakeTimeChanged,
    required this.onBedTimeChangeEnd,
    required this.onWakeTimeChangeEnd,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == AdaptiveTileMode.expanded || mode == AdaptiveTileMode.medium) {
      return _SlidersSleepView(
        mode: mode,
        localBedTime: localBedTime,
        localWakeTime: localWakeTime,
        onBedTimeChanged: onBedTimeChanged,
        onWakeTimeChanged: onWakeTimeChanged,
        onBedTimeChangeEnd: onBedTimeChangeEnd,
        onWakeTimeChangeEnd: onWakeTimeChangeEnd,
        tileWidth: tileWidth,
        tileHeight: tileHeight,
      );
    }
    return _CompactSleepSummaryView(
      localBedTime: localBedTime,
      localWakeTime: localWakeTime,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
    );
  }
}

// ==================== Sliders View (Medium & Expanded) ====================

class _SlidersSleepView extends StatelessWidget {
  final AdaptiveTileMode mode;
  final double? localBedTime;
  final double? localWakeTime;
  final ValueChanged<double> onBedTimeChanged;
  final ValueChanged<double> onWakeTimeChanged;
  final VoidCallback onBedTimeChangeEnd;
  final VoidCallback onWakeTimeChangeEnd;
  final double tileWidth;
  final double tileHeight;

  const _SlidersSleepView({
    required this.mode,
    this.localBedTime,
    this.localWakeTime,
    required this.onBedTimeChanged,
    required this.onWakeTimeChanged,
    required this.onBedTimeChangeEnd,
    required this.onWakeTimeChangeEnd,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = mode == AdaptiveTileMode.expanded;
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isExpanded ? 16 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SlidersHeader(
              mode: mode,
              tileWidth: tileWidth,
              tileHeight: tileHeight,
            ),
            const SizedBox(height: 8),
            _ResponsiveSliderLayout(
              mode: mode,
              localBedTime: localBedTime,
              localWakeTime: localWakeTime,
              onBedTimeChanged: onBedTimeChanged,
              onWakeTimeChanged: onWakeTimeChanged,
              onBedTimeChangeEnd: onBedTimeChangeEnd,
              onWakeTimeChangeEnd: onWakeTimeChangeEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidersHeader extends StatelessWidget {
  final AdaptiveTileMode mode;
  final double tileWidth;
  final double tileHeight;

  const _SlidersHeader({
    required this.mode,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isExpanded = mode == AdaptiveTileMode.expanded;
    final isMedium = mode == AdaptiveTileMode.medium;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        final bedTime = appState.todayState.sleepBedTimeMinutes;
        final wakeTime = appState.todayState.sleepWakeTimeMinutes;
        final duration = _calculateSleepDuration(bedTime, wakeTime);

        return Row(
          children: [
            Icon(
              Icons.bedtime_outlined,
              color: scheme.primary,
              size: isExpanded ? 20 : 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                BaselineModuleId.localizedLabel(l10n, BaselineModuleId.sleep),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                  fontSize: isExpanded ? null : 13,
                ),
              ),
            ),
            // Show duration chip in both expanded and medium modes
            if (isExpanded || isMedium)
              _SleepDurationChip(duration: duration, compact: isMedium),
            _DeveloperModeIndicator(
              tileMode: mode,
              tileWidth: tileWidth,
              tileHeight: tileHeight,
            ),
            _HelpButton(moduleId: BaselineModuleId.sleep),
          ],
        );
      },
    );
  }
}

class _SleepDurationChip extends StatelessWidget {
  final Duration duration;
  final bool compact;

  const _SleepDurationChip({required this.duration, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHealthy = duration.isHealthy;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: isHealthy
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        duration.format(),
        style:
            (compact
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.titleMedium)
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isHealthy
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                  fontSize: compact ? 11 : null,
                ),
      ),
    );
  }
}

class _ResponsiveSliderLayout extends StatelessWidget {
  final AdaptiveTileMode mode;
  final double? localBedTime;
  final double? localWakeTime;
  final ValueChanged<double> onBedTimeChanged;
  final ValueChanged<double> onWakeTimeChanged;
  final VoidCallback onBedTimeChangeEnd;
  final VoidCallback onWakeTimeChangeEnd;

  const _ResponsiveSliderLayout({
    required this.mode,
    this.localBedTime,
    this.localWakeTime,
    required this.onBedTimeChanged,
    required this.onWakeTimeChanged,
    required this.onBedTimeChangeEnd,
    required this.onWakeTimeChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Prefer vertical layout (stacked sliders) for better usability.
        // Only use horizontal if width is very large (>500) AND height is very tight (<180)
        final preferVertical =
            constraints.maxWidth < 500 || constraints.maxHeight >= 180;

        if (preferVertical) {
          // Vertical stacked sliders - super compact
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SleepSlider(
                isBedTime: true,
                localValue: localBedTime,
                onChanged: onBedTimeChanged,
                onChangeEnd: onBedTimeChangeEnd,
                compact: true, // Always compact in vertical mode
                superCompact: mode == AdaptiveTileMode.medium,
              ),
              const SizedBox(height: 8),
              _SleepSlider(
                isBedTime: false,
                localValue: localWakeTime,
                onChanged: onWakeTimeChanged,
                onChangeEnd: onWakeTimeChangeEnd,
                compact: true,
                superCompact: mode == AdaptiveTileMode.medium,
              ),
            ],
          );
        } else {
          // Horizontal layout - used only when width > 500 and height < 180
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SleepSlider(
                  isBedTime: true,
                  localValue: localBedTime,
                  onChanged: onBedTimeChanged,
                  onChangeEnd: onBedTimeChangeEnd,
                  compact: false,
                  superCompact: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SleepSlider(
                  isBedTime: false,
                  localValue: localWakeTime,
                  onChanged: onWakeTimeChanged,
                  onChangeEnd: onWakeTimeChangeEnd,
                  compact: false,
                  superCompact: false,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// ==================== Compact Summary View ====================

class _CompactSleepSummaryView extends StatelessWidget {
  final double? localBedTime;
  final double? localWakeTime;
  final double tileWidth;
  final double tileHeight;

  const _CompactSleepSummaryView({
    this.localBedTime,
    this.localWakeTime,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => showSleepModule(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CompactHeader(tileWidth: tileWidth, tileHeight: tileHeight),
              const SizedBox(height: 2),
              Flexible(
                child: ClipRect(
                  child: _SleepSummaryDisplay(
                    mode: AdaptiveTileMode.compact,
                    localBedTime: localBedTime,
                    localWakeTime: localWakeTime,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final double tileWidth;
  final double tileHeight;

  const _CompactHeader({required this.tileWidth, required this.tileHeight});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.bedtime_outlined, color: scheme.primary, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            BaselineModuleId.localizedLabel(l10n, BaselineModuleId.sleep),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DeveloperModeIndicator(
          tileMode: AdaptiveTileMode.compact,
          tileWidth: tileWidth,
          tileHeight: tileHeight,
        ),
        _HelpButton(moduleId: BaselineModuleId.sleep),
      ],
    );
  }
}

class _SleepSummaryDisplay extends StatelessWidget {
  final AdaptiveTileMode mode;
  final double? localBedTime;
  final double? localWakeTime;

  const _SleepSummaryDisplay({
    required this.mode,
    this.localBedTime,
    this.localWakeTime,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final bedTime =
            (localBedTime?.round() ?? appState.todayState.sleepBedTimeMinutes);
        final wakeTime =
            (localWakeTime?.round() ??
            appState.todayState.sleepWakeTimeMinutes);
        final duration = _calculateSleepDuration(bedTime, wakeTime);

        if (mode == AdaptiveTileMode.compact) {
          return _CompactSleepSummary(
            duration: duration,
            bedTime: bedTime,
            wakeTime: wakeTime,
          );
        }
        return _MediumSleepSummary(
          duration: duration,
          bedTime: bedTime,
          wakeTime: wakeTime,
        );
      },
    );
  }
}

class _CompactSleepSummary extends StatelessWidget {
  final Duration duration;
  final int bedTime;
  final int wakeTime;

  const _CompactSleepSummary({
    required this.duration,
    required this.bedTime,
    required this.wakeTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          duration.format(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 2,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bedtime_outlined, size: 12, color: scheme.outline),
                const SizedBox(width: 2),
                Text(
                  bedTime.toTimeString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_outlined, size: 12, color: scheme.outline),
                const SizedBox(width: 2),
                Text(
                  wakeTime.toTimeString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MediumSleepSummary extends StatelessWidget {
  final Duration duration;
  final int bedTime;
  final int wakeTime;

  const _MediumSleepSummary({
    required this.duration,
    required this.bedTime,
    required this.wakeTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          duration.format(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bedtime_outlined, size: 14, color: scheme.outline),
                const SizedBox(width: 4),
                Text(
                  bedTime.toTimeString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_outlined, size: 14, color: scheme.outline),
                const SizedBox(width: 4),
                Text(
                  wakeTime.toTimeString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== Slider Component ====================

class _SleepSlider extends StatelessWidget {
  final bool isBedTime;
  final double? localValue;
  final ValueChanged<double> onChanged;
  final VoidCallback onChangeEnd;
  final bool compact;
  final bool superCompact;

  const _SleepSlider({
    required this.isBedTime,
    this.localValue,
    required this.onChanged,
    required this.onChangeEnd,
    this.compact = false,
    this.superCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icon = isBedTime ? Icons.bedtime_outlined : Icons.wb_sunny_outlined;
    final label = isBedTime ? l10n.sleepBedTimeLabel : l10n.sleepWakeTimeLabel;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        final actualMinutes = isBedTime
            ? appState.todayState.sleepBedTimeMinutes
            : appState.todayState.sleepWakeTimeMinutes;
        final otherMinutes = isBedTime
            ? appState.todayState.sleepWakeTimeMinutes
            : appState.todayState.sleepBedTimeMinutes;
        final displayMinutes = (localValue ?? actualMinutes.toDouble()).round();

        // Ultra compact styles for vertical medium mode
        final double labelFontSize = superCompact ? 11 : (compact ? 12 : 13);
        final double timeFontSize = superCompact ? 13 : (compact ? 14 : 16);
        final double iconSize = superCompact ? 14 : (compact ? 16 : 18);
        final double sliderHeight = superCompact
            ? 20.0
            : (compact ? 24.0 : 30.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: iconSize, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                      fontSize: labelFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayMinutes.toTimeString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                    fontSize: timeFontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: sliderHeight,
              child: buildSliderWithZones(
                context,
                displayMinutes,
                otherMinutes,
                isBedTime: isBedTime,
                onChanged: onChanged,
                onChangeEnd: (v) {
                  _persistChange(context, v.round());
                  onChangeEnd();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '00:00',
                    style: _sliderLabelStyle(theme, superCompact || compact),
                  ),
                  Text(
                    '12:00',
                    style: _sliderLabelStyle(theme, superCompact || compact),
                  ),
                  Text(
                    '23:59',
                    style: _sliderLabelStyle(theme, superCompact || compact),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  TextStyle _sliderLabelStyle(ThemeData theme, bool isCompact) {
    return (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
      color: theme.colorScheme.outline,
      fontSize: isCompact ? 7 : 9,
    );
  }

  void _persistChange(BuildContext context, int value) {
    final appState = Provider.of<AppState>(context, listen: false);
    final rounded = roundTo30Minutes(value);
    appState.updateTodayState((state) {
      if (isBedTime) {
        state.sleepBedTimeMinutes = rounded;
      } else {
        state.sleepWakeTimeMinutes = rounded;
      }
    });
  }
}

// ==================== Reusable Components ====================

class _DeveloperModeIndicator extends StatelessWidget {
  final AdaptiveTileMode tileMode;
  final double tileWidth;
  final double tileHeight;

  const _DeveloperModeIndicator({
    required this.tileMode,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.settings.developerModeEnabled,
      builder: (context, developerModeEnabled, child) {
        if (!developerModeEnabled) return const SizedBox.shrink();
        return buildLayoutModeIndicator(context, tileMode, enabled: true);
      },
    );
  }
}

class _HelpButton extends StatelessWidget {
  final String moduleId;

  const _HelpButton({required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: Icon(
        Icons.help_outline,
        size: 20,
        color: Theme.of(context).colorScheme.outline,
      ),
      tooltip: l10n.dialogWhyThisHelps,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () => showModuleHelp(context, moduleId),
    );
  }
}

// ==================== Helper Functions ====================

Duration _calculateSleepDuration(int bedMinutes, int wakeMinutes) {
  final bed = roundTo30Minutes(bedMinutes);
  final wake = roundTo30Minutes(wakeMinutes);
  return calculateSleepDuration(bed, wake);
}
