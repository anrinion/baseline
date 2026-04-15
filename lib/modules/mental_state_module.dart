import 'dart:async';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/mental_state_constants.dart';
import '../state/app_state.dart';

class MentalStateModule extends StatelessWidget {
  const MentalStateModule({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final mentalStateMode = appState.settings.mentalStateMode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  l10n.mentalStateModuleLabel,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: mentalStateMode == 'rightNow'
                    ? _MoodSelectionContent(appState: appState, l10n: l10n)
                    : mentalStateMode == 'goodThings'
                        ? _GoodThingsContent(appState: appState, l10n: l10n)
                        : _ThoughtLensContent(appState: appState, l10n: l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _MoodSelectionContent extends StatelessWidget {
  final AppState appState;
  final AppLocalizations l10n;

  const _MoodSelectionContent({
    required this.appState,
    required this.l10n,
  });

  /// Checks if mood can be changed based on timestamp (1-hour cooldown)
  bool _canChangeMood() {
    return canChangeMood(appState);
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = appState.todayState.moodSelection;

    return Column(
      children: [
        Text(
          l10n.cbtRightNowQuestion,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 16,
          children: [
            _MoodFace(
              emoji: '😢',
              value: 1,
              label: l10n.cbtMoodVerySad,
              isSelected: currentMood == 1,
              onTap: () => _selectMood(1),
            ),
            _MoodFace(
              emoji: '😕',
              value: 2,
              label: l10n.cbtMoodSad,
              isSelected: currentMood == 2,
              onTap: () => _selectMood(2),
            ),
            _MoodFace(
              emoji: '😐',
              value: 3,
              label: l10n.cbtMoodNeutral,
              isSelected: currentMood == 3,
              onTap: () => _selectMood(3),
            ),
            _MoodFace(
              emoji: '🙂',
              value: 4,
              label: l10n.cbtMoodGood,
              isSelected: currentMood == 4,
              onTap: () => _selectMood(4),
            ),
            _MoodFace(
              emoji: '😊',
              value: 5,
              label: l10n.cbtMoodVeryGood,
              isSelected: currentMood == 5,
              onTap: () => _selectMood(5),
            ),
          ],
        ),
        if (currentMood != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.cbtMoodRecorded,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  void _selectMood(int value) {
    if (_canChangeMood()) {
      appState.updateTodayState((state) {
        state.moodSelection = value;
        state.moodSelectionTimestamp = clock.now();
      });
    }
  }
}

class _MoodFace extends StatelessWidget {
  final String emoji;
  final int value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodFace({
    required this.emoji,
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                  ? Border.all(color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _GoodThingsContent extends StatefulWidget {
  final AppState appState;
  final AppLocalizations l10n;

  const _GoodThingsContent({
    required this.appState,
    required this.l10n,
  });

  @override
  State<_GoodThingsContent> createState() => _GoodThingsContentState();
}

class _GoodThingsContentState extends State<_GoodThingsContent> {
  late List<TextEditingController> _controllers;
  Timer? _debounceTimer;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      final controller = TextEditingController();
      if (index < widget.appState.todayState.goodThings.length) {
        controller.text = widget.appState.todayState.goodThings[index];
      }
      return controller;
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _debouncedUpdateState(int index, String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_disposed) {
        _updateState(index, value);
      }
    });
  }

  void _updateState(int index, String value) {
    // Sanitize input: trim whitespace and limit length
    final sanitizedValue = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (sanitizedValue.length > 200) {
      // Prevent excessively long inputs
      return;
    }
    
    final currentGoodThings = widget.appState.todayState.goodThings;
    final updatedGoodThings = List<String>.from(currentGoodThings);
    
    // Ensure list has enough elements
    while (updatedGoodThings.length <= index) {
      updatedGoodThings.add('');
    }
    
    updatedGoodThings[index] = sanitizedValue;
    
    // Only update state if something actually changed
    if (!_listsEqual(currentGoodThings, updatedGoodThings)) {
      widget.appState.updateTodayState((state) {
        state.goodThings = updatedGoodThings.where((item) => item.isNotEmpty).toList();
      });
    }
  }

  /// Helper method to compare two lists efficiently
  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.l10n.cbtGoodThingsQuestion,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (index) {
          final hasContent = _controllers[index].text.trim().isNotEmpty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _controllers[index],
              decoration: InputDecoration(
                hintText: '${widget.l10n.cbtGoodThing} ${index + 1}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasContent 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: hasContent 
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      )
                    : null,
              ),
              maxLines: 2,
              onChanged: (value) {
                _debouncedUpdateState(index, value);
                // Force rebuild to update the visual indicators
                setState(() {});
              },
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'You can edit these entries anytime during the day',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.l10n.cbtGoodThingsHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThoughtLensContent extends StatelessWidget {
  final AppState appState;
  final AppLocalizations l10n;

  const _ThoughtLensContent({
    required this.appState,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = appState.todayState.thoughtLensIndex;
    final distortion = MentalStateConstants.getDistortion(currentIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.cbtThoughtLensTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                distortion['title'] ?? 'Unknown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                distortion['description'] ?? 'No description available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cbtThoughtLensExample,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      distortion['example'] ?? 'No example available.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.cbtThoughtLensDaily,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

void showMentalStateModule(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => const MentalStateModule(),
  );
}

/// Checks if mood can be changed based on timestamp (1-hour cooldown)
bool canChangeMood(AppState appState) {
  final currentMood = appState.todayState.moodSelection;
  final moodTimestamp = appState.todayState.moodSelectionTimestamp;
  
  if (currentMood == null) return true;
  if (moodTimestamp == null) return true;
  
  final oneHourAgo = clock.now().subtract(const Duration(hours: 1));
  return moodTimestamp.isBefore(oneHourAgo);
}
