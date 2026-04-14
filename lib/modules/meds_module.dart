import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/meds_notifications_service.dart';
import '../state/app_state.dart';
import '../state/settings.dart';
import 'module_help.dart';
import 'module_ids.dart';

const String _medsListSettingKey = 'list';
const String _medsRemindersJsonSettingKey = 'remindersByMedJson';
const int defaultMedsReminderMinutes = 9 * 60;

Map<String, int> medsReminderMinutesByMedFromSettings(Settings settings) {
  final raw = settings.getModuleSetting(
    BaselineModuleId.meds,
    _medsRemindersJsonSettingKey,
    '{}',
  );
  if (raw.isEmpty) return {};

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    final out = <String, int>{};
    for (final entry in decoded.entries) {
      final key = entry.key.toString().trim();
      if (key.isEmpty) continue;
      final parsed = int.tryParse(entry.value.toString());
      if (parsed == null) continue;
      out[key] = _normalizeMinutes(parsed);
    }
    return out;
  } catch (_) {
    return {};
  }
}

int? medsReminderMinutesForMed(Settings settings, String medName) {
  return medsReminderMinutesByMedFromSettings(settings)[medName];
}

void setMedsReminderMinutesForMedOnSettings(
  Settings settings,
  String medName,
  int minutes,
) {
  final next = Map<String, int>.from(
    medsReminderMinutesByMedFromSettings(settings),
  );
  next[medName] = _normalizeMinutes(minutes);
  settings.setModuleSetting(
    BaselineModuleId.meds,
    _medsRemindersJsonSettingKey,
    jsonEncode(next),
  );
}

void removeMedsReminderForMedOnSettings(Settings settings, String medName) {
  final next = Map<String, int>.from(
    medsReminderMinutesByMedFromSettings(settings),
  );
  next.remove(medName);
  settings.setModuleSetting(
    BaselineModuleId.meds,
    _medsRemindersJsonSettingKey,
    jsonEncode(next),
  );
}

void syncMedsRemindersWithListOnSettings(Settings settings, List<String> meds) {
  final existing = medsReminderMinutesByMedFromSettings(settings);
  final allowed = meds.toSet();
  final filtered = <String, int>{};
  for (final entry in existing.entries) {
    if (allowed.contains(entry.key)) {
      filtered[entry.key] = entry.value;
    }
  }
  settings.setModuleSetting(
    BaselineModuleId.meds,
    _medsRemindersJsonSettingKey,
    jsonEncode(filtered),
  );
}

List<String> getMedsList(AppState appState, AppLocalizations l10n) {
  final raw = appState.settings.getModuleSetting(
    BaselineModuleId.meds,
    _medsListSettingKey,
    l10n.medsDefaultList,
  );

  final seen = <String>{};
  final meds = <String>[];
  for (final line in raw.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final dedupeKey = trimmed.toLowerCase();
    if (seen.add(dedupeKey)) meds.add(trimmed);
  }
  return meds;
}

void setMedsList(AppState appState, List<String> meds) {
  appState.updateSettings((settings) {
    settings.setModuleSetting(
      BaselineModuleId.meds,
      _medsListSettingKey,
      meds.join('\n'),
    );
    syncMedsRemindersWithListOnSettings(settings, meds);
  });
}

bool isMedTakenToday(AppState appState, String medName) {
  return appState.todayState.medsChecked[medName] == true;
}

void setMedTakenToday(AppState appState, String medName, bool isTaken) {
  // Cancel notification and snooze when marking as taken
  if (isTaken) {
    MedsNotificationsService.instance.clearSnooze(medName);
    MedsNotificationsService.instance.cancelNotificationForMed(medName);
  }

  appState.updateTodayState((state) {
    final next = Map<String, bool>.from(state.medsChecked);
    next[medName] = isTaken;
    state.medsChecked = next;
    state.medsTaken = next.values.any((v) => v);
  });
  HapticFeedback.selectionClick();
}

void syncMedsChecksWithList(AppState appState, List<String> meds) {
  appState.updateTodayState((state) {
    final next = <String, bool>{};
    for (final med in meds) {
      next[med] = state.medsChecked[med] == true;
    }
    state.medsChecked = next;
    state.medsTaken = next.values.any((v) => v);
  });
}

void resetAllMedsForToday(AppState appState) {
  appState.updateTodayState((state) {
    state.medsChecked = {};
    state.medsTaken = false;
  });
  HapticFeedback.lightImpact();
}

void showMedsModule(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => const _MedsDialog(),
  );
}

