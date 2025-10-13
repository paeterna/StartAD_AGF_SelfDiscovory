// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'خريطة الذات';

  @override
  String get welcomeMessage => 'مرحباً بك في خريطة الذات';

  @override
  String get tagline => 'اكتشف مستقبلك';

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authSignupTitle => 'إنشاء حساب';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authDisplayNameLabel => 'الاسم';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authSignupButton => 'إنشاء حساب';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetPasswordMessage =>
      'أدخل عنوان بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور.';

  @override
  String get authResetPasswordSuccess =>
      'تم إرسال رابط إعادة تعيين كلمة المرور! تحقق من بريدك الإلكتروني.';

  @override
  String get authSendResetLink => 'إرسال رابط الإعادة';

  @override
  String get authSwitchToSignup => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get authSwitchToLogin => 'لديك حساب؟ سجل الدخول';

  @override
  String get authLogoutButton => 'تسجيل الخروج';

  @override
  String get authLoggingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get authSigningUp => 'جارٍ إنشاء الحساب...';

  @override
  String get authGoogleSignIn => 'متابعة مع Google';

  @override
  String get authDividerOr => 'أو';

  @override
  String get authPrivacyLink => 'الخصوصية';

  @override
  String get authTermsLink => 'الشروط';

  @override
  String get onboardingTitle => 'لنبدأ!';

  @override
  String get onboardingSubtitle => 'أجب عن بعض الأسئلة لتخصيص رحلتك';

  @override
  String onboardingQuestionPrefix(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get onboardingNextButton => 'التالي';

  @override
  String get onboardingBackButton => 'السابق';

  @override
  String get onboardingFinishButton => 'إنهاء';

  @override
  String get onboardingSkipButton => 'تخطي';

  @override
  String get welcomeTitle => 'مرحباً بك في خريطة الذات! 🚀';

  @override
  String get welcomeSubtitle => 'اكتشف من أنت وإلى أين تتجه';

  @override
  String get welcomeGetStartedButton => 'لنبدأ! ✨';

  @override
  String get welcomeQuickTitle => 'سريع وممتع';

  @override
  String get welcomeQuickDescription => 'يستغرق دقيقتين فقط!';

  @override
  String get welcomeDiscoverTitle => 'اكتشف نفسك';

  @override
  String get welcomeDiscoverDescription => 'اعثر على نقاط قوتك الفريدة';

  @override
  String get welcomePlanTitle => 'خطط لمستقبلك';

  @override
  String get welcomePlanDescription => 'احصل على مسارات مهنية مخصصة';

  @override
  String get onboardingQuestion1 => 'عندما أواجه مشكلة، أفضل أن:';

  @override
  String get onboardingQ1Option1 => 'أحللها منطقياً';

  @override
  String get onboardingQ1Option2 => 'أفكر بطريقة إبداعية';

  @override
  String get onboardingQ1Option3 => 'أناقشها مع الآخرين';

  @override
  String get onboardingQuestion2 => 'أشعر بأكبر قدر من الطاقة عندما:';

  @override
  String get onboardingQ2Option1 => 'أعمل بشكل مستقل';

  @override
  String get onboardingQ2Option2 => 'أتعاون مع فريق';

  @override
  String get onboardingQ2Option3 => 'أقود الأنشطة الجماعية';

  @override
  String get onboardingQuestion3 => 'عند بدء مشروع جديد، أنا:';

  @override
  String get onboardingQ3Option1 => 'أتبع الطرق المجربة';

  @override
  String get onboardingQ3Option2 => 'أجرب مناهج جديدة';

  @override
  String get onboardingQ3Option3 => 'أدمج الأفكار المجربة والجديدة';

  @override
  String get onboardingQuestion4 => 'أنا مهتم أكثر بـ:';

  @override
  String get onboardingQ4Option1 => 'تعلم مهارات جديدة';

  @override
  String get onboardingQ4Option2 => 'إتقان ما أعرفه';

  @override
  String get onboardingQ4Option3 => 'تطبيق المعرفة عملياً';

  @override
  String get onboardingQuestion5 => 'عند العمل على المهام، أنا:';

  @override
  String get onboardingQ5Option1 => 'أركز على الصورة الكبيرة';

  @override
  String get onboardingQ5Option2 => 'أنتبه للتفاصيل';

  @override
  String get onboardingQ5Option3 => 'أوازن بين الطريقتين';

  @override
  String get dashboardTitle => 'لوحة المعلومات';

  @override
  String dashboardWelcome(String name) {
    return 'مرحباً بعودتك، $name!';
  }

  @override
  String get dashboardProgressLabel => 'تقدم الاكتشاف';

  @override
  String dashboardProgressPercent(int percent) {
    return '$percent٪';
  }

  @override
  String get dashboardStreakLabel => 'سلسلة الأيام';

  @override
  String dashboardStreakDays(int days) {
    return '$days أيام';
  }

  @override
  String get dashboardContinueDiscovery => 'متابعة الاكتشاف';

  @override
  String get dashboardViewCareers => 'استكشاف المهن';

  @override
  String get dashboardStartRoadmap => 'عرض خارطة الطريق';

  @override
  String get dashboardWhatsNext => 'ما التالي؟';

  @override
  String get dashboardContinueDiscoverySubtitle =>
      'خذ الاختبارات والعب الألعاب';

  @override
  String get dashboardViewCareersSubtitle => 'ابحث عن المهن التي تناسبك';

  @override
  String get dashboardStartRoadmapSubtitle => 'خطط طريقك نحو النجاح';

  @override
  String get dashboardProfileProgress => 'تقدم الملف الشخصي';

  @override
  String get dashboardProgressJustStarted => 'بداية الرحلة';

  @override
  String get dashboardProgressGettingThere => 'في الطريق';

  @override
  String get dashboardProgressAlmostDone => 'على وشك الانتهاء';

  @override
  String get dashboardProgressComplete => 'الملف مكتمل!';

  @override
  String get dashboardProgressHint =>
      'أكمل المزيد من الاختبارات والألعاب لتحسين التطابقات';

  @override
  String get dashboardProgressCompleteHint =>
      'عمل رائع! ملفك الشخصي مكتمل والتطابقات محسّنة';

  @override
  String get discoverTitle => 'اكتشف';

  @override
  String get discoverSubtitle =>
      'خذ الاختبارات والعب الألعاب لتتعرف على نفسك أكثر';

  @override
  String get discoverQuizzesTab => 'الاختبارات';

  @override
  String get discoverGamesTab => 'الألعاب';

  @override
  String get discoverStartButton => 'ابدأ';

  @override
  String get discoverResumeButton => 'استئناف';

  @override
  String get discoverCompletedBadge => 'مكتمل';

  @override
  String get discoverLockedBadge => 'مقفل';

  @override
  String discoverProgressLabel(int completed, int total) {
    return '$completed من $total مكتمل';
  }

  @override
  String discoverDurationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get quizPersonalityTitle => 'اكتشاف الشخصية';

  @override
  String get quizPersonalityDescription => 'اكتشف سمات شخصيتك الأساسية';

  @override
  String get quizInterestTitle => 'مستكشف الاهتمامات';

  @override
  String get quizInterestDescription => 'حدد اهتماماتك الرئيسية';

  @override
  String get quizSkillsTitle => 'تقييم المهارات';

  @override
  String get quizSkillsDescription => 'قيم مهاراتك الحالية';

  @override
  String get gamePatternTitle => 'التعرف على الأنماط';

  @override
  String get gamePatternDescription => 'اختبر مهاراتك التحليلية';

  @override
  String get gameCreativeTitle => 'التحدي الإبداعي';

  @override
  String get gameCreativeDescription => 'استكشف إبداعك';

  @override
  String get careersTitle => 'المهن';

  @override
  String get careersSubtitle => 'استكشف المهن التي تناسب اهتماماتك';

  @override
  String get careersFilterLabel => 'تصفية حسب';

  @override
  String get careersFilterAll => 'الكل';

  @override
  String get careersSearchHint => 'ابحث عن المهن...';

  @override
  String get careersMatchScoreLabel => 'درجة التطابق';

  @override
  String careersMatchScoreValue(int score) {
    return '$score٪';
  }

  @override
  String get careersHighMatch => 'تطابق عالٍ';

  @override
  String get careersMediumMatch => 'تطابق متوسط';

  @override
  String get careersLowMatch => 'استكشف المزيد';

  @override
  String get careersAddToRoadmapButton => 'إضافة إلى خارطة الطريق';

  @override
  String get careersViewDetailsButton => 'عرض التفاصيل';

  @override
  String get careersEmptyState => 'لم يتم العثور على مهن. جرب تعديل الفلاتر.';

  @override
  String get careerSoftwareEngineerTitle => 'مهندس برمجيات';

  @override
  String get careerSoftwareEngineerDescription =>
      'تصميم وتطوير وصيانة تطبيقات البرمجيات';

  @override
  String get careerDataScientistTitle => 'عالم بيانات';

  @override
  String get careerDataScientistDescription =>
      'تحليل البيانات المعقدة لمساعدة المؤسسات على اتخاذ القرارات';

  @override
  String get careerGraphicDesignerTitle => 'مصمم جرافيك';

  @override
  String get careerGraphicDesignerDescription =>
      'إنشاء مفاهيم بصرية لتوصيل الأفكار';

  @override
  String get careerMarketingManagerTitle => 'مدير التسويق';

  @override
  String get careerMarketingManagerDescription =>
      'تخطيط وتنفيذ استراتيجيات التسويق';

  @override
  String get clusterTechnology => 'التكنولوجيا';

  @override
  String get clusterSTEM => 'العلوم والتكنولوجيا';

  @override
  String get clusterArtsHumanities => 'الفنون والعلوم الإنسانية';

  @override
  String get clusterBusinessFinance => 'الأعمال والمالية';

  @override
  String get roadmapTitle => 'خارطة الطريق';

  @override
  String get roadmapSubtitle => 'مسارك الشخصي نحو النجاح';

  @override
  String get roadmapSelectCareer => 'اختر مهنة لرؤية خارطة الطريق';

  @override
  String get roadmapProgressLabel => 'التقدم';

  @override
  String roadmapProgressValue(int completed, int total) {
    return '$completed من $total خطوات';
  }

  @override
  String get roadmapMarkCompleteButton => 'وضع علامة مكتمل';

  @override
  String get roadmapMarkIncompleteButton => 'وضع علامة غير مكتمل';

  @override
  String get roadmapEmptyState => 'أضف مهناً إلى خارطة الطريق للبدء';

  @override
  String get roadmapSoftwareEngineerTitle => 'خارطة طريق مهندس البرمجيات';

  @override
  String get roadmapStepProgrammingTitle => 'إتقان أساسيات البرمجة';

  @override
  String get roadmapStepProgrammingDescription =>
      'تعلم أساسيات البرمجة باستخدام Python أو JavaScript';

  @override
  String get roadmapStepProjectsTitle => 'بناء مشاريع شخصية';

  @override
  String get roadmapStepProjectsDescription =>
      'إنشاء 3-5 مشاريع تعرض مهارات مختلفة';

  @override
  String get roadmapStepAlgorithmsTitle => 'تعلم هياكل البيانات والخوارزميات';

  @override
  String get roadmapStepAlgorithmsDescription =>
      'دراسة هياكل البيانات والخوارزميات الشائعة';

  @override
  String get roadmapStepOpenSourceTitle => 'المساهمة في المصادر المفتوحة';

  @override
  String get roadmapStepOpenSourceDescription =>
      'العثور على مشاريع مفتوحة المصدر والمساهمة فيها';

  @override
  String get roadmapStepInternshipTitle => 'إكمال التدريب';

  @override
  String get roadmapStepInternshipDescription =>
      'التقدم لتدريب هندسة البرمجيات';

  @override
  String get roadmapCategorySubject => 'موضوع';

  @override
  String get roadmapCategoryProject => 'مشروع';

  @override
  String get roadmapCategorySkill => 'مهارة';

  @override
  String get roadmapCategoryExperience => 'خبرة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsProfileSection => 'الملف الشخصي';

  @override
  String get settingsDisplayName => 'الاسم';

  @override
  String get settingsEmail => 'البريد الإلكتروني';

  @override
  String get settingsAppearanceSection => 'المظهر';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsNotificationsSection => 'الإشعارات';

  @override
  String get settingsNotificationsEnabled => 'تفعيل الإشعارات';

  @override
  String get settingsNotificationsDescription => 'تلقي التحديثات والتذكيرات';

  @override
  String get settingsPrivacySection => 'الخصوصية والقانون';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsTermsOfUse => 'شروط الاستخدام';

  @override
  String get settingsAbout => 'حول خريطة الذات';

  @override
  String get settingsSupportSection => 'الدعم';

  @override
  String get settingsFeedback => 'إرسال ملاحظات';

  @override
  String get settingsReportIssue => 'الإبلاغ عن مشكلة';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get selectLanguageTitle => 'اختر اللغة';

  @override
  String get selectThemeTitle => 'اختر السمة';

  @override
  String get notSetLabel => 'غير محدد';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyConsentTitle => 'الخصوصية والموافقة';

  @override
  String get privacyConsentMessage =>
      'نحن نقدر خصوصيتك. يجمع هذا التطبيق الحد الأدنى من البيانات لتزويدك بتوصيات مخصصة. لن يتم مشاركة بياناتك مع أطراف ثالثة.';

  @override
  String get privacyConsentAccept => 'أوافق';

  @override
  String get privacyConsentDecline => 'رفض';

  @override
  String get termsTitle => 'شروط الاستخدام';

  @override
  String get termsAccept => 'أوافق على شروط الاستخدام';

  @override
  String get aboutTitle => 'حول خريطة الذات';

  @override
  String get aboutDescription =>
      'خريطة الذات هي منصة اكتشاف الذات مصممة لمساعدة طلاب المدارس الثانوية على استكشاف اهتماماتهم واكتشاف المهن والتخطيط لمستقبلهم.';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get errorTitle => 'عذراً!';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetwork => 'خطأ في الشبكة. يرجى التحقق من اتصالك.';

  @override
  String get errorInvalidCredentials => 'بريد إلكتروني أو كلمة مرور غير صحيحة.';

  @override
  String get errorEmailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة جداً.';

  @override
  String get errorRetryButton => 'حاول مرة أخرى';

  @override
  String get errorGoBackButton => 'العودة';

  @override
  String get emptyStateTitle => 'لا يوجد شيء هنا حتى الآن';

  @override
  String get emptyStateMessage => 'تحقق مرة أخرى لاحقاً لمزيد من المحتوى';

  @override
  String get loadingMessage => 'جارٍ التحميل...';

  @override
  String get savingMessage => 'جارٍ الحفظ...';

  @override
  String get successMessage => 'نجح!';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get saveButton => 'حفظ';

  @override
  String get continueButton => 'متابعة';

  @override
  String get doneButton => 'تم';

  @override
  String get closeButton => 'إغلاق';
}
