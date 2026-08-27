import 'package:flutter/material.dart';

abstract final class AppColors {
  // ==========================================
  // Primary Palette
  // ==========================================
  static const int _primaryValue = 0xFF1E5AE8;

  static const MaterialColor primary =
      MaterialColor(_primaryValue, <int, Color>{
        50: Color(0xFFECF3FF),
        100: Color(0xFFDCE8FF),
        200: Color(0xFFC3D9FF),
        300: Color(0xFF8CB3FF),
        400: Color(0xFF5F8EF4),
        500: Color(_primaryValue),
        600: Color(0xFF1B4ACD),
        700: Color(0xFF133B99),
        800: Color(0xFF1F2D73),
        900: Color(0xFF0F1B45),
      });

  // ==========================================
  // Semantic Status Colors
  // ==========================================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color information = Color(0xFF0EA5E9);

  // ==========================================
  // Neutral Palette
  // ==========================================
  static const int _neutralValue = 0xFF737373;

  static const MaterialColor neutral =
      MaterialColor(_neutralValue, <int, Color>{
        50: Color(0xFFFAFAFA),
        100: Color(0xFFF5F5F5),
        200: Color(0xFFEAEAEA),
        300: Color(0xFFD6D6D6),
        400: Color(0xFFA3A3A3),
        500: Color(_neutralValue),
        600: Color(0xFF525252),
        700: Color(0xFF404040),
        800: Color(0xFF262626),
        900: Color(0xFF171717),
      });
}
