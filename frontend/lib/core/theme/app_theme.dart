import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseSans = GoogleFonts.interTextTheme();
    final serifFamily = GoogleFonts.dmSerifDisplayTextTheme();
    final headingSans = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.ivory,
      textTheme: baseSans.copyWith(
        displayLarge: serifFamily.displayLarge?.copyWith(
          color: AppColors.navy,
          fontSize: 54,
          fontWeight: FontWeight.w400,
          letterSpacing: -1.0,
          height: 1.15,
        ),
        displayMedium: serifFamily.displayMedium?.copyWith(
          color: AppColors.navy,
          fontSize: 42,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.6,
          height: 1.2,
        ),
        headlineLarge: headingSans.headlineLarge?.copyWith(
          color: AppColors.navy,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.25,
        ),
        headlineMedium: headingSans.headlineMedium?.copyWith(
          color: AppColors.navy,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: headingSans.titleLarge?.copyWith(
          color: AppColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: headingSans.titleMedium?.copyWith(
          color: AppColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseSans.bodyLarge?.copyWith(
          color: AppColors.navy,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: baseSans.bodyMedium?.copyWith(
          color: AppColors.slate,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: baseSans.bodySmall?.copyWith(
          color: AppColors.slate,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: headingSans.labelLarge?.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(80, 46),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          minimumSize: const Size(80, 46),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.slate,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
