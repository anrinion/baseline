import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final label = context.select<AppState, String>(
      (s) => s.settings.hereButtonText,
    );

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
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.grounding,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
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
                    ? _buildAffirmation(theme, scheme)
                    : _buildButton(theme, scheme, label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(ThemeData theme, ColorScheme scheme, String label) {
    return SizedBox(
      key: const ValueKey('btn'),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onPressed(context),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildAffirmation(ThemeData theme, ColorScheme scheme) {
    return FadeTransition(
      key: const ValueKey('phrase'),
      opacity: _fadeIn,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Center(
          child: Text(
            _activePhrase!,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
