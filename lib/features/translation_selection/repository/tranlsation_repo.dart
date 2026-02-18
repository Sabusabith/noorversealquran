import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationRepository {
  Map<String, Map<int, List<String>>> _translations =
      {}; // lang -> surah -> ayahs
  String? selectedLanguage;
  bool translationEnabled = false;

  bool isTranslationEnabled() => translationEnabled;

  void clearTranslations() {
    _translations = {};
    selectedLanguage = null;
    translationEnabled = false;
    disableTranslation();
  }

  /// Load any language JSON that follows the { "sura": [ { "aya": [...] }, ... ] } format
  Future<void> loadLanguage(String lang, String assetPath) async {
    final file = await rootBundle.loadString(assetPath);
    final data = json.decode(file);

    Map<int, List<String>> langData = {};
    final suraList = data['sura'] as List<dynamic>;
    for (int i = 0; i < suraList.length; i++) {
      final ayaList = suraList[i]['aya'] as List<dynamic>;
      langData[i + 1] = ayaList.map((e) => e as String).toList();
    }

    _translations[lang] = langData;
    selectedLanguage = lang;
    translationEnabled = true; // <<-- add this line

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_translation', lang);
  }

  void disableTranslation() {
    translationEnabled = false;
    selectedLanguage = null;
  }

  Future<void> loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    selectedLanguage = prefs.getString('selected_translation');
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    translationEnabled = prefs.getBool('translation_enabled') ?? false;
    selectedLanguage = prefs.getString('selected_translation');
    if (!translationEnabled) {
      selectedLanguage = null;
    }
  }

  /// Get the translation for a specific surah and ayah
  String? getTranslation(int surah, int ayahIndex) {
    if (selectedLanguage == null) return null;
    return _translations[selectedLanguage!]?[surah]?[ayahIndex];
  }
}
