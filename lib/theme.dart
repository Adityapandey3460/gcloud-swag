// lib/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const blue = Color(0xFF4285F4);
  static const green = Color(0xFF34A853);
  static const red = Color(0xFFEA4335);
  static const yellow = Color(0xFFFBBC04);

  static const bg = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const card = Color(0xFF1C2230);
  static const border = Color(0xFF30363D);

  static const text = Color(0xFFE6EDF3);
  static const textMuted = Color(0xFF8B949E);

  static const blueBg = Color(0x1F4285F4);
  static const greenBg = Color(0x1F34A853);
  static const redBg = Color(0x1FEA4335);
  static const yellowBg = Color(0x1FFBBC04);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.blue,
      secondary: AppColors.green,
      surface: AppColors.surface,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
          color: AppColors.text, fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.inter(
          color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(color: AppColors.text, fontSize: 16),
      bodyMedium: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
          color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600),
      iconTheme: const IconThemeData(color: AppColors.text),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: const TextStyle(color: AppColors.textMuted),
    ),
  );
}
