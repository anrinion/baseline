import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/module_ids.dart';
import '../modules/sleep_module.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import '../utils/layout_constants.dart';
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

// ==================== Shared Sleep Zone Helper ====================

class SleepZone {
  final int startMinute;
  final int endMinute;
  final Color color;
  final double opacity;

  const SleepZone({
    required this.startMinute,
    required this.endMinute,
    required this.color,
    this.opacity = 0.15,
  });
}

/// Returns recommended sleep zones for both bed and wake times.
/// Bed time recommendation: 20:00-02:00 (wraps overnight)
/// Wake time recommendation: 07:00-12:00
List<SleepZone> getRecommendedSleepZones(
  BuildContext context, {
  bool isBedTime = true,
}) {
  final scheme = Theme.of(context).colorScheme;

  if (isBedTime) {
    // Bed time: 20:00 (1200) to 02:00 (120) - wraps overnight
    return [
      SleepZone(
        startMinute: 20 * 60,
        endMinute: 2 * 60,
        color: scheme.tertiaryContainer,
        opacity: 1.0,
      ),
    ];
  } else {
    // Wake time: 07:00 (420) to 12:00 (720)
    return [
      SleepZone(
        startMinute: 7 * 60,
        endMinute: 12 * 60,
        color: scheme.tertiaryContainer,
        opacity: 1.0,
      ),
    ];
  }
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
    final available = calculateModuleTileAvailableSpace(constraints);
    return resolveStandardTileMode(
      availableWidth: available.width,
      availableHeight: available.height,
      thresholds: standardModuleTileThresholds,
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
    return Card(
      margin: EdgeInsets.all(TileMargins.forMode(mode)),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: tileShape(),
      child: Padding(
        padding: EdgeInsets.all(TilePadding.forMode(mode)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SlidersHeader(
              mode: mode,
              tileWidth: tileWidth,
              tileHeight: tileHeight,
            ),
            const SizedBox(height: TileSpacing.small),
            Expanded(
              child: Center(
                child: _ResponsiveSliderLayout(
                  mode: mode,
                  localBedTime: localBedTime,
                  localWakeTime: localWakeTime,
                  onBedTimeChanged: onBedTimeChanged,
                  onWakeTimeChanged: onWakeTimeChanged,
                  onBedTimeChangeEnd: onBedTimeChangeEnd,
                  onWakeTimeChangeEnd: onWakeTimeChangeEnd,
                ),
              ),
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
              size: TileIconSizes.forMode(mode),
            ),
            const SizedBox(width: TileSpacing.medium),
            Expanded(
              child: Text(
                BaselineModuleId.localizedLabel(l10n, BaselineModuleId.sleep),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                  fontSize: mode.isCompact ? TileFontSizes.compactHeader : null,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
            _HelpButton(
              moduleId: BaselineModuleId.sleep,
              compact: mode == AdaptiveTileMode.compact,
            ),
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
        horizontal: compact ? TileSpacing.normal : TilePadding.normal,
        vertical: compact ? TileSpacing.small : 6,
      ),
      decoration: BoxDecoration(
        color: isHealthy
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TileBorderRadius.chip),
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
                  fontSize: compact ? TileFontSizes.labelSmall : null,
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
        if ((mode == AdaptiveTileMode.medium ||
                mode == AdaptiveTileMode.expanded) &&
            constraints.maxHeight <= 170) {
          return _RangeSleepSlider(
            onBedTimeChanged: onBedTimeChanged,
            onWakeTimeChanged: onWakeTimeChanged,
            onBedTimeChangeEnd: onBedTimeChangeEnd,
            onWakeTimeChangeEnd: onWakeTimeChangeEnd,
          );
        }

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
              const SizedBox(height: TileSpacing.normal),
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
    final useHorizontalLayout = tileWidth > tileHeight;

    return Card(
      margin: const EdgeInsets.all(TileMargins.compact),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: tileShape(),
      child: InkWell(
        onTap: () => showSleepModule(context),
        borderRadius: BorderRadius.circular(TileBorderRadius.tile),
        child: Padding(
          padding: const EdgeInsets.all(TilePadding.compact),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CompactHeader(tileWidth: tileWidth, tileHeight: tileHeight),
              const SizedBox(height: TileSpacing.tiny),
              Flexible(
                child: ClipRect(
                  child: _SleepSummaryDisplay(
                    mode: AdaptiveTileMode.compact,
                    localBedTime: localBedTime,
                    localWakeTime: localWakeTime,
                    useHorizontalLayout: useHorizontalLayout,
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
        Icon(
          Icons.bedtime_outlined,
          color: scheme.primary,
          size: TileIconSizes.compact,
        ),
        const SizedBox(width: TileSpacing.medium),
        Expanded(
          child: Text(
            BaselineModuleId.localizedLabel(l10n, BaselineModuleId.sleep),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              fontSize: TileFontSizes.compactHeader,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DeveloperModeIndicator(
          tileMode: AdaptiveTileMode.compact,
          tileWidth: tileWidth,
          tileHeight: tileHeight,
        ),
        const _HelpButton(moduleId: BaselineModuleId.sleep, compact: true),
      ],
    );
  }
}

class _SleepSummaryDisplay extends StatelessWidget {
  final AdaptiveTileMode mode;
  final double? localBedTime;
  final double? localWakeTime;
  final bool useHorizontalLayout;

  const _SleepSummaryDisplay({
    required this.mode,
    this.localBedTime,
    this.localWakeTime,
    this.useHorizontalLayout = false,
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
            useHorizontalLayout: useHorizontalLayout,
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
  final bool useHorizontalLayout;

  const _CompactSleepSummary({
    required this.duration,
    required this.bedTime,
    required this.wakeTime,
    this.useHorizontalLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useHorizontalLayout) {
      return _HorizontalCompactLayout(
        duration: duration,
        bedTime: bedTime,
        wakeTime: wakeTime,
      );
    } else {
      return _VerticalCompactLayout(
        duration: duration,
        bedTime: bedTime,
        wakeTime: wakeTime,
      );
    }
  }
}

class _VerticalCompactLayout extends StatelessWidget {
  final Duration duration;
  final int bedTime;
  final int wakeTime;

  const _VerticalCompactLayout({
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
            fontSize: TileIconSizes.normal + 4,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: TileSpacing.small),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: TileSpacing.normal,
          runSpacing: TileSpacing.tiny,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bedtime_outlined,
                  size: TileIconSizes.small - 2,
                  color: scheme.outline,
                ),
                const SizedBox(width: TileSpacing.tiny),
                Text(
                  bedTime.toTimeString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: TileFontSizes.labelSmall,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: TileIconSizes.small - 2,
                  color: scheme.outline,
                ),
                const SizedBox(width: TileSpacing.tiny),
                Text(
                  wakeTime.toTimeString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: TileFontSizes.labelSmall,
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

class _HorizontalCompactLayout extends StatelessWidget {
  final Duration duration;
  final int bedTime;
  final int wakeTime;

  const _HorizontalCompactLayout({
    required this.duration,
    required this.bedTime,
    required this.wakeTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        // Bed time (left) - lower flex, can shrink
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bedtime_outlined,
                size: TileIconSizes.small,
                color: scheme.outline,
              ),
              const SizedBox(width: TileSpacing.small),
              Flexible(
                child: Text(
                  bedTime.toTimeString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: TileFontSizes.labelSmall,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Duration (center) - higher flex, prioritized
        Expanded(
          flex: 3,
          child: Center(
            child: Text(
              duration.format(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
                fontSize: TileIconSizes.normal + 4,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Wake time (right) - lower flex, can shrink
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  wakeTime.toTimeString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: TileFontSizes.labelSmall,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: TileSpacing.small),
              Icon(
                Icons.wb_sunny_outlined,
                size: TileIconSizes.small,
                color: scheme.outline,
              ),
            ],
          ),
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
                Icon(
                  Icons.bedtime_outlined,
                  size: TileIconSizes.small,
                  color: scheme.outline,
                ),
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
                Icon(
                  Icons.wb_sunny_outlined,
                  size: TileIconSizes.small,
                  color: scheme.outline,
                ),
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
        final double labelFontSize = superCompact
            ? TileFontSizes.labelSmall
            : (compact ? 12 : TileFontSizes.compactHeader);
        final double timeFontSize = superCompact
            ? TileFontSizes.compactHeader
            : (compact ? 14 : TileIconSizes.normal - 4);
        final double iconSize = superCompact
            ? TileIconSizes.small
            : (compact ? TileIconSizes.compact - 2 : TileIconSizes.compact);
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
                const SizedBox(width: TileSpacing.medium),
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
            const SizedBox(height: TileSpacing.small),
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
              padding: const EdgeInsets.symmetric(
                horizontal: TileSpacing.small,
              ),
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
      fontSize: isCompact ? TileFontSizes.tiny - 2 : TileFontSizes.tiny,
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

class _RangeSleepSlider extends StatefulWidget {
  final ValueChanged<double> onBedTimeChanged;
  final ValueChanged<double> onWakeTimeChanged;
  final VoidCallback onBedTimeChangeEnd;
  final VoidCallback onWakeTimeChangeEnd;

  const _RangeSleepSlider({
    required this.onBedTimeChanged,
    required this.onWakeTimeChanged,
    required this.onBedTimeChangeEnd,
    required this.onWakeTimeChangeEnd,
  });

  @override
  State<_RangeSleepSlider> createState() => _RangeSleepSliderState();
}

class _RangeSleepSliderState extends State<_RangeSleepSlider> {
  static const int _minSleepMinutes = 30;
  late RangeValues _currentRange;
  bool _isDragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialise if not currently dragging
    if (!_isDragging) {
      _syncFromAppState();
    }
  }

  void _syncFromAppState() {
    final appState = Provider.of<AppState>(context, listen: false);
    final bed = appState.todayState.sleepBedTimeMinutes.toDouble();
    final wake = appState.todayState.sleepWakeTimeMinutes.toDouble();
    final start = bed;
    final end = wake <= bed ? wake + 1440.0 : wake;
    _currentRange = RangeValues(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Only use appState to compute the displayed times (for the header)
        final bed = _currentRange.start.round();
        final wake = (_currentRange.end % 1440).round();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row – balanced with two Expanded groups
            Row(
              children: [
                // Bedtime group (icon, label, time)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bedtime_outlined,
                        size: TileIconSizes.small,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: TileSpacing.medium),
                      Flexible(
                        flex: 1, // label can shrink
                        child: Text(
                          l10n.sleepBedTimeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                            fontSize: TileFontSizes.labelSmall,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: TileSpacing.small),
                      Flexible(
                        flex: 2, // time resists shrinking
                        child: Text(
                          bed.toTimeString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TileSpacing.large),
                // Wake time group (time, label, icon)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 2, // time resists shrinking
                        child: Text(
                          wake.toTimeString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      const SizedBox(width: TileSpacing.small),
                      Flexible(
                        flex: 1, // label can shrink
                        child: Text(
                          l10n.sleepWakeTimeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                            fontSize: TileFontSizes.labelSmall,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      const SizedBox(width: TileSpacing.medium),
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: TileIconSizes.small,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TileSpacing.small),
            // Slider track
            SizedBox(
              height: 18,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final trackRect = _calculateTrackRect(context, width, height);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: _SleepZonePainter(
                          bedTime: _currentRange.start.round(),
                          wakeTime: _currentRange.end.round(),
                          zones: _getCombinedRecommendedZones(context),
                          activeColor: scheme.primary,
                          trackRect: trackRect,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.transparent,
                          inactiveTrackColor: Colors.transparent,
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 20.0,
                          ),
                          rangeThumbShape: const RoundRangeSliderThumbShape(
                            enabledThumbRadius: 10.0,
                          ),
                          rangeTrackShape:
                              const RectangularRangeSliderTrackShape(),
                          showValueIndicator: ShowValueIndicator.never,
                        ),
                        child: RangeSlider(
                          values: _currentRange,
                          min: 0,
                          max: 1440 * 2,
                          divisions: 96,
                          labels: RangeLabels(
                            (_currentRange.start % 1440).round().toTimeString(),
                            (_currentRange.end % 1440).round().toTimeString(),
                          ),
                          onChanged: _isDragging
                              ? _handleDragUpdate
                              : (values) {
                                  setState(() {
                                    _isDragging = true;
                                    _currentRange = _applyConstraints(values);
                                  });
                                  _notifyParent(_currentRange);
                                },
                          onChangeEnd: (values) {
                            setState(() {
                              _isDragging = false;
                              _currentRange = _applyConstraints(values);
                            });
                            _persistToAppState(_currentRange);
                            widget.onBedTimeChangeEnd();
                            widget.onWakeTimeChangeEnd();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  RangeValues _applyConstraints(RangeValues values) {
    double start = values.start;
    double end = values.end;

    // Enforce minimum sleep duration
    if (end - start < _minSleepMinutes) {
      if (_currentRange.start != start) {
        // Left thumb moved → adjust right
        end = start + _minSleepMinutes;
      } else {
        // Right thumb moved → adjust left
        start = end - _minSleepMinutes;
      }
    }

    // Clamp to valid 48‑hour window
    start = start.clamp(0.0, 2880.0 - _minSleepMinutes);
    end = end.clamp(0.0 + _minSleepMinutes, 2880.0);

    return RangeValues(start, end);
  }

  void _handleDragUpdate(RangeValues values) {
    final constrained = _applyConstraints(values);
    setState(() {
      _currentRange = constrained;
    });
    _notifyParent(constrained);
  }

  void _notifyParent(RangeValues range) {
    final bed = (range.start % 1440).round();
    final wake = (range.end % 1440).round();
    widget.onBedTimeChanged(bed.toDouble());
    widget.onWakeTimeChanged(wake.toDouble());
  }

  void _persistToAppState(RangeValues range) {
    final appState = Provider.of<AppState>(context, listen: false);
    final bed = (range.start % 1440).round();
    final wake = (range.end % 1440).round();
    appState.updateTodayState((state) {
      state.sleepBedTimeMinutes = roundTo30Minutes(bed);
      state.sleepWakeTimeMinutes = roundTo30Minutes(wake);
    });
  }

  TextStyle _sliderLabelStyle(ThemeData theme) {
    return (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
      color: theme.colorScheme.outline,
      fontSize: TileFontSizes.tiny,
    );
  }

  /// Calculates the track rectangle that aligns with slider thumb centers.
  /// The track is inset by the thumb radius on both sides.
  Rect _calculateTrackRect(
    BuildContext context,
    double totalWidth,
    double totalHeight,
  ) {
    final sliderTheme = SliderTheme.of(context);
    final thumbSize =
        sliderTheme.rangeThumbShape?.getPreferredSize(true, false) ??
        const Size(20, 20);
    final thumbRadius = thumbSize.width / 2;
    final trackHeight = sliderTheme.trackHeight ?? 4.0;
    final centerY = totalHeight / 2;
    final trackTop = centerY - trackHeight / 2;
    final trackBottom = centerY + trackHeight / 2;
    return Rect.fromLTRB(
      thumbRadius,
      trackTop,
      totalWidth - thumbRadius,
      trackBottom,
    );
  }

  /// Combines recommended zones for both bed time (20:00-02:00) and wake time (07:00-12:00).
  List<SleepZone> _getCombinedRecommendedZones(BuildContext context) {
    final bedZones = getRecommendedSleepZones(context, isBedTime: true);
    final wakeZones = getRecommendedSleepZones(context, isBedTime: false);
    // Combine both zones for the 48-hour view
    return [...bedZones, ...wakeZones];
  }
}

// Zone painter that aligns exactly with slider thumb centers
class _SleepZonePainter extends CustomPainter {
  final int bedTime;
  final int wakeTime;
  final List<SleepZone> zones;
  final Color activeColor;
  final Rect trackRect;

  _SleepZonePainter({
    required this.bedTime,
    required this.wakeTime,
    required this.zones,
    required this.activeColor,
    required this.trackRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double trackLeft = trackRect.left;
    final double trackWidth = trackRect.width;
    final double trackTop = trackRect.top;
    final double trackBottom = trackRect.bottom;

    // Map minute (0-2880) to x coordinate within the track
    double mapToX(int minutes) {
      return trackLeft + (minutes / 2880.0) * trackWidth;
    }

    // Paint recommended zones
    for (final zone in zones) {
      double startX = mapToX(zone.startMinute);
      double endX = mapToX(
        zone.endMinute <= zone.startMinute
            ? zone.endMinute + 1440
            : zone.endMinute,
      );
      final paint = Paint()..color = zone.color.withValues(alpha: zone.opacity);
      canvas.drawRect(
        Rect.fromLTRB(startX, trackTop, endX, trackBottom),
        paint,
      );
    }

    // Paint active sleep window (bed → wake)
    final double bedX = mapToX(bedTime);
    final double wakeX = mapToX(
      wakeTime <= bedTime ? wakeTime + 1440 : wakeTime,
    );
    final activePaint = Paint()..color = activeColor.withValues(alpha: 0.2);
    canvas.drawRect(
      Rect.fromLTRB(bedX, trackTop, wakeX, trackBottom),
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
  final bool compact;

  const _HelpButton({required this.moduleId, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return TileHelpButton(moduleId: moduleId, compact: compact);
  }
}

// ==================== Helper Functions ====================

Duration _calculateSleepDuration(int bedMinutes, int wakeMinutes) {
  final bed = roundTo30Minutes(bedMinutes);
  final wake = roundTo30Minutes(wakeMinutes);
  return calculateSleepDuration(bed, wake);
}
