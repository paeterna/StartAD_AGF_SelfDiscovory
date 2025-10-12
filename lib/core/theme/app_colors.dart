import 'package:flutter/material.dart';

/// Modern futuristic color palette with AI-era aesthetics
class AppColors {
  AppColors._();

  // === Modern Gradient Colors (Futuristic & Friendly) ===

  // Primary gradient (Digital Sky)
  static const Color gradientDeepBlue = Color(0xFF1E3A8A);
  static const Color gradientBlue = Color(0xFF3B82F6);
  static const Color gradientCyan = Color(0xFF06B6D4);
  static const Color gradientTeal = Color(0xFF0D9488);

  // Secondary gradient (Neural Purple)
  static const Color gradientPurple = Color(0xFF7C3AED);
  static const Color gradientIndigo = Color(0xFF4F46E5);
  static const Color gradientViolet = Color(0xFF8B5CF6);
  static const Color gradientPink = Color(0xFFEC4899);

  // Accent gradient (Soft Neons)
  static const Color gradientEmerald = Color(0xFF059669);
  static const Color gradientLime = Color(0xFF65A30D);
  static const Color gradientRose = Color(0xFFF43F5E);
  static const Color gradientAmber = Color(0xFFF59E0B);

  // Accent colors (Modern & Expressive)
  static const Color accentElectric = Color(0xFF3B82F6);
  static const Color accentNeon = Color(0xFF06B6D4);
  static const Color accentMatrix = Color(0xFF10B981);
  static const Color accentCobalt = Color(0xFF1E40AF);
  static const Color accentSlate = Color(0xFF475569);

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

  // === Status & Feedback (Modern & Clear) ===
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // === Progress Colors (Motivational) ===
  static const Color progressLow = Color(0xFFEF4444);
  static const Color progressMedium = Color(0xFFF59E0B);
  static const Color progressHigh = Color(0xFF10B981);

  // === Glassmorphism Effects ===
  static Color glassLight = Colors.white.withValues(alpha: 0.15);
  static Color glassDark = Colors.white.withValues(alpha: 0.08);
  static Color glassBlur = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);

  // === Gradient Presets (Dynamic & Modern) ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientPurple, gradientBlue, gradientCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [gradientPink, gradientViolet, gradientPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [gradientTeal, gradientEmerald, gradientLime],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Futuristic gradients for special effects
  static const LinearGradient neonGradient = LinearGradient(
    colors: [gradientCyan, gradientPink, gradientAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient holographicGradient = LinearGradient(
    colors: [gradientIndigo, gradientCyan, gradientViolet, gradientPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // === Dynamic Background Gradients ===
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFAFBFF), // Very light blue
      Color(0xFFF0F4FF), // Light lavender
      Color(0xFFF8FAFC), // Slate-50
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF0F0F23), // Deep navy
      Color(0xFF1A1A2E), // Dark slate
      Color(0xFF16213E), // Midnight blue
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  // Hero section gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [gradientPurple, gradientBlue, gradientCyan, gradientTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [gradientIndigo, gradientPurple, gradientViolet, gradientPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // === Overlay & Scrim ===
  static Color scrimLight = Colors.black.withValues(alpha: 0.2);
  static Color scrimDark = Colors.black.withValues(alpha: 0.5);
  static Color shimmer = Colors.white.withValues(alpha: 0.3);
}
