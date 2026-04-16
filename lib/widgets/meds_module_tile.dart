import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/meds_module.dart';
import '../modules/module_ids.dart';
import '../services/meds_notifications_service.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import '../utils/layout_constants.dart';
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

        final available = calculateModuleTileAvailableSpace(constraints);

        final mode = resolveStandardTileMode(
          availableWidth: available.width,
          availableHeight: available.height,
          thresholds: standardModuleTileThresholds,
        );

        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.meds);
        }

        return TileCard(
          isCompact: mode.isCompact,
          onTap: () => showMedsModule(context),
          child: Padding(
            padding: EdgeInsets.all(TilePadding.forMode(mode)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      color: scheme.primary,
                      size: TileIconSizes.forMode(mode),
                    ),
                    const SizedBox(width: TileSpacing.medium),
                    Expanded(
                      child: Text(
                        BaselineModuleId.localizedLabel(
                          l10n,
                          BaselineModuleId.meds,
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          fontSize: mode.isCompact
                              ? TileFontSizes.compactHeader
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      '$takenCount/${meds.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                    TileModeIndicator(mode: mode),
                    TileHelpButton(
                      moduleId: BaselineModuleId.meds,
                      compact: mode.isCompact,
                    ),
                  ],
                ),
                const SizedBox(height: TileSpacing.small),
                if (meds.isEmpty)
                  Expanded(
                    child: Center(child: _EmptyMedsState(mode: mode)),
                  )
                else
                  Expanded(
                    child: Center(
                      child: _MedsContent(
                        mode: mode,
                        meds: meds,
                        takenCount: takenCount,
                      ),
                    ),
                  ),
              ],
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
      maxLines: mode.isCompact ? 1 : 3,
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

    final maxItems = mode.isCompact ? 4 : 3;
    final visible = meds.take(maxItems).toList();

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.start,
      children: [
        for (final med in visible)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: mode.isCompact ? 120 : double.infinity,
            ),
            child: mode.isCompact
                ? _MedItemTile.compactGrid(med: med, appState: appState)
                : _MedItemTile(med: med, appState: appState),
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

enum _TileLayout { vertical, compactGrid }

class _MedItemTile extends StatelessWidget {
  const _MedItemTile({
    required this.med,
    required this.appState,
    this.layout = _TileLayout.vertical,
  });

  const _MedItemTile.compactGrid({
    required this.med,
    required this.appState,
  }) : layout = _TileLayout.compactGrid;

  final String med;
  final AppState appState;
  final _TileLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaken = isMedTakenToday(appState, med);
    final snoozeTime = MedsNotificationsService.instance.getSnoozeTime(med);
    final isSnoozed = snoozeTime != null && snoozeTime.isAfter(clock.now());

    if (layout == _TileLayout.compactGrid) {
      return InkWell(
        onTap: () {
          setMedTakenToday(appState, med, !isTaken);
          if (!isTaken) MedsNotificationsService.instance.clearSnooze(med);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isTaken
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
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
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  med,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (isSnoozed) ...[
                const SizedBox(width: 4),
                Icon(Icons.snooze, size: 12, color: theme.colorScheme.primary),
              ],
            ],
          ),
        ),
      );
    }

    Widget? subtitle;
    if (isSnoozed) {
      final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay(hour: snoozeTime.hour, minute: snoozeTime.minute),
        alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
      );
      subtitle = Text(
        'Snoozed until $timeStr',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;

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
              Text(
                med,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              if (subtitle != null)
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant,
                  ),
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
