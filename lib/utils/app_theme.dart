import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors (Emerald Green from designs - Image 1, 2)
  static const Color primaryGreen = Color(0xFF347928); // Vibrant emerald green
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color brandGreen = Color(0xFF347928);
  static const Color accentGreen = Color(0xFFE8F5E9);
  
  // Background & Surface
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFF9FAFB);
  static const Color cardLite = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textDark = Color(0xFF0F172A); // Navy-ish Dark
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  
  // Status Colors
  static const Color orangeAccent = Color(0xFFF59E0B);
  static const Color redBadge = Color(0xFFDC2626);
  static const Color mintGreen = Color(0xFFD1FAE5);
  
  // Input Decoration - Match images (Gray filled with icons - Image 2, 3)
  static InputDecorationTheme get inputDecoration => InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandGreen, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textLight, fontSize: 14),
        prefixIconColor: textLight,
        suffixIconColor: textLight,
      );

  // Button Style - Large and rounded (Image 2, 3)
  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      );

  // Global Style Settings
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandGreen, Color(0xFF2E6A21)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Success Screen Colors (Image 8)
  static const Color successBg = Color(0xFFF1FDF0);
  static const Color successIconBg = Color(0xFFE8F5E9);

  // Status Styling Helpers (Image 7)
  static Color getStatusColor(int index) {
    switch (index) {
      case 0: return const Color(0xFF3B82F6); // Blue - Received
      case 1: return const Color(0xFFF59E0B); // Orange - Preparing
      case 2: return const Color(0xFF10B981); // Emerald - Out for Delivery
      case 3: return brandGreen; // Green - Delivered
      default: return textLight;
    }
  }
}
