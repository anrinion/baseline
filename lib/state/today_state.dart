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

  /// Sleep times as minutes from midnight (0-1439). Defaults: 23:00 bed, 07:00 wake.
  @HiveField(21)
  int sleepBedTimeMinutes = 1380; // 23:00

  @HiveField(22)
  int sleepWakeTimeMinutes = 420;  // 07:00

  @HiveField(8)
  bool hereTapped = false;

  @HiveField(9)
  String cbtTemp = '';

  @HiveField(16)
  int? moodSelection; // 1-5 scale from sad to happy

  @HiveField(19)
  DateTime? moodSelectionTimestamp; // When mood was last selected

  @HiveField(17)
  List<String> goodThings = []; // Up to 3 good things

  @HiveField(18)
  int thoughtLensIndex = 0; // Current cognitive distortion index

  @HiveField(20)
  int yesterdayThoughtLensIndex = -1; // Previous day's distortion index for avoiding repetition

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