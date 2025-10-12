import 'package:flutter/material.dart';

/// Modern vibrant color palette for teens (15-18) with AI-era aesthetics
class AppColors {
  AppColors._();

  // === Vibrant Gradient Colors for AI-Era Feel ===

  // Primary gradient (Sunset/Aurora)
  static const Color gradientPink = Color(0xFFFF6B9D);
  static const Color gradientPurple = Color(0xFFC371F8);
  static const Color gradientBlue = Color(0xFF5B86E5);
  static const Color gradientCyan = Color(0xFF36D1DC);

  // Secondary gradient (Warm & Energetic)
  static const Color gradientOrange = Color(0xFFFF8A5B);
  static const Color gradientYellow = Color(0xFFFFC371);
  static const Color gradientGreen = Color(0xFF52E5A0);
  static const Color gradientTeal = Color(0xFF2DD4BF);

  // Accent colors (Punchy & Fun)
  static const Color accentCoral = Color(0xFFFF6B9D);
  static const Color accentLavender = Color(0xFFB4A5FF);
  static const Color accentMint = Color(0xFF6FFFB0);
  static const Color accentSky = Color(0xFF89D4FF);
  static const Color accentPeach = Color(0xFFFFB4A9);

  // === Light Theme (Bright & Airy) ===
  static const Color lightBackground = Color(0xFFFAFBFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF8F9FF);
  static const Color lightOnBackground = Color(0xFF1E1E2E);
  static const Color lightOnSurface = Color(0xFF2D2D3A);

  // === Dark Theme (Soft & Warm) ===
  static const Color darkBackground = Color(0xFF0F0F1E);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF25253A);
  static const Color darkOnBackground = Color(0xFFF0F0F7);
  static const Color darkOnSurface = Color(0xFFE0E0EB);

  // === Status & Feedback (Friendly & Soft) ===
  static const Color success = Color(0xFF52E5A0);
  static const Color warning = Color(0xFFFFCB6B);
  static const Color error = Color(0xFFFF6B9D);
  static const Color info = Color(0xFF89D4FF);

  // === Progress Colors (Motivational) ===
  static const Color progressLow = Color(0xFFFF8A5B);
  static const Color progressMedium = Color(0xFFFFC371);
  static const Color progressHigh = Color(0xFF52E5A0);

  // === Glassmorphism Effects ===
  static Color glassLight = Colors.white.withValues(alpha: 0.15);
  static Color glassDark = Colors.white.withValues(alpha: 0.08);
  static Color glassBlur = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);

  // === Gradient Presets ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientPink, gradientPurple, gradientBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [gradientOrange, gradientYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [gradientTeal, gradientGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAFBFF), Color(0xFFF0F5FF), Color(0xFFFFF0F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E), Color(0xFF1E1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // === Overlay & Scrim ===
  static Color scrimLight = Colors.black.withValues(alpha: 0.2);
  static Color scrimDark = Colors.black.withValues(alpha: 0.5);
  static Color shimmer = Colors.white.withValues(alpha: 0.3);
}
