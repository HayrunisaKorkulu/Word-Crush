import '../constants/app_constants.dart';
import 'dictionary_service.dart';


class ScoreResult {
  final String mainWord;
  final int basePoints;
  final Set<String> subwords;
  final int comboPoints;
  final int totalPoints;
  final int comboCount;

  const ScoreResult({
    required this.mainWord,
    required this.basePoints,
    required this.subwords,
    required this.comboPoints,
    required this.totalPoints,
    required this.comboCount,
  });
}


class ScoreCalculator {
  static int calculateWordPoints(String word) {
    final normalized = _toUpperTurkish(word);

    int total = 0;

    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      total += AppConstants.letterPoints[char] ?? 0;
    }

    return total;
  }

  static ScoreResult calculate(String mainWord, DictionaryService dict) {
    final word = _toUpperTurkish(mainWord);
    final basePoints = calculateWordPoints(word);

    final allSubwords = dict.findSubwords(word);
    final extraSubwords = allSubwords.where((w) => w != word).toSet();

    int comboPoints = 0;
    for (final sub in extraSubwords) {
      comboPoints += calculateWordPoints(sub);
    }

    return ScoreResult(
      mainWord: word,
      basePoints: basePoints,
      subwords: extraSubwords,
      comboPoints: comboPoints,
      totalPoints: basePoints + comboPoints,
      comboCount: allSubwords.length,
    );
  }

  static String _toUpperTurkish(String text) {
    return text
        .trim()
        .replaceAll('i', 'İ')
        .replaceAll('ı', 'I')
        .replaceAll('â', 'A')
        .replaceAll('î', 'İ')
        .replaceAll('û', 'U')
        .replaceAll('Â', 'A')
        .replaceAll('Î', 'İ')
        .replaceAll('Û', 'U')
        .toUpperCase();
  }
}

