import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/module_ids.dart';
import '../modules/mental_state_module.dart';
import '../modules/mental_state_constants.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import '../utils/layout_constants.dart';
import 'module_tile.dart';

// ==================== Enums & Extensions ====================

enum MentalStateMode {
  rightNow,
  goodThings,
  thoughtLens;

  static MentalStateMode fromString(String value) {
    return MentalStateMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MentalStateMode.rightNow,
    );
  }
}

extension MentalStateModeExtension on MentalStateMode {
  IconData get icon {
    switch (this) {
      case MentalStateMode.rightNow:
        return Icons.mood;
      case MentalStateMode.goodThings:
        return Icons.favorite;
      case MentalStateMode.thoughtLens:
        return Icons.psychology;
    }
  }

  String title(AppLocalizations l10n) {
    switch (this) {
      case MentalStateMode.rightNow:
        return l10n.mentalStateRightNow;
      case MentalStateMode.goodThings:
        return l10n.mentalStateGoodThing;
      case MentalStateMode.thoughtLens:
        return l10n.mentalStateThoughtLens;
    }
  }
}

extension MoodEmojiExtension on int {
  String get emoji {
    switch (this) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😊';
      default:
        return '😐';
    }
  }
}

// ==================== Main Widget ====================

class MentalStateModuleTile extends StatelessWidget {
  const MentalStateModuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = _resolveTileMode(constraints);
        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.mentalState);
        }
        return _MentalStateTileContent(mode: mode);
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

class _MentalStateTileContent extends StatelessWidget {
  final AdaptiveTileMode mode;

