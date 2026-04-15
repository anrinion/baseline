import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/meds_module.dart';
import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../services/meds_notifications_service.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import 'module_tile.dart';

class MedsModuleTile extends StatelessWidget {
  const MedsModuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appState = Provider.of<AppState>(context);
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context)!;
        final meds = getMedsList(appState, l10n);
        final takenCount = meds
            .where((m) => isMedTakenToday(appState, m))
            .length;

        final availableWidth = constraints.maxWidth - 32;
        final availableHeight = constraints.maxHeight - 48;

        final mode = resolveStandardTileMode(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          thresholds: const AdaptiveTileThresholds(
            microHeight: 55,
            microWidth: 100,
            compactHeight: 85,
            compactWidth: 220,
            expandedHeight: 140,
            expandedWidth: 360,
          ),
        );

        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.meds);
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
            onTap: () => showMedsModule(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRect(
                child: OverflowBox(
                  minHeight: 0,
                  maxHeight: double.infinity,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            color: scheme.primary,
                            size: mode == AdaptiveTileMode.compact ? 18 : 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              BaselineModuleId.localizedLabel(
                                l10n,
                                BaselineModuleId.meds,
                              ),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                                fontSize: mode == AdaptiveTileMode.compact ? 13 : null,
                              ),
                            ),
                          ),
                          Text(
                            '$takenCount/${meds.length}',
                            style: theme.textTheme.labelMedium?.copyWith(
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
                            tooltip: l10n.dialogWhyThisHelps,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            onPressed: () =>
                                showModuleHelp(context, BaselineModuleId.meds),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (meds.isEmpty)
                        _EmptyMedsState(mode: mode)
                      else
                        _MedsContent(
                          mode: mode,
                          meds: meds,
                          takenCount: takenCount,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyMedsState extends StatelessWidget {
  const _EmptyMedsState({required this.mode});

  final AdaptiveTileMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = mode == AdaptiveTileMode.compact
        ? l10n.medsEmptyCompact
        : l10n.medsEmptyState;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
      maxLines: mode == AdaptiveTileMode.compact ? 1 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MedsContent extends StatelessWidget {
  const _MedsContent({
    required this.mode,
    required this.meds,
    required this.takenCount,
  });

  final AdaptiveTileMode mode;
  final List<String> meds;
  final int takenCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    final progressText = l10n.medsTodayProgress(takenCount, meds.length);

    final takeCount = mode == AdaptiveTileMode.compact ? 1 : 3;
    final visible = meds.take(takeCount).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final med in visible)
          _MedItemTile(
            med: med,
            appState: appState,
          ),
        if (meds.length > visible.length)
          Text(
            l10n.medsMoreCount(meds.length - visible.length),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _MedItemTile extends StatelessWidget {
  const _MedItemTile({
    required this.med,
    required this.appState,
  });

  final String med;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaken = isMedTakenToday(appState, med);
    final snoozeTime = MedsNotificationsService.instance.getSnoozeTime(med);
    final isSnoozed = snoozeTime != null && snoozeTime.isAfter(clock.now());

    Widget? subtitle;
    if (isSnoozed) {
      final timeStr =
          '${snoozeTime.hour.toString().padLeft(2, '0')}:${snoozeTime.minute.toString().padLeft(2, '0')}';
      subtitle = Text(
        'Snoozed until $timeStr',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;

    // In extremely narrow bounds, CheckboxListTile throws constraint errors.
    // We build a custom highly-compact row to gracefully degenerate.
    final tileContent = Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Checkbox(
            value: isTaken,
            visualDensity: VisualDensity.compact,
            onChanged: (value) {
              setMedTakenToday(appState, med, value == true);
              if (value == true) {
                MedsNotificationsService.instance.clearSnooze(med);
              }
            },
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(med, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
              if (subtitle != null)
                DefaultTextStyle(
                  style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: subtitle,
                ),
            ],
          ),
        ),
      ],
    );

    return InkWell(
      onTap: () {
        setMedTakenToday(appState, med, !isTaken);
        if (!isTaken) {
          MedsNotificationsService.instance.clearSnooze(med);
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36, maxHeight: 48),
        child: tileContent,
      ),
    );
  }
}
