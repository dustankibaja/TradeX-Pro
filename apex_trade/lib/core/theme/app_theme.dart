import 'package:flutter/material.dart';

/// Minimal, high-contrast single-purpose trading-engine monitor palette.
class AppColors {
  static const bg0 = Color(0xFF090E1A);
  static const bg1 = Color(0xFF111A2B);
  static const bg2 = Color(0xFF162135);
  static const accent = Color(0xFF4779FF);
  static const accentSoft = Color(0xFF21385E);
  static const green = Color(0xFF3CDEAD);
  static const amber = Color(0xFFF5B963);
  static const red = Color(0xFFFF7780);
  static const text1 = Color(0xFFF4F7FC);
  static const text2 = Color(0xFFB3C0D4);
  static const text3 = Color(0xFF8795AE);
  static const border = Color(0xFF27354C);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg0,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.green,
      surface: AppColors.bg1,
      error: AppColors.red,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: AppColors.text1,
          fontSize: 24, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: AppColors.text1,
          fontSize: 18, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: AppColors.text2, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg2,
      hintStyle: const TextStyle(color: AppColors.text3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(13),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        borderRadius: BorderRadius.circular(13),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(51),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bg1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
