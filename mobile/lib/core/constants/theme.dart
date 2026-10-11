import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryAmber = Color(0xFFFF9F0A);
  static const Color primaryLime = Color(0xFFD4FF00);
  static const Color criticalRed = Color(0xFFFF453A);
  static const Color mutedGray = Color(0xFF6C757D);

  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF181B20);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(
          primary: primaryLime,
          secondary: primaryAmber,
          error: criticalRed,
          surface: darkSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(color: darkSurface),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8DB600),
          secondary: primaryAmber,
          error: criticalRed,
          surface: lightSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBg,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(color: lightSurface),
      );
}
