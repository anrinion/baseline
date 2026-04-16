import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/adaptive_layout.dart';
import '../utils/layout_constants.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'module_tile.dart';
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
            ? TileAvailableSpace.width(constraints.maxWidth, padding: TilePadding.small + TileSpacing.normal)
            : 300.0;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - 56
            : 100.0;

        final mode = resolveStandardTileMode(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          thresholds: const AdaptiveTileThresholds(
            microHeight: 60,
            microWidth: 100,
            compactHeight: 60,
            compactWidth: 100,
            expandedHeight: 100,
            expandedWidth: 100,
          ),
        );

        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.here);
        }

        return TileCard(
          isCompact: mode.isCompact,
          child: Padding(
            padding: EdgeInsets.all(TilePadding.forMode(mode)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header row (icon + title + help) ──
                Row(
                  children: [
                    Icon(
                      Icons.center_focus_strong_outlined,
                      color: scheme.primary,
                      size: TileIconSizes.forMode(mode),
                    ),
                    const SizedBox(width: TileSpacing.medium),
                    Expanded(
                      child: Text(
                        l10n.grounding,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          fontSize: mode.isCompact ? TileFontSizes.compactHeader : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    TileModeIndicator(mode: mode),
                    TileHelpButton(
                      moduleId: BaselineModuleId.here,
                      compact: mode.isCompact,
                    ),
                  ],
                ),

                const SizedBox(height: TileSpacing.small),

                // ── Button / affirmation ──
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _activePhrase != null
                        ? _buildAffirmation(theme, scheme, mode.isCompact)
                        : _buildButton(theme, scheme, label, mode.isCompact),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(ThemeData theme, ColorScheme scheme, String label, bool isCompact) {
    return Align(
      key: const ValueKey('btn'),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () => _onPressed(context),
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(isCompact ? 44 : 52),
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isCompact ? TileBorderRadius.chip + 4 : TileBorderRadius.tile - 4),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onPrimaryContainer,
            fontSize: isCompact ? TileFontSizes.compactHeader + 1 : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAffirmation(ThemeData theme, ColorScheme scheme, bool isCompact) {
    return FadeTransition(
      key: const ValueKey('phrase'),
      opacity: _fadeIn,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          _activePhrase!,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
            fontSize: isCompact ? TileFontSizes.compactHeader + 1 : null,
          ),
        ),
      ),
    );
  }
}
