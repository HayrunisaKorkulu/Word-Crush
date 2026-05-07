

part of 'game_record.dart';


class GameRecordAdapter extends TypeAdapter<GameRecord> {
  @override
  final int typeId = 0;

  @override
  GameRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameRecord(
      date: fields[0] as DateTime,
      gridSize: fields[1] as int,
      score: fields[2] as int,
      wordsFound: fields[3] as int,
      longestWord: fields[4] as String,
      durationSeconds: fields[5] as int,
      difficulty: fields[6] as String,
      movesUsed: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.gridSize)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.wordsFound)
      ..writeByte(4)
      ..write(obj.longestWord)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.movesUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}



