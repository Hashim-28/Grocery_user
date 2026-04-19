import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // ─── Theme State ────────────────────────────────────────────────────────
  static bool isDarkMode = true;

  // ─── Brand Colors (Premium Palette) ────────────────────────────────────────
  static Color get primary => isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF4F46E5); // Violet : Indigo
  static Color get accent => isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669);  // Emerald : Deep Emerald
  static Color get secondary => isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFF7C3AED); // Amber : Purple
  
  // ─── Background & Surface ─────────────────────────────────────────────────
  static Color get scaffold => isDarkMode ? const Color(0xFF020617) : Colors.white;
  static Color get surface => isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  static Color get surfaceVariant => isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  static Color get border => isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  static Color get glassBorder => isDarkMode ? const Color(0x33FFFFFF) : const Color(0x20000000);

  // ─── Text Colors ──────────────────────────────────────────────────────────
  static Color get textHeading => isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textBody => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted => isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get textPrimary => primary;

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);         // Rose Red
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color success = Color(0xFF10B981);        // Emerald
  static const Color info = Color(0xFF3B82F6);           // Blue

  // ─── Radius ───────────────────────────────────────────────────────────────
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusXXL = 40.0;

  // ─── Gradients (Premium Depth) ─────────────────────────────────────────────
  static LinearGradient get primaryGradient => LinearGradient(
    colors: isDarkMode 
      ? [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]
      : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get darkGradient => LinearGradient(
    colors: isDarkMode 
      ? [const Color(0xFF0F172A), const Color(0xFF020617)]
      : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get glassGradient => LinearGradient(
    colors: isDarkMode
      ? [const Color(0x1A6366F1), const Color(0x05FFFFFF)]
      : [const Color(0x1A4F46E5), const Color(0x05000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> get neonShadow => [
        BoxShadow(
          color: primary.withOpacity(isDarkMode ? 0.3 : 0.15),
          blurRadius: 20,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.04),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ];

  // ─── Decorations ──────────────────────────────────────────────────────────
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(radiusL),
        border: Border.all(color: glassBorder, width: 1),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusL),
        boxShadow: cardShadow,
        border: Border.all(color: border, width: 1),
      );


  // ─── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get themeData {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSurface: textHeading,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: textBody,
        displayColor: textHeading,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textHeading),
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textHeading,
          letterSpacing: -0.5,
        ),
        systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        hintStyle: TextStyle(color: textMuted, fontSize: 14),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 2),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: textHeading,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide(color: glassBorder, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent, 
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary.withOpacity(0.2),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13, 
          fontWeight: FontWeight.w700,
          color: textHeading,
        ),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusS),
        ),
      ),
    );
  }
}
