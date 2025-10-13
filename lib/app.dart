import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'application/auth/auth_controller.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/user.dart';
import 'generated/l10n/app_localizations.dart';

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
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final locale = ref.watch(localeProvider);

    // Determine theme mode based on user preference
    final themeMode = _getThemeMode(user?.theme);

    return MaterialApp.router(
      title: 'SelfMap',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router configuration
      routerConfig: router,

      // Locale configuration
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  ThemeMode _getThemeMode(ThemeModePreference? preference) {
    switch (preference) {
      case ThemeModePreference.light:
        return ThemeMode.light;
      case ThemeModePreference.dark:
        return ThemeMode.dark;
      case ThemeModePreference.system:
      case null:
        return ThemeMode.system;
    }
  }
}
