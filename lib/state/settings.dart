import 'package:hive/hive.dart';

import '../modules/module_ids.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  String language = 'en'; // default English

  @HiveField(1)
  String theme = 'light1';

  @HiveField(2)
  String hereButtonText = 'I\'m here';

  /// Subset of [BaselineModuleId.all]; persisted. Missing on legacy data → all on.
  @HiveField(3)
  List<String> enabledModuleIds = List<String>.from(BaselineModuleId.all);

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
}