import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/auth/auth_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/user.dart';

class SelfMapApp extends ConsumerWidget {
  const SelfMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

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

      // Locale configuration (will be used when we add l10n)
      // locale: Locale(user?.locale ?? 'en'),
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
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
