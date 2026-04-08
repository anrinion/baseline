import 'package:hive/hive.dart';

part 'today_state.g.dart';

@HiveType(typeId: 0)
class TodayState extends HiveObject {
  /// Portions logged today (0 … max for each category). Legacy Hive fields 0–4
  /// are ignored on read; counts use 11–15.
  @HiveField(11)
  int proteinCount = 0;
  @HiveField(12)
  int greensCount = 0;
  @HiveField(13)
  int legumesCount = 0;
  @HiveField(14)
  int fillersCount = 0;
  @HiveField(15)
  int treatCount = 0;

  @HiveField(5)
  bool moved = false;

  @HiveField(6)
  bool medsTaken = false;

  @HiveField(7)
  bool sleepStarted = false;

  @HiveField(8)
  bool hereTapped = false;

  @HiveField(9)
  String cbtTemp = '';

  /// Local calendar day as yyyy-MM-dd; used only for daily reset boundaries.
  @HiveField(10)
  String lastDayKey = '';

  /// Local calendar day as yyyy-MM-dd for daily reset boundaries.
  static String dayKeyFor(DateTime dateTime) {
    final d = dateTime.toLocal();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}