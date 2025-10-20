import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/theme/teen_palette_extension.dart';
import '../gamification/gamification_providers.dart';

// ============================================================================
// Current Theme State
// ============================================================================

/// User's current selected theme key
/// Watches gamification profile for theme changes
final AutoDisposeStreamProvider<String> currentThemeKeyProvider =
    StreamProvider.autoDispose<String>((ref) {
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

final AutoDisposeStateNotifierProvider<ThemeController, AsyncValue<void>>
themeControllerProvider =
    StateNotifierProvider.autoDispose<ThemeController, AsyncValue<void>>((ref) {
      return ThemeController(ref);
    });

// ============================================================================
// Theme Data Builders
// ============================================================================

// ---------- Shared component theming ----------
CardThemeData _cardTheme(TeenPalette p, ColorScheme scheme) => CardThemeData(
  color: scheme.surface,
  surfaceTintColor: scheme.surfaceTint,
  elevation: p.elevation,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(p.buttonRadius),
  ),
);

ElevatedButtonThemeData _elevated(TeenPalette p, ColorScheme scheme) =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: p.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(p.buttonRadius),
        ),
      ),
    );

FilledButtonThemeData _filled(TeenPalette p, ColorScheme scheme) =>
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(p.buttonRadius),
        ),
      ),
    );

FloatingActionButtonThemeData _fab(TeenPalette p, ColorScheme scheme) =>
    FloatingActionButtonThemeData(
      backgroundColor: scheme.tertiary,
      foregroundColor: scheme.onTertiary,
      elevation: p.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(p.buttonRadius),
      ),
    );

ChipThemeData _chips(TeenPalette p, ColorScheme scheme) => ChipThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(p.buttonRadius * .75),
  ),
  color: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return scheme.secondaryContainer;
    }
    return scheme.surfaceContainerLowest;
  }),
  labelStyle: TextStyle(color: scheme.onSurfaceVariant),
);

InputDecorationTheme _inputs(TeenPalette p, ColorScheme scheme) =>
    InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(p.buttonRadius),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(p.buttonRadius),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      labelStyle: TextStyle(color: scheme.onSurface),
    );

AppBarTheme _appBar(TeenPalette p, ColorScheme scheme) => AppBarTheme(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  foregroundColor: scheme.onSurface,
  titleTextStyle: TextStyle(
    color: scheme.onSurface,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  ),
);

TabBarThemeData _tabs(ColorScheme scheme) => TabBarThemeData(
  labelColor: scheme.primary,
  unselectedLabelColor: scheme.onSurfaceVariant,
  indicator: UnderlineTabIndicator(
    borderSide: BorderSide(color: scheme.primary, width: 3),
  ),
);

SnackBarThemeData _snacks(ColorScheme scheme) => SnackBarThemeData(
  backgroundColor: scheme.inverseSurface,
  contentTextStyle: TextStyle(color: scheme.onInverseSurface),
  actionTextColor: scheme.inversePrimary,
);

ProgressIndicatorThemeData _progress(ColorScheme scheme) =>
    ProgressIndicatorThemeData(color: scheme.primary);

// Utility: choose black/white for readable text on a given color
Color _onColor(Color c) =>
    c.computeLuminance() > 0.5 ? Colors.black : Colors.white;

