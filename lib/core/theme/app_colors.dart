import 'package:flutter/material.dart';

/// Warm glassmorphic color palette with soft gradients
/// Design: Futuristic yet friendly, balancing technology with human warmth
class AppColors {
  AppColors._();

  // === Warm Gradient Colors (Orange → Amber → Beige → Sky Blue) ===

  // Primary warm gradient
  static const Color warmOrange = Color(0xFFFF8C42); // Soft orange
  static const Color warmAmber = Color(0xFFFFB366); // Light amber
  static const Color warmPeach = Color(0xFFFFD4A3); // Warm peach
  static const Color warmBeige = Color(0xFFFFF3E0); // Soft beige
  static const Color warmSkyBlue = Color(0xFFB8D4F1); // Faint sky blue
  static const Color warmLightBlue = Color(0xFFD4E7F7); // Very light blue

  // Accent colors (Muted & Warm)
  static const Color accentCoral = Color(0xFFFF8A80); // Muted coral
  static const Color accentPeach = Color(0xFFFFAB91); // Soft peach highlight
  static const Color accentRose = Color(0xFFFFCDD2); // Light rose
  static const Color accentBlush = Color(0xFFFFF0E8); // Pale blush

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

  // Light theme backgrounds
  static const Color lightBackground = Color(0xFFFFF8F0); // Very light beige
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCard = Color(0xFFFFFAF5); // Soft cream

  // Dark theme backgrounds (warm-toned, not cold)
  static const Color darkBackground = Color(0xFF1F1F1F); // Warm dark gray
  static const Color darkSurface = Color(0xFF2A2A2A); // Slightly lighter
  static const Color darkCard = Color(0xFF353535); // Medium dark

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

  /// Primary background gradient: Orange → Amber → Beige → Sky Blue
  /// Diagonal from bottom-left to top-right
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      warmOrange, // Bottom-left: warm orange
      warmAmber, //
      warmPeach, //
      warmBeige, //
      warmSkyBlue, // Top-right: faint sky blue
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  /// Subtle background gradient for light mode
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFFE0B2), // Light orange
      Color(0xFFFFF8E1), // Pale amber
      Color(0xFFE1F5FE), // Very light blue
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    stops: [0.0, 0.5, 1.0],
  );

  /// Dark mode gradient (warmer tones)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF2D1F1A), // Warm dark brown
      Color(0xFF1F1F1F), // Neutral dark
      Color(0xFF1A2332), // Warm dark blue
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    stops: [0.0, 0.5, 1.0],
  );

  /// Accent gradient for highlights (coral/peach)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      accentCoral, // Muted coral
      accentPeach, // Soft peach
      warmAmber, // Light amber
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
