import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _bookmarkKey = 'bookmarks';
  static const String _reciterKey = "reciter";

  static Future<void> saveReciter(String reciterCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciterCode);
  }

  static Future<String> getReciter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reciterKey) ?? "ar.alafasy";
  }

  static Future<void> saveBookmark(int surah, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_bookmarkKey) ?? [];

    final newBookmark = {'surah': surah, 'page': page};

    // Remove duplicate if exists
    existing.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['surah'] == surah && decoded['page'] == page;
    });

    // Add new bookmark
    existing.add(jsonEncode(newBookmark));

    // 🔥 Keep only last 3 bookmarks
    while (existing.length > 3) {
      existing.removeAt(0); // removes oldest
    }

    await prefs.setStringList(_bookmarkKey, existing);
  }

  static Future<void> removeBookmark(int surah, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_bookmarkKey) ?? [];

    existing.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['surah'] == surah && decoded['page'] == page;
    });

    await prefs.setStringList(_bookmarkKey, existing);
  }

  // 🔥 ADD THIS
  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_bookmarkKey) ?? [];

    return existing.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> getLastThreeBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_bookmarkKey) ?? [];

    final decoded = existing
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    return decoded.reversed.take(3).toList();
  }
}
