import 'package:flutter/material.dart';

import 'theme_common.dart';

/// Light (warm) — amber / warm sand surfaces.
ThemeData buildLightWarmTheme() {
  const seed = Color(0xFFD97706);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  ).copyWith(
    surface: Color(0xFFFFF7ED),
    onSurface: Color(0xFF431407),
    onSurfaceVariant: Color(0xFF7C2D12),
  );

  return applyBaselineChrome(
    colorScheme: scheme,
    scaffoldBackground: Color(0xFFFFF7ED),
    cardColor: Color(0xFFFFFBF5),
  );
}