class _MedsDialog extends StatelessWidget {
  const _MedsDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            final meds = getMedsList(appState, l10n);
            final takenCount = meds
                .where((m) => isMedTakenToday(appState, m))
                .length;
            final isEmpty = meds.isEmpty;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        color: scheme.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.medsModuleLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: scheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.help_outline,
                          size: 22,
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
                      if (!isEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final useIconOnly = constraints.maxWidth < 60;
                            return Tooltip(
                              message: l10n.dialogReset,
                              child: TextButton(
                                onPressed: () => resetAllMedsForToday(appState),
                                style: TextButton.styleFrom(
                                  padding: useIconOnly
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                  minimumSize: Size(useIconOnly ? 36 : 0, 36),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: useIconOnly
                                    ? Icon(
                                        Icons.restart_alt,
                                        size: 20,
                                        color: scheme.outline,
                                      )
                                    : Text(
                                        l10n.dialogReset,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),

                // Progress row – only shown when list is NOT empty
                if (!isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Text(
                      l10n.medsTodayProgress(takenCount, meds.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // List or empty state
                Flexible(
                  child: isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Centered progress text for empty state
                              Center(
                                child: Text(
                                  l10n.medsTodayProgress(
                                    takenCount,
                                    meds.length,
                                  ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.medsEmptyState,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () => _openMedsListEditor(
                                  context,
                                  appState,
                                  l10n,
                                ),
                                icon: const Icon(Icons.add),
                                label: Text(l10n.medsAddButtonLabel),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                          itemCount: meds.length,
                          itemBuilder: (context, index) {
                            final med = meds[index];
                            final checked = isMedTakenToday(appState, med);
                            final reminderMinutes = medsReminderMinutesForMed(
                              appState.settings,
                              med,
                            );
                            final snoozeTime = MedsNotificationsService.instance
                                .getSnoozeTime(med);
                            final isSnoozed =
                                snoozeTime != null &&
                                snoozeTime.isAfter(DateTime.now());

                            Widget? subtitle;
                            if (isSnoozed) {
                              final timeStr =
                                  '${snoozeTime.hour.toString().padLeft(2, '0')}:${snoozeTime.minute.toString().padLeft(2, '0')}';
                              subtitle = Text(
                                'Snoozed until $timeStr',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                              );
                            }

                            return CheckboxListTile(
                              dense: true,
                              title: Text(
                                med,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: subtitle,
                              value: checked,
                              secondary: _MedReminderControl(
                                medName: med,
                                reminderMinutes: reminderMinutes,
                              ),
                              onChanged: (value) => setMedTakenToday(
                                appState,
                                med,
                                value == true,
                              ),
                            );
                          },
                        ),
                ),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextButton.icon(
                          onPressed: () =>
                              _openMedsListEditor(context, appState, l10n),
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(
                            l10n.medsEditListButtonLabel,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.dialogClose),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openMedsListEditor(
    BuildContext context,
    AppState appState,
    AppLocalizations l10n,
  ) async {
    final initial = getMedsList(appState, l10n);
    final controller = TextEditingController(text: initial.join('\n'));
    final saved = await showDialog<bool>(
      context: context,
      builder: (editorContext) => AlertDialog(
        title: Text(l10n.medsEditListTitle),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: l10n.medsEditListHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(editorContext).pop(false),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(l10n.dialogCancel),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(editorContext).pop(true),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(l10n.dialogSave),
            ),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final meds = controller.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setMedsList(appState, meds);
    syncMedsChecksWithList(appState, meds);
  }
}

class _MedReminderControl extends StatelessWidget {
  const _MedReminderControl({
    required this.medName,
    required this.reminderMinutes,
  });

  final String medName;
  final int? reminderMinutes;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final localizations = MaterialLocalizations.of(context);
    final hasReminder = reminderMinutes != null;

    final timeLabel = hasReminder
        ? localizations.formatTimeOfDay(
            TimeOfDay(
              hour: reminderMinutes! ~/ 60,
              minute: reminderMinutes! % 60,
            ),
          )
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (timeLabel != null)
          TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: reminderMinutes! ~/ 60,
                  minute: reminderMinutes! % 60,
                ),
              );
              if (picked == null) return;
              appState.updateSettings((s) {
                setMedsReminderMinutesForMedOnSettings(
                  s,
                  medName,
                  picked.hour * 60 + picked.minute,
                );
              });
            },
            child: Text(timeLabel),
          ),
        IconButton(
          tooltip: hasReminder
              ? l10n.medsReminderDisableTooltip
              : l10n.medsReminderEnableTooltip,
          icon: Icon(hasReminder ? Icons.alarm_on : Icons.alarm_add),
          onPressed: () async {
            if (!hasReminder) {
              final granted = await MedsNotificationsService.instance
                  .requestPermissionIfNeeded();
              if (!context.mounted) return;
              if (!granted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.medsReminderPermissionDenied)),
                );
                return;
              }
              appState.updateSettings((s) {
                setMedsReminderMinutesForMedOnSettings(
                  s,
                  medName,
                  defaultMedsReminderMinutes,
                );
              });
              return;
            }

            appState.updateSettings((s) {
              removeMedsReminderForMedOnSettings(s, medName);
            });
          },
        ),
      ],
    );
  }
}

int _normalizeMinutes(int value) {
  const minutesPerDay = 24 * 60;
  return ((value % minutesPerDay) + minutesPerDay) % minutesPerDay;
}
