import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../modules/mental_state_module.dart';
import '../modules/mental_state_constants.dart';
import '../state/app_state.dart';
import '../utils/adaptive_layout.dart';
import 'module_tile.dart';

class MentalStateModuleTile extends StatelessWidget {
  const MentalStateModuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appState = Provider.of<AppState>(context);
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context)!;

        final mentalStateMode = appState.settings.mentalStateMode;

        final availableWidth =
            constraints.maxWidth - 32; // 16 padding on each side
        final availableHeight =
            constraints.maxHeight - 64; // rough header/margins

        final mode = resolveStandardTileMode(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          thresholds: const AdaptiveTileThresholds(
            microHeight: 55,
            microWidth: 120,
            compactHeight: 100,
            compactWidth: 220,
            expandedHeight: 140,
            expandedWidth: 400,
          ),
        );

        if (mode == AdaptiveTileMode.micro) {
          // Micro: use standard tile that opens a popup.
          return const ModuleTile(moduleId: BaselineModuleId.mentalState);
        }

        // Use much less padding in compact mode
        final isCompact = mode == AdaptiveTileMode.compact;
        final cardPadding = isCompact ? 8.0 : 16.0;
        final headerSpacing = isCompact ? 4.0 : 8.0;
        final iconSize = isCompact ? 16.0 : 20.0;
        
        return Card(
          margin: EdgeInsets.all(isCompact ? 8 : 12),
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: scheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      _getModeIcon(mentalStateMode),
                      color: scheme.primary,
                      size: iconSize,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getModeTitle(l10n, mentalStateMode),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          fontSize: isCompact ? 13 : null,
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
                    if (!isCompact)
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
                            showModuleHelp(context, BaselineModuleId.mentalState),
                      ),
                  ],
                ),
                SizedBox(height: headerSpacing),
                _buildContent(context, appState, mentalStateMode, mode, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppState appState,
    String mentalStateMode,
    AdaptiveTileMode mode,
    AppLocalizations l10n,
  ) {
    switch (mentalStateMode) {
      case 'rightNow':
        return _buildRightNowContent(context, appState, mode, l10n);
      case 'goodThings':
        return _buildGoodThingsContent(context, appState, mode, l10n);
      case 'thoughtLens':
        return _buildThoughtLensContent(context, appState, mode, l10n);
      default:
        return _buildRightNowContent(context, appState, mode, l10n);
    }
  }

  Widget _buildRightNowContent(
    BuildContext context,
    AppState appState,
    AdaptiveTileMode mode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentMood = appState.todayState.moodSelection;
    final moodTimestamp = appState.todayState.moodSelectionTimestamp;
    
    // Check if 1 hour has passed since mood selection
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final canChangeMood = currentMood == null || 
        (moodTimestamp != null && moodTimestamp.isBefore(oneHourAgo));

    if (currentMood != null && !canChangeMood) {
      return _buildMoodCompleted(context, currentMood, mode, l10n);
    }

    if (mode == AdaptiveTileMode.compact) {
      // Compact: show mood emojis in a row
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          _CompactMoodButton(
            emoji: '😢',
            onTap: () => _selectMood(appState, 1),
          ),
          _CompactMoodButton(
            emoji: '😐',
            onTap: () => _selectMood(appState, 3),
          ),
          _CompactMoodButton(
            emoji: '😊',
            onTap: () => _selectMood(appState, 5),
          ),
        ],
      );
    }

    // Medium or Expanded: show all mood options with responsive grid
    final isExpanded = mode == AdaptiveTileMode.expanded;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        
        // Calculate button sizing based on available space
        final minButtonWidth = isExpanded ? 70.0 : 60.0;
        final columns = (availableWidth / minButtonWidth).floor().clamp(2, 5);
        final buttonWidth = (availableWidth - (columns - 1) * 8) / columns;
        
        // Calculate if we need compact sizing
        final useCompact = availableHeight < 100 || buttonWidth < 65;
        final emojiSize = useCompact ? 20.0 : (isExpanded ? 28.0 : 24.0);
        final labelSize = useCompact ? 10.0 : (isExpanded ? 12.0 : 11.0);
        final padding = useCompact ? 6.0 : (isExpanded ? 12.0 : 10.0);
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExpanded)
              Text(
                l10n.cbtRightNowQuestion,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            if (isExpanded) const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _ResizableMoodButton(
                  emoji: '😢',
                  label: l10n.cbtMoodVerySad,
                  onTap: () => _selectMood(appState, 1),
                  width: buttonWidth,
                  emojiSize: emojiSize,
                  labelSize: labelSize,
                  padding: padding,
                  showLabel: !useCompact,
                ),
                _ResizableMoodButton(
                  emoji: '😕',
                  label: l10n.cbtMoodSad,
                  onTap: () => _selectMood(appState, 2),
                  width: buttonWidth,
                  emojiSize: emojiSize,
                  labelSize: labelSize,
                  padding: padding,
                  showLabel: !useCompact,
                ),
                _ResizableMoodButton(
                  emoji: '😐',
                  label: l10n.cbtMoodNeutral,
                  onTap: () => _selectMood(appState, 3),
                  width: buttonWidth,
                  emojiSize: emojiSize,
                  labelSize: labelSize,
                  padding: padding,
                  showLabel: !useCompact,
                ),
                _ResizableMoodButton(
                  emoji: '🙂',
                  label: l10n.cbtMoodGood,
                  onTap: () => _selectMood(appState, 4),
                  width: buttonWidth,
                  emojiSize: emojiSize,
                  labelSize: labelSize,
                  padding: padding,
                  showLabel: !useCompact,
                ),
                _ResizableMoodButton(
                  emoji: '😊',
                  label: l10n.cbtMoodVeryGood,
                  onTap: () => _selectMood(appState, 5),
                  width: buttonWidth,
                  emojiSize: emojiSize,
                  labelSize: labelSize,
                  padding: padding,
                  showLabel: !useCompact,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoodCompleted(
    BuildContext context,
    int mood,
    AdaptiveTileMode mode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final moodEmoji = _getMoodEmoji(mood);

    if (mode == AdaptiveTileMode.compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            moodEmoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.cbtMoodRecorded,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF059669),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              moodEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.cbtMoodRecorded,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _selectMood(
            Provider.of<AppState>(context, listen: false),
            null,
          ),
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

  Widget _buildGoodThingsContent(
    BuildContext context,
    AppState appState,
    AdaptiveTileMode mode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final goodThings = appState.todayState.goodThings;

    if (goodThings.isNotEmpty) {
      return _buildGoodThingsCompleted(context, goodThings, mode, l10n);
    }

    if (mode == AdaptiveTileMode.compact) {
      return ElevatedButton(
        onPressed: () => showMentalStateModule(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          padding: const EdgeInsets.all(12),
          minimumSize: const Size(44, 44),
        ),
        child: const Icon(Icons.add, size: 20),
      );
    }

    return Column(
      children: [
        if (mode == AdaptiveTileMode.expanded) ...[
          Text(
            l10n.cbtGoodThingsQuestion,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Show good things inline in expanded mode
          ...goodThings.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final thing = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      thing,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (goodThings.isNotEmpty) const SizedBox(height: 12),
        ],
        // Show button in all cases when list is empty, or when not in expanded mode
        if (goodThings.isEmpty || mode != AdaptiveTileMode.expanded)
          ElevatedButton.icon(
            onPressed: () => showMentalStateModule(context),
            icon: Icon(goodThings.isEmpty ? Icons.edit_note : Icons.add, size: 18),
            label: Text(goodThings.isEmpty ? l10n.cbtModeGoodThings : l10n.dialogClose),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              elevation: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildGoodThingsCompleted(
    BuildContext context,
    List<String> goodThings,
    AdaptiveTileMode mode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (mode == AdaptiveTileMode.compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 24, color: Color(0xFF059669)),
          const SizedBox(width: 8),
          Text(
            '${goodThings.length} ${l10n.cbtModeGoodThings.toLowerCase()}',
            style: theme.textTheme.bodyMedium?.copyWith(
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 32, color: Color(0xFF059669)),
            const SizedBox(width: 12),
            Text(
              '${goodThings.length} ${l10n.cbtModeGoodThings.toLowerCase()}',
              style: theme.textTheme.bodyMedium,
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

  Widget _buildThoughtLensContent(
    BuildContext context,
    AppState appState,
    AdaptiveTileMode mode,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (mode == AdaptiveTileMode.compact) {
      return ElevatedButton(
        onPressed: () => showMentalStateModule(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          padding: const EdgeInsets.all(12),
          minimumSize: const Size(44, 44),
        ),
        child: const Icon(Icons.psychology, size: 20),
      );
    }

    return Column(
      children: [
        if (mode == AdaptiveTileMode.expanded) ...[
          Text(
            l10n.cbtThoughtLensTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Show thought lens content inline in expanded mode
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MentalStateConstants.getDistortion(appState.todayState.thoughtLensIndex)['title'] ?? 'Unknown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  MentalStateConstants.getDistortion(appState.todayState.thoughtLensIndex)['description'] ?? '',
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
                        MentalStateConstants.getDistortion(appState.todayState.thoughtLensIndex)['example'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    appState.updateTodayState((state) {
                      state.thoughtLensIndex = ((appState.todayState.thoughtLensIndex - 1 + MentalStateConstants.distortionCount) % MentalStateConstants.distortionCount);
                    });
                  },
                  child: Text(l10n.cbtThoughtLensPrevious),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    appState.updateTodayState((state) {
                      state.thoughtLensIndex = ((appState.todayState.thoughtLensIndex + 1) % MentalStateConstants.distortionCount);
                    });
                  },
                  child: Text(l10n.cbtThoughtLensNext),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${appState.todayState.thoughtLensIndex + 1} / ${MentalStateConstants.distortionCount}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (mode != AdaptiveTileMode.expanded)
          ElevatedButton.icon(
            onPressed: () => showMentalStateModule(context),
            icon: const Icon(Icons.psychology, size: 18),
            label: Text(l10n.cbtModeThoughtLens),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              elevation: 0,
            ),
          ),
      ],
    );
  }

  /// Checks if mood can be changed based on timestamp (1-hour cooldown)
  bool _canChangeMood(AppState appState) {
    return canChangeMood(appState);
  }

  void _selectMood(AppState appState, int? value) {
    if (value == null || _canChangeMood(appState)) {
      appState.updateTodayState((state) {
        state.moodSelection = value;
        state.moodSelectionTimestamp = value != null ? DateTime.now() : null;
      });
    }
  }

  
  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'rightNow':
        return Icons.mood;
      case 'goodThings':
        return Icons.favorite;
      case 'thoughtLens':
        return Icons.psychology;
      default:
        return Icons.mood;
    }
  }

  String _getModeTitle(AppLocalizations l10n, String mode) {
    switch (mode) {
      case 'rightNow':
        return l10n.cbtModeRightNow;
      case 'goodThings':
        return l10n.cbtModeGoodThings;
      case 'thoughtLens':
        return l10n.cbtModeThoughtLens;
      default:
        return l10n.mentalStateModuleLabel;
    }
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
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

class _ResizableMoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final double width;
  final double emojiSize;
  final double labelSize;
  final double padding;
  final bool showLabel;

  const _ResizableMoodButton({
    required this.emoji,
    required this.label,
    required this.onTap,
    required this.width,
    required this.emojiSize,
    required this.labelSize,
    required this.padding,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: TextStyle(fontSize: emojiSize)),
                if (showLabel) ...[
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontSize: labelSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactMoodButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _CompactMoodButton({
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
