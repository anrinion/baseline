import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../modules/module_help.dart';
import '../state/app_state.dart';
import 'adaptive_layout.dart';

// =============================================================================
// SPACING & INSETS
// =============================================================================

/// Card margins for module tiles
abstract final class TileMargins {
  static const double normal = 12;
  static const double compact = 8;

  static double forMode(AdaptiveTileMode mode) =>
      mode == AdaptiveTileMode.compact ? compact : normal;
}

/// Padding values for tile content
abstract final class TilePadding {
  static const double normal = 12;
  static const double compact = 6;
  static const double small = 8;

  static double forMode(AdaptiveTileMode mode) =>
      mode == AdaptiveTileMode.compact ? compact : normal;
}

/// Vertical spacing between elements
abstract final class TileSpacing {
  static const double tiny = 2;
  static const double small = 4;
  static const double medium = 6;
  static const double normal = 8;
  static const double large = 12;
}

/// Standard thresholds for the 4 main modules (meds, sleep, mental, movement)
/// to ensure consistent mode transitions across all tiles.
const standardModuleTileThresholds = AdaptiveTileThresholds(
  microHeight: 60,
  microWidth: 100,
  compactHeight: 100,
  compactWidth: 200,
  expandedHeight: 140,
  expandedWidth: 350,
);

/// Calculates available space for the 4 main modules using unified margins.
/// Use this in sleep, mental, meds, and movement modules for consistent behavior.
({double width, double height}) calculateModuleTileAvailableSpace(BoxConstraints constraints) {
  const horizontalPadding = TilePadding.normal * 2; // 24px total left+right
  const verticalMargin = TileMargins.normal * 2 + TileSpacing.normal; // ~32px
  return (
    width: constraints.maxWidth - horizontalPadding,
    height: constraints.maxHeight - verticalMargin,
  );
}

/// Available space calculation helpers
abstract final class TileAvailableSpace {
  static double width(double maxWidth, {double padding = TilePadding.normal}) =>
      maxWidth - (padding * 2);

  static double height(double maxHeight, {double padding = TilePadding.normal}) =>
      maxHeight - (padding * 2);
}

// =============================================================================
// DIMENSIONS & SHAPES
// =============================================================================

/// Border radius values
abstract final class TileBorderRadius {
  static const double tile = 20;
  static const double button = 40;
  static const double chip = 8;
  static const double iconButton = 16;
}

/// Pre-built shape for module tiles
RoundedRectangleBorder tileShape() =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(TileBorderRadius.tile));

/// Icon sizes used across tiles
abstract final class TileIconSizes {
  static const double small = 14;
  static const double compact = 18;
  static const double normal = 20;
  static const double large = 32;

  static double forMode(AdaptiveTileMode mode) =>
      mode == AdaptiveTileMode.compact ? compact : normal;
}

/// Button and control sizes
abstract final class TileControlSizes {
  static const double iconButtonMin = 36;
  static const double iconButtonMinCompact = 28;
}

// =============================================================================
// TYPOGRAPHY
// =============================================================================

/// Font sizes used across tiles
abstract final class TileFontSizes {
  static const double compactHeader = 13;
  static const double small = 10;
  static const double labelSmall = 11;
  static const double tiny = 9;
}

// =============================================================================
// CARD STYLING
// =============================================================================

/// Standard card styling for module tiles
class TileCard extends StatelessWidget {
  final Widget child;
  final bool isCompact;
  final VoidCallback? onTap;
  final Color? color;

  const TileCard({
    super.key,
    required this.child,
    this.isCompact = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final card = Card(
      margin: EdgeInsets.all(TileMargins.forMode(
          isCompact ? AdaptiveTileMode.compact : AdaptiveTileMode.medium)),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: color ?? scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: tileShape(),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(TileBorderRadius.tile),
              child: child,
            )
          : child,
    );

    return onTap == null ? card : card;
  }
}

// =============================================================================
// HEADER COMPONENTS
// =============================================================================

/// Standard module header with icon, title, and optional trailing widgets
class TileHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isCompact;
  final List<Widget> trailing;

  const TileHeader({
    super.key,
    required this.icon,
    required this.title,
    this.isCompact = false,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color: scheme.primary,
          size: TileIconSizes.forMode(
              isCompact ? AdaptiveTileMode.compact : AdaptiveTileMode.medium),
        ),
        const SizedBox(width: TileSpacing.medium),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                  fontSize: isCompact ? TileFontSizes.compactHeader : null,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ...trailing,
      ],
    );
  }
}

/// Layout mode indicator widget that shows current tile mode (for debugging)
class TileModeIndicator extends StatelessWidget {
  final AdaptiveTileMode mode;

  const TileModeIndicator({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.settings.developerModeEnabled,
      builder: (context, enabled, child) {
        return buildLayoutModeIndicator(context, mode, enabled: enabled);
      },
    );
  }
}

/// Standardized help button for module tiles
class TileHelpButton extends StatelessWidget {
  final String moduleId;
  final bool compact;

  const TileHelpButton({
    super.key,
    required this.moduleId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: Icon(
        Icons.help_outline,
        size: compact ? TileIconSizes.compact : TileIconSizes.normal,
        color: Theme.of(context).colorScheme.outline,
      ),
      tooltip: l10n.dialogWhyThisHelps,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: TileControlSizes.iconButtonMin,
        minHeight: TileControlSizes.iconButtonMin,
      ),
      onPressed: () => showModuleHelp(context, moduleId),
    );
  }
}

/// A compact action button (icon only) used in several tiles
class TileCompactActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const TileCompactActionButton({
    super.key,
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
        padding: const EdgeInsets.all(TilePadding.normal),
        minimumSize: const Size(44, 44),
      ),
      child: Icon(icon, size: TileIconSizes.normal),
    );
  }
}

/// An adaptive icon button that maintains aspect ratio
class TileAdaptiveIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double maxHeight;
  final Color backgroundColor;

  const TileAdaptiveIconButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.maxHeight,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(TileBorderRadius.iconButton),
            child: InkWell(
              borderRadius: BorderRadius.circular(TileBorderRadius.iconButton),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(TilePadding.normal),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER EXTENSIONS
// =============================================================================

extension TileModeExtensions on AdaptiveTileMode {
  bool get isCompact => this == AdaptiveTileMode.compact;
  bool get isMicro => this == AdaptiveTileMode.micro;
  bool get isExpanded => this == AdaptiveTileMode.expanded;
  bool get isMedium => this == AdaptiveTileMode.medium;
}

extension BoolCompact on bool {
  double margin() => this ? TileMargins.compact : TileMargins.normal;
  double padding() => this ? TilePadding.compact : TilePadding.normal;
  double iconSize() => this ? TileIconSizes.compact : TileIconSizes.normal;
}
