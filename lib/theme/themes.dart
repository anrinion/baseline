import 'package:flutter/material.dart';

import 'dark_soft_theme.dart';
import 'dark_true_theme.dart';
import 'light_neutral_theme.dart';
import 'light_warm_theme.dart';

/// App-wide theme entry points. Settings keys: `light1`, `light2`, `dark1`, `dark2`.
///
/// To add a theme: create a new file (e.g. `my_theme.dart`) that returns [ThemeData]
/// via [applyBaselineChrome] from [theme_common.dart], import it here, and add a
/// static method plus a branch in [AppState.currentTheme].
abstract final class BaselineThemes {
  /// Light (neutral) — emerald + slate; matches Food module palette.
  static ThemeData light1() => buildLightNeutralTheme();

  /// Light (warm) — amber / sand.
  static ThemeData light2() => buildLightWarmTheme();

  /// Dark — true black, emerald accent.
  static ThemeData dark1() => buildDarkTrueTheme();

  /// Dark — soft zinc surfaces.
  static ThemeData dark2() => buildDarkSoftTheme();
}
