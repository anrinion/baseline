import 'dart:convert';

import 'package:hive/hive.dart';

import '../modules/module_ids.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings extends HiveObject {
  static const String themeModeManual = 'manual';
  static const String themeModeDevice = 'device';
  static const String themeModeSchedule = 'schedule';

  static const String _themeModeKey = 'theme.mode';
  static const String _lightThemeKey = 'theme.lightTheme';
  static const String _darkThemeKey = 'theme.darkTheme';
  static const String _scheduleLightStartKey = 'theme.scheduleLightStartMinutes';
  static const String _scheduleDarkStartKey = 'theme.scheduleDarkStartMinutes';
  static const String _developerModeKey = 'app.developerMode';

  @HiveField(0)
  String language = 'en'; // default English

  @HiveField(1)
  String theme = 'light1';

  /// Label for the [BaselineModuleId.here] anchor (same persisted field as before migration).
  @HiveField(2)
  String hereButtonText = 'I\'m here. I\'m alive.';

  /// Subset of [BaselineModuleId.all]; persisted. Missing on legacy data → all on.
  @HiveField(3)
  List<String> enabledModuleIds = List<String>.from(BaselineModuleId.all);

  /// JSON map of `"moduleId.settingKey"` → string. [hereButtonText] remains the source for `here` + `buttonText` until migrated into this map; prefer [getModuleSetting] / [setModuleSetting].
  @HiveField(4)
  String moduleSettingsJson = '{}';

  @HiveField(5)
  bool isFirstLaunch = true;

  @HiveField(6)
  String mentalStateMode = 'rightNow'; // 'rightNow', 'goodThings', 'thoughtLens'

  String get themeMode =>
      _normalizeThemeMode(_moduleSettingsMap()[_themeModeKey]);

  set themeMode(String value) {
    _setAppSetting(_themeModeKey, _normalizeThemeMode(value));
  }

  String get lightThemeKey =>
      _normalizeLightThemeKey(
        _moduleSettingsMap()[_lightThemeKey] ??
            (isLightTheme(theme) ? theme : 'light1'),
      );

  set lightThemeKey(String value) {
    _setAppSetting(_lightThemeKey, _normalizeLightThemeKey(value));
  }

  String get darkThemeKey =>
      _normalizeDarkThemeKey(
        _moduleSettingsMap()[_darkThemeKey] ??
            (isDarkTheme(theme) ? theme : 'dark2'),
      );

  set darkThemeKey(String value) {
    _setAppSetting(_darkThemeKey, _normalizeDarkThemeKey(value));
  }

  int get scheduleLightStartMinutes => _readMinuteSetting(
        _scheduleLightStartKey,
        defaultValue: 7 * 60,
      );

  set scheduleLightStartMinutes(int value) {
    _setAppSetting(_scheduleLightStartKey, _normalizeMinutes(value).toString());
  }

  int get scheduleDarkStartMinutes => _readMinuteSetting(
        _scheduleDarkStartKey,
        defaultValue: 21 * 60,
      );

  set scheduleDarkStartMinutes(int value) {
    _setAppSetting(_scheduleDarkStartKey, _normalizeMinutes(value).toString());
  }

  bool get usesDarkManualTheme => isDarkTheme(theme);

  bool get developerModeEnabled =>
      _moduleSettingsMap()[_developerModeKey] == 'true';

  set developerModeEnabled(bool value) {
    _setAppSetting(_developerModeKey, value.toString());
  }

  void setManualTheme(String themeKey) {
    final normalized = _normalizeThemeKey(themeKey);
    theme = normalized;
    if (isDarkTheme(normalized)) {
      darkThemeKey = normalized;
    } else {
      lightThemeKey = normalized;
    }
    themeMode = themeModeManual;
  }

  bool isModuleEnabled(String id) => enabledModuleIds.contains(id);

  void setModuleEnabled(String id, bool enabled) {
    final next = List<String>.from(enabledModuleIds);
    if (enabled) {
      if (!next.contains(id)) next.add(id);
    } else {
      next.remove(id);
    }
    enabledModuleIds = next;
  }

  Map<String, String> _moduleSettingsMap() {
    if (moduleSettingsJson.isEmpty || moduleSettingsJson == '{}') {
      return {};
    }
    try {
      final decoded = jsonDecode(moduleSettingsJson);
      if (decoded is! Map) return {};
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return {};
    }
  }

  void _setModuleSettingsMap(Map<String, String> next) {
    moduleSettingsJson = jsonEncode(next);
  }

  void _setAppSetting(String key, String value) {
    final next = Map<String, String>.from(_moduleSettingsMap());
    next[key] = value;
    _setModuleSettingsMap(next);
  }

  int _readMinuteSetting(String key, {required int defaultValue}) {
    final rawValue = _moduleSettingsMap()[key];
    final parsed = rawValue == null ? null : int.tryParse(rawValue);
    return _normalizeMinutes(parsed ?? defaultValue);
  }

  /// Optional per-module string settings (e.g. `meds.*` later). `here` + `buttonText` uses [hereButtonText].
  String getModuleSetting(String moduleId, String key, [String defaultValue = '']) {
    if (moduleId == BaselineModuleId.here && key == 'buttonText') {
      return hereButtonText.isNotEmpty ? hereButtonText : defaultValue;
    }
    return _moduleSettingsMap()['$moduleId.$key'] ?? defaultValue;
  }

  void setModuleSetting(String moduleId, String key, String value) {
    if (moduleId == BaselineModuleId.here && key == 'buttonText') {
      hereButtonText = value;
      return;
    }
    final m = Map<String, String>.from(_moduleSettingsMap());
    m['$moduleId.$key'] = value;
    _setModuleSettingsMap(m);
  }

  /// Ensures legacy boxes include the `here` module and sane defaults.
  /// Returns `true` if storage should be written.
  bool ensureBaselineModuleDefaults() {
    if (!enabledModuleIds.contains(BaselineModuleId.here)) {
      setModuleEnabled(BaselineModuleId.here, true);
      return true;
    }
    return false;
  }

  static bool isLightTheme(String key) =>
      _normalizeThemeKey(key).startsWith('light');

  static bool isDarkTheme(String key) =>
      _normalizeThemeKey(key).startsWith('dark');

  static String _normalizeThemeMode(String? value) {
    switch (value) {
      case themeModeDevice:
      case themeModeSchedule:
      case themeModeManual:
        return value!;
      default:
        return themeModeManual;
    }
  }

  static String _normalizeThemeKey(String? value) {
    switch (value) {
      case 'light1':
      case 'light2':
      case 'dark1':
      case 'dark2':
        return value!;
      default:
        return 'light1';
    }
  }

  static String _normalizeLightThemeKey(String? value) {
    final normalized = _normalizeThemeKey(value);
    return isDarkTheme(normalized) ? 'light1' : normalized;
  }

  static String _normalizeDarkThemeKey(String? value) {
    final normalized = _normalizeThemeKey(value);
    return isLightTheme(normalized) ? 'dark2' : normalized;
  }

  static int _normalizeMinutes(int value) {
    const minutesPerDay = 24 * 60;
    return ((value % minutesPerDay) + minutesPerDay) % minutesPerDay;
  }
}
