import 'package:flutter/material.dart';

/// Warm glassmorphic color palette with soft gradients
/// Design: Futuristic yet friendly, balancing technology with human warmth
class AppColors {
  AppColors._();

  // === Blue & Purple Gradient Colors ===

  // Primary blue-purple gradient
  static const Color deepPurple = Color(0xFF6B4EFF); // Rich purple
  static const Color vibrantPurple = Color(0xFF8B7AFF); // Vibrant purple
  static const Color softPurple = Color(0xFFB4A5FF); // Soft purple
  static const Color skyBlue = Color(0xFF6BA5FF); // Sky blue
  static const Color lightBlue = Color(0xFF94C4FF); // Light blue
  static const Color paleBlue = Color(0xFFC2DBFF); // Pale blue

  // Accent colors (Blue/Purple tones)
  static const Color accentViolet = Color(0xFF9D7BFF); // Violet accent
  static const Color accentLavender = Color(0xFFB8A5FF); // Lavender
  static const Color accentPeriwinkle = Color(0xFFADC5FF); // Periwinkle
  static const Color accentLightPurple = Color(0xFFD9CFFF); // Light purple

  // === Text Colors (Soft, Never Harsh) ===

  // Light mode text (warm charcoal, not black)
  static const Color textPrimary = Color(0xFF1A1A1A); // Soft charcoal
  static const Color textSecondary = Color(0xFF5A5A5A); // Medium gray
  static const Color textTertiary = Color(0xFF8A8A8A); // Light gray
  static const Color textOnGlass = Color(
    0xFF2D2D2D,
  ); // Slightly darker for glass

  // Dark mode text (warm white, not pure white)
  static const Color textDarkPrimary = Color(0xFFF5F5F5); // Warm white
  static const Color textDarkSecondary = Color(0xFFE0E0E0); // Light gray
  static const Color textDarkTertiary = Color(0xFFC0C0C0); // Medium gray

  // === Background Colors ===

  // Light theme backgrounds - Pure white
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCard = Color(
    0xFFFAFAFA,
  ); // Slightly off-white for cards

  // Dark theme backgrounds - Dark grey
  static const Color darkBackground = Color(0xFF1E1E1E); // Dark grey
  static const Color darkSurface = Color(0xFF2D2D2D); // Medium dark grey
  static const Color darkCard = Color(
    0xFF3A3A3A,
  ); // Lighter dark grey for cards

  // === Glassmorphism Effects (15-25% opacity) ===

  static Color glassLight = Colors.white.withValues(alpha: 0.15);
  static Color glassMedium = Colors.white.withValues(alpha: 0.20);
  static Color glassHeavy = Colors.white.withValues(alpha: 0.25);

  // Glass borders (semi-transparent white)
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.2);
  static Color glassBorderMedium = Colors.white.withValues(alpha: 0.3);

  // Inner glow for glass surfaces
  static Color glassGlow = Colors.white.withValues(alpha: 0.4);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.6);

  // Dark mode glass (slightly different)
  static Color glassDark = Colors.white.withValues(alpha: 0.1);
  static Color glassDarkBorder = Colors.white.withValues(alpha: 0.15);

  // === Status Colors (Soft, Not Harsh) ===

  static const Color success = Color(0xFF81C784); // Soft green
  static const Color warning = Color(0xFFFFB74D); // Soft amber
  static const Color error = Color(0xFFE57373); // Soft red
  static const Color info = Color(0xFF64B5F6); // Soft blue

  // === Progress Colors (Warm Tones) ===

  static const Color progressLow = Color(0xFFFFAB91); // Warm orange
  static const Color progressMedium = Color(0xFFFFD54F); // Warm yellow
  static const Color progressHigh = Color(0xFF81C784); // Soft green

  // === Gradient Definitions ===

  /// Primary card gradient: Deep Purple → Vibrant Purple → Blue
  /// Used for cards and interactive elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      deepPurple, // Deep purple
      vibrantPurple, // Vibrant purple
      skyBlue, // Sky blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  /// Subtle background gradient for light mode - Pure white
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // White
      Color(0xFFFFFFFF), // White
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode gradient - Dark grey
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF1E1E1E), // Dark grey
      Color(0xFF252525), // Slightly lighter dark grey
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient for highlights (purple/blue)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      accentViolet, // Violet
      accentPeriwinkle, // Periwinkle
      lightBlue, // Light blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Radial glow effect for depth
  static RadialGradient radialGlow({
    required Color centerColor,
    required Color edgeColor,
  }) {
    return RadialGradient(
      colors: [centerColor, edgeColor],
      center: Alignment.center,
      radius: 1.2,
      stops: const [0.0, 1.0],
    );
  }

  /// Soft shadow gradient for floating elements
  static BoxShadow softShadow({
    Color? color,
    double opacity = 0.1,
    double blurRadius = 20.0,
    Offset offset = const Offset(0, 8),
  }) {
    return BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: opacity),
      blurRadius: blurRadius,
      offset: offset,
    );
  }

  /// Glass shadow for glassmorphic cards
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.5),
      blurRadius: 10,
      offset: const Offset(-2, -2),
      blurStyle: BlurStyle.inner,
    ),
  ];

  // === Overlay Colors ===

  static Color scrimLight = Colors.black.withValues(alpha: 0.15);
  static Color scrimMedium = Colors.black.withValues(alpha: 0.3);
  static Color scrimDark = Colors.black.withValues(alpha: 0.5);

  // Shimmer effect for loading states
  static Color shimmerBase = Colors.white.withValues(alpha: 0.2);
  static Color shimmerHighlight = Colors.white.withValues(alpha: 0.4);
}
