import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Masar'**
  String get appName;

  /// Welcome message on splash
  ///
  /// In en, this message translates to:
  /// **'Welcome to Masar'**
  String get welcomeMessage;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Discover Your Future'**
  String get tagline;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginTitle;

  /// No description provided for @authSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authSignupTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get authDisplayNameLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginButton;

  /// No description provided for @authSignupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignupButton;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authResetPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get authResetPasswordMessage;

  /// No description provided for @authResetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email.'**
  String get authResetPasswordSuccess;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get authSendResetLink;

  /// No description provided for @authSwitchToSignup.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authSwitchToSignup;

  /// No description provided for @authSwitchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authSwitchToLogin;

  /// No description provided for @authLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get authLogoutButton;

  /// No description provided for @authLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get authLoggingIn;

  /// No description provided for @authSigningUp.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get authSigningUp;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogleSignIn;

  /// No description provided for @authDividerOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authDividerOr;

  /// No description provided for @authPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get authPrivacyLink;

  /// No description provided for @authTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get authTermsLink;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started!'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions to personalize your journey'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingQuestionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String onboardingQuestionPrefix(int current, int total);

  /// No description provided for @onboardingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// No description provided for @onboardingBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBackButton;

  /// No description provided for @onboardingFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinishButton;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkipButton;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Masar! 🚀'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover who you are and where you\'re going'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeGetStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started! ✨'**
  String get welcomeGetStartedButton;

  /// No description provided for @welcomeQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick & Fun'**
  String get welcomeQuickTitle;

  /// No description provided for @welcomeQuickDescription.
  ///
  /// In en, this message translates to:
  /// **'Takes just 2 minutes!'**
  String get welcomeQuickDescription;

  /// No description provided for @welcomeDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Yourself'**
  String get welcomeDiscoverTitle;

  /// No description provided for @welcomeDiscoverDescription.
  ///
  /// In en, this message translates to:
  /// **'Find your unique strengths'**
  String get welcomeDiscoverDescription;

  /// No description provided for @welcomePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Future'**
  String get welcomePlanTitle;

  /// No description provided for @welcomePlanDescription.
  ///
  /// In en, this message translates to:
  /// **'Get personalized career paths'**
  String get welcomePlanDescription;

  /// No description provided for @onboardingQuestion1.
  ///
  /// In en, this message translates to:
  /// **'When faced with a problem, I prefer to:'**
  String get onboardingQuestion1;

  /// No description provided for @onboardingQ1Option1.
  ///
  /// In en, this message translates to:
  /// **'Analyze it logically'**
  String get onboardingQ1Option1;

  /// No description provided for @onboardingQ1Option2.
  ///
  /// In en, this message translates to:
  /// **'Think creatively'**
  String get onboardingQ1Option2;

  /// No description provided for @onboardingQ1Option3.
  ///
  /// In en, this message translates to:
  /// **'Discuss with others'**
  String get onboardingQ1Option3;

  /// No description provided for @onboardingQuestion2.
  ///
  /// In en, this message translates to:
  /// **'I feel most energized when:'**
  String get onboardingQuestion2;

  /// No description provided for @onboardingQ2Option1.
  ///
  /// In en, this message translates to:
  /// **'Working independently'**
  String get onboardingQ2Option1;

  /// No description provided for @onboardingQ2Option2.
  ///
  /// In en, this message translates to:
  /// **'Collaborating with a team'**
  String get onboardingQ2Option2;

  /// No description provided for @onboardingQ2Option3.
  ///
  /// In en, this message translates to:
  /// **'Leading group activities'**
  String get onboardingQ2Option3;

  /// No description provided for @onboardingQuestion3.
  ///
  /// In en, this message translates to:
  /// **'When starting a new project, I:'**
  String get onboardingQuestion3;

  /// No description provided for @onboardingQ3Option1.
  ///
  /// In en, this message translates to:
  /// **'Follow established methods'**
  String get onboardingQ3Option1;

  /// No description provided for @onboardingQ3Option2.
  ///
  /// In en, this message translates to:
  /// **'Experiment with new approaches'**
  String get onboardingQ3Option2;

  /// No description provided for @onboardingQ3Option3.
  ///
  /// In en, this message translates to:
  /// **'Combine proven and new ideas'**
  String get onboardingQ3Option3;

  /// No description provided for @onboardingQuestion4.
  ///
  /// In en, this message translates to:
  /// **'I am most interested in:'**
  String get onboardingQuestion4;

  /// No description provided for @onboardingQ4Option1.
  ///
  /// In en, this message translates to:
  /// **'Learning new skills'**
  String get onboardingQ4Option1;

  /// No description provided for @onboardingQ4Option2.
  ///
  /// In en, this message translates to:
  /// **'Mastering what I know'**
  String get onboardingQ4Option2;

  /// No description provided for @onboardingQ4Option3.
  ///
  /// In en, this message translates to:
  /// **'Applying knowledge practically'**
  String get onboardingQ4Option3;

  /// No description provided for @onboardingQuestion5.
  ///
  /// In en, this message translates to:
  /// **'When working on tasks, I:'**
  String get onboardingQuestion5;

  /// No description provided for @onboardingQ5Option1.
  ///
  /// In en, this message translates to:
  /// **'Focus on the big picture'**
  String get onboardingQ5Option1;

  /// No description provided for @onboardingQ5Option2.
  ///
  /// In en, this message translates to:
  /// **'Pay attention to details'**
  String get onboardingQ5Option2;

  /// No description provided for @onboardingQ5Option3.
  ///
  /// In en, this message translates to:
  /// **'Balance both approaches'**
  String get onboardingQ5Option3;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String dashboardWelcome(String name);

  /// No description provided for @dashboardProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Discovery Progress'**
  String get dashboardProgressLabel;

  /// No description provided for @dashboardProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String dashboardProgressPercent(int percent);

  /// No description provided for @dashboardStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dashboardStreakLabel;

  /// No description provided for @dashboardStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String dashboardStreakDays(int days);

  /// No description provided for @dashboardContinueDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Continue Discovery'**
  String get dashboardContinueDiscovery;

  /// No description provided for @dashboardViewCareers.
  ///
  /// In en, this message translates to:
  /// **'Explore Careers'**
  String get dashboardViewCareers;

  /// No description provided for @dashboardStartRoadmap.
  ///
  /// In en, this message translates to:
  /// **'View Roadmap'**
  String get dashboardStartRoadmap;

  /// No description provided for @dashboardWhatsNext.
  ///
  /// In en, this message translates to:
  /// **'What\'s Next?'**
  String get dashboardWhatsNext;

  /// No description provided for @dashboardContinueDiscoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take quizzes and games'**
  String get dashboardContinueDiscoverySubtitle;

  /// No description provided for @dashboardViewCareersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find careers that match you'**
  String get dashboardViewCareersSubtitle;

  /// No description provided for @dashboardStartRoadmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your path to success'**
  String get dashboardStartRoadmapSubtitle;

  /// No description provided for @dashboardProfileProgress.
  ///
  /// In en, this message translates to:
  /// **'Profile Progress'**
  String get dashboardProfileProgress;

  /// No description provided for @dashboardProgressJustStarted.
  ///
  /// In en, this message translates to:
  /// **'Just Getting Started'**
  String get dashboardProgressJustStarted;

  /// No description provided for @dashboardProgressGettingThere.
  ///
  /// In en, this message translates to:
  /// **'Getting There'**
  String get dashboardProgressGettingThere;

  /// No description provided for @dashboardProgressAlmostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost Done'**
  String get dashboardProgressAlmostDone;

  /// No description provided for @dashboardProgressComplete.
  ///
  /// In en, this message translates to:
  /// **'Profile Complete!'**
  String get dashboardProgressComplete;

  /// No description provided for @dashboardProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Complete more quizzes and games to improve your matches'**
  String get dashboardProgressHint;

  /// No description provided for @dashboardProgressCompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Great job! Your profile is complete and matches are optimized'**
  String get dashboardProgressCompleteHint;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @discoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take quizzes and play games to learn more about yourself'**
  String get discoverSubtitle;

  /// No description provided for @discoverQuizzesTab.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get discoverQuizzesTab;

  /// No description provided for @discoverGamesTab.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get discoverGamesTab;

  /// No description provided for @discoverStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get discoverStartButton;

  /// No description provided for @discoverResumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get discoverResumeButton;

  /// No description provided for @discoverCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get discoverCompletedBadge;

  /// No description provided for @discoverLockedBadge.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get discoverLockedBadge;

  /// No description provided for @discoverProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String discoverProgressLabel(int completed, int total);

  /// No description provided for @discoverDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String discoverDurationMinutes(int minutes);

  /// No description provided for @quizPersonalityTitle.
  ///
  /// In en, this message translates to:
  /// **'Personality Discovery'**
  String get quizPersonalityTitle;

  /// No description provided for @quizPersonalityDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover your core personality traits'**
  String get quizPersonalityDescription;

  /// No description provided for @quizInterestTitle.
  ///
  /// In en, this message translates to:
  /// **'Interest Explorer'**
  String get quizInterestTitle;

  /// No description provided for @quizInterestDescription.
  ///
  /// In en, this message translates to:
  /// **'Identify your key interests'**
  String get quizInterestDescription;

  /// No description provided for @quizSkillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills Assessment'**
  String get quizSkillsTitle;

  /// No description provided for @quizSkillsDescription.
  ///
  /// In en, this message translates to:
  /// **'Evaluate your current skills'**
  String get quizSkillsDescription;

  /// No description provided for @gamePatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Pattern Recognition'**
  String get gamePatternTitle;

  /// No description provided for @gamePatternDescription.
  ///
  /// In en, this message translates to:
  /// **'Test your analytical skills'**
  String get gamePatternDescription;

  /// No description provided for @gameCreativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Creative Challenge'**
  String get gameCreativeTitle;

  /// No description provided for @gameCreativeDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore your creativity'**
  String get gameCreativeDescription;

  /// No description provided for @careersTitle.
  ///
  /// In en, this message translates to:
  /// **'Careers'**
  String get careersTitle;

  /// No description provided for @careersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore careers that match your interests'**
  String get careersSubtitle;

  /// No description provided for @careersFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get careersFilterLabel;

  /// No description provided for @careersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get careersFilterAll;

  /// No description provided for @careersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search careers...'**
  String get careersSearchHint;

  /// No description provided for @careersMatchScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Match Score'**
  String get careersMatchScoreLabel;

  /// No description provided for @careersMatchScoreValue.
  ///
  /// In en, this message translates to:
  /// **'{score}%'**
  String careersMatchScoreValue(int score);

  /// No description provided for @careersHighMatch.
  ///
  /// In en, this message translates to:
  /// **'High Match'**
  String get careersHighMatch;

  /// No description provided for @careersMediumMatch.
  ///
  /// In en, this message translates to:
  /// **'Medium Match'**
  String get careersMediumMatch;

  /// No description provided for @careersLowMatch.
  ///
  /// In en, this message translates to:
  /// **'Explore More'**
  String get careersLowMatch;

  /// No description provided for @careersAddToRoadmapButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Roadmap'**
  String get careersAddToRoadmapButton;

  /// No description provided for @careersViewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get careersViewDetailsButton;

  /// No description provided for @careersEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No careers found. Try adjusting your filters.'**
  String get careersEmptyState;

  /// No description provided for @careerSoftwareEngineerTitle.
  ///
  /// In en, this message translates to:
  /// **'Software Engineer'**
  String get careerSoftwareEngineerTitle;

  /// No description provided for @careerSoftwareEngineerDescription.
  ///
  /// In en, this message translates to:
  /// **'Design, develop, and maintain software applications'**
  String get careerSoftwareEngineerDescription;

  /// No description provided for @careerDataScientistTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Scientist'**
  String get careerDataScientistTitle;

  /// No description provided for @careerDataScientistDescription.
  ///
  /// In en, this message translates to:
  /// **'Analyze complex data to help organizations make decisions'**
  String get careerDataScientistDescription;

  /// No description provided for @careerGraphicDesignerTitle.
  ///
  /// In en, this message translates to:
  /// **'Graphic Designer'**
  String get careerGraphicDesignerTitle;

  /// No description provided for @careerGraphicDesignerDescription.
  ///
  /// In en, this message translates to:
  /// **'Create visual concepts to communicate ideas'**
  String get careerGraphicDesignerDescription;

  /// No description provided for @careerMarketingManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketing Manager'**
  String get careerMarketingManagerTitle;

  /// No description provided for @careerMarketingManagerDescription.
  ///
  /// In en, this message translates to:
  /// **'Plan and execute marketing strategies'**
  String get careerMarketingManagerDescription;

  /// No description provided for @clusterTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get clusterTechnology;

  /// No description provided for @clusterSTEM.
  ///
  /// In en, this message translates to:
  /// **'STEM'**
  String get clusterSTEM;

  /// No description provided for @clusterArtsHumanities.
  ///
  /// In en, this message translates to:
  /// **'Arts & Humanities'**
  String get clusterArtsHumanities;

  /// No description provided for @clusterBusinessFinance.
  ///
  /// In en, this message translates to:
  /// **'Business & Finance'**
  String get clusterBusinessFinance;

  /// No description provided for @roadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Roadmap'**
  String get roadmapTitle;

  /// No description provided for @roadmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personalized path to success'**
  String get roadmapSubtitle;

  /// No description provided for @roadmapSelectCareer.
  ///
  /// In en, this message translates to:
  /// **'Select a career to see your roadmap'**
  String get roadmapSelectCareer;

  /// No description provided for @roadmapProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get roadmapProgressLabel;

  /// No description provided for @roadmapProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} steps'**
  String roadmapProgressValue(int completed, int total);

  /// No description provided for @roadmapMarkCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get roadmapMarkCompleteButton;

  /// No description provided for @roadmapMarkIncompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Incomplete'**
  String get roadmapMarkIncompleteButton;

  /// No description provided for @roadmapEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Add careers to your roadmap to get started'**
  String get roadmapEmptyState;

  /// No description provided for @roadmapSoftwareEngineerTitle.
  ///
  /// In en, this message translates to:
  /// **'Software Engineer Roadmap'**
  String get roadmapSoftwareEngineerTitle;

  /// No description provided for @roadmapStepProgrammingTitle.
  ///
  /// In en, this message translates to:
  /// **'Master Programming Fundamentals'**
  String get roadmapStepProgrammingTitle;

  /// No description provided for @roadmapStepProgrammingDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn programming basics with Python or JavaScript'**
  String get roadmapStepProgrammingDescription;

  /// No description provided for @roadmapStepProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Personal Projects'**
  String get roadmapStepProjectsTitle;

  /// No description provided for @roadmapStepProjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Create 3-5 projects showcasing different skills'**
  String get roadmapStepProjectsDescription;

  /// No description provided for @roadmapStepAlgorithmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn Data Structures & Algorithms'**
  String get roadmapStepAlgorithmsTitle;

  /// No description provided for @roadmapStepAlgorithmsDescription.
  ///
  /// In en, this message translates to:
  /// **'Study common data structures and algorithms'**
  String get roadmapStepAlgorithmsDescription;

  /// No description provided for @roadmapStepOpenSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribute to Open Source'**
  String get roadmapStepOpenSourceTitle;

  /// No description provided for @roadmapStepOpenSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Find open source projects and make contributions'**
  String get roadmapStepOpenSourceDescription;

  /// No description provided for @roadmapStepInternshipTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Internship'**
  String get roadmapStepInternshipTitle;

  /// No description provided for @roadmapStepInternshipDescription.
  ///
  /// In en, this message translates to:
  /// **'Apply for software engineering internships'**
  String get roadmapStepInternshipDescription;

  /// No description provided for @roadmapCategorySubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get roadmapCategorySubject;

  /// No description provided for @roadmapCategoryProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get roadmapCategoryProject;

  /// No description provided for @roadmapCategorySkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get roadmapCategorySkill;

  /// No description provided for @roadmapCategoryExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get roadmapCategoryExperience;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// No description provided for @settingsDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get settingsDisplayName;

  /// No description provided for @settingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmail;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive updates and reminders'**
  String get settingsNotificationsDescription;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Legal'**
  String get settingsPrivacySection;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Masar'**
  String get settingsAbout;

  /// No description provided for @settingsSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupportSection;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settingsFeedback;

  /// No description provided for @settingsReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get settingsReportIssue;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @selectThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectThemeTitle;

  /// No description provided for @notSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetLabel;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Consent'**
  String get privacyConsentTitle;

  /// No description provided for @privacyConsentMessage.
  ///
  /// In en, this message translates to:
  /// **'We value your privacy. This app collects minimal data to provide you with personalized recommendations. Your data is never shared with third parties.'**
  String get privacyConsentMessage;

  /// No description provided for @privacyConsentAccept.
  ///
  /// In en, this message translates to:
  /// **'I Accept'**
  String get privacyConsentAccept;

  /// No description provided for @privacyConsentDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get privacyConsentDecline;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsTitle;

  /// No description provided for @termsAccept.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Use'**
  String get termsAccept;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Masar'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Masar is a self-discovery platform designed to help high school students explore their interests, discover careers, and plan their future.'**
  String get aboutDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get errorTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get errorWeakPassword;

  /// No description provided for @errorRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get errorRetryButton;

  /// No description provided for @errorGoBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get errorGoBackButton;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'Check back later for more content'**
  String get emptyStateMessage;

  /// No description provided for @loadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage;

  /// No description provided for @savingMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingMessage;

  /// No description provided for @successMessage.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @discoverNoQuizzesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No quizzes available at the moment'**
  String get discoverNoQuizzesAvailable;

  /// No description provided for @discoverNoGamesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No games available at the moment'**
  String get discoverNoGamesAvailable;

  /// No description provided for @discoverErrorLoadingQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load quizzes'**
  String get discoverErrorLoadingQuizzes;

  /// No description provided for @discoverErrorLoadingGames.
  ///
  /// In en, this message translates to:
  /// **'Failed to load games'**
  String get discoverErrorLoadingGames;

  /// No description provided for @discoverRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get discoverRetryButton;

  /// No description provided for @quizGenericDescription.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge and skills'**
  String get quizGenericDescription;

  /// No description provided for @gameGenericDescription.
  ///
  /// In en, this message translates to:
  /// **'Fun interactive challenge'**
  String get gameGenericDescription;

  /// No description provided for @quizWhatYouWillLearn.
  ///
  /// In en, this message translates to:
  /// **'What you will learn:'**
  String get quizWhatYouWillLearn;

  /// No description provided for @quizInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions:'**
  String get quizInstructions;

  /// No description provided for @discoverQuizNotFound.
  ///
  /// In en, this message translates to:
  /// **'Quiz not found'**
  String get discoverQuizNotFound;

  /// No description provided for @discoverQuizNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'The requested quiz could not be found.'**
  String get discoverQuizNotFoundDesc;

  /// No description provided for @discoverBackToDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Back to Discovery'**
  String get discoverBackToDiscovery;

  /// No description provided for @discoverErrorLoadingQuiz.
  ///
  /// In en, this message translates to:
  /// **'Error loading quiz'**
  String get discoverErrorLoadingQuiz;

  /// No description provided for @discoverQuizNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Quiz not supported yet'**
  String get discoverQuizNotSupported;

  /// No description provided for @discoverQuizNotSupportedDesc.
  ///
  /// In en, this message translates to:
  /// **'This quiz is not yet available. Please try other quizzes.'**
  String get discoverQuizNotSupportedDesc;

  /// No description provided for @quizRiasecDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover your career interests with the RIASEC model. This assessment helps identify what types of work environments and activities you might enjoy.'**
  String get quizRiasecDescription;

  /// No description provided for @quizIpip50Description.
  ///
  /// In en, this message translates to:
  /// **'Understand your personality traits with the Big Five model. This assessment measures five key dimensions of personality.'**
  String get quizIpip50Description;

  /// No description provided for @quizRiasecLearning1.
  ///
  /// In en, this message translates to:
  /// **'Your career interest profile across 6 dimensions'**
  String get quizRiasecLearning1;

  /// No description provided for @quizRiasecLearning2.
  ///
  /// In en, this message translates to:
  /// **'Which work environments suit you best'**
  String get quizRiasecLearning2;

  /// No description provided for @quizRiasecLearning3.
  ///
  /// In en, this message translates to:
  /// **'Career paths that match your interests'**
  String get quizRiasecLearning3;

  /// No description provided for @quizRiasecLearning4.
  ///
  /// In en, this message translates to:
  /// **'How you compare to others in your age group'**
  String get quizRiasecLearning4;

  /// No description provided for @quizIpip50Learning1.
  ///
  /// In en, this message translates to:
  /// **'Your Big Five personality profile'**
  String get quizIpip50Learning1;

  /// No description provided for @quizIpip50Learning2.
  ///
  /// In en, this message translates to:
  /// **'Your strengths and development areas'**
  String get quizIpip50Learning2;

  /// No description provided for @quizIpip50Learning3.
  ///
  /// In en, this message translates to:
  /// **'How your personality affects your career choices'**
  String get quizIpip50Learning3;

  /// No description provided for @quizIpip50Learning4.
  ///
  /// In en, this message translates to:
  /// **'Personalized insights and recommendations'**
  String get quizIpip50Learning4;

  /// No description provided for @quizGenericLearning.
  ///
  /// In en, this message translates to:
  /// **'Insights about your personality and career interests'**
  String get quizGenericLearning;

  /// No description provided for @quizRiasecInstructions.
  ///
  /// In en, this message translates to:
  /// **'Rate each activity based on how much you would enjoy it. There are no right or wrong answers - just be honest about your preferences.'**
  String get quizRiasecInstructions;

  /// No description provided for @quizIpip50Instructions.
  ///
  /// In en, this message translates to:
  /// **'Read each statement and indicate how accurately it describes you. Answer honestly for the most accurate results.'**
  String get quizIpip50Instructions;

  /// No description provided for @quizGenericInstructions.
  ///
  /// In en, this message translates to:
  /// **'Answer all questions honestly. This should take just a few minutes and will provide valuable insights.'**
  String get quizGenericInstructions;

  /// No description provided for @memoryMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Match'**
  String get memoryMatchTitle;

  /// No description provided for @memoryMatchDescription.
  ///
  /// In en, this message translates to:
  /// **'Train your memory and attention by matching pairs of cards as quickly as possible.'**
  String get memoryMatchDescription;

  /// No description provided for @memoryMatchSelectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get memoryMatchSelectDifficulty;

  /// No description provided for @memoryMatchDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get memoryMatchDifficultyEasy;

  /// No description provided for @memoryMatchDifficultyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get memoryMatchDifficultyNormal;

  /// No description provided for @memoryMatchDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get memoryMatchDifficultyHard;

  /// No description provided for @memoryMatchDifficultyEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'4×4 Grid (8 pairs)'**
  String get memoryMatchDifficultyEasyDesc;

  /// No description provided for @memoryMatchDifficultyNormalDesc.
  ///
  /// In en, this message translates to:
  /// **'5×4 Grid (10 pairs)'**
  String get memoryMatchDifficultyNormalDesc;

  /// No description provided for @memoryMatchDifficultyHardDesc.
  ///
  /// In en, this message translates to:
  /// **'6×5 Grid (15 pairs)'**
  String get memoryMatchDifficultyHardDesc;

  /// No description provided for @memoryMatchHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get memoryMatchHowToPlay;

  /// No description provided for @memoryMatchHowToPlayStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap cards to flip them over'**
  String get memoryMatchHowToPlayStep1;

  /// No description provided for @memoryMatchHowToPlayStep2.
  ///
  /// In en, this message translates to:
  /// **'Find matching pairs'**
  String get memoryMatchHowToPlayStep2;

  /// No description provided for @memoryMatchHowToPlayStep3.
  ///
  /// In en, this message translates to:
  /// **'Complete the grid as fast as you can'**
  String get memoryMatchHowToPlayStep3;

  /// No description provided for @memoryMatchHowToPlayStep4.
  ///
  /// In en, this message translates to:
  /// **'Fewer mistakes = higher score'**
  String get memoryMatchHowToPlayStep4;

  /// No description provided for @memoryMatchTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get memoryMatchTime;

  /// No description provided for @memoryMatchMoves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get memoryMatchMoves;

  /// No description provided for @memoryMatchMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get memoryMatchMatches;

  /// No description provided for @memoryMatchPaused.
  ///
  /// In en, this message translates to:
  /// **'Game Paused'**
  String get memoryMatchPaused;

  /// No description provided for @memoryMatchResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get memoryMatchResume;

  /// No description provided for @memoryMatchSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save results. Please try again later.'**
  String get memoryMatchSaveFailed;

  /// No description provided for @gameResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Complete!'**
  String get gameResultsTitle;

  /// No description provided for @gameResultsYourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get gameResultsYourScore;

  /// No description provided for @gameResultsComposite.
  ///
  /// In en, this message translates to:
  /// **'Overall Performance'**
  String get gameResultsComposite;

  /// No description provided for @gameResultsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get gameResultsTime;

  /// No description provided for @gameResultsMoves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get gameResultsMoves;

  /// No description provided for @gameResultsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get gameResultsAccuracy;

  /// No description provided for @gameResultsPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get gameResultsPerformance;

  /// No description provided for @gameResultsTraitInsights.
  ///
  /// In en, this message translates to:
  /// **'Trait Insights'**
  String get gameResultsTraitInsights;

  /// No description provided for @gameResultsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get gameResultsTryAgain;

  /// No description provided for @gameResultsBackToDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Back to Discovery'**
  String get gameResultsBackToDiscovery;

  /// No description provided for @gameResultsOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding!'**
  String get gameResultsOutstanding;

  /// No description provided for @gameResultsExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get gameResultsExcellent;

  /// No description provided for @gameResultsGreat.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get gameResultsGreat;

  /// No description provided for @gameResultsGood.
  ///
  /// In en, this message translates to:
  /// **'Good!'**
  String get gameResultsGood;

  /// No description provided for @gameResultsKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep Going!'**
  String get gameResultsKeepGoing;

  /// No description provided for @gameResultsNiceTry.
  ///
  /// In en, this message translates to:
  /// **'Nice Try!'**
  String get gameResultsNiceTry;

  /// No description provided for @assessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessmentTitle;

  /// No description provided for @assessmentPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get assessmentPrevious;

  /// No description provided for @assessmentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing your responses...'**
  String get assessmentProcessing;

  /// No description provided for @assessmentComplete.
  ///
  /// In en, this message translates to:
  /// **'Assessment Complete!'**
  String get assessmentComplete;

  /// No description provided for @assessmentCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for completing the assessment.'**
  String get assessmentCompleteMessage;

  /// No description provided for @assessmentSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit assessment: {error}'**
  String assessmentSubmitFailed(String error);

  /// No description provided for @onboardingProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing your responses...'**
  String get onboardingProcessing;

  /// No description provided for @onboardingErrorCompleting.
  ///
  /// In en, this message translates to:
  /// **'Error completing onboarding: {error}'**
  String onboardingErrorCompleting(String error);

  /// No description provided for @onboardingInvalidItemType.
  ///
  /// In en, this message translates to:
  /// **'Invalid item type'**
  String get onboardingInvalidItemType;

  /// No description provided for @authSchoolLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'School Sign In'**
  String get authSchoolLoginTitle;

  /// No description provided for @authSignInAsSchool.
  ///
  /// In en, this message translates to:
  /// **'Sign in as School'**
  String get authSignInAsSchool;

  /// No description provided for @authSignInAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Sign in as Student'**
  String get authSignInAsStudent;

  /// No description provided for @authPleaseSelectSchool.
  ///
  /// In en, this message translates to:
  /// **'Please select a school'**
  String get authPleaseSelectSchool;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @oauthCallbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get oauthCallbackFailed;

  /// No description provided for @oauthCallbackError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String oauthCallbackError(String error);

  /// No description provided for @schoolDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'School Dashboard'**
  String get schoolDashboardTitle;

  /// No description provided for @schoolDashboardNoSchool.
  ///
  /// In en, this message translates to:
  /// **'No school found for your account'**
  String get schoolDashboardNoSchool;

  /// No description provided for @schoolDashboardErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading school: {error}'**
  String schoolDashboardErrorLoading(String error);

  /// No description provided for @schoolDashboardNoStudentData.
  ///
  /// In en, this message translates to:
  /// **'No student data available'**
  String get schoolDashboardNoStudentData;

  /// No description provided for @schoolDashboardNoCareerData.
  ///
  /// In en, this message translates to:
  /// **'No career match data available'**
  String get schoolDashboardNoCareerData;

  /// No description provided for @schoolDashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get schoolDashboardViewAll;

  /// No description provided for @schoolDashboardStudentsTablePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Students table with search and filters will be here'**
  String get schoolDashboardStudentsTablePlaceholder;

  /// No description provided for @studentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Details'**
  String get studentDetailsTitle;

  /// No description provided for @studentDetailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Student not found'**
  String get studentDetailsNotFound;

  /// No description provided for @studentDetailsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading student: {error}'**
  String studentDetailsErrorLoading(String error);

  /// No description provided for @studentsListTitle.
  ///
  /// In en, this message translates to:
  /// **'All Students'**
  String get studentsListTitle;

  /// No description provided for @studentsListProfileColumn.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get studentsListProfileColumn;

  /// No description provided for @studentsListStrengthColumn.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get studentsListStrengthColumn;

  /// No description provided for @studentsListLastActiveColumn.
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get studentsListLastActiveColumn;

  /// No description provided for @studentsListActionsColumn.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get studentsListActionsColumn;

  /// No description provided for @errorLoadingCareers.
  ///
  /// In en, this message translates to:
  /// **'Error loading careers: {error}'**
  String errorLoadingCareers(String error);

  /// No description provided for @errorGenericWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGenericWithMessage(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
