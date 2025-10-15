import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Futuristic theme configuration with glassmorphism and modern aesthetics
class AppTheme {
  AppTheme._();

  // Border radius constants (warm, rounded feel: 20-32px)
  static const double radiusSmall = 20.0;
  static const double radiusMedium = 24.0;
  static const double radiusLarge = 28.0;
  static const double radiusXLarge = 32.0;

  // Spacing constants
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;

  // Glassmorphism constants (15-25% opacity)
  static const double glassBlur = 40.0;
  static const double glassOpacity = 0.35; // Light glass
  static const double glassOpacityMedium = 0.40; // Medium glass
  static const double glassOpacityHeavy = 0.55; // Heavy glass
  static const double glassBorderOpacity = 0.2;

  /// Light theme - Modern blue and purple with white background
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.deepPurple,
      secondary: AppColors.skyBlue,
      tertiary: AppColors.vibrantPurple,
      error: AppColors.error,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.lightCard,
      outline: AppColors.softPurple.withValues(alpha: 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,

      // Typography - Poppins for approachable, rounded feel
      textTheme: _buildTextTheme(AppColors.textPrimary),

      // Card theme - With blue/purple gradient
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(
            color: AppColors.softPurple.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        color: Colors.white,
        shadowColor: AppColors.deepPurple.withValues(alpha: 0.1),
      ),

      // AppBar theme - White background
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
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
      focusColor: AppColors.deepPurple.withValues(alpha: 0.2),

      // Divider with subtle transparency
      dividerTheme: DividerThemeData(
        color: AppColors.textSecondary.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark theme - Modern blue and purple with dark grey background
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.vibrantPurple,
      secondary: AppColors.lightBlue,
      tertiary: AppColors.accentViolet,
      error: AppColors.error,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textDarkPrimary,
      surfaceContainerHighest: AppColors.darkCard,
      outline: AppColors.softPurple.withValues(alpha: 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,

      // Typography - Poppins for approachable feel
      textTheme: _buildTextTheme(AppColors.textDarkPrimary),

      // Card theme - Dark with blue/purple gradient
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(
            color: AppColors.softPurple.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        color: AppColors.darkCard,
        shadowColor: AppColors.deepPurple.withValues(alpha: 0.3),
      ),

      // AppBar theme - Dark grey background
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textDarkPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textDarkPrimary,
          letterSpacing: 0.3,
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
      focusColor: AppColors.vibrantPurple.withValues(alpha: 0.3),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.textDarkSecondary.withValues(alpha: 0.1),
        thickness: 1,
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
          vertical: spaceMedium + 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spaceLarge,
          vertical: spaceMedium + 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        side: BorderSide(color: colorScheme.primary, width: 2),
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
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
