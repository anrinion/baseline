import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  String language = 'en'; // default English

  @HiveField(1)
  String theme = 'light1';

  @HiveField(2)
  String hereButtonText = 'I\'m here';
}