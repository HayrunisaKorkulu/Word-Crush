import '../constants/app_constants.dart';


class LetterTile {
  
  String letter;

  
  final int row;
  final int col;

  
  SpecialPower power;

  
  bool isSelected;

  
  bool isExploding;

  
  final String id;

  LetterTile({
    required this.letter,
    required this.row,
    required this.col,
    this.power = SpecialPower.none,
    this.isSelected = false,
    this.isExploding = false,
    String? id,
  }) : id = id ?? '${row}_${col}_${DateTime.now().microsecondsSinceEpoch}';

  
  int get points => AppConstants.letterPoints[letter] ?? 0;

  
  bool get isEmpty => letter == ' ' || letter.isEmpty;

  
  String get powerSymbol {
    switch (power) {
      case SpecialPower.rowClear:
        return '⇆';
      case SpecialPower.bomb:
        return '✹';
      case SpecialPower.columnClear:
        return '⇅';
      case SpecialPower.mega:
        return '✪';
      case SpecialPower.none:
        return '';
    }
  }

 
  bool isNeighborOf(LetterTile other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
   
    return (dr <= 1 && dc <= 1) && !(dr == 0 && dc == 0);
  }

  
  LetterTile copyWith({
    String? letter,
    SpecialPower? power,
    bool? isSelected,
    bool? isExploding,
  }) {
    return LetterTile(
      letter: letter ?? this.letter,
      row: row,
      col: col,
      power: power ?? this.power,
      isSelected: isSelected ?? this.isSelected,
      isExploding: isExploding ?? this.isExploding,
      id: id,
    );
  }

  @override
  String toString() => 'LetterTile($letter @ [$row,$col])';
}





