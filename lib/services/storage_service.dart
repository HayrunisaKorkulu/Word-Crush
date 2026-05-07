import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';


class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._internal();

  
  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._internal();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  
  Future<bool> saveUsername(String username) async {
    return await _prefs!.setString(AppConstants.keyUsername, username.trim());
  }

 
  String? getUsername() {
    return _prefs!.getString(AppConstants.keyUsername);
  }

  
  bool hasUsername() {
    final username = getUsername();
    return username != null && username.isNotEmpty;
  }

  
  int getGold() {
    return _prefs!.getInt(AppConstants.keyGold) ?? AppConstants.initialGold;
  }

  
  Future<bool> setGold(int amount) async {
    return await _prefs!.setInt(AppConstants.keyGold, amount);
  }

  
  Future<bool> addGold(int amount) async {
    final current = getGold();
    return await setGold(current + amount);
  }

 
  Future<bool> spendGold(int amount) async {
    final current = getGold();
    if (current < amount) return false;
    return await setGold(current - amount);
  }

  
  Map<String, int> getOwnedJokers() {
    final List<String>? raw = _prefs!.getStringList(AppConstants.keyOwnedJokers);
    if (raw == null) return {};

    final Map<String, int> result = {};
    for (final entry in raw) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        result[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }
    return result;
  }

  
  Future<bool> setOwnedJokers(Map<String, int> jokers) async {
    final List<String> raw =
        jokers.entries.map((e) => '${e.key}:${e.value}').toList();
    return await _prefs!.setStringList(AppConstants.keyOwnedJokers, raw);
  }

  
  Future<bool> addJoker(String jokerName) async {
    final current = getOwnedJokers();
    current[jokerName] = (current[jokerName] ?? 0) + 1;
    return await setOwnedJokers(current);
  }

  
  Future<bool> useJoker(String jokerName) async {
    final current = getOwnedJokers();
    final count = current[jokerName] ?? 0;
    if (count <= 0) return false;
    current[jokerName] = count - 1;
    return await setOwnedJokers(current);
  }

  
  Future<bool> clearAll() async {
    return await _prefs!.clear();
  }
}




