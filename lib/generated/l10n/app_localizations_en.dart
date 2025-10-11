// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SelfMap';

  @override
  String get welcomeMessage => 'Welcome to SelfMap';

  @override
  String get tagline => 'Discover Your Future';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authSignupTitle => 'Create Account';

  @override
  String get authEmailLabel => 'Email Address';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authDisplayNameLabel => 'Display Name';

  @override
  String get authLoginButton => 'Sign In';

  @override
  String get authSignupButton => 'Sign Up';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authSwitchToSignup => 'Don\'t have an account? Sign up';

  @override
  String get authSwitchToLogin => 'Already have an account? Sign in';

  @override
  String get authLogoutButton => 'Log Out';

  @override
  String get authLoggingIn => 'Signing in...';

  @override
  String get authSigningUp => 'Creating account...';

  @override
  String get onboardingTitle => 'Let\'s Get Started!';

  @override
  String get onboardingSubtitle =>
      'Answer a few questions to personalize your journey';

  @override
  String onboardingQuestionPrefix(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get onboardingNextButton => 'Next';

  @override
  String get onboardingBackButton => 'Back';

  @override
  String get onboardingFinishButton => 'Finish';

  @override
  String get onboardingSkipButton => 'Skip';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardWelcome(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get dashboardProgressLabel => 'Discovery Progress';

  @override
  String dashboardProgressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get dashboardStreakLabel => 'Day Streak';

  @override
  String dashboardStreakDays(int days) {
    return '$days days';
  }

  @override
  String get dashboardContinueDiscovery => 'Continue Discovery';

  @override
  String get dashboardViewCareers => 'Explore Careers';

  @override
  String get dashboardStartRoadmap => 'View Roadmap';

  @override
  String get dashboardWhatsNext => 'What\'s Next?';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverSubtitle =>
      'Take quizzes and play games to learn more about yourself';

  @override
  String get discoverQuizzesTab => 'Quizzes';

  @override
  String get discoverGamesTab => 'Games';

  @override
  String get discoverStartButton => 'Start';

  @override
  String get discoverResumeButton => 'Resume';

  @override
  String get discoverCompletedBadge => 'Completed';

  @override
  String get discoverLockedBadge => 'Locked';

  @override
  String discoverProgressLabel(int completed, int total) {
    return '$completed of $total completed';
  }

  @override
  String get careersTitle => 'Careers';

  @override
  String get careersSubtitle => 'Explore careers that match your interests';

  @override
  String get careersFilterLabel => 'Filter by';

  @override
  String get careersFilterAll => 'All';

  @override
  String get careersSearchHint => 'Search careers...';

  @override
  String get careersMatchScoreLabel => 'Match Score';

  @override
  String careersMatchScoreValue(int score) {
    return '$score%';
  }

  @override
  String get careersHighMatch => 'High Match';

  @override
  String get careersMediumMatch => 'Medium Match';

  @override
  String get careersLowMatch => 'Explore More';

  @override
  String get careersAddToRoadmapButton => 'Add to Roadmap';

  @override
  String get careersViewDetailsButton => 'View Details';

  @override
  String get careersEmptyState =>
      'No careers found. Try adjusting your filters.';

  @override
  String get roadmapTitle => 'Roadmap';

  @override
  String get roadmapSubtitle => 'Your personalized path to success';

  @override
  String get roadmapSelectCareer => 'Select a career to see your roadmap';

  @override
  String get roadmapProgressLabel => 'Progress';

  @override
  String roadmapProgressValue(int completed, int total) {
    return '$completed of $total steps';
  }

  @override
  String get roadmapMarkCompleteButton => 'Mark Complete';

  @override
  String get roadmapMarkIncompleteButton => 'Mark Incomplete';

  @override
  String get roadmapEmptyState => 'Add careers to your roadmap to get started';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsDisplayName => 'Display Name';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Enable Notifications';

  @override
  String get settingsPrivacySection => 'Privacy & Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfUse => 'Terms of Use';

  @override
  String get settingsAbout => 'About SelfMap';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get settingsFeedback => 'Send Feedback';

  @override
  String get settingsReportIssue => 'Report an Issue';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyConsentTitle => 'Privacy & Consent';

  @override
  String get privacyConsentMessage =>
      'We value your privacy. This app collects minimal data to provide you with personalized recommendations. Your data is never shared with third parties.';

  @override
  String get privacyConsentAccept => 'I Accept';

  @override
  String get privacyConsentDecline => 'Decline';

  @override
  String get termsTitle => 'Terms of Use';

  @override
  String get termsAccept => 'I agree to the Terms of Use';

  @override
  String get aboutTitle => 'About SelfMap';

  @override
  String get aboutDescription =>
      'SelfMap is a self-discovery platform designed to help high school students explore their interests, discover careers, and plan their future.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get errorTitle => 'Oops!';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorInvalidCredentials => 'Invalid email or password.';

  @override
  String get errorEmailInUse => 'This email is already in use.';

  @override
  String get errorWeakPassword => 'Password is too weak.';

  @override
  String get errorRetryButton => 'Try Again';

  @override
  String get errorGoBackButton => 'Go Back';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyStateMessage => 'Check back later for more content';

  @override
  String get loadingMessage => 'Loading...';

  @override
  String get savingMessage => 'Saving...';

  @override
  String get successMessage => 'Success!';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get continueButton => 'Continue';

  @override
  String get doneButton => 'Done';

  @override
  String get closeButton => 'Close';
}
