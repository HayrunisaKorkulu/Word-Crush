import 'dart:math';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/game_settings.dart';
import '../models/letter_tile_model.dart';
import 'dictionary_service.dart';
import 'letter_generator.dart';
import 'score_calculator.dart';
import 'score_service.dart';
import '../models/game_record.dart';

class EffectCell {
  final int row;
  final int col;

  const EffectCell({required this.row, required this.col});
}

class PowerEffect {
  final SpecialPower power;
  final int originRow;
  final int originCol;
  final List<EffectCell> cells;

  const PowerEffect({
    required this.power,
    required this.originRow,
    required this.originCol,
    required this.cells,
  });
}


class JokerAnimationEvent {
  final int id;
  final JokerType type;
  final List<EffectCell> affectedCells;
  final EffectCell? firstCell;
  final EffectCell? secondCell;

  const JokerAnimationEvent({
    required this.id,
    required this.type,
    required this.affectedCells,
    this.firstCell,
    this.secondCell,
  });
}

class WordAttempt {
  final String word;
  final bool isValid;
  final int points;
  final int basePoints;
  final int comboPoints;
  final Set<String> subwords;
  final int comboCount;
  final SpecialPower powerEarned;
  final List<PowerEffect> powerEffects;
  final List<EffectCell> wordCells;

  const WordAttempt({
    required this.word,
    required this.isValid,
    required this.points,
    this.basePoints = 0,
    this.comboPoints = 0,
    required this.subwords,
    required this.comboCount,
    required this.powerEarned,
    this.powerEffects = const [],
    this.wordCells = const [],
  });

  bool get hasCombo => comboCount > 1 && subwords.isNotEmpty;
  bool get hasPowerEarned => powerEarned != SpecialPower.none;
  bool get hasTriggeredPower => powerEffects.isNotEmpty;
  bool get hasWordExplosion => isValid && wordCells.isNotEmpty;
}

class _PossibleWordPath {
  final String word;
  final List<LetterTile> path;

  const _PossibleWordPath({required this.word, required this.path});
}

class GameState extends ChangeNotifier {
  final GameSettings settings;
  final DictionaryService _dict;
  final LetterGenerator _gen = LetterGenerator();
  final Random _random = Random();

  late List<List<LetterTile>> grid;

  final List<LetterTile> _selectedTiles = [];

  int _score = 0;
  late int _movesLeft;
  int _wordsFound = 0;
  String _longestWord = '';
  bool _isGameOver = false;
  late DateTime _startTime;
  WordAttempt? _lastAttempt;

  int _possibleWordCount = 0;
  List<_PossibleWordPath> _possibleWordPaths = [];

  JokerType? _activeJoker;
  bool _jokerJustConsumed = false;
  LetterTile? _firstSwapTile;
  JokerAnimationEvent? _pendingJokerAction;
  int _jokerActionSeq = 0;

  List<LetterTile> get selectedTiles => List.unmodifiable(_selectedTiles);
  int get score => _score;
  int get movesLeft => _movesLeft;
  int get wordsFound => _wordsFound;
  String get longestWord => _longestWord;
  bool get isGameOver => _isGameOver;
  WordAttempt? get lastAttempt => _lastAttempt;
  DateTime get startTime => _startTime;
  Duration get elapsedTime => DateTime.now().difference(_startTime);
  String get currentWord => _selectedTiles.map((t) => t.letter).join();

  int get possibleWordCount => _possibleWordCount;

  List<String> get possibleWordsPreview {
    return _possibleWordPaths.map((e) => e.word).toList();
  }

  JokerType? get activeJoker => _activeJoker;
  bool get jokerJustConsumed => _jokerJustConsumed;
  LetterTile? get firstSwapTile => _firstSwapTile;
  JokerAnimationEvent? get pendingJokerAction => _pendingJokerAction;

  GameState({required this.settings, required DictionaryService dictionary})
    : _dict = dictionary {
    _movesLeft = settings.totalMoves;
    _startTime = DateTime.now();
    _initGrid();
  }

  void clearJokerConsumed() {
    _jokerJustConsumed = false;
  }

