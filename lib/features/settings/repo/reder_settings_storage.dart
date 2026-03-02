import 'package:shared_preferences/shared_preferences.dart';

class ReaderSettingsStorage {
  static Future<double> loadArabicSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("arabicFontSize") ?? 24;
  }

  static Future<double> loadTranslationSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("translationFontSize") ?? 13;
  }

  static Future<void> saveArabicSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("arabicFontSize", size);
  }

  static Future<void> saveTranslationSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("translationFontSize", size);
  }
}
