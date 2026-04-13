import 'package:flutter/material.dart';

enum AdaptiveTileMode { micro, compact, medium, expanded }

class AdaptiveTileThresholds {
  const AdaptiveTileThresholds({
    required this.microHeight,
    required this.microWidth,
    required this.compactHeight,
    required this.compactWidth,
    required this.expandedHeight,
    required this.expandedWidth,
  });

  final double microHeight;
  final double microWidth;
  final double compactHeight;
  final double compactWidth;
  final double expandedHeight;
  final double expandedWidth;
}

class AdaptiveSizing {
  static double measureTextWidth(
    BuildContext context,
    String text,
    TextStyle? style,
  ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  static double measureTextHeight(
    BuildContext context,
    String text,
    TextStyle? style,
    double maxWidth,
  ) {
    if (maxWidth <= 0) return 0;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
    )..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.size.height;
  }

  static double calculateWrapHeight(
    List<double> itemWidths,
    double availableWidth,
    double itemHeight,
    double runSpacing,
    double spacing,
  ) {
    if (itemWidths.isEmpty) return 0;
    if (availableWidth <= 0) return double.infinity;
    double currentX = 0;
    int rows = 1;

    for (final width in itemWidths) {
      if (currentX + width > availableWidth) {
        if (currentX == 0) {
          currentX = width + spacing;
        } else {
          rows++;
          currentX = width + spacing;
        }
      } else {
        currentX += width + spacing;
      }
    }
    return rows * itemHeight + (rows - 1) * runSpacing;
  }
}

AdaptiveTileMode resolveStandardTileMode({
  required double availableWidth,
  required double availableHeight,
  required AdaptiveTileThresholds thresholds,
}) {
  if (availableHeight < thresholds.microHeight ||
      availableWidth < thresholds.microWidth) {
    return AdaptiveTileMode.micro;
  }

  if (availableHeight < thresholds.compactHeight ||
      availableWidth < thresholds.compactWidth) {
    return AdaptiveTileMode.compact;
  }

  if (availableWidth >= thresholds.expandedWidth &&
      availableHeight >= thresholds.expandedHeight) {
    return AdaptiveTileMode.expanded;
  }

  return AdaptiveTileMode.medium;
}

/// Builds a small indicator showing the current layout mode.
/// Used for debugging when developer mode is enabled.
Widget buildLayoutModeIndicator(
  BuildContext context,
  AdaptiveTileMode mode, {
  bool enabled = false,
  double? availableWidth,
  double? availableHeight,
}) {
  if (!enabled) return const SizedBox.shrink();

  final scheme = Theme.of(context).colorScheme;
  final theme = Theme.of(context);

  final letter = mode.name.substring(0, 1).toUpperCase();

  // Use provided constraints or fallback to screen size
  final size = MediaQuery.of(context).size;
  double widthValue = availableWidth ?? size.width;
  double heightValue = availableHeight ?? size.height;
  
  // Handle NaN or negative values
  if (widthValue.isNaN || widthValue < 0) widthValue = 0;
  if (heightValue.isNaN || heightValue < 0) heightValue = 0;
  
  final width = widthValue.toInt();
  final height = heightValue.toInt();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: BoxDecoration(
      color: scheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          letter,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onTertiaryContainer,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '${width}x$height',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onTertiaryContainer,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
