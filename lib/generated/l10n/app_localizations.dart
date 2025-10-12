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
  /// **'SelfMap'**
  String get appName;

  /// Welcome message on splash
  ///
  /// In en, this message translates to:
  /// **'Welcome to SelfMap'**
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
  /// **'Welcome to SelfMap! 🚀'**
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
  /// **'About SelfMap'**
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
  /// **'About SelfMap'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'SelfMap is a self-discovery platform designed to help high school students explore their interests, discover careers, and plan their future.'**
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
