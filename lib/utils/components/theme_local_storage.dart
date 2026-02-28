import 'package:shared_preferences/shared_preferences.dart';
import 'package:noorversealquran/utils/components/theme.dart';

class ThemeLocalStorage {
  static const _keyTheme = 'app_theme';

  static Future<void> saveTheme(AppThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, theme.index);
  }

  static Future<AppThemeType> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyTheme);

    if (index != null && index < AppThemeType.values.length) {
      return AppThemeType.values[index];
    }

    return AppThemeType.maroonGold; // default theme
  }
}
