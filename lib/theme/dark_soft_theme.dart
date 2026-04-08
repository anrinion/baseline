import 'package:flutter/material.dart';

import 'theme_common.dart';

/// Dark (soft) — zinc surfaces, softer contrast.
ThemeData buildDarkSoftTheme() {
  const surface = Color(0xFF18181B);
  final scheme = ColorScheme.fromSeed(
    seedColor: Color(0xFF4ADE80),
    brightness: Brightness.dark,
  ).copyWith(
    surface: surface,
    onSurface: Color(0xFFFAFAFA),
    onSurfaceVariant: Color(0xFFA1A1AA),
  );

  return applyBaselineChrome(
    colorScheme: scheme,
    scaffoldBackground: surface,
    cardColor: Color(0xFF27272A),
  );
}
