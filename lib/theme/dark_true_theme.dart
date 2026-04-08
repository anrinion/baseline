import 'package:flutter/material.dart';

import 'theme_common.dart';

/// Dark (true black) — high contrast, emerald accent.
ThemeData buildDarkTrueTheme() {
  const primary = Color(0xFF34D399);
  final scheme = ColorScheme.dark(
    primary: primary,
    onPrimary: Color(0xFF022C22),
    primaryContainer: Color(0xFF065F46),
    onPrimaryContainer: Color(0xFFD1FAE5),
    secondary: Color(0xFFFBBF24),
    onSecondary: Color(0xFF422006),
    surface: Colors.black,
    onSurface: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF334155),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
  );

  return applyBaselineChrome(
    colorScheme: scheme,
    scaffoldBackground: Colors.black,
    cardColor: Color(0xFF0A0A0A),
  );
}
