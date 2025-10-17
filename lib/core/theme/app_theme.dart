import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Minimalist and aesthetic theme configuration for high schoolers and teenagers
/// Clean, modern, and functional with vibrant yet subtle colors
class AppTheme {
  AppTheme._();

  // Border radius constants (subtle, modern feel: 12-20px)
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;

  // Spacing constants
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;

  // Minimalist constants
  static const double glassBlur = 20.0;
  static const double glassOpacity = 0.05; // Very subtle
  static const double glassOpacityMedium = 0.08; // Subtle
  static const double glassOpacityHeavy = 0.12; // Light
  static const double glassBorderOpacity = 0.1;

  /// Light theme - Vibrant and energetic colors for high schoolers
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.teal, // Primary teal
      secondary: AppColors.orange, // Vibrant orange
      tertiary: AppColors.lime, // Fresh lime
      error: AppColors.error,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.lightCard,
      outline: AppColors.lavender.withValues(alpha: 0.3),
      primaryContainer: AppColors.tealLight,
      secondaryContainer: AppColors.orangeLight,
      tertiaryContainer: AppColors.limeLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,

      // Typography - Poppins for approachable, rounded feel
      textTheme: _buildTextTheme(AppColors.textPrimary),

      // Card theme - Minimalist and clean
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(
            color: AppColors.teal.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        color: Colors.white,
        shadowColor: Colors.transparent,
      ),

      // AppBar theme - Minimalist and clean
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
      ),

      // Button themes
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),

      // Input decoration theme
      inputDecorationTheme: _inputDecorationTheme(colorScheme, false),

      // Icon theme
      iconTheme: IconThemeData(color: AppColors.textSecondary, size: 24),

      // Focus theme
      focusColor: AppColors.teal.withValues(alpha: 0.2),

      // Divider with subtle transparency
      dividerTheme: DividerThemeData(
        color: AppColors.textSecondary.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Dark theme - Vibrant and energetic colors adapted for dark mode
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.tealLight, // Lighter teal for dark mode
      secondary: AppColors.orangeLight, // Softer orange for dark mode
      tertiary: AppColors.limeLight, // Softer lime for dark mode
      error: AppColors.error,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textDarkPrimary,
      surfaceContainerHighest: AppColors.darkCard,
      outline: AppColors.lavenderLight.withValues(alpha: 0.3),
      primaryContainer: AppColors.tealDark,
      secondaryContainer: AppColors.orangeDark,
      tertiaryContainer: AppColors.limeDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,

      // Typography - Poppins for approachable feel
      textTheme: _buildTextTheme(AppColors.textDarkPrimary),

      // Card theme - Minimalist dark
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(
            color: AppColors.tealLight.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        color: AppColors.darkCard,
        shadowColor: Colors.transparent,
      ),

      // AppBar theme - Minimalist dark
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textDarkPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkPrimary,
          letterSpacing: 0,
        ),
      ),

      // Button themes
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),

      // Input decoration theme
      inputDecorationTheme: _inputDecorationTheme(colorScheme, true),

      // Icon theme
      iconTheme: IconThemeData(color: AppColors.textDarkSecondary),

      // Focus theme
      focusColor: AppColors.tealLight.withValues(alpha: 0.3),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.textDarkSecondary.withValues(alpha: 0.1),
        thickness: 1,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.orangeLight,
        foregroundColor: AppColors.darkSurface,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      // Display styles - Bold & Friendly
      displayLarge: GoogleFonts.poppins(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.25,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.2,
      ),

      // Headline styles - Friendly & Punchy
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),

      // Title styles - Clear & Readable
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
        height: 1.4,
      ),

      // Body styles - Comfortable reading
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.2,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.2,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.2,
        height: 1.5,
      ),

      // Label styles - Clean & Compact
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.3,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.3,
        height: 1.3,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spaceLarge,
          vertical: spaceMedium + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spaceLarge,
          vertical: spaceMedium + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spaceMedium,
          vertical: spaceSmall,
        ),
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceMedium,
        vertical: spaceMedium,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
    );
  }
}
