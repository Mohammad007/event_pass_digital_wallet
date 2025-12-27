import 'package:flutter/material.dart';

/// App-wide color constants for Event Pass app
class AppColors {
  // Primary Colors - Premium Purple/Blue gradient theme
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5548C8);
  static const Color primaryLight = Color(0xFF8B84FF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryDark = Color(0xFFE5004D);
  static const Color secondaryLight = Color(0xFFFF8FA3);
  
  // Accent Colors
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentDark = Color(0xFF00B894);
  static const Color accentLight = Color(0xFF00F5C4);
  
  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF00D68F);
  static const Color error = Color(0xFFFF3838);
  static const Color warning = Color(0xFFFFA502);
  static const Color info = Color(0xFF0984E3);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5548C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00F5C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F0F1E);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
}
