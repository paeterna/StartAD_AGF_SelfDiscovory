import 'package:flutter/material.dart';

/// Teen UX Theme Extension
/// Provides TikTok-energy themed palettes with motion parameters
@immutable
class TeenPalette extends ThemeExtension<TeenPalette> {
  const TeenPalette({
    required this.themeKey,
    required this.displayName,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.bgGradient,
    required this.cardGlow,
    required this.buttonRadius,
    required this.elevation,
    required this.motionScale,
    required this.motionDurationMs,
    required this.emojiPack,
    required this.lottieSet,
    required this.illustrationStyle,
  });

  final String themeKey;
  final String displayName;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final LinearGradient bgGradient;
  final double cardGlow;
  final double buttonRadius;
  final double elevation;
  final double motionScale; // Animation amplitude multiplier
  final int motionDurationMs; // Base animation duration
  final List<String> emojiPack;
  final Map<String, String> lottieSet; // Animation asset paths
  final String illustrationStyle;

  Duration get motionDuration => Duration(milliseconds: motionDurationMs);

  @override
  TeenPalette copyWith({
    String? themeKey,
    String? displayName,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? background,
    LinearGradient? bgGradient,
    double? cardGlow,
    double? buttonRadius,
    double? elevation,
    double? motionScale,
    int? motionDurationMs,
    List<String>? emojiPack,
    Map<String, String>? lottieSet,
    String? illustrationStyle,
  }) {
    return TeenPalette(
      themeKey: themeKey ?? this.themeKey,
      displayName: displayName ?? this.displayName,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      background: background ?? this.background,
      bgGradient: bgGradient ?? this.bgGradient,
      cardGlow: cardGlow ?? this.cardGlow,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      elevation: elevation ?? this.elevation,
      motionScale: motionScale ?? this.motionScale,
      motionDurationMs: motionDurationMs ?? this.motionDurationMs,
      emojiPack: emojiPack ?? this.emojiPack,
      lottieSet: lottieSet ?? this.lottieSet,
      illustrationStyle: illustrationStyle ?? this.illustrationStyle,
    );
  }

  @override
  TeenPalette lerp(ThemeExtension<TeenPalette>? other, double t) {
    if (other is! TeenPalette) return this;
    return TeenPalette(
      themeKey: themeKey,
      displayName: displayName,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      background: Color.lerp(background, other.background, t)!,
      bgGradient: LinearGradient.lerp(bgGradient, other.bgGradient, t)!,
      cardGlow: cardGlow,
      buttonRadius: buttonRadius,
      elevation: elevation,
      motionScale: motionScale,
      motionDurationMs: motionDurationMs,
      emojiPack: emojiPack,
      lottieSet: lottieSet,
      illustrationStyle: illustrationStyle,
    );
  }
}

