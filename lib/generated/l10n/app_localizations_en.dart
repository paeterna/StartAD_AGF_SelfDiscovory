// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Masar';

  @override
  String get welcomeMessage => 'Welcome to Masar';

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
  String get authResetPasswordMessage =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get authResetPasswordSuccess =>
      'Password reset link sent! Check your email.';

  @override
  String get authSendResetLink => 'Send Reset Link';

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
  String get authGoogleSignIn => 'Continue with Google';

  @override
  String get authDividerOr => 'OR';

  @override
  String get authPrivacyLink => 'Privacy';

  @override
  String get authTermsLink => 'Terms';

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
  String get welcomeTitle => 'Welcome to Masar! 🚀';

  @override
  String get welcomeSubtitle => 'Discover who you are and where you\'re going';

  @override
  String get welcomeGetStartedButton => 'Let\'s Get Started! ✨';

  @override
  String get welcomeQuickTitle => 'Quick & Fun';

  @override
  String get welcomeQuickDescription => 'Takes just 2 minutes!';

  @override
  String get welcomeDiscoverTitle => 'Discover Yourself';

  @override
  String get welcomeDiscoverDescription => 'Find your unique strengths';

  @override
  String get welcomePlanTitle => 'Plan Your Future';

  @override
  String get welcomePlanDescription => 'Get personalized career paths';

  @override
  String get onboardingQuestion1 => 'When faced with a problem, I prefer to:';

  @override
  String get onboardingQ1Option1 => 'Analyze it logically';

  @override
  String get onboardingQ1Option2 => 'Think creatively';

  @override
  String get onboardingQ1Option3 => 'Discuss with others';

  @override
  String get onboardingQuestion2 => 'I feel most energized when:';

  @override
  String get onboardingQ2Option1 => 'Working independently';

  @override
  String get onboardingQ2Option2 => 'Collaborating with a team';

  @override
  String get onboardingQ2Option3 => 'Leading group activities';

  @override
  String get onboardingQuestion3 => 'When starting a new project, I:';

  @override
  String get onboardingQ3Option1 => 'Follow established methods';

  @override
  String get onboardingQ3Option2 => 'Experiment with new approaches';

  @override
  String get onboardingQ3Option3 => 'Combine proven and new ideas';

  @override
  String get onboardingQuestion4 => 'I am most interested in:';

  @override
  String get onboardingQ4Option1 => 'Learning new skills';

  @override
  String get onboardingQ4Option2 => 'Mastering what I know';

  @override
  String get onboardingQ4Option3 => 'Applying knowledge practically';

  @override
  String get onboardingQuestion5 => 'When working on tasks, I:';

  @override
  String get onboardingQ5Option1 => 'Focus on the big picture';

  @override
  String get onboardingQ5Option2 => 'Pay attention to details';

  @override
  String get onboardingQ5Option3 => 'Balance both approaches';

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
  String get dashboardContinueDiscoverySubtitle => 'Take quizzes and games';

  @override
  String get dashboardViewCareersSubtitle => 'Find careers that match you';

  @override
  String get dashboardStartRoadmapSubtitle => 'Plan your path to success';

  @override
  String get dashboardProfileProgress => 'Profile Progress';

  @override
  String get dashboardProgressJustStarted => 'Just Getting Started';

  @override
  String get dashboardProgressGettingThere => 'Getting There';

  @override
  String get dashboardProgressAlmostDone => 'Almost Done';

  @override
  String get dashboardProgressComplete => 'Profile Complete!';

  @override
  String get dashboardProgressHint =>
      'Complete more quizzes and games to improve your matches';

  @override
  String get dashboardProgressCompleteHint =>
      'Great job! Your profile is complete and matches are optimized';

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
  String discoverDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get quizPersonalityTitle => 'Personality Discovery';

  @override
  String get quizPersonalityDescription =>
      'Discover your core personality traits';

  @override
  String get quizInterestTitle => 'Interest Explorer';

  @override
  String get quizInterestDescription => 'Identify your key interests';

  @override
  String get quizSkillsTitle => 'Skills Assessment';

  @override
  String get quizSkillsDescription => 'Evaluate your current skills';

  @override
  String get gamePatternTitle => 'Pattern Recognition';

  @override
  String get gamePatternDescription => 'Test your analytical skills';

  @override
  String get gameCreativeTitle => 'Creative Challenge';

  @override
  String get gameCreativeDescription => 'Explore your creativity';

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
  String get careerSoftwareEngineerTitle => 'Software Engineer';

  @override
  String get careerSoftwareEngineerDescription =>
      'Design, develop, and maintain software applications';

  @override
  String get careerDataScientistTitle => 'Data Scientist';

  @override
  String get careerDataScientistDescription =>
      'Analyze complex data to help organizations make decisions';

  @override
  String get careerGraphicDesignerTitle => 'Graphic Designer';

  @override
  String get careerGraphicDesignerDescription =>
      'Create visual concepts to communicate ideas';

  @override
  String get careerMarketingManagerTitle => 'Marketing Manager';

  @override
  String get careerMarketingManagerDescription =>
      'Plan and execute marketing strategies';

  @override
  String get clusterTechnology => 'Technology';

  @override
  String get clusterSTEM => 'STEM';

  @override
  String get clusterArtsHumanities => 'Arts & Humanities';

  @override
  String get clusterBusinessFinance => 'Business & Finance';

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
  String get roadmapSoftwareEngineerTitle => 'Software Engineer Roadmap';

  @override
  String get roadmapStepProgrammingTitle => 'Master Programming Fundamentals';

  @override
  String get roadmapStepProgrammingDescription =>
      'Learn programming basics with Python or JavaScript';

  @override
  String get roadmapStepProjectsTitle => 'Build Personal Projects';

  @override
  String get roadmapStepProjectsDescription =>
      'Create 3-5 projects showcasing different skills';

  @override
  String get roadmapStepAlgorithmsTitle => 'Learn Data Structures & Algorithms';

  @override
  String get roadmapStepAlgorithmsDescription =>
      'Study common data structures and algorithms';

  @override
  String get roadmapStepOpenSourceTitle => 'Contribute to Open Source';

  @override
  String get roadmapStepOpenSourceDescription =>
      'Find open source projects and make contributions';

  @override
  String get roadmapStepInternshipTitle => 'Complete Internship';

  @override
  String get roadmapStepInternshipDescription =>
      'Apply for software engineering internships';

  @override
  String get roadmapCategorySubject => 'Subject';

  @override
  String get roadmapCategoryProject => 'Project';

  @override
  String get roadmapCategorySkill => 'Skill';

  @override
  String get roadmapCategoryExperience => 'Experience';

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
  String get settingsNotificationsDescription =>
      'Receive updates and reminders';

  @override
  String get settingsPrivacySection => 'Privacy & Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfUse => 'Terms of Use';

  @override
  String get settingsAbout => 'About Masar';

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
  String get selectLanguageTitle => 'Select Language';

  @override
  String get selectThemeTitle => 'Select Theme';

  @override
  String get notSetLabel => 'Not set';

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
  String get aboutTitle => 'About Masar';

  @override
  String get aboutDescription =>
      'Masar is a self-discovery platform designed to help high school students explore their interests, discover careers, and plan their future.';

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

  @override
  String get discoverNoQuizzesAvailable => 'No quizzes available at the moment';

  @override
  String get discoverNoGamesAvailable => 'No games available at the moment';

  @override
  String get discoverErrorLoadingQuizzes => 'Failed to load quizzes';

  @override
  String get discoverErrorLoadingGames => 'Failed to load games';

  @override
  String get discoverRetryButton => 'Retry';

  @override
  String get quizGenericDescription => 'Test your knowledge and skills';

  @override
  String get gameGenericDescription => 'Fun interactive challenge';

  @override
  String get quizWhatYouWillLearn => 'What you will learn:';

  @override
  String get quizInstructions => 'Instructions:';

  @override
  String get discoverQuizNotFound => 'Quiz not found';

  @override
  String get discoverQuizNotFoundDesc =>
      'The requested quiz could not be found.';

  @override
  String get discoverBackToDiscovery => 'Back to Discovery';

  @override
  String get discoverErrorLoadingQuiz => 'Error loading quiz';

  @override
  String get discoverQuizNotSupported => 'Quiz not supported yet';

  @override
  String get discoverQuizNotSupportedDesc =>
      'This quiz is not yet available. Please try other quizzes.';

  @override
  String get quizRiasecDescription =>
      'Discover your career interests with the RIASEC model. This assessment helps identify what types of work environments and activities you might enjoy.';

  @override
  String get quizIpip50Description =>
      'Understand your personality traits with the Big Five model. This assessment measures five key dimensions of personality.';

  @override
  String get quizRiasecLearning1 =>
      'Your career interest profile across 6 dimensions';

  @override
  String get quizRiasecLearning2 => 'Which work environments suit you best';

  @override
  String get quizRiasecLearning3 => 'Career paths that match your interests';

  @override
  String get quizRiasecLearning4 =>
      'How you compare to others in your age group';

  @override
  String get quizIpip50Learning1 => 'Your Big Five personality profile';

  @override
  String get quizIpip50Learning2 => 'Your strengths and development areas';

  @override
  String get quizIpip50Learning3 =>
      'How your personality affects your career choices';

  @override
  String get quizIpip50Learning4 => 'Personalized insights and recommendations';

  @override
  String get quizGenericLearning =>
      'Insights about your personality and career interests';

  @override
  String get quizRiasecInstructions =>
      'Rate each activity based on how much you would enjoy it. There are no right or wrong answers - just be honest about your preferences.';

  @override
  String get quizIpip50Instructions =>
      'Read each statement and indicate how accurately it describes you. Answer honestly for the most accurate results.';

  @override
  String get quizGenericInstructions =>
      'Answer all questions honestly. This should take just a few minutes and will provide valuable insights.';

  @override
  String get memoryMatchTitle => 'Memory Match';

  @override
  String get memoryMatchDescription =>
      'Train your memory and attention by matching pairs of cards as quickly as possible.';

  @override
  String get memoryMatchSelectDifficulty => 'Select Difficulty';

  @override
  String get memoryMatchDifficultyEasy => 'Easy';

  @override
  String get memoryMatchDifficultyNormal => 'Normal';

  @override
  String get memoryMatchDifficultyHard => 'Hard';

  @override
  String get memoryMatchDifficultyEasyDesc => '4×4 Grid (8 pairs)';

  @override
  String get memoryMatchDifficultyNormalDesc => '5×4 Grid (10 pairs)';

  @override
  String get memoryMatchDifficultyHardDesc => '6×5 Grid (15 pairs)';

  @override
  String get memoryMatchHowToPlay => 'How to Play';

  @override
  String get memoryMatchHowToPlayStep1 => 'Tap cards to flip them over';

  @override
  String get memoryMatchHowToPlayStep2 => 'Find matching pairs';

  @override
  String get memoryMatchHowToPlayStep3 =>
      'Complete the grid as fast as you can';

  @override
  String get memoryMatchHowToPlayStep4 => 'Fewer mistakes = higher score';

  @override
  String get memoryMatchTime => 'Time';

  @override
  String get memoryMatchMoves => 'Moves';

  @override
  String get memoryMatchMatches => 'Matches';

  @override
  String get memoryMatchPaused => 'Game Paused';

  @override
  String get memoryMatchResume => 'Resume';

  @override
  String get memoryMatchSaveFailed =>
      'Failed to save results. Please try again later.';

  @override
  String get gameResultsTitle => 'Game Complete!';

  @override
  String get gameResultsYourScore => 'Your Score';

  @override
  String get gameResultsComposite => 'Overall Performance';

  @override
  String get gameResultsTime => 'Time';

  @override
  String get gameResultsMoves => 'Moves';

  @override
  String get gameResultsAccuracy => 'Accuracy';

  @override
  String get gameResultsPerformance => 'Performance';

  @override
  String get gameResultsTraitInsights => 'Trait Insights';

  @override
  String get gameResultsTryAgain => 'Try Again';

  @override
  String get gameResultsBackToDiscovery => 'Back to Discovery';

  @override
  String get gameResultsOutstanding => 'Outstanding!';

  @override
  String get gameResultsExcellent => 'Excellent!';

  @override
  String get gameResultsGreat => 'Great!';

  @override
  String get gameResultsGood => 'Good!';

  @override
  String get gameResultsKeepGoing => 'Keep Going!';

  @override
  String get gameResultsNiceTry => 'Nice Try!';

  @override
  String get assessmentTitle => 'Assessment';

  @override
  String get assessmentPrevious => 'Previous';

  @override
  String get assessmentProcessing => 'Processing your responses...';

  @override
  String get assessmentComplete => 'Assessment Complete!';

  @override
  String get assessmentCompleteMessage =>
      'Thank you for completing the assessment.';

  @override
  String assessmentSubmitFailed(String error) {
    return 'Failed to submit assessment: $error';
  }

  @override
  String get onboardingProcessing => 'Processing your responses...';

  @override
  String onboardingErrorCompleting(String error) {
    return 'Error completing onboarding: $error';
  }

  @override
  String get onboardingInvalidItemType => 'Invalid item type';

  @override
  String get authSchoolLoginTitle => 'School Sign In';

  @override
  String get authSignInAsSchool => 'Sign in as School';

  @override
  String get authSignInAsStudent => 'Sign in as Student';

  @override
  String get authPleaseSelectSchool => 'Please select a school';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get oauthCallbackFailed => 'Authentication failed. Please try again.';

  @override
  String oauthCallbackError(String error) {
    return 'Authentication error: $error';
  }

  @override
  String get schoolDashboardTitle => 'School Dashboard';

  @override
  String get schoolDashboardNoSchool => 'No school found for your account';

  @override
  String schoolDashboardErrorLoading(String error) {
    return 'Error loading school: $error';
  }

  @override
  String get schoolDashboardNoStudentData => 'No student data available';

  @override
  String get schoolDashboardNoCareerData => 'No career match data available';

  @override
  String get schoolDashboardViewAll => 'View All';

  @override
  String get schoolDashboardStudentsTablePlaceholder =>
      'Students table with search and filters will be here';

  @override
  String get studentDetailsTitle => 'Student Details';

  @override
  String get studentDetailsNotFound => 'Student not found';

  @override
  String studentDetailsErrorLoading(String error) {
    return 'Error loading student: $error';
  }

  @override
  String get studentsListTitle => 'All Students';

  @override
  String get studentsListProfileColumn => 'Profile';

  @override
  String get studentsListStrengthColumn => 'Strength';

  @override
  String get studentsListLastActiveColumn => 'Last Active';

  @override
  String get studentsListActionsColumn => 'Actions';

  @override
  String errorLoadingCareers(String error) {
    return 'Error loading careers: $error';
  }

  @override
  String errorGenericWithMessage(String error) {
    return 'Error: $error';
  }
}
