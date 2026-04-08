// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings()
      ..language = fields[0] as String
      ..theme = fields[1] as String
      ..hereButtonText = fields[2] as String
      ..enabledModuleIds = fields[3] != null
          ? (fields[3] as List).cast<String>()
          : List<String>.from(BaselineModuleId.all)
      ..moduleSettingsJson = fields[4] as String? ?? '{}';
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.hereButtonText)
      ..writeByte(3)
      ..write(obj.enabledModuleIds)
      ..writeByte(4)
      ..write(obj.moduleSettingsJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
