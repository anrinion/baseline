import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../l10n/app_localizations.dart';
import 'module_help.dart';
import 'module_ids.dart';

/// Opens the Sleep module dialog.
void showSleepModule(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => const _SleepDialog(),
  );
}

/// Converts minutes from midnight to localized time string respecting 12/24h setting.
String formatTimeFromMinutes(BuildContext context, int minutes) {
  // Handle 1440 (24:00 / end of day) as 00:00
  final normalizedMinutes = minutes >= 1440 ? 0 : minutes;
  final timeOfDay = TimeOfDay(
    hour: normalizedMinutes ~/ 60,
    minute: normalizedMinutes % 60,
  );
  return MaterialLocalizations.of(context).formatTimeOfDay(
    timeOfDay,
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
  );
}

/// Rounds minutes to nearest 30-minute chunk for display.
int roundTo30Minutes(int minutes) {
  return (minutes / 30).round() * 30;
}

/// Calculates sleep duration handling overnight case.
Duration calculateSleepDuration(int bedMinutes, int wakeMinutes) {
  int diff = wakeMinutes - bedMinutes;
  if (diff < 0) {
    // Sleep went past midnight
    diff += 24 * 60;
  }
  return Duration(minutes: diff);
}

/// Calculates sleep window for slider visualization.
/// Returns [sleepStart, sleepEnd] in minutes from midnight.
/// For bed slider: shows sleep from bedtime to wake (or midnight if overnight)
/// For wake slider: shows sleep from bedtime (or midnight if overnight) to wake
List<int> calculateSleepWindow(
  int thisMinutes,
  int otherMinutes,
  bool isBedTime,
) {
  // For bed slider: overnight when bed (this) > wake (other)
  // For wake slider: overnight when wake (this) < bed (other)
  final isOvernight = isBedTime
      ? thisMinutes > otherMinutes
      : thisMinutes < otherMinutes;
  final sleepStart = isBedTime
      ? thisMinutes // bed slider: start at bed time
      : (isOvernight
            ? 0
            : otherMinutes); // wake slider: start at midnight (overnight) or bed time (same day)
  final sleepEnd = isBedTime
      ? (isOvernight
            ? 1440
            : otherMinutes) // bed slider: end at midnight (overnight) or wake time (same day)
      : thisMinutes; // wake slider: end at wake time
  return [sleepStart, sleepEnd];
}

/// Formats duration as localized "Xh Ym" (e.g., "7h 30m").
String formatDuration(BuildContext context, Duration duration) {
  final l10n = AppLocalizations.of(context)!;
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '$hours${l10n.sleepHoursAbbreviation} ${minutes}${l10n.sleepMinutesAbbreviation}';
  }
  return '$minutes${l10n.sleepMinutesAbbreviation}';
}

/// Checks if the sleep duration is considered healthy (7-9 hours).
bool isHealthySleep(Duration duration) {
  final hours = duration.inHours;
  return hours >= 7 && hours <= 9;
}

/// Builds a slider with recommended zones and sleep window visualization.
Widget buildSliderWithZones(
  BuildContext context,
  int minutes,
  int otherTime, {
  required bool isBedTime,
  required ValueChanged<double> onChanged,
  required ValueChanged<double> onChangeEnd,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  // Recommended ranges: Bed 20:00-02:00, Wake 07:00-12:00
  final recommendedStart = isBedTime ? 20 * 60 : 7 * 60;
  final recommendedEnd = isBedTime ? 2 * 60 : 12 * 60;

  // Calculate sleep window for visualization (using rounded values)
  final sleepWindow = calculateSleepWindow(
    roundTo30Minutes(minutes),
    roundTo30Minutes(otherTime),
    isBedTime,
  );
  final sleepStart = sleepWindow[0];
  final sleepEnd = sleepWindow[1];

  return Stack(
    alignment: Alignment.center,
    children: [
      // Background track with recommended zone and sleep window
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth - 24;

            return SizedBox(
              width: trackWidth,
              height: 4,
              child: Stack(
                children: [
                  // Recommended zone (tertiary color, thinner)
                  if (isBedTime && recommendedStart > recommendedEnd) ...[
                    Positioned(
                      left: trackWidth * (recommendedStart / 1440),
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: trackWidth * (1 - recommendedEnd / 1440),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ] else
                    Positioned(
                      left: trackWidth * (recommendedStart / 1440),
                      right: trackWidth * (1 - recommendedEnd / 1440),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  // Sleep window (primary color, fills the actual sleep time)
                  Positioned(
                    left: trackWidth * (sleepStart / 1440),
                    right: trackWidth * (1 - sleepEnd / 1440),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      // The actual slider (uniform track color so standard fill isn't visible)
      Slider(
        value: minutes.toDouble(),
        min: 0,
        max: 1440,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
        activeColor: scheme.outline.withValues(alpha: 0.3),
        inactiveColor: scheme.outline.withValues(alpha: 0.3),
        thumbColor: scheme.primary,
      ),
    ],
  );
}

class _SleepDialog extends StatefulWidget {
  const _SleepDialog();

  @override
  State<_SleepDialog> createState() => _SleepDialogState();
}

class _SleepDialogState extends State<_SleepDialog> {
  double? _localBedTime;
  double? _localWakeTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Consumer<AppState>(
            builder: (context, appState, _) {
              final bedTime = appState.todayState.sleepBedTimeMinutes;
              final wakeTime = appState.todayState.sleepWakeTimeMinutes;
              final duration = calculateSleepDuration(
                roundTo30Minutes(bedTime),
                roundTo30Minutes(wakeTime),
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bedtime_outlined,
                          color: scheme.primary,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.sleepModuleLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: scheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.help_outline,
                            size: 22,
                            color: scheme.outline,
                          ),
                          tooltip: l10n.dialogWhyThisHelps,
                          onPressed: () =>
                              showModuleHelp(context, BaselineModuleId.sleep),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: scheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bed time slider
                        _buildTimeSlider(
                          context,
                          l10n.sleepBedTimeLabel,
                          (_localBedTime ?? bedTime.toDouble()).round(),
                          (_localWakeTime ?? wakeTime.toDouble()).round(),
                          Icons.bedtime_outlined,
                          onChanged: (value) {
                            setState(() {
                              _localBedTime = value;
                            });
                          },
                          onChangeEnd: (value) {
                            appState.updateTodayState((state) {
                              state.sleepBedTimeMinutes = roundTo30Minutes(
                                value.round(),
                              );
                            });
                            setState(() {
                              _localBedTime = null;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        // Wake time slider
                        _buildTimeSlider(
                          context,
                          l10n.sleepWakeTimeLabel,
                          (_localWakeTime ?? wakeTime.toDouble()).round(),
                          (_localBedTime ?? bedTime.toDouble()).round(),
                          Icons.wb_sunny_outlined,
                          onChanged: (value) {
                            setState(() {
                              _localWakeTime = value;
                            });
                          },
                          onChangeEnd: (value) {
                            appState.updateTodayState((state) {
                              state.sleepWakeTimeMinutes = roundTo30Minutes(
                                value.round(),
                              );
                            });
                            setState(() {
                              _localWakeTime = null;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        // Duration display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isHealthySleep(duration)
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.sleepDurationLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isHealthySleep(duration)
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDuration(context, duration),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isHealthySleep(duration)
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.dialogClose),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlider(
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
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              formatTimeFromMinutes(context, roundTo30Minutes(minutes)),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildSliderWithZones(
          context,
          minutes,
          otherTime,
          isBedTime: isBedTime,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTimeFromMinutes(context, 0),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
              Text(
                formatTimeFromMinutes(context, 12 * 60),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
              Text(
                formatTimeFromMinutes(context, 23 * 60 + 59),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
