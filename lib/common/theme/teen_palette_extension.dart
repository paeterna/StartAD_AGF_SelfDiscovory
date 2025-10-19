import 'package:flutter/material.dart';

@immutable
class TeenPalette extends ThemeExtension<TeenPalette> {
  final String key; // e.g. 'neon_arcade'
  final Color seed; // base for ColorScheme.fromSeed
  final Color primary; // brand/accent
  final Color secondary; // complementary accent
  final Color tertiary; // playful tertiary accent
  final Color background; // fallback bg (scaffold)
  final LinearGradient bgGradient; // hero/dashboard backgrounds
  final double buttonRadius; // 12–20 for teen rounded vibe
  final double elevation; // default elevation for cards/buttons
  final double motionScale; // 0.8–1.2 to speed up/down animations
  final List<String> emojiPack; // used in microcopy
  final List<String> lottieSet; // asset keys

  const TeenPalette({
    required this.key,
    required this.seed,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.bgGradient,
    required this.buttonRadius,
    required this.elevation,
    required this.motionScale,
    required this.emojiPack,
    required this.lottieSet,
  });

  @override
  TeenPalette copyWith({
    String? key,
    Color? seed,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? background,
    LinearGradient? bgGradient,
    double? buttonRadius,
    double? elevation,
    double? motionScale,
    List<String>? emojiPack,
    List<String>? lottieSet,
  }) {
    return TeenPalette(
      key: key ?? this.key,
      seed: seed ?? this.seed,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      background: background ?? this.background,
      bgGradient: bgGradient ?? this.bgGradient,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      elevation: elevation ?? this.elevation,
      motionScale: motionScale ?? this.motionScale,
      emojiPack: emojiPack ?? this.emojiPack,
      lottieSet: lottieSet ?? this.lottieSet,
    );
  }

  @override
  ThemeExtension<TeenPalette> lerp(
    ThemeExtension<TeenPalette>? other,
    double t,
  ) {
    if (other is! TeenPalette) return this;
    return TeenPalette(
      key: t < .5 ? key : other.key,
      seed: Color.lerp(seed, other.seed, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      background: Color.lerp(background, other.background, t)!,
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            bgGradient.colors.first,
            other.bgGradient.colors.first,
            t,
          )!,
          Color.lerp(bgGradient.colors.last, other.bgGradient.colors.last, t)!,
        ],
      ),
      buttonRadius: _lerpDouble(buttonRadius, other.buttonRadius, t),
      elevation: _lerpDouble(elevation, other.elevation, t),
      motionScale: _lerpDouble(motionScale, other.motionScale, t),
      emojiPack: emojiPack, // keep stable
      lottieSet: lottieSet,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

class TeenThemes {
  // 1) Neon Arcade
  static final neonArcade = TeenPalette(
    key: 'neon_arcade',
    seed: const Color(0xFFFF006E), // neon magenta
    primary: const Color(0xFF3A86FF), // electric blue
    secondary: const Color(0xFFA7FF83), // lime mint
    tertiary: const Color(0xFFFF006E), // neon magenta
    background: const Color(0xFF0B1023),
    bgGradient: const LinearGradient(
      colors: [Color(0xFFFF006E), Color(0xFF3A86FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    buttonRadius: 16,
    elevation: 3,
    motionScale: 1.0,
    emojiPack: ['🎮', '⚡', '🕹️'],
    lottieSet: ['confetti_neon', 'pulse_neon', 'success_neon'],
  );

  // 2) Galaxy Pulse
  static final galaxyPulse = TeenPalette(
    key: 'galaxy_pulse',
    seed: const Color(0xFF6C63FF), // ultraviolet
    primary: const Color(0xFF1ED7C1), // aurora teal
    secondary: const Color(0xFFF3F6FF), // starlight
    tertiary: const Color(0xFF6C63FF), // UV
    background: const Color(0xFF12122B),
    bgGradient: const LinearGradient(
      colors: [Color(0xFF12122B), Color(0xFF6C63FF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    buttonRadius: 18,
    elevation: 2,
    motionScale: 1.05,
    emojiPack: ['🌌', '🚀', '🪐'],
    lottieSet: ['confetti_galaxy', 'pulse_galaxy', 'success_galaxy'],
  );

  // 3) Street Pop
  static final streetPop = TeenPalette(
    key: 'street_pop',
    seed: const Color(0xFFFF5A5F), // coral
    primary: const Color(0xFFFFD166), // canary
    secondary: const Color(0xFF1F1F1F), // graphite
    tertiary: const Color(0xFFFAFAFA), // cloud
    background: const Color(0xFF111111),
    bgGradient: const LinearGradient(
      colors: [Color(0xFFFF5A5F), Color(0xFFFFD166)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    buttonRadius: 14,
    elevation: 4,
    motionScale: 1.1,
    emojiPack: ['🛹', '🎧', '🔥'],
    lottieSet: ['confetti_street', 'pulse_street', 'success_street'],
  );

  // 4) Ocean Wave
  static final oceanWave = TeenPalette(
    key: 'ocean_wave',
    seed: const Color(0xFF00D1FF), // aqua
    primary: const Color(0xFFFF9E7A), // sunset peach
    secondary: const Color(0xFF002B5B), // deep navy
    tertiary: const Color(0xFFE6FAFF), // foam
    background: const Color(0xFF031A2E),
    bgGradient: const LinearGradient(
      colors: [Color(0xFF00D1FF), Color(0xFF002B5B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    buttonRadius: 16,
    elevation: 2,
    motionScale: 0.95,
    emojiPack: ['🌊', '🐬', '🏄'],
    lottieSet: ['confetti_ocean', 'pulse_ocean', 'success_ocean'],
  );

  // 5) Retro Pixel
  static final retroPixel = TeenPalette(
    key: 'retro_pixel',
    seed: const Color(0xFF9BBC0F), // gameboy green
    primary: const Color(0xFFFFA552), // orange popup
    secondary: const Color(0xFF0F380F), // charcoal
    tertiary: const Color(0xFFE8E4C9), // cream
    background: const Color(0xFF0B1F0B),
    bgGradient: const LinearGradient(
      colors: [Color(0xFF0F380F), Color(0xFF9BBC0F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    buttonRadius: 12,
    elevation: 3,
    motionScale: 1.0,
    emojiPack: ['🧩', '👾', '💾'],
    lottieSet: ['confetti_pixel', 'pulse_pixel', 'success_pixel'],
  );

  static TeenPalette getByKey(String key) {
    switch (key) {
      case 'galaxy_pulse':
        return galaxyPulse;
      case 'street_pop':
        return streetPop;
      case 'ocean_wave':
        return oceanWave;
      case 'retro_pixel':
        return retroPixel;
      case 'neon_arcade':
      default:
        return neonArcade;
    }
  }

  static List<TeenPalette> get allThemes => [
    neonArcade,
    galaxyPulse,
    streetPop,
    oceanWave,
    retroPixel,
  ];
}

/// Extension to access teen palette from Theme
extension TeenThemeExtension on ThemeData {
  TeenPalette get teenPalette =>
      extension<TeenPalette>() ?? TeenThemes.neonArcade;
}
