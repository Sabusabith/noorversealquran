import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keySurah = 'last_surah';
  static const _keyAyah = 'last_ayah';

  static Future<void> saveLastRead(int surah, int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySurah, surah);
    await prefs.setInt(_keyAyah, ayah);
  }

  static Future<Map<String, int>> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'surah': prefs.getInt(_keySurah) ?? 1,
      'ayah': prefs.getInt(_keyAyah) ?? 1,
    };
  }
}
