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
