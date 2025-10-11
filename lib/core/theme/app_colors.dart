import 'package:flutter/material.dart';

/// Color palette for SelfMap with futuristic neon accents
class AppColors {
  AppColors._();

  // Neon accent colors
  static const Color neonTeal = Color(0xFF00FFF0);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonViolet = Color(0xFFBB86FC);
  static const Color neonPink = Color(0xFFFF1744);
  static const Color neonBlue = Color(0xFF2196F3);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF1A1F33);
  static const Color darkSurfaceVariant = Color(0xFF252B3F);
  static const Color darkOnBackground = Color(0xFFE6E8F0);
  static const Color darkOnSurface = Color(0xFFD0D3E0);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F2F5);
  static const Color lightOnBackground = Color(0xFF1A1F33);
  static const Color lightOnSurface = Color(0xFF252B3F);

  // Status colors
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFD600);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);

  // Progress colors
  static const Color progressLow = Color(0xFFFF5252);
  static const Color progressMedium = Color(0xFFFFD600);
  static const Color progressHigh = Color(0xFF00C853);

  // Glass effect colors
  static Color glassLight = Colors.white.withValues(alpha: 0.1);
  static Color glassDark = Colors.black.withValues(alpha: 0.2);
  static Color glassBlur = Colors.white.withValues(alpha: 0.05);

  // Overlay colors
  static Color scrimLight = Colors.black.withValues(alpha: 0.3);
  static Color scrimDark = Colors.black.withValues(alpha: 0.6);
}
