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
      ..proteinDone = fields[0] as bool
      ..greensDone = fields[1] as bool
      ..legumesDone = fields[2] as bool
      ..fillersDone = fields[3] as bool
      ..treatDone = fields[4] as bool
      ..moved = fields[5] as bool
      ..medsTaken = fields[6] as bool
      ..sleepStarted = fields[7] as bool
      ..hereTapped = fields[8] as bool
      ..cbtTemp = fields[9] as String;
  }

  @override
  void write(BinaryWriter writer, TodayState obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.proteinDone)
      ..writeByte(1)
      ..write(obj.greensDone)
      ..writeByte(2)
      ..write(obj.legumesDone)
      ..writeByte(3)
      ..write(obj.fillersDone)
      ..writeByte(4)
      ..write(obj.treatDone)
      ..writeByte(5)
      ..write(obj.moved)
      ..writeByte(6)
      ..write(obj.medsTaken)
      ..writeByte(7)
      ..write(obj.sleepStarted)
      ..writeByte(8)
      ..write(obj.hereTapped)
      ..writeByte(9)
      ..write(obj.cbtTemp);
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
