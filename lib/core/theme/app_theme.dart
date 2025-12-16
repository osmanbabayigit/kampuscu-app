import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Font paketi
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Ana Renkler
      primaryColor: AppColors.scuRed,
      scaffoldBackgroundColor: AppColors.scuBg,

      // Renk Şeması
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.scuRed,
        primary: AppColors.scuRed,
        surface: AppColors.surface,
      ),
      useMaterial3: true,

      // 🔥 YENİ FONT: INTER 🔥
      // Hem başlıklar hem de metinler için Inter kullanıyoruz.
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(),

      // AppBar Teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Input (Yazı Alanı) Teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.scuRed, width: 1.5)),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // Buton Teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.scuRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}