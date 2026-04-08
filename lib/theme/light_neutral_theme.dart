import 'package:flutter/material.dart';

import 'theme_common.dart';

/// Light (neutral) — emerald primary, slate surfaces (matches Food module demo).
ThemeData buildLightNeutralTheme() {
  const primary = Color(0xFF059669);
  const surface = Color(0xFFF8FAFC);
  final scheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD1FAE5),
    onPrimaryContainer: Color(0xFF064E3B),
    secondary: Color(0xFFF59E0B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFEDD5),
    onSecondaryContainer: Color(0xFF7C2D12),
    tertiary: Color(0xFF0EA5E9),
    onTertiary: Colors.white,
    error: Color(0xFFDC2626),
    onError: Colors.white,
    surface: surface,
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF475569),
    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),
    shadow: Colors.black26,
    scrim: Colors.black54,
  );

  return applyBaselineChrome(
    colorScheme: scheme,
    scaffoldBackground: surface,
    cardColor: Colors.white,
  );
}