// ---------- DARK ----------
ThemeData buildDarkThemeFromPalette(TeenPalette palette) {
  // Start with a dark scheme, then override with our vivid brand tokens
  final base = ColorScheme.fromSeed(
    seedColor: palette.seed,
    brightness: Brightness.dark,
  );

  final scheme = base.copyWith(
    // Vivid brand accents
    primary: palette.primary,
    onPrimary: _onColor(palette.primary),
    primaryContainer: Color.alphaBlend(
      palette.primary.withValues(alpha: .14),
      const Color(0xFF0E1224),
    ),
    onPrimaryContainer: _onColor(palette.primary),

    secondary: palette.secondary,
    onSecondary: _onColor(palette.secondary),
    secondaryContainer: Color.alphaBlend(
      palette.secondary.withValues(alpha: .16),
      const Color(0xFF0E1224),
    ),
    onSecondaryContainer: _onColor(palette.secondary),

    tertiary: palette.tertiary,
    onTertiary: _onColor(palette.tertiary),
    tertiaryContainer: Color.alphaBlend(
      palette.tertiary.withValues(alpha: .14),
      const Color(0xFF0E1224),
    ),
    onTertiaryContainer: _onColor(palette.tertiary),
    surface: const Color(0xFF0E1224), // slightly lighter than bg
    onSurface: const Color(0xFFECECEC),
    surfaceContainerHighest: const Color(0xFF1A2033),
    onSurfaceVariant: const Color(0xFFB7C0CF),

    // System tokens
    error: const Color(0xFFFF4D4F),
    onError: Colors.white,
    outline: const Color(0xFF3F4662),
    outlineVariant: const Color(0xFF2A3048),
    inverseSurface: Colors.white,
    onInverseSurface: const Color(0xFF0E1224),
    inversePrimary: palette.tertiary,
    surfaceTint: palette.primary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: _appBar(palette, scheme),
    iconTheme: IconThemeData(color: scheme.tertiary),
    primaryIconTheme: IconThemeData(color: scheme.tertiary),
    cardTheme: _cardTheme(palette, scheme),
    elevatedButtonTheme: _elevated(palette, scheme),
    filledButtonTheme: _filled(palette, scheme),
    floatingActionButtonTheme: _fab(palette, scheme),
    chipTheme: _chips(palette, scheme),
    inputDecorationTheme: _inputs(palette, scheme),
    tabBarTheme: _tabs(scheme),
    snackBarTheme: _snacks(scheme),
    progressIndicatorTheme: _progress(scheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    extensions: [palette],
  );
}

// ---------- LIGHT ----------
ThemeData buildLightThemeFromPalette(TeenPalette palette) {
  final base = ColorScheme.fromSeed(
    seedColor: palette.seed,
    brightness: Brightness.light,
  );

  final scheme = base.copyWith(
    // Vivid brand accents
    primary: palette.primary,
    onPrimary: _onColor(palette.primary),
    primaryContainer: Color.alphaBlend(
      palette.primary.withValues(alpha: .10),
      Colors.white,
    ),
    onPrimaryContainer: _onColor(palette.primary),

    secondary: palette.secondary,
    onSecondary: _onColor(palette.secondary),
    secondaryContainer: Color.alphaBlend(
      palette.secondary.withValues(alpha: .12),
      Colors.white,
    ),
    onSecondaryContainer: _onColor(palette.secondary),

    tertiary: palette.tertiary,
    onTertiary: _onColor(palette.tertiary),
    tertiaryContainer: Color.alphaBlend(
      palette.tertiary.withValues(alpha: .10),
      Colors.white,
    ),
    onTertiaryContainer: _onColor(palette.tertiary),
    surface: Colors.white,
    onSurface: const Color(0xFF0F1224),
    surfaceContainerHighest: const Color(0xFFE8EBF5),
    onSurfaceVariant: const Color(0xFF4B556A),

    // System tokens
    error: const Color(0xFFB00020),
    onError: Colors.white,
    outline: const Color(0xFFCDD3E0),
    outlineVariant: const Color(0xFFE0E5F0),
    inverseSurface: const Color(0xFF0F1224),
    onInverseSurface: Colors.white,
    inversePrimary: palette.tertiary,
    surfaceTint: palette.primary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: _appBar(palette, scheme),
    iconTheme: IconThemeData(color: scheme.tertiary),
    primaryIconTheme: IconThemeData(color: scheme.tertiary),
    cardTheme: _cardTheme(palette, scheme),
    elevatedButtonTheme: _elevated(palette, scheme),
    filledButtonTheme: _filled(palette, scheme),
    floatingActionButtonTheme: _fab(palette, scheme),
    chipTheme: _chips(palette, scheme),
    inputDecorationTheme: _inputs(palette, scheme),
    tabBarTheme: _tabs(scheme),
    snackBarTheme: _snacks(scheme),
    progressIndicatorTheme: _progress(scheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    extensions: [palette],
  );
}

// ---------- Fallbacks ----------
ThemeData buildDefaultDarkTheme() =>
    buildDarkThemeFromPalette(TeenThemes.neonArcade);
ThemeData buildDefaultLightTheme() =>
    buildLightThemeFromPalette(TeenThemes.neonArcade);

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

final StateNotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
      return ThemeModeNotifier();
    });
