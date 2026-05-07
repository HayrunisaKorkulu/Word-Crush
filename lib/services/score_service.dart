import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_record.dart';


class ScoreService {
  static const String _boxName = 'game_records';
  static ScoreService? _instance;
  Box<GameRecord>? _box;

  ScoreService._internal();

  static Future<ScoreService> getInstance() async {
    if (_instance == null) {
      _instance = ScoreService._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GameRecordAdapter());
    }
    _box = await Hive.openBox<GameRecord>(_boxName);
  }

  
  Future<void> addRecord(GameRecord record) async {
    await _box!.add(record);
  }

  
  List<GameRecord> getAllRecords() {
    final records = _box!.values.toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  
  int getTotalGames() => _box!.length;


  int getHighScore() {
    if (_box!.isEmpty) return 0;
    return _box!.values.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  
  int getAverageScore() {
    if (_box!.isEmpty) return 0;
    final total = _box!.values.fold(0, (sum, r) => sum + r.score);
    return total ~/ _box!.length;
  }


  int getTotalWordsFound() {
    return _box!.values.fold(0, (sum, r) => sum + r.wordsFound);
  }

  
  String getLongestWord() {
    if (_box!.isEmpty) return '-';
    String longest = '';
    for (final r in _box!.values) {
      if (r.longestWord.length > longest.length) {
        longest = r.longestWord;
      }
    }
    return longest.isEmpty ? '-' : longest;
  }

  
  int getTotalDurationSeconds() {
    return _box!.values.fold(0, (sum, r) => sum + r.durationSeconds);
  }

 
  String getTotalDurationText() {
    final total = getTotalDurationSeconds();
    if (total == 0) return '0 dk';

    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;

    if (hours == 0) return '$minutes dk';
    return '$hours saat $minutes dk';
  }

  
  Future<void> clearAll() async {
    await _box!.clear();
  }
}



