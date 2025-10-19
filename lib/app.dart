import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'application/auth/auth_controller.dart';
import 'application/theme/theme_providers.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'generated/l10n/app_localizations.dart';

/// Custom scroll behavior for web to fix double-click issue
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class SelfMapApp extends ConsumerStatefulWidget {
  const SelfMapApp({super.key});

  @override
  ConsumerState<SelfMapApp> createState() => _SelfMapAppState();
}

class _SelfMapAppState extends ConsumerState<SelfMapApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen to Supabase auth state changes (OAuth callbacks, etc.)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      debugPrint('🔵 [AUTH] State change: $event');

      if (event == AuthChangeEvent.signedIn && session != null) {
        debugPrint(
          '✅ [AUTH] User signed in via OAuth, refreshing auth state...',
        );
        // Trigger auth controller to refresh user state
        ref.read(authControllerProvider.notifier).refreshUser();
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('🔴 [AUTH] User signed out');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    // Watch teen palette for authenticated users
    final teenPaletteAsync = ref.watch(currentTeenPaletteProvider);

    // Build theme from teen palette or use fallback
    final teenTheme = teenPaletteAsync.when(
      data: (palette) => buildThemeFromPalette(palette),
      loading: () => buildDefaultTheme(),
      error: (_, _) => buildDefaultTheme(),
    );

    return MaterialApp.router(
      title: 'SelfMap',
      debugShowCheckedModeBanner: false,

      // Theme configuration - use teen theme system
      // Always use dark theme for teens (teen themes are designed for dark mode)
      theme: teenTheme,
      darkTheme: teenTheme,
      themeMode: ThemeMode.dark,

      // Router configuration
      routerConfig: router,

      // Locale configuration
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Fix double-click issue on web by enabling mouse drag for scrolling
      scrollBehavior: AppScrollBehavior(),
    );
  }
}
