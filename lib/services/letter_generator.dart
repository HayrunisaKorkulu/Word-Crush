import 'dart:math';
import '../constants/app_constants.dart';


class LetterGenerator {
  final Random _random;

  LetterGenerator({int? seed}) : _random = Random(seed);

  
  String generateLetter() {
    final roll = _random.nextInt(100);

    if (roll < AppConstants.highFreqWeight) {
      
      return _pickFrom(AppConstants.highFreqLetters);
    } else if (roll < AppConstants.highFreqWeight + AppConstants.midFreqWeight) {
      
      return _pickFrom(AppConstants.midFreqLetters);
    } else {
      
      return _pickFrom(AppConstants.lowFreqLetters);
    }
  }

  
  List<String> generateLetters(int count) {
    return List.generate(count, (_) => generateLetter());
  }

  
  List<List<String>> generateGrid(int size) {
    return List.generate(
      size,
      (_) => List.generate(size, (_) => generateLetter()),
    );
  }

  
  List<String> shuffle(List<String> letters) {
    final copy = List<String>.from(letters);
    copy.shuffle(_random);
    return copy;
  }

 

  String _pickFrom(List<String> source) {
    return source[_random.nextInt(source.length)];
  }
}