  void _initGrid() {
    grid = List.generate(
      settings.gridSize,
      (r) => List.generate(
        settings.gridSize,
        (c) => LetterTile(letter: _gen.generateLetter(), row: r, col: c),
      ),
    );

    _recalculatePossibleWords();

    
    if (_possibleWordCount == 0) {
      _forcePlacePlayableWord();
      _recalculatePossibleWords();
    }

    
    if (_possibleWordCount == 0) {
      _forcePlaceExactWord('SORU');
      _recalculatePossibleWords();
    }
  }

  void selectTile(LetterTile tile) {
    if (_isGameOver) return;
    if (tile.isEmpty) return;

    if (_selectedTiles.contains(tile)) {
      if (_selectedTiles.last == tile) return;

      final idx = _selectedTiles.indexOf(tile);
      for (int i = _selectedTiles.length - 1; i > idx; i--) {
        _selectedTiles[i].isSelected = false;
        _selectedTiles.removeAt(i);
      }

      notifyListeners();
      return;
    }

    if (_selectedTiles.isEmpty) {
      _selectedTiles.add(tile);
      tile.isSelected = true;
      notifyListeners();
      return;
    }

    final last = _selectedTiles.last;
    if (!tile.isNeighborOf(last)) return;

    _selectedTiles.add(tile);
    tile.isSelected = true;
    notifyListeners();
  }

  WordAttempt finalizeSelection() {
    if (_selectedTiles.isEmpty) {
      return _emptyAttempt();
    }

    final word = currentWord;

    if (word.length < AppConstants.minWordLength) {
      _clearSelection();
      notifyListeners();
      return _emptyAttempt();
    }

    
    _movesLeft--;

    final isValid = _dict.contains(word);

    if (isValid) {
      final scoreResult = ScoreCalculator.calculate(word, _dict);
      final powerEarned = _getPowerForLength(word.length);

      _score += scoreResult.totalPoints;
      _wordsFound++;

      if (word.length > _longestWord.length) {
        _longestWord = word;
      }

      final wordCells = _selectedTiles
          .map((t) => EffectCell(row: t.row, col: t.col))
          .toList();

      final powerEffects = _explodeSelectedTiles(powerEarned);
      _afterGridChanged();

      _lastAttempt = WordAttempt(
        word: word,
        isValid: true,
        points: scoreResult.totalPoints,
        basePoints: scoreResult.basePoints,
        comboPoints: scoreResult.comboPoints,
        subwords: scoreResult.subwords,
        comboCount: scoreResult.comboCount,
        powerEarned: powerEarned,
        powerEffects: powerEffects,
        wordCells: wordCells,
      );
    } else {
      _clearSelection();
      _recalculatePossibleWords();

      _lastAttempt = WordAttempt(
        word: word,
        isValid: false,
        points: 0,
        subwords: {},
        comboCount: 0,
        powerEarned: SpecialPower.none,
      );
    }

    if (_movesLeft <= 0) {
      _isGameOver = true;
      _saveGameRecord();
    }

    notifyListeners();
    return _lastAttempt!;
  }

  void _clearSelection() {
    for (final t in _selectedTiles) {
      t.isSelected = false;
    }
    _selectedTiles.clear();
  }

  List<PowerEffect> _explodeSelectedTiles(SpecialPower powerEarned) {
    if (_selectedTiles.isEmpty) return [];

    final lastTile = _selectedTiles.last;
    final lastRow = lastTile.row;
    final lastCol = lastTile.col;
    final lastLetter = lastTile.letter;

    final triggeredPowerItems = _selectedTiles
        .where((t) => t.power != SpecialPower.none)
        .map((t) => (row: t.row, col: t.col, power: t.power))
        .toList();

    for (final t in _selectedTiles) {
      grid[t.row][t.col].letter = ' ';
      grid[t.row][t.col].power = SpecialPower.none;
      grid[t.row][t.col].isSelected = false;
    }

    _selectedTiles.clear();

    final effects = <PowerEffect>[];

    for (final item in triggeredPowerItems) {
      final effect = _applySpecialPowerAt(item.row, item.col, item.power);
      if (effect.cells.isNotEmpty) {
        effects.add(effect);
      }
    }

    _applyGravity();
    _refillEmpty();

    if (powerEarned != SpecialPower.none) {
      if (lastRow >= 0 &&
          lastRow < settings.gridSize &&
          lastCol >= 0 &&
          lastCol < settings.gridSize) {
        grid[lastRow][lastCol].letter = lastLetter;
        grid[lastRow][lastCol].power = powerEarned;
        grid[lastRow][lastCol].isSelected = false;
      }
    }

    return effects;
  }

