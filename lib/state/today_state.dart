import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'today_state.g.dart';

@HiveType(typeId: 0)
class TodayState extends HiveObject {
  @HiveField(0)
  bool proteinDone = false;
  @HiveField(1)
  bool greensDone = false;
  @HiveField(2)
  bool legumesDone = false;
  @HiveField(3)
  bool fillersDone = false;
  @HiveField(4)
  bool treatDone = false;

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
}