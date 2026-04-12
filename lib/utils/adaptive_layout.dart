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