  const _MentalStateTileContent({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final mentalStateMode = MentalStateMode.fromString(
          appState.settings.mentalStateMode,
        );
        return TileCard(
          isCompact: mode.isCompact,
          child: Padding(
            padding: EdgeInsets.all(TilePadding.forMode(mode)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TileHeader(
                  mode: mentalStateMode,
                  tileMode: mode,
                ),
                SizedBox(height: mode.isCompact ? TileSpacing.small : TileSpacing.normal),
                Expanded(
                  child: Center(
                    child: _ModeContentSwitcher(
                      mode: mentalStateMode,
                      tileMode: mode,
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

// ==================== Header ====================

class _TileHeader extends StatelessWidget {
  final MentalStateMode mode;
  final AdaptiveTileMode tileMode;
  const _TileHeader({
    required this.mode,
    required this.tileMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iconSize = TileIconSizes.forMode(tileMode);

    return Row(
      children: [
        Icon(mode.icon, color: scheme.primary, size: iconSize),
        const SizedBox(width: TileSpacing.medium),
        Expanded(
          child: Text(
            mode.title(l10n),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              fontSize: tileMode.isCompact ? TileFontSizes.compactHeader : null,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DeveloperModeIndicator(tileMode: tileMode),
        _HelpButton(moduleId: BaselineModuleId.mentalState, isCompact: tileMode.isCompact),
      ],
    );
  }
}

class _DeveloperModeIndicator extends StatelessWidget {
  final AdaptiveTileMode tileMode;

  const _DeveloperModeIndicator({required this.tileMode});

  @override
  Widget build(BuildContext context) {
    return TileModeIndicator(mode: tileMode);
  }
}

class _HelpButton extends StatelessWidget {
  final String moduleId;
  final bool isCompact;

  const _HelpButton({required this.moduleId, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return TileHelpButton(moduleId: moduleId, compact: isCompact);
  }
}

// ==================== Content Switcher ====================

class _ModeContentSwitcher extends StatelessWidget {
  final MentalStateMode mode;
  final AdaptiveTileMode tileMode;

  const _ModeContentSwitcher({required this.mode, required this.tileMode});

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case MentalStateMode.rightNow:
        return _RightNowContent(tileMode: tileMode);
      case MentalStateMode.goodThings:
        return _GoodThingsContent(tileMode: tileMode);
      case MentalStateMode.thoughtLens:
        return _ThoughtLensContent(tileMode: tileMode);
    }
  }
}

// ==================== Right Now Mode ====================

class _RightNowContent extends StatelessWidget {
  final AdaptiveTileMode tileMode;

  const _RightNowContent({required this.tileMode});

  @override
  Widget build(BuildContext context) {
    return Selector<
      AppState,
      ({int? mood, DateTime? timestamp, bool canChange})
    >(
      selector: (_, appState) => (
        mood: appState.todayState.moodSelection,
        timestamp: appState.todayState.moodSelectionTimestamp,
        canChange: _canChangeMood(appState),
      ),
      builder: (context, data, child) {
        if (data.mood != null && !data.canChange) {
          return _MoodCompletedView(mood: data.mood!, tileMode: tileMode);
        }
        return _MoodSelectionView(tileMode: tileMode);
      },
    );
  }

  bool _canChangeMood(AppState appState) {
    final mood = appState.todayState.moodSelection;
    final timestamp = appState.todayState.moodSelectionTimestamp;
    if (mood == null) return true;
    if (timestamp == null) return true;
    final oneHourAgo = clock.now().subtract(const Duration(hours: 1));
    return timestamp.isBefore(oneHourAgo);
  }
}

class _MoodSelectionView extends StatelessWidget {
  final AdaptiveTileMode tileMode;

  const _MoodSelectionView({required this.tileMode});

  @override
  Widget build(BuildContext context) {
    if (tileMode == AdaptiveTileMode.compact) {
      return const _CompactMoodSelector();
    }
    return _ExpandedMoodSelector(tileMode: tileMode);
  }
}

class _AdaptiveEmojiButton extends StatelessWidget {
  final String emoji;
  final int value;
  final double maxHeight;

  const _AdaptiveEmojiButton({
    required this.emoji,
    required this.value,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Material(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Provider.of<AppState>(context, listen: false).updateTodayState(
                  (state) {
                    state.moodSelection = value;
                    state.moodSelectionTimestamp = clock.now();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(TilePadding.normal),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 24), // Natural size
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactMoodSelector extends StatelessWidget {
  const _CompactMoodSelector();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed-height row of exactly 3 emoji buttons (bad / neutral / good).
        // Using a Row with Expanded children ensures they fill available width
        // and AspectRatio(1) keeps them square — no blank space below.
        final buttonSize = constraints.maxHeight.clamp(32.0, 72.0);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _AdaptiveEmojiButton(emoji: '😢', value: 1, maxHeight: buttonSize)),
            Expanded(child: _AdaptiveEmojiButton(emoji: '😐', value: 3, maxHeight: buttonSize)),
            Expanded(child: _AdaptiveEmojiButton(emoji: '😊', value: 5, maxHeight: buttonSize)),
          ],
        );
      },
    );
  }
}

class _ExpandedMoodSelector extends StatelessWidget {
  final AdaptiveTileMode tileMode;

  const _ExpandedMoodSelector({required this.tileMode});

  @override
  Widget build(BuildContext context) {
    final isExpanded = tileMode == AdaptiveTileMode.expanded;
    final isMedium = tileMode == AdaptiveTileMode.medium;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Medium mode always shows all 5 moods.
        // Expanded mode shows all 5 if they fit, otherwise falls back to 3.
        const minButtonWidth = 40.0;
        const spacing = TileSpacing.normal;
        final fitsAll5 = isMedium || constraints.maxWidth >= 5 * minButtonWidth + 4 * spacing;
        final moods = fitsAll5
            ? const [
                (emoji: '😢', value: 1),
                (emoji: '😕', value: 2),
                (emoji: '😐', value: 3),
                (emoji: '🙂', value: 4),
                (emoji: '😊', value: 5),
              ]
            : const [
                (emoji: '😢', value: 1),
                (emoji: '😐', value: 3),
                (emoji: '😊', value: 5),
              ];

        final buttonMaxHeight = constraints.maxHeight.clamp(32.0, 80.0);

        return Column(
          children: [
            if (isExpanded) ...[
              Text(
                l10n.cbtRightNowQuestion,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TileSpacing.normal),
            ],
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final m in moods)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _AdaptiveEmojiButton(
                          emoji: m.emoji,
                          value: m.value,
                          maxHeight: buttonMaxHeight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}



class _MoodCompletedView extends StatelessWidget {
  final int mood;
  final AdaptiveTileMode tileMode;

  const _MoodCompletedView({required this.mood, required this.tileMode});

  @override
  Widget build(BuildContext context) {
    if (tileMode == AdaptiveTileMode.compact) {
      return _CompactMoodCompleted(mood: mood);
    }
    return _ExpandedMoodCompleted(mood: mood);
  }
}

class _CompactMoodCompleted extends StatelessWidget {
  final int mood;

  const _CompactMoodCompleted({required this.mood});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(mood.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Text(
          l10n.cbtMoodRecorded,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF059669),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            Provider.of<AppState>(
              context,
              listen: false,
            ).updateTodayState((state) => state.moodSelection = null);
          },
          icon: const Icon(Icons.undo, size: 16),
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.outline,
            minimumSize: const Size(32, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          tooltip: l10n.dialogReset,
        ),
      ],
    );
  }
}

class _ExpandedMoodCompleted extends StatelessWidget {
  final int mood;

  const _ExpandedMoodCompleted({required this.mood});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Text(
              l10n.cbtMoodRecorded,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _resetMood(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.onSurfaceVariant,
            side: BorderSide(color: scheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Text(l10n.dialogReset),
        ),
      ],
    );
  }

  void _resetMood(BuildContext context) {
    Provider.of<AppState>(
      context,
      listen: false,
    ).updateTodayState((state) => state.moodSelection = null);
  }
}

// ==================== Good Things Mode ====================

class _GoodThingsContent extends StatelessWidget {
  final AdaptiveTileMode tileMode;

  const _GoodThingsContent({required this.tileMode});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, List<String>>(
      selector: (_, appState) => appState.todayState.goodThings,
      builder: (context, goodThings, child) {
        if (goodThings.isNotEmpty) {
          return _GoodThingsCompletedView(
            goodThings: goodThings,
            tileMode: tileMode,
          );
        }
        return _GoodThingsEmptyView(tileMode: tileMode);
      },
    );
  }
}

class _GoodThingsEmptyView extends StatelessWidget {
  final AdaptiveTileMode tileMode;

  const _GoodThingsEmptyView({required this.tileMode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    if (tileMode == AdaptiveTileMode.compact) {
      return _CompactActionButton(
        onPressed: () => showMentalStateModule(context),
        icon: Icons.add,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      );
    }

    return Column(
      children: [
        if (tileMode == AdaptiveTileMode.expanded)
          Text(
            l10n.cbtGoodThingsQuestion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => showMentalStateModule(context),
          icon: const Icon(Icons.edit_note, size: 18),
          label: Text(l10n.mentalStateGoodThing),
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

class _GoodThingsCompletedView extends StatelessWidget {
  final List<String> goodThings;
  final AdaptiveTileMode tileMode;

  const _GoodThingsCompletedView({
    required this.goodThings,
    required this.tileMode,
  });

  @override
  Widget build(BuildContext context) {
    if (tileMode == AdaptiveTileMode.compact) {
      return _CompactGoodThingsCompleted(goodThings: goodThings);
    }
    return _ExpandedGoodThingsCompleted(goodThings: goodThings);
  }
}

class _CompactGoodThingsCompleted extends StatelessWidget {
  final List<String> goodThings;

  const _CompactGoodThingsCompleted({required this.goodThings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 24, color: Color(0xFF059669)),
        const SizedBox(width: 8),
        Text(
          '${goodThings.length} ${l10n.mentalStateGoodThing.toLowerCase()}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF059669),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => showMentalStateModule(context),
          icon: const Icon(Icons.edit, size: 16),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF059669),
            minimumSize: const Size(32, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _ExpandedGoodThingsCompleted extends StatelessWidget {
  final List<String> goodThings;

  const _ExpandedGoodThingsCompleted({required this.goodThings});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 32, color: Color(0xFF059669)),
            const SizedBox(width: 12),
            Text(
              '${goodThings.length} good things',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => showMentalStateModule(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.onSurfaceVariant,
            side: BorderSide(color: scheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: const Text('Edit'),
        ),
      ],
    );
  }
}

// ==================== Thought Lens Mode ====================

class _ThoughtLensContent extends StatelessWidget {
  final AdaptiveTileMode tileMode;

  const _ThoughtLensContent({required this.tileMode});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, int>(
      selector: (_, appState) => appState.todayState.thoughtLensIndex,
      builder: (context, thoughtLensIndex, child) {
        if (tileMode == AdaptiveTileMode.compact) {
          return _CompactActionButton(
            onPressed: () => showMentalStateModule(context),
            icon: Icons.psychology,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          );
        }
        return _ExpandedThoughtLensContent(
          thoughtLensIndex: thoughtLensIndex,
          tileMode: tileMode,
        );
      },
    );
  }
}

class _ExpandedThoughtLensContent extends StatelessWidget {
  final int thoughtLensIndex;
  final AdaptiveTileMode tileMode;

  const _ExpandedThoughtLensContent({
    required this.thoughtLensIndex,
    required this.tileMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isExpanded = tileMode == AdaptiveTileMode.expanded;

    return Column(
      children: [
        if (isExpanded) ...[
          Text(
            l10n.cbtThoughtLensTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _DistortionCard(index: thoughtLensIndex),
          const SizedBox(height: 12),
          _ThoughtLensNavigation(index: thoughtLensIndex),
          const SizedBox(height: 8),
          Text(
            '${thoughtLensIndex + 1} / ${MentalStateConstants.distortionCount}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        if (!isExpanded)
          ElevatedButton.icon(
            onPressed: () => showMentalStateModule(context),
            icon: const Icon(Icons.psychology, size: 18),
            label: Text(l10n.mentalStateThoughtLens),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              elevation: 0,
            ),
          ),
      ],
    );
  }
}

class _DistortionCard extends StatelessWidget {
  final int index;

  const _DistortionCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final distortion = MentalStateConstants.getDistortion(index);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            distortion['title'] ?? 'Unknown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            distortion['description'] ?? '',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cbtThoughtLensExample,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distortion['example'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThoughtLensNavigation extends StatelessWidget {
  final int index;

  const _ThoughtLensNavigation({required this.index});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _navigate(context, -1),
            child: Text(l10n.cbtThoughtLensPrevious),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _navigate(context, 1),
            child: Text(l10n.cbtThoughtLensNext),
          ),
        ),
      ],
    );
  }

  void _navigate(BuildContext context, int delta) {
    final appState = Provider.of<AppState>(context, listen: false);
    final count = MentalStateConstants.distortionCount;
    appState.updateTodayState((state) {
      state.thoughtLensIndex = (index + delta + count) % count;
    });
  }
}

// ==================== Reusable Components ====================

class _CompactActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _CompactActionButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(44, 44),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
