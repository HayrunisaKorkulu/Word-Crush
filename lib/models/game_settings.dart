import '../constants/app_constants.dart';


class GameSettings {
  final Difficulty difficulty;
  final int gridSize;
  final int totalMoves;

  const GameSettings({
    required this.difficulty,
    required this.gridSize,
    required this.totalMoves,
  });

  
  factory GameSettings.fromDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const GameSettings(
          difficulty: Difficulty.easy,
          gridSize: AppConstants.gridSizeEasy,
          totalMoves: AppConstants.movesEasy,
        );
      case Difficulty.medium:
        return const GameSettings(
          difficulty: Difficulty.medium,
          gridSize: AppConstants.gridSizeMedium,
          totalMoves: AppConstants.movesMedium,
        );
      case Difficulty.hard:
        return const GameSettings(
          difficulty: Difficulty.hard,
          gridSize: AppConstants.gridSizeHard,
          totalMoves: AppConstants.movesHard,
        );
    }
  }

  
  GameSettings copyWith({
    Difficulty? difficulty,
    int? gridSize,
    int? totalMoves,
  }) {
    return GameSettings(
      difficulty: difficulty ?? this.difficulty,
      gridSize: gridSize ?? this.gridSize,
      totalMoves: totalMoves ?? this.totalMoves,
    );
  }

  
  String get difficultyName {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Kolay';
      case Difficulty.medium:
        return 'Orta';
      case Difficulty.hard:
        return 'Zor';
    }
  }

  
  String get gridSizeText => '${gridSize}x$gridSize';
}