  PowerEffect _applySpecialPowerAt(int row, int col, SpecialPower power) {
    final cells = <EffectCell>[];

    switch (power) {
      case SpecialPower.rowClear:
        for (int c = 0; c < settings.gridSize; c++) {
          cells.add(EffectCell(row: row, col: c));
        }
        break;

      case SpecialPower.columnClear:
        for (int r = 0; r < settings.gridSize; r++) {
          cells.add(EffectCell(row: r, col: col));
        }
        break;

      case SpecialPower.bomb:
        for (int r = row - 1; r <= row + 1; r++) {
          for (int c = col - 1; c <= col + 1; c++) {
            if (r >= 0 &&
                r < settings.gridSize &&
                c >= 0 &&
                c < settings.gridSize) {
              cells.add(EffectCell(row: r, col: c));
            }
          }
        }
        break;

      case SpecialPower.mega:
        for (int r = row - 2; r <= row + 2; r++) {
          for (int c = col - 2; c <= col + 2; c++) {
            if (r >= 0 &&
                r < settings.gridSize &&
                c >= 0 &&
                c < settings.gridSize) {
              cells.add(EffectCell(row: r, col: c));
            }
          }
        }
        break;

      case SpecialPower.none:
        break;
    }

    for (final cell in cells) {
      grid[cell.row][cell.col].letter = ' ';
      grid[cell.row][cell.col].power = SpecialPower.none;
      grid[cell.row][cell.col].isSelected = false;
    }

    return PowerEffect(
      power: power,
      originRow: row,
      originCol: col,
      cells: cells,
    );
  }

  void _applyGravity() {
    for (int c = 0; c < settings.gridSize; c++) {
      int writeRow = settings.gridSize - 1;

      for (int r = settings.gridSize - 1; r >= 0; r--) {
        if (!grid[r][c].isEmpty) {
          if (r != writeRow) {
            grid[writeRow][c].letter = grid[r][c].letter;
            grid[writeRow][c].power = grid[r][c].power;

            grid[r][c].letter = ' ';
            grid[r][c].power = SpecialPower.none;
          }

          writeRow--;
        }
      }
    }
  }

