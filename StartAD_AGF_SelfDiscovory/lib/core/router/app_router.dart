import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/school/school_providers.dart';
import '../../presentation/features/auth/login_page.dart';
import '../../presentation/features/auth/signup_page.dart';
import '../../presentation/features/auth/oauth_callback_page.dart';
import '../../presentation/features/auth/school_login_page.dart';
import '../../presentation/features/assessment/assessment_page.dart';
import '../../presentation/features/careers/careers_page.dart';
import '../../presentation/features/dashboard/dashboard_page.dart';
import '../../presentation/features/discover/discover_page.dart';
import '../../presentation/features/onboarding/onboarding_page.dart';
import '../../presentation/features/quiz/quiz_page.dart';
import '../../presentation/features/game/game_page.dart';
import '../../presentation/features/games/memory_match/memory_match_page.dart';
import '../../presentation/features/roadmap/roadmap_page.dart';
import '../../presentation/features/settings/settings_page.dart';
import '../../presentation/features/school/school_dashboard_page.dart';
import '../../presentation/features/school/student_detail_page.dart';
import '../../presentation/features/static_pages/about_page.dart';
import '../../presentation/features/static_pages/privacy_page.dart';
import '../../presentation/features/static_pages/terms_page.dart';
import '../../presentation/features/ai_insights/ai_insights_page.dart';
import '../../presentation/widgets/gradient_background.dart';
import '../../presentation/shell/adaptive_shell.dart';
import '../providers/providers.dart';

