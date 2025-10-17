/// Core application constants and configuration values
class AppConstants {
  AppConstants._();

  /// Application information
  static const String appName = 'SelfMap';
  static const String appVersion = '1.0.0';

  // Discovery
  static const int maxDiscoveryProgress = 100;
  static const int minDiscoveryProgress = 0;
  static const int onboardingProgressBoost = 10;
  static const int quizProgressBoost = 5;
  static const int gameProgressBoost = 8;

  // Career Matching
  static const int minMatchScore = 0;
  static const int maxMatchScore = 100;
  static const int highMatchThreshold = 70;
  static const int mediumMatchThreshold = 40;

  // UI
  static const double maxContentWidth = 1200;
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Animation durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Storage Keys
  static const String storageKeyLocale = 'app_locale';
  static const String storageKeyTheme = 'app_theme';
  static const String storageKeyOnboarding = 'onboarding_complete';
  static const String storageKeyUserId = 'user_id';
}
