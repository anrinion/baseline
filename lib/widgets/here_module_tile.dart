import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/adaptive_layout.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'module_tile.dart';
import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../state/app_state.dart';
import '../l10n/app_localizations.dart';

/// Grounding anchor module — tap to affirm presence. Shows a random
/// affirmation phrase, then the button reappears after 30 seconds.
/// No persisted state; purely ephemeral.
class HereModuleTile extends StatefulWidget {
  const HereModuleTile({super.key});

  @override
  State<HereModuleTile> createState() => _HereModuleTileState();
}

class _HereModuleTileState extends State<HereModuleTile>
    with SingleTickerProviderStateMixin {
  static const _cooldown = Duration(seconds: 30);

  List<String> _phrases(AppLocalizations l10n) => [
        l10n.groundingAffirmation1,
        l10n.groundingAffirmation2,
        l10n.groundingAffirmation3,
        l10n.groundingAffirmation4,
        l10n.groundingAffirmation5,
      ];

  final _random = Random();

  /// Currently displayed affirmation, or null when button is showing.
  String? _activePhrase;
  Timer? _resetTimer;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPressed(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();
    setState(() {
      final phrases = _phrases(l10n);
      _activePhrase = phrases[_random.nextInt(phrases.length)];
    });
    _fadeController
      ..reset()
      ..forward();

    _resetTimer?.cancel();
    _resetTimer = Timer(_cooldown, () {
      if (mounted) {
        setState(() => _activePhrase = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context)!;
        final appState = Provider.of<AppState>(context);
        final label = appState.settings.hereButtonText;

        final availableWidth = constraints.maxWidth.isFinite 
            ? constraints.maxWidth - 40 // 20 padding each side
            : 300.0; // fallback
        final availableHeight = constraints.maxHeight.isFinite 
            ? constraints.maxHeight - 64 // header + margins
            : 100.0; // fallback

        final mode = resolveStandardTileMode(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          thresholds: const AdaptiveTileThresholds(
            microHeight: 40,
            microWidth: 100,
            compactHeight: 80,
            compactWidth: 200,
            expandedHeight: 100,
            expandedWidth: 400,
          ),
        );

        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.here);
        }

        final isCompact = mode == AdaptiveTileMode.compact;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header row (icon + title + help) ──
                  Row(
                    children: [
                      Icon(
                        Icons.center_focus_strong_outlined,
                        color: scheme.primary,
                        size: isCompact ? 18 : 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.grounding,
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
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.help_outline,
                          size: isCompact ? 18 : 20,
                          color: scheme.outline,
                        ),
                        tooltip: l10n.dialogWhyThisHelps,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed: () =>
                            showModuleHelp(context, BaselineModuleId.here),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Button / affirmation ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _activePhrase != null
                        ? _buildAffirmation(theme, scheme, isCompact)
                        : _buildButton(theme, scheme, label, isCompact),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(ThemeData theme, ColorScheme scheme, String label, bool isCompact) {
    return SizedBox(
      key: const ValueKey('btn'),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onPressed(context),
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(isCompact ? 44 : 52),
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onPrimaryContainer,
            fontSize: isCompact ? 14 : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAffirmation(ThemeData theme, ColorScheme scheme, bool isCompact) {
    return FadeTransition(
      key: const ValueKey('phrase'),
      opacity: _fadeIn,
      child: SizedBox(
        width: double.infinity,
        height: isCompact ? 44 : 52,
        child: Center(
          child: Text(
            _activePhrase!,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              fontSize: isCompact ? 14 : null,
            ),
          ),
        ),
      ),
    );
  }
}