  void _refillEmpty() {
    for (int r = 0; r < settings.gridSize; r++) {
      for (int c = 0; c < settings.gridSize; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c].letter = _gen.generateLetter();
          grid[r][c].power = SpecialPower.none;
          grid[r][c].isSelected = false;
        }
      }
    }
  }

  void _afterGridChanged() {
    _recalculatePossibleWords();

    if (_possibleWordCount == 0) {
      _forcePlacePlayableWord();
      _recalculatePossibleWords();
    }

    if (_possibleWordCount == 0) {
      _forcePlaceExactWord('SORU');
      _recalculatePossibleWords();
    }
  }

  void _recalculatePossibleWords() {
    final paths = _findPossibleWordPaths(maxResult: 10000);

    paths.sort((a, b) {
      final lenCompare = b.word.length.compareTo(a.word.length);
      if (lenCompare != 0) return lenCompare;
      return a.word.compareTo(b.word);
    });

    final usedCells = <String>{};
    final selectedPaths = <_PossibleWordPath>[];
    final selectedWords = <String>{};

    for (final item in paths) {
      if (selectedWords.contains(item.word)) continue;

      final ids = item.path.map((t) => '${t.row}_${t.col}').toSet();
      final overlaps = ids.any(usedCells.contains);

      if (!overlaps) {
        usedCells.addAll(ids);
        selectedWords.add(item.word);
        selectedPaths.add(item);
      }
    }

    _possibleWordPaths = selectedPaths;
    _possibleWordCount = selectedPaths.length;
  }

  List<_PossibleWordPath> _findPossibleWordPaths({required int maxResult}) {
    final result = <_PossibleWordPath>[];

    final size = settings.gridSize;
    final maxDepth = min(10, size * size);

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final start = grid[r][c];
        if (start.isEmpty) continue;

        _dfsFindWords(
          tile: start,
          currentWord: '',
          path: [],
          visited: <String>{},
          result: result,
          maxDepth: maxDepth,
          maxResult: maxResult,
        );

        if (result.length >= maxResult) {
          return result;
        }
      }
    }

    return result;
  }

  void _dfsFindWords({
    required LetterTile tile,
    required String currentWord,
    required List<LetterTile> path,
    required Set<String> visited,
    required List<_PossibleWordPath> result,
    required int maxDepth,
    required int maxResult,
  }) {
    if (result.length >= maxResult) return;

    final key = '${tile.row}_${tile.col}';
    if (visited.contains(key)) return;

    final nextWord = currentWord + tile.letter;

    if (!_dict.hasPrefix(nextWord)) return;

    final nextPath = [...path, tile];
    final nextVisited = {...visited, key};

    if (nextWord.length >= AppConstants.minWordLength &&
        _dict.contains(nextWord)) {
      result.add(_PossibleWordPath(word: nextWord, path: nextPath));

      if (result.length >= maxResult) return;
    }

    if (nextWord.length >= maxDepth) return;

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final nr = tile.row + dr;
        final nc = tile.col + dc;

        if (nr < 0 || nr >= settings.gridSize) continue;
        if (nc < 0 || nc >= settings.gridSize) continue;

        final nextTile = grid[nr][nc];
        if (nextTile.isEmpty) continue;

        _dfsFindWords(
          tile: nextTile,
          currentWord: nextWord,
          path: nextPath,
          visited: nextVisited,
          result: result,
          maxDepth: maxDepth,
          maxResult: maxResult,
        );

        if (result.length >= maxResult) return;
      }
    }
  }

  void _forcePlacePlayableWord() {
    final candidates = [
      'SORU',
      'MASA',
      'SARI',
      'KARA',
      'KAPI',
      'ANA',
      'ADA',
      'ARI',
    ];

    for (final word in candidates) {
      if (word.length <= settings.gridSize && _dict.contains(word)) {
        _forcePlaceExactWord(word);
        return;
      }
    }

    
    final word = _dict.getPlayableWordForGrid(settings.gridSize);
    _forcePlaceExactWord(word);
  }

  void _forcePlaceExactWord(String word) {
    if (word.isEmpty || word.length > settings.gridSize) return;

    final row = _random.nextInt(settings.gridSize);
    final maxStartCol = settings.gridSize - word.length;
    final startCol = maxStartCol <= 0 ? 0 : _random.nextInt(maxStartCol + 1);

    for (int i = 0; i < word.length; i++) {
      final col = startCol + i;

      grid[row][col].letter = word[i];
      grid[row][col].power = SpecialPower.none;
      grid[row][col].isSelected = false;
    }
  }

  SpecialPower _getPowerForLength(int length) {
    if (length >= AppConstants.powerMegaLength) {
      return SpecialPower.mega;
    } else if (length >= AppConstants.powerColumnClearLength) {
      return SpecialPower.columnClear;
    } else if (length >= AppConstants.powerBombLength) {
      return SpecialPower.bomb;
    } else if (length >= AppConstants.powerRowClearLength) {
      return SpecialPower.rowClear;
    }

    return SpecialPower.none;
  }

  void activateJoker(JokerType joker) {
    if (_isGameOver) return;

    _clearSelection();
    _jokerJustConsumed = false;
    _pendingJokerAction = null;

    switch (joker) {
      case JokerType.fish:
      case JokerType.shuffle:
      case JokerType.party:
        _queueImmediateJokerAction(joker);
        notifyListeners();
        break;

      case JokerType.lollipop:
      case JokerType.wheel:
      case JokerType.swap:
        _activeJoker = joker;
        _firstSwapTile = null;
        notifyListeners();
        break;
    }
  }

  void selectJokerTarget(LetterTile tile) {
    if (_activeJoker == null) return;
    if (tile.isEmpty && _activeJoker != JokerType.swap) return;

    switch (_activeJoker!) {
      case JokerType.lollipop:
        _queueTargetJokerAction(JokerType.lollipop, tile);
        _activeJoker = null;
        notifyListeners();
        break;

      case JokerType.wheel:
        _queueTargetJokerAction(JokerType.wheel, tile);
        _activeJoker = null;
        notifyListeners();
        break;

      case JokerType.swap:
        if (_firstSwapTile == null) {
          _firstSwapTile = tile;
          tile.isSelected = true;
          notifyListeners();
        } else {
          if (_firstSwapTile!.isNeighborOf(tile)) {
            _firstSwapTile!.isSelected = false;
            tile.isSelected = false;
            _queueSwapJokerAction(_firstSwapTile!, tile);
            _firstSwapTile = null;
            _activeJoker = null;
          } else {
            _firstSwapTile!.isSelected = false;
            _firstSwapTile = tile;
            tile.isSelected = true;
          }

          notifyListeners();
        }
        break;

      default:
        break;
    }
  }

  void cancelJoker() {
    _activeJoker = null;
    _pendingJokerAction = null;

    if (_firstSwapTile != null) {
      _firstSwapTile!.isSelected = false;
      _firstSwapTile = null;
    }

    notifyListeners();
  }

  void _queueImmediateJokerAction(JokerType joker) {
    _activeJoker = null;
    _firstSwapTile = null;

    final affected = <EffectCell>[];

    switch (joker) {
      case JokerType.fish:
        affected.addAll(_pickFishCells());
        break;
      case JokerType.shuffle:
      case JokerType.party:
        affected.addAll(_allGridCells());
        break;
      case JokerType.lollipop:
      case JokerType.wheel:
      case JokerType.swap:
        break;
    }

    _pendingJokerAction = JokerAnimationEvent(
      id: ++_jokerActionSeq,
      type: joker,
      affectedCells: affected,
    );
  }

  void _queueTargetJokerAction(JokerType joker, LetterTile tile) {
    final affected = <EffectCell>[];

    switch (joker) {
      case JokerType.lollipop:
        affected.add(EffectCell(row: tile.row, col: tile.col));
        break;
      case JokerType.wheel:
        affected.addAll(_wheelCells(tile.row, tile.col));
        break;
      case JokerType.fish:
      case JokerType.shuffle:
      case JokerType.party:
      case JokerType.swap:
        break;
    }

    _pendingJokerAction = JokerAnimationEvent(
      id: ++_jokerActionSeq,
      type: joker,
      firstCell: EffectCell(row: tile.row, col: tile.col),
      affectedCells: affected,
    );
  }

  void _queueSwapJokerAction(LetterTile a, LetterTile b) {
    _pendingJokerAction = JokerAnimationEvent(
      id: ++_jokerActionSeq,
      type: JokerType.swap,
      firstCell: EffectCell(row: a.row, col: a.col),
      secondCell: EffectCell(row: b.row, col: b.col),
      affectedCells: [
        EffectCell(row: a.row, col: a.col),
        EffectCell(row: b.row, col: b.col),
      ],
    );
  }

  List<EffectCell> _allGridCells() {
    final cells = <EffectCell>[];
    for (int r = 0; r < settings.gridSize; r++) {
      for (int c = 0; c < settings.gridSize; c++) {
        cells.add(EffectCell(row: r, col: c));
      }
    }
    return cells;
  }

  List<EffectCell> _wheelCells(int row, int col) {
    final cells = <EffectCell>[];
    for (int c = 0; c < settings.gridSize; c++) {
      cells.add(EffectCell(row: row, col: c));
    }
    for (int r = 0; r < settings.gridSize; r++) {
      if (r == row) continue;
      cells.add(EffectCell(row: r, col: col));
    }
    return cells;
  }

  List<EffectCell> _pickFishCells() {
    final cellList = <EffectCell>[];

    for (int r = 0; r < settings.gridSize; r++) {
      for (int c = 0; c < settings.gridSize; c++) {
        if (!grid[r][c].isEmpty) {
          cellList.add(EffectCell(row: r, col: c));
        }
      }
    }

    cellList.shuffle(_random);
    final count = (settings.gridSize * settings.gridSize * 0.10).ceil().clamp(4, 8);
    return cellList.take(count).toList();
  }

  void executePendingJokerAction(int actionId) {
    final action = _pendingJokerAction;
    if (action == null || action.id != actionId || _isGameOver) return;

    switch (action.type) {
      case JokerType.fish:
      case JokerType.lollipop:
      case JokerType.wheel:
        for (final cell in action.affectedCells) {
          grid[cell.row][cell.col].letter = ' ';
          grid[cell.row][cell.col].power = SpecialPower.none;
          grid[cell.row][cell.col].isSelected = false;
        }
        _applyGravity();
        _refillEmpty();
        _afterGridChanged();
        break;

      case JokerType.swap:
        final first = action.firstCell;
        final second = action.secondCell;
        if (first != null && second != null) {
          final a = tileAt(first.row, first.col);
          final b = tileAt(second.row, second.col);
          if (a != null && b != null) {
            _useSwapJoker(a, b);
          }
        }
        break;

      case JokerType.shuffle:
        _useShuffleJoker();
        break;

      case JokerType.party:
        _usePartyJoker();
        break;
    }

    _pendingJokerAction = null;
    _activeJoker = null;
    _firstSwapTile = null;
    _jokerJustConsumed = true;
    notifyListeners();
  }

  


  void _useSwapJoker(LetterTile a, LetterTile b) {
    final tempLetter = a.letter;
    final tempPower = a.power;

    a.letter = b.letter;
    a.power = b.power;

    b.letter = tempLetter;
    b.power = tempPower;

    a.isSelected = false;
    b.isSelected = false;

    _afterGridChanged();
  }

  void _useShuffleJoker() {
    final size = settings.gridSize;
    final letters = <String>[];
    final powers = <SpecialPower>[];

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (!grid[r][c].isEmpty) {
          letters.add(grid[r][c].letter);
          powers.add(grid[r][c].power);
        }
      }
    }

    letters.shuffle();
    powers.shuffle();

    int idx = 0;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (!grid[r][c].isEmpty) {
          grid[r][c].letter = letters[idx];
          grid[r][c].power = powers[idx];
          grid[r][c].isSelected = false;
          idx++;
        }
      }
    }

    _afterGridChanged();
  }

  void _usePartyJoker() {
    final size = settings.gridSize;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        grid[r][c].letter = _gen.generateLetter();
        grid[r][c].power = SpecialPower.none;
        grid[r][c].isSelected = false;
      }
    }

    _afterGridChanged();
  }

  void endGame() {
    if (_isGameOver) return;

    _isGameOver = true;
    _saveGameRecord();
    notifyListeners();
  }

  Future<void> _saveGameRecord() async {
    try {
      final scoreService = await ScoreService.getInstance();

      final record = GameRecord(
        date: DateTime.now(),
        gridSize: settings.gridSize,
        score: _score,
        wordsFound: _wordsFound,
        longestWord: _longestWord,
        durationSeconds: elapsedTime.inSeconds,
        difficulty: settings.difficultyName,
        movesUsed: settings.totalMoves - _movesLeft,
      );

      await scoreService.addRecord(record);
    } catch (_) {
      
    }
  }

  WordAttempt _emptyAttempt() {
    return const WordAttempt(
      word: '',
      isValid: false,
      points: 0,
      basePoints: 0,
      comboPoints: 0,
      subwords: {},
      comboCount: 0,
      powerEarned: SpecialPower.none,
      powerEffects: [],
      wordCells: [],
    );
  }

  LetterTile? tileAt(int row, int col) {
    if (row < 0 || row >= settings.gridSize) return null;
    if (col < 0 || col >= settings.gridSize) return null;

    return grid[row][col];
  }
}


