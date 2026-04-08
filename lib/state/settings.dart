import 'dart:convert';

import 'package:hive/hive.dart';

import '../modules/module_ids.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings extends HiveObject {
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
}