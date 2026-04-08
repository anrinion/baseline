import 'package:flutter/material.dart';

/// Shared Material 3 chrome (cards, app bar, buttons, typography) for all Baseline themes.
ThemeData applyBaselineChrome({
  required ColorScheme colorScheme,
  required Color scaffoldBackground,
  required Color cardColor,
}) {
  final isDark = colorScheme.brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      shadowColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 1),
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: isDark ? cardColor : colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scaffoldBackground,
      foregroundColor: colorScheme.primary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: colorScheme.onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: colorScheme.onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        color: colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