/// Predefined Teen Themes
class TeenThemes {
  // 1. Neon Arcade
  static const neonArcadeLight = TeenPalette(
    themeKey: 'neon_arcade',
    displayName: 'Neon Arcade',
    primary: Color(0xFF3A86FF), // Electric blue
    secondary: Color(0xFFFF006E), // Neon magenta
    tertiary: Color(0xFFA7FF83), // Lime mint
    background: Color(0xFF0B1023), // Ink
    bgGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF006E), Color(0xFF3A86FF)],
    ),
    cardGlow: 8.0,
    buttonRadius: 16.0,
    elevation: 4.0,
    motionScale: 1.1,
    motionDurationMs: 220,
    emojiPack: ['🎮', '⚡', '🕹️'],
    lottieSet: {
      'success': 'assets/lottie/neon_success.json',
      'confetti': 'assets/lottie/neon_confetti.json',
      'pulse': 'assets/lottie/neon_pulse.json',
    },
    illustrationStyle: 'neon',
  );

  // 2. Galaxy Pulse
  static const galaxyPulseLight = TeenPalette(
    themeKey: 'galaxy_pulse',
    displayName: 'Galaxy Pulse',
    primary: Color(0xFF6C63FF), // Ultraviolet
    secondary: Color(0xFF1ED7C1), // Aurora teal
    tertiary: Color(0xFFF3F6FF), // Starlight
    background: Color(0xFF12122B), // Deep space
    bgGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF12122B), Color(0xFF1ED7C1)],
      stops: [0.0, 1.0],
    ),
    cardGlow: 6.0,
    buttonRadius: 20.0,
    elevation: 6.0,
    motionScale: 1.2,
    motionDurationMs: 280,
    emojiPack: ['🌌', '🚀', '🪐'],
    lottieSet: {
      'success': 'assets/lottie/galaxy_success.json',
      'confetti': 'assets/lottie/galaxy_confetti.json',
      'pulse': 'assets/lottie/galaxy_pulse.json',
    },
    illustrationStyle: 'cosmic',
  );

  // 3. Street Pop
  static const streetPopLight = TeenPalette(
    themeKey: 'street_pop',
    displayName: 'Street Pop',
    primary: Color(0xFFFF5A5F), // Coral
    secondary: Color(0xFFFFD166), // Canary
    tertiary: Color(0xFFFAFAFA), // Cloud
    background: Color(0xFF1F1F1F), // Graphite
    bgGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF5A5F), Color(0xFFFFD166)],
      transform: GradientRotation(0.5),
    ),
    cardGlow: 4.0,
    buttonRadius: 12.0,
    elevation: 3.0,
    motionScale: 1.15,
    motionDurationMs: 200,
    emojiPack: ['🛹', '🎧', '🔥'],
    lottieSet: {
      'success': 'assets/lottie/street_success.json',
      'confetti': 'assets/lottie/street_confetti.json',
      'pulse': 'assets/lottie/street_pulse.json',
    },
    illustrationStyle: 'street',
  );

  // 4. Ocean Wave
  static const oceanWaveLight = TeenPalette(
    themeKey: 'ocean_wave',
    displayName: 'Ocean Wave',
    primary: Color(0xFF00D1FF), // Aqua
    secondary: Color(0xFFFF9E7A), // Sunset peach
    tertiary: Color(0xFFE6FAFF), // Foam
    background: Color(0xFF002B5B), // Deep navy
    bgGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF00D1FF), Color(0xFF002B5B), Color(0xFFFF9E7A)],
      stops: [0.0, 0.5, 1.0],
    ),
    cardGlow: 5.0,
    buttonRadius: 18.0,
    elevation: 4.0,
    motionScale: 1.0,
    motionDurationMs: 260,
    emojiPack: ['🌊', '🐬', '🏄'],
    lottieSet: {
      'success': 'assets/lottie/ocean_success.json',
      'confetti': 'assets/lottie/ocean_confetti.json',
      'pulse': 'assets/lottie/ocean_pulse.json',
    },
    illustrationStyle: 'fluid',
  );

  // 5. Retro Pixel
  static const retroPixelLight = TeenPalette(
    themeKey: 'retro_pixel',
    displayName: 'Retro Pixel',
    primary: Color(0xFF9BBC0F), // Gameboy green
    secondary: Color(0xFFFFA552), // Orange popup
    tertiary: Color(0xFFE8E4C9), // Cream
    background: Color(0xFF0F380F), // Charcoal
    bgGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF9BBC0F), Color(0xFF0F380F)],
    ),
    cardGlow: 0.0, // Flat design
    buttonRadius: 4.0, // Sharp corners
    elevation: 0.0,
    motionScale: 1.0,
    motionDurationMs: 180,
    emojiPack: ['🧩', '👾', '💾'],
    lottieSet: {
      'success': 'assets/lottie/retro_success.json',
      'confetti': 'assets/lottie/retro_confetti.json',
      'pulse': 'assets/lottie/retro_pulse.json',
    },
    illustrationStyle: 'pixel',
  );

  /// Get all available themes
  static List<TeenPalette> get allThemes => [
        neonArcadeLight,
        galaxyPulseLight,
        streetPopLight,
        oceanWaveLight,
        retroPixelLight,
      ];

  /// Get theme by key
  static TeenPalette getByKey(String key) {
    return allThemes.firstWhere(
      (theme) => theme.themeKey == key,
      orElse: () => neonArcadeLight,
    );
  }
}

/// Extension to access teen palette from Theme
extension TeenThemeExtension on ThemeData {
  TeenPalette get teenPalette =>
      extension<TeenPalette>() ?? TeenThemes.neonArcadeLight;
}
