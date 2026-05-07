import 'package:flutter/services.dart';
import '../constants/app_constants.dart';


class DictionaryService {
  static DictionaryService? _instance;

  final Set<String> _words = {};
  final Set<String> _prefixes = {};

  bool _isLoaded = false;

  static const int _minGameWordLength = 3;
  static const int _maxGameWordLength = 10;

 
  static const Set<String> _blockedWords = {
    
    'ABD',
    'AB',
    'TC',
    'TBMM',
    'TDK',
    'TÜİK',
    'NASA',

    
    'ACE',
    'PRINT',
    'START',
    'STOP',
    'GAME',
    'WORD',
    'CRUSH',

    
    'NİTE',
    'ŞENELME',
    'MENENT',
    'TİTR',
  };

  DictionaryService._internal();

  static DictionaryService get instance {
    _instance ??= DictionaryService._internal();
    return _instance!;
  }

  bool get isLoaded => _isLoaded;
  int get wordCount => _words.length;

  Future<void> load() async {
    if (_isLoaded) return;

    try {
      final raw = await rootBundle.loadString(AppConstants.dictionaryPath);
      final lines = raw.split('\n');

      for (final line in lines) {
        final rawWord = line.trim();

        if (rawWord.isEmpty) continue;

        
        if (rawWord.contains(' ')) continue;

        
        if (rawWord.contains('-')) continue;
        if (rawWord.contains("'")) continue;
        if (rawWord.contains('.')) continue;
        if (rawWord.contains(',')) continue;
        if (_containsDigit(rawWord)) continue;

        final word = _normalize(rawWord);
        _addWord(word);
      }

      
      _addVerbRoots();

      
      _addCommonGameWords();

      if (_words.isEmpty) {
        _addFallbackWords();
      }

      _isLoaded = true;
    } catch (_) {
      _addFallbackWords();
      _isLoaded = true;
    }
  }

  void _addWord(String word) {
    final normalized = _normalize(word);

    if (normalized.length < _minGameWordLength) return;
    if (normalized.length > _maxGameWordLength) return;
    if (_blockedWords.contains(normalized)) return;
    if (!_isValidTurkishWord(normalized)) return;

    _words.add(normalized);

    for (int i = 1; i <= normalized.length; i++) {
      _prefixes.add(normalized.substring(0, i));
    }
  }

  void _addVerbRoots() {
    final snapshot = Set<String>.from(_words);

    for (final word in snapshot) {
      String? root;

      if (word.endsWith('MEK') || word.endsWith('MAK')) {
        root = word.substring(0, word.length - 3);
      }

      if (root != null) {
        _addWord(root);
      }
    }
  }

  void _addCommonGameWords() {
    final common = [
      'GİT',
      'GEL',
      'KOŞ',
      'OKU',
      'YAZ',
      'SOR',
      'BUL',
      'VER',
      'DÖN',
      'BAK',
      'SEV',
      'AL',
      'ARA',
      'AÇ',
      'İÇ',
      'YE',
      'KOY',
      'SİL',
      'ÇİZ',
      'KAZ',
      'KES',
      'DUR',
      'UÇ',
      'YAT',
      'KAL',
    ];

    for (final word in common) {
      _addWord(word);
    }
  }

  void _addFallbackWords() {
    final fallback = [
      'SORU',
      'KELİME',
      'ANA',
      'ADA',
      'ARI',
      'SARI',
      'MASA',
      'MASAL',
      'ADANA',
      'DANA',
      'SAL',
      'ASA',
      'KARA',
      'KART',
      'KAPI',
      'KALE',
      'KALEM',
      'TAŞ',
      'YOL',
      'ELMA',
      'ARMUT',
      'OKUL',
      'BALIK',
      'DENİZ',
      'KEDİ',
      'KÖPEK',
      'KUŞ',
      'ODA',
      'DERE',
      'DAĞ',
      'GÖL',
      'ÇAY',
      'KUM',
      'KİTAP',
      'ÇANTA',
      'KAŞE',
      'YAKAR',
      'GİT',
      'GEL',
      'KOŞ',
      'OKU',
      'YAZ',
      'SOR',
      'BUL',
      'VER',
      'DÖN',
      'BAK',
      'SEV',
    ];

    for (final word in fallback) {
      _addWord(word);
    }
  }

  bool contains(String word) {
    final normalized = _normalize(word);
    return _words.contains(normalized);
  }

  bool hasPrefix(String prefix) {
    final normalized = _normalize(prefix);
    return _prefixes.contains(normalized);
  }

  String getPlayableWordForGrid(int gridSize) {
    final preferred = [
      'SORU',
      'MASA',
      'SARI',
      'KARA',
      'KAPI',
      'KALE',
      'GİT',
      'GEL',
      'KOŞ',
      'OKU',
      'YAZ',
      'ANA',
      'ADA',
      'ARI',
    ];

    for (final word in preferred) {
      if (word.length <= gridSize && contains(word)) {
        return word;
      }
    }

    for (final word in _words) {
      if (word.length >= AppConstants.minWordLength && word.length <= gridSize) {
        return word;
      }
    }

    return 'SORU';
  }

  Set<String> findSubwords(String mainWord) {
    final word = _normalize(mainWord);
    final Set<String> found = {};

    if (_words.contains(word)) {
      found.add(word);
    }

    for (int start = 0; start < word.length; start++) {
      for (int end = start + AppConstants.minWordLength;
          end <= word.length;
          end++) {
        final sub = word.substring(start, end);

        if (sub != word && _words.contains(sub)) {
          found.add(sub);
        }
      }
    }

    return found;
  }

  String _normalize(String word) {
    return _toUpperTurkish(word.trim());
  }

  String _toUpperTurkish(String text) {
    return text
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

  bool _isValidTurkishWord(String word) {
    const turkishLetters = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';

    for (int i = 0; i < word.length; i++) {
      if (!turkishLetters.contains(word[i])) {
        return false;
      }
    }

    return true;
  }

  bool _containsDigit(String text) {
    return text.contains(RegExp(r'[0-9]'));
  }
}