/// App routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String authCallback = '/auth/callback';
  static const String schoolLogin = '/auth/school';
  static const String authCallback = '/auth/callback';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String discover = '/discover';
  static const String quiz = '/quiz';
  static const String assessment = '/assessment';
  static const String careers = '/careers';
  static const String roadmap = '/roadmap';
  static const String aiInsights = '/ai-insights';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String about = '/about';
  static const String schoolDashboard = '/school/dashboard';
  static const String schoolStudent = '/school/student';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final schoolRepository = ref.watch(schoolRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final currentLocation = state.matchedLocation;

      // Always allow OAuth callback route (needed for Google sign-in)
      if (currentLocation == AppRoutes.authCallback) {
        return null;
      }

      // Get current user
      final user = await authRepository.getCurrentUser();
      final isLoggedIn = user != null;
      final onboardingComplete = user?.onboardingComplete ?? false;

      // Check user role from school repository
      final isSchoolAdmin = await schoolRepository.isSchoolAdmin();

      final isGoingToAuth = currentLocation.startsWith('/auth');
      final isGoingToOnboarding = currentLocation == AppRoutes.onboarding;
      final isGoingToSchool = currentLocation.startsWith('/school');
      final isGoingToStatic =
          currentLocation.startsWith('/privacy') ||
          currentLocation.startsWith('/terms') ||
          currentLocation.startsWith('/about');

      // Allow access to static pages without auth
      if (isGoingToStatic) {
        return null;
      }

      // Not logged in
      if (!isLoggedIn) {
        if (isGoingToAuth) return null; // Allow access to auth pages
        // Avoid redirect loop: don't redirect if already going to login
        if (currentLocation == AppRoutes.login) return null;
        return AppRoutes.login; // Redirect to login
      }

      // School admin logged in
      if (isSchoolAdmin) {
        // Allow school routes
        if (isGoingToSchool) return null;
        // Allow settings page
        if (currentLocation == AppRoutes.settings) return null;
        // Redirect to school dashboard if trying to access student routes
        if (!isGoingToAuth) {
          // Avoid redirect loop
          if (currentLocation == AppRoutes.schoolDashboard) return null;
          return AppRoutes.schoolDashboard;
        }
        return null;
      }

      // Regular student logged in but onboarding not complete
      if (!onboardingComplete) {
        if (isGoingToOnboarding) return null; // Allow access to onboarding
        // Avoid redirect loop
        if (currentLocation == AppRoutes.onboarding) return null;
        return AppRoutes.onboarding; // Force onboarding
      }

      // Student trying to access school routes
      if (isGoingToSchool) {
        // Avoid redirect loop
        if (currentLocation == AppRoutes.dashboard) return null;
        return AppRoutes.dashboard; // Redirect students away from school routes
      }

      // Logged in and onboarding complete
      if (isGoingToAuth || isGoingToOnboarding) {
        // Avoid redirect loop
        if (currentLocation == AppRoutes.dashboard) return null;
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
      // Auth routes (no shell)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SignupPage()),
      ),
      GoRoute(
        path: AppRoutes.authCallback,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const OAuthCallbackPage()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const OnboardingPage()),
      ),
      // School auth route (no shell)
      GoRoute(
        path: AppRoutes.schoolLogin,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SchoolLoginPage()),
      ),
      // OAuth callback route
      GoRoute(
        path: AppRoutes.authCallback,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _AuthCallbackPage(),
        ),
      ),
      // School routes (no shell - school has its own navigation)
      GoRoute(
        path: AppRoutes.schoolDashboard,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SchoolDashboardPage(),
        ),
      ),
      // Student detail route
      GoRoute(
        path: '${AppRoutes.schoolStudent}/:studentId',
        pageBuilder: (context, state) {
          final studentId = state.pathParameters['studentId']!;
          return MaterialPage(
            key: state.pageKey,
            child: StudentDetailPage(studentId: studentId),
          );
        },
      ),
      // Main app shell with adaptive navigation
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.discover,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DiscoverPage()),
          ),
          GoRoute(
            path: AppRoutes.careers,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CareersPage()),
          ),
          GoRoute(
            path: AppRoutes.roadmap,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RoadmapPage()),
          ),
          GoRoute(
            path: AppRoutes.aiInsights,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AIInsightsPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
      // Assessment and game routes (full screen, no shell)
      GoRoute(
        path: '/quiz/:activityId',
        pageBuilder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return MaterialPage(
            key: state.pageKey,
            child: QuizPage(activityId: activityId),
          );
        },
      ),
      GoRoute(
        path: '/assessment/:instrument/:language',
        pageBuilder: (context, state) {
          final instrument = state.pathParameters['instrument']!;
          final language = state.pathParameters['language']!;
          return MaterialPage(
            key: state.pageKey,
            child: AssessmentPage(
              instrument: instrument,
              language: language,
            ),
          );
        },
      ),
      GoRoute(
        path: '/game/:activityId',
        pageBuilder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return MaterialPage(
            key: state.pageKey,
            child: GamePage(activityId: activityId),
          );
        },
      ),
      GoRoute(
        path: '/games/memory-match',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const MemoryMatchPage()),
      ),
      // Static pages (no shell)
      GoRoute(
        path: AppRoutes.privacy,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const PrivacyPage()),
      ),
      GoRoute(
        path: AppRoutes.terms,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const TermsPage()),
      ),
      GoRoute(
        path: AppRoutes.about,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const AboutPage()),
      ),
    ],
    errorBuilder: (context, state) {
      // Check if this is an OAuth callback with auth tokens in the URL
      final uri = state.uri;
      final fragment = uri.fragment;

      // If URL contains auth tokens (from OAuth redirect), show a loading screen
      // Supabase will automatically process these tokens
      if (fragment.contains('access_token=') || fragment.contains('error=')) {
        debugPrint(
          '🔵 [ROUTER] OAuth callback detected, processing auth tokens...',
        );
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

/// OAuth callback page - handles redirect after Google sign-in
class _AuthCallbackPage extends ConsumerStatefulWidget {
  const _AuthCallbackPage();

  @override
  ConsumerState<_AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends ConsumerState<_AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    debugPrint('🔵 [AUTH_CALLBACK] Processing OAuth callback...');

    // Wait a moment for Supabase to process the session
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Refresh user state
    await ref.read(authControllerProvider.notifier).refreshUser();

    if (!mounted) return;

    // Check if user is school admin
    final isSchoolAdmin = await ref
        .read(schoolRepositoryProvider)
        .isSchoolAdmin();

    if (!mounted) return;

    // Navigate to appropriate dashboard
    if (isSchoolAdmin) {
      debugPrint('🔵 [AUTH_CALLBACK] Redirecting to school dashboard');
      context.go(AppRoutes.schoolDashboard);
    } else {
      debugPrint('🔵 [AUTH_CALLBACK] Redirecting to student dashboard');
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
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
}
