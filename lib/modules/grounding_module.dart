import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'module_help.dart';
import 'module_ids.dart';

/// Cooldown duration after showing an affirmation.
const groundingCooldown = Duration(seconds: 30);

/// Fade animation duration for affirmation.
const groundingFadeDuration = Duration(milliseconds: 500);

/// Switcher animation duration.
const groundingSwitchDuration = Duration(milliseconds: 400);

/// Returns the list of grounding affirmation phrases.
List<String> groundingPhrases(AppLocalizations l10n) => [
      l10n.groundingAffirmation1,
      l10n.groundingAffirmation2,
      l10n.groundingAffirmation3,
      l10n.groundingAffirmation4,
      l10n.groundingAffirmation5,
    ];

/// Controller that manages grounding module state and business logic.
/// Used by both the tile and the dialog.
class GroundingController extends ChangeNotifier {
  final TickerProvider _vsync;
  late final AnimationController fadeController;
  late final Animation<double> fadeAnimation;

  String? _activePhrase;
  Timer? _resetTimer;
  final _random = Random();

  GroundingController(this._vsync) {
    fadeController = AnimationController(
      vsync: _vsync,
      duration: groundingFadeDuration,
    );
    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  /// Currently displayed affirmation, or null when button is showing.
  String? get activePhrase => _activePhrase;

  /// Whether an affirmation is currently being shown.
  bool get isShowingAffirmation => _activePhrase != null;

  /// Triggers the grounding action: selects a random phrase, triggers haptic,
  /// starts the fade animation, and sets up the cooldown timer.
  void trigger(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();

    final phrases = groundingPhrases(l10n);
    _activePhrase = phrases[_random.nextInt(phrases.length)];
    notifyListeners();

    fadeController.reset();
    fadeController.forward();

    _resetTimer?.cancel();
    _resetTimer = Timer(groundingCooldown, () {
      _activePhrase = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    fadeController.dispose();
    super.dispose();
  }
}

/// Opens the Grounding module dialog.
void showGroundingModule(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => const _GroundingDialog(),
  );
}

class _GroundingDialog extends StatefulWidget {
  const _GroundingDialog();

  @override
  State<_GroundingDialog> createState() => _GroundingDialogState();
}

class _GroundingDialogState extends State<_GroundingDialog>
    with TickerProviderStateMixin {
  late final GroundingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GroundingController(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() => _controller.trigger(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppState>(
      builder: (context, appState, _) {
        final label = appState.settings.hereButtonText;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360, maxHeight: 280),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogHeader(theme, scheme, l10n),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GroundingContent(
                      controller: _controller,
                      label: label,
                      onPressed: _onPressed,
                      minButtonHeight: 56,
                      borderRadius: 16,
                      buttonStyle: GroundingButtonStyle.dialog,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(
      ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.center_focus_strong_outlined,
          color: scheme.primary,
          size: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.grounding,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.help_outline, size: 22, color: scheme.outline),
          tooltip: l10n.dialogWhyThisHelps,
          onPressed: () => showModuleHelp(context, BaselineModuleId.here),
        ),
        IconButton(
          icon: Icon(Icons.close, size: 22, color: scheme.outline),
          tooltip: l10n.dialogClose,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Style preset for [GroundingButton].
enum GroundingButtonStyle { tile, dialog }

/// Shared widget that displays either the grounding button or the affirmation.
/// Used by both the tile and the dialog.
class GroundingContent extends StatelessWidget {
  final GroundingController controller;
  final String label;
  final VoidCallback onPressed;
  final double minButtonHeight;
  final double borderRadius;
  final GroundingButtonStyle buttonStyle;

  const GroundingContent({
    super.key,
    required this.controller,
    required this.label,
    required this.onPressed,
    required this.minButtonHeight,
    required this.borderRadius,
    this.buttonStyle = GroundingButtonStyle.tile,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: groundingSwitchDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: controller.isShowingAffirmation
              ? _buildAffirmation(context)
              : _buildButton(context),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    return GroundingButton(
      key: const ValueKey('btn'),
      label: label,
      onPressed: onPressed,
      minHeight: minButtonHeight,
      borderRadius: borderRadius,
      style: buttonStyle,
    );
  }

  Widget _buildAffirmation(BuildContext context) {
    return GroundingAffirmation(
      key: const ValueKey('phrase'),
      phrase: controller.activePhrase!,
      fadeAnimation: controller.fadeAnimation,
      style: buttonStyle,
    );
  }
}

/// The grounding button widget with consistent styling.
class GroundingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double minHeight;
  final double borderRadius;
  final GroundingButtonStyle style;

  const GroundingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.minHeight,
    required this.borderRadius,
    this.style = GroundingButtonStyle.tile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(minHeight),
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            label,
            style: _buttonTextStyle(theme, scheme),
          ),
        ),
      ),
    );
  }

  TextStyle? _buttonTextStyle(ThemeData theme, ColorScheme scheme) {
    final baseStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: scheme.onPrimaryContainer,
    );

    if (style == GroundingButtonStyle.dialog) {
      return baseStyle;
    }
    // Tile style may override in the tile itself via fontSize
    return baseStyle;
  }
}

/// The grounding affirmation widget with fade animation.
class GroundingAffirmation extends StatelessWidget {
  final String phrase;
  final Animation<double> fadeAnimation;
  final GroundingButtonStyle style;

  const GroundingAffirmation({
    super.key,
    required this.phrase,
    required this.fadeAnimation,
    this.style = GroundingButtonStyle.tile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return FadeTransition(
      opacity: fadeAnimation,
      child: Align(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            phrase,
            textAlign: TextAlign.center,
            style: _affirmationTextStyle(theme, scheme),
          ),
        ),
      ),
    );
  }

  TextStyle? _affirmationTextStyle(ThemeData theme, ColorScheme scheme) {
    if (style == GroundingButtonStyle.dialog) {
      return theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      );
    }
    return theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w500,
      color: scheme.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    );
  }
}
