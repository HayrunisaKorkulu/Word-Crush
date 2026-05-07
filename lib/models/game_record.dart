import 'package:hive/hive.dart';

part 'game_record.g.dart';


@HiveType(typeId: 0)
class GameRecord extends HiveObject {

  @HiveField(0)
  final DateTime date;

  
  @HiveField(1)
  final int gridSize;

  
  @HiveField(2)
  final int score;

  
  @HiveField(3)
  final int wordsFound;

  
  @HiveField(4)
  final String longestWord;

  
  @HiveField(5)
  final int durationSeconds;

  
  @HiveField(6)
  final String difficulty;

 
  @HiveField(7)
  final int movesUsed;

  GameRecord({
    required this.date,
    required this.gridSize,
    required this.score,
    required this.wordsFound,
    required this.longestWord,
    required this.durationSeconds,
    required this.difficulty,
    required this.movesUsed,
  });

  
  String get gridSizeText => '${gridSize}x$gridSize';

  
  String get durationText {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) return '$seconds sn';
    return '$minutes dk $seconds sn';
  }
}




