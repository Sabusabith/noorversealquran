import 'package:flutter/material.dart';

enum AppThemeType {
  maroonGold,
  emeraldGreen,
  midnightDark,
  sandBeige,
  royalBlue,
  softDark,
}

class AppThemes {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.maroonGold:
        return ThemeData(
          primaryColor: const Color(0xFF6D001A),
          scaffoldBackgroundColor: const Color(0xFFF8F6F4),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6D001A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6D001A),
            secondary: Color(0xFFD4AF37),
          ),
        );

      case AppThemeType.emeraldGreen:
        return ThemeData(
          primaryColor: const Color(0xFF0B3D2E),
          scaffoldBackgroundColor: const Color(0xFFFAF9F6),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0B3D2E),
            foregroundColor: Colors.white,
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0B3D2E),
            secondary: Color.fromARGB(255, 6, 124, 69),
          ),
        );
      case AppThemeType.sandBeige:
        return ThemeData(
          primaryColor: const Color(0xFF8B6F47),
          scaffoldBackgroundColor: const Color(0xFFF5EBDD),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF8B6F47),
            foregroundColor: Colors.white,
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8B6F47),
            secondary: Color(0xFFC9A227),
          ),
        );
      case AppThemeType.midnightDark:
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF0A1A2F),
          scaffoldBackgroundColor: const Color(0xFF0E1624), // dark navy
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A1A2F),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0A1A2F),
            secondary: Color(0xFFD4AF37), // gold accent
            surface: Color(0xFF162032),
            onPrimary: Colors.white,
            onSurface: Colors.white70,
          ),
        );

      case AppThemeType.royalBlue:
        return ThemeData(
          primaryColor: const Color(0xFF1E3A8A),
          scaffoldBackgroundColor: const Color(0xFFF1F5FF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1E3A8A),
            secondary: Color(0xFF94A3B8),
          ),
        );

      case AppThemeType.softDark:
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1C1C1C),
          scaffoldBackgroundColor: const Color(0xFF121212), // real dark
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1C1C1C),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1C1C1C),
            secondary: Color(0xFFBFA46F), // soft gold
            surface: Color(0xFF1E1E1E),
            onPrimary: Colors.white,
            onSurface: Colors.white70,
          ),
        );
    }
  }
}
