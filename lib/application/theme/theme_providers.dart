import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/theme/teen_palette_extension.dart';
import '../gamification/gamification_providers.dart';

// ============================================================================
// Current Theme State
// ============================================================================

/// User's current selected theme key
/// Watches gamification profile for theme changes
final currentThemeKeyProvider = StreamProvider.autoDispose<String>((ref) {
  final profileAsync = ref.watch(gamificationProfileProvider);

  return profileAsync.when(
    data: (profile) => Stream.value(profile?.themeKey ?? 'neon_arcade'),
    loading: () => Stream.value('neon_arcade'),
    error: (_, __) => Stream.value('neon_arcade'),
  );
});

/// Current Teen Palette based on user's theme selection
final AutoDisposeFutureProvider<TeenPalette> currentTeenPaletteProvider =
    FutureProvider.autoDispose<TeenPalette>((ref) async {
  final themeKeyAsync = await ref.watch(currentThemeKeyProvider.future);
  return TeenThemes.getByKey(themeKeyAsync);
});

// ============================================================================
// Theme Actions
// ============================================================================

/// Controller for theme selection
class ThemeController extends StateNotifier<AsyncValue<void>> {
  ThemeController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Change user's theme
  Future<void> changeTheme(String themeKey) async {
    state = const AsyncValue.loading();

    try {
      final updateTheme = _ref.read(updateThemeProvider);
      await updateTheme(themeKey);

      // Log telemetry event
      final logEvent = _ref.read(logEventProvider);
      await logEvent('theme_changed', metadata: {'theme_key': themeKey});

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final themeControllerProvider =
    StateNotifierProvider.autoDispose<ThemeController, AsyncValue<void>>((ref) {
  return ThemeController(ref);
});

// ============================================================================
// Theme Data Builders
// ============================================================================

/// Build Material ThemeData from TeenPalette
ThemeData buildThemeFromPalette(TeenPalette palette) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.tertiary,
      surface: palette.background,
    ),
    scaffoldBackgroundColor: palette.background,
    cardTheme: CardThemeData(
      elevation: palette.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(palette.buttonRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: palette.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(palette.buttonRadius),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: palette.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(palette.buttonRadius),
      ),
    ),
    extensions: [palette],
  );
}

/// Build light ThemeData (fallback/default)
ThemeData buildDefaultTheme() {
  return buildThemeFromPalette(TeenThemes.neonArcadeLight);
}

// ============================================================================
// Theme Mode (Light/Dark)
// ============================================================================

/// Theme mode notifier (for system-wide light/dark toggle)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleThemeMode() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
