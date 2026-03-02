import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderSettings extends ChangeNotifier {
  double _arabicFontSize = 24;
  double _translationFontSize = 13;

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble("arabicFontSize") ?? 24;
    _translationFontSize = prefs.getDouble("translationFontSize") ?? 13;
    notifyListeners();
  }

  Future<void> setArabicSize(double size) async {
    _arabicFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("arabicFontSize", size);
    notifyListeners();
  }

  Future<void> setTranslationSize(double size) async {
    _translationFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("translationFontSize", size);
    notifyListeners();
  }
}
