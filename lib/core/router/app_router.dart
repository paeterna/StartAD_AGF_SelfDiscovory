import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/features/auth/login_page.dart';
import '../../presentation/features/auth/signup_page.dart';
import '../../presentation/features/careers/careers_page.dart';
import '../../presentation/features/dashboard/dashboard_page.dart';
import '../../presentation/features/discover/discover_page.dart';
import '../../presentation/features/onboarding/onboarding_page.dart';
import '../../presentation/features/roadmap/roadmap_page.dart';
import '../../presentation/features/settings/settings_page.dart';
import '../../presentation/features/static_pages/about_page.dart';
import '../../presentation/features/static_pages/privacy_page.dart';
import '../../presentation/features/static_pages/terms_page.dart';
import '../../presentation/widgets/gradient_background.dart';
import '../providers/providers.dart';

/// App routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String discover = '/discover';
  static const String careers = '/careers';
  static const String roadmap = '/roadmap';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String about = '/about';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // Get current user
      final user = await authRepository.getCurrentUser();
      final isLoggedIn = user != null;
      final onboardingComplete = user?.onboardingComplete ?? false;

      final isGoingToAuth = state.matchedLocation.startsWith('/auth');
      final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isGoingToStatic = state.matchedLocation.startsWith('/privacy') ||
          state.matchedLocation.startsWith('/terms') ||
          state.matchedLocation.startsWith('/about');

      // Allow access to static pages without auth
      if (isGoingToStatic) {
        return null;
      }

      // Not logged in
      if (!isLoggedIn) {
        if (isGoingToAuth) return null; // Allow access to auth pages
        return AppRoutes.login; // Redirect to login
      }

      // Logged in but onboarding not complete
      if (!onboardingComplete) {
        if (isGoingToOnboarding) return null; // Allow access to onboarding
        return AppRoutes.onboarding; // Force onboarding
      }

      // Logged in and onboarding complete
      if (isGoingToAuth || isGoingToOnboarding) {
        return AppRoutes.dashboard; // Redirect to dashboard
      }

      // Default: allow navigation
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        redirect: (context, state) => AppRoutes.dashboard,
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.discover,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DiscoverPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.careers,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CareersPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.roadmap,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RoadmapPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PrivacyPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TermsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.about,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AboutPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) {
      // Check if this is an OAuth callback with auth tokens in the URL
      final uri = state.uri;
      final fragment = uri.fragment;

      // If URL contains auth tokens (from OAuth redirect), show a loading screen
      // Supabase will automatically process these tokens
      if (fragment.contains('access_token=') || fragment.contains('error=')) {
        debugPrint('🔵 [ROUTER] OAuth callback detected, processing auth tokens...');
        return GradientBackground(
          child: const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Completing sign in...'),
                ],
              ),
            ),
          ),
        );
      }

      // Regular 404 page
      return GradientBackground(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Page not found: ${state.matchedLocation}'),
              ],
            ),
          ),
        ),
      );
    },
  );
});
