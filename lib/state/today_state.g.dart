// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodayStateAdapter extends TypeAdapter<TodayState> {
  @override
  final int typeId = 0;

  @override
  TodayState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodayState()
      ..proteinCount = (fields[11] as int?) ?? 0
      ..greensCount = (fields[12] as int?) ?? 0
      ..legumesCount = (fields[13] as int?) ?? 0
      ..fillersCount = (fields[14] as int?) ?? 0
      ..treatCount = (fields[15] as int?) ?? 0
      ..moved = (fields[5] as bool?) ?? false
      ..medsTaken = (fields[6] as bool?) ?? false
      ..sleepStarted = (fields[7] as bool?) ?? false
      ..hereTapped = (fields[8] as bool?) ?? false
      ..cbtTemp = (fields[9] as String?) ?? ''
      ..lastDayKey = (fields[10] as String?) ?? '';
  }

  @override
  void write(BinaryWriter writer, TodayState obj) {
    writer
      ..writeByte(11)
      ..writeByte(11)
      ..write(obj.proteinCount)
      ..writeByte(12)
      ..write(obj.greensCount)
      ..writeByte(13)
      ..write(obj.legumesCount)
      ..writeByte(14)
      ..write(obj.fillersCount)
      ..writeByte(15)
      ..write(obj.treatCount)
      ..writeByte(5)
      ..write(obj.moved)
      ..writeByte(6)
      ..write(obj.medsTaken)
      ..writeByte(7)
      ..write(obj.sleepStarted)
      ..writeByte(8)
      ..write(obj.hereTapped)
      ..writeByte(9)
      ..write(obj.cbtTemp)
      ..writeByte(10)
      ..write(obj.lastDayKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
