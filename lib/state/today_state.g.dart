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
      ..proteinCount = fields[11] as int
      ..greensCount = fields[12] as int
      ..legumesCount = fields[13] as int
      ..fillersCount = fields[14] as int
      ..treatCount = fields[15] as int
      ..moved = fields[5] as bool
      ..medsTaken = fields[6] as bool
      ..sleepStarted = fields[7] as bool
      ..hereTapped = fields[8] as bool
      ..cbtTemp = fields[9] as String
      ..moodSelection = fields[16] as int?
      ..moodSelectionTimestamp = fields[19] as DateTime?
      ..goodThings = (fields[17] as List).cast<String>()
      ..thoughtLensIndex = fields[18] as int
      ..yesterdayThoughtLensIndex = fields[20] as int
      ..lastDayKey = fields[10] as String;
  }

  @override
  void write(BinaryWriter writer, TodayState obj) {
    writer
      ..writeByte(16)
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
      ..writeByte(16)
      ..write(obj.moodSelection)
      ..writeByte(19)
      ..write(obj.moodSelectionTimestamp)
      ..writeByte(17)
      ..write(obj.goodThings)
      ..writeByte(18)
      ..write(obj.thoughtLensIndex)
      ..writeByte(20)
      ..write(obj.yesterdayThoughtLensIndex)
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
