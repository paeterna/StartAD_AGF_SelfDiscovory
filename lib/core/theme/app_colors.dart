import 'package:flutter/material.dart';

/// Warm glassmorphic color palette with soft gradients
/// Design: Futuristic yet friendly, balancing technology with human warmth
class AppColors {
  AppColors._();

  // === Vibrant Color Palette for High Schoolers ===

  // Primary colors - Vibrant and energetic
  static const Color teal = Color(0xFF38AFB7); // Primary teal
  static const Color tealDark = Color(0xFF2D8A91); // Darker teal for dark mode
  static const Color tealLight = Color(0xFF5DC5CC); // Lighter teal for highlights
  
  static const Color orange = Color(0xFFEDA43B); // Vibrant orange
  static const Color orangeDark = Color(0xFFD88F2A); // Deeper orange
  static const Color orangeLight = Color(0xFFF5BD6B); // Soft orange
  
  static const Color lime = Color(0xFFA4C252); // Fresh lime green
  static const Color limeDark = Color(0xFF8CAA3F); // Darker lime
  static const Color limeLight = Color(0xFFBDD47A); // Lighter lime
  
  static const Color lavender = Color(0xFFA587BB); // Cool lavender
  static const Color lavenderDark = Color(0xFF8B6FA3); // Deeper lavender
  static const Color lavenderLight = Color(0xFFC1A7D4); // Soft lavender

  // Legacy colors for gradual migration
  static const Color deepPurple = lavenderDark; // Map to lavender
  static const Color vibrantPurple = lavender; // Map to lavender
  static const Color softPurple = lavenderLight; // Map to light lavender
  static const Color skyBlue = teal; // Map to teal
  static const Color lightBlue = tealLight; // Map to light teal
  static const Color paleBlue = Color(0xFFC2DBFF); // Keep as complement

  // Accent colors - Energetic combinations
  static const Color accentViolet = lavender; // Lavender accent
  static const Color accentLavender = lavenderLight; // Light lavender
  static const Color accentPeriwinkle = tealLight; // Teal accent
  static const Color accentLightPurple = lavenderLight; // Light purple

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

  // === Background Colors (Minimalist) ===

  // Light theme backgrounds - Pure white for minimalism
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCard = Color(0xFFFBFBFB); // Subtle off-white for depth

  // Dark theme backgrounds - True black/dark grey for contrast
  static const Color darkBackground = Color(0xFF0A0A0A); // Near black
  static const Color darkSurface = Color(0xFF121212); // Dark grey
  static const Color darkCard = Color(0xFF1E1E1E); // Card background

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

  // === Status Colors (Vibrant & Friendly) ===

  static const Color success = lime; // Fresh lime green
  static const Color warning = orange; // Vibrant orange
  static const Color error = Color(0xFFE57373); // Soft red
  static const Color info = teal; // Primary teal

  // === Progress Colors (Energetic Tones) ===

  static const Color progressLow = orange; // Vibrant orange
  static const Color progressMedium = Color(0xFFFFD54F); // Bright yellow
  static const Color progressHigh = lime; // Fresh lime green

  // === Gradient Definitions ===

  /// Primary card gradient: Teal → Lavender → Lime (Vibrant & Energetic)
  /// Used for cards and interactive elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      teal, // Vibrant teal
      lavender, // Cool lavender
      lime, // Fresh lime
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  /// Secondary gradient: Orange → Teal (Warm to Cool)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [
      orange, // Vibrant orange
      teal, // Cool teal
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient: Lavender → Lime (Purple to Green)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      lavender, // Lavender
      lime, // Lime green
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle background gradient for light mode - Pure white with hint of color
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // White
      Color(0xFFFAFDFD), // Very subtle teal tint
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode gradient - Dark grey with subtle color
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF1E1E1E), // Dark grey
      Color(0xFF1F2324), // Subtle teal-grey
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
