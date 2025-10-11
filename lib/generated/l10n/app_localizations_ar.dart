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
