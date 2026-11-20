// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get authRegistrationSignInFailed =>
      'تم إنشاء حسابك، لكن تسجيل الدخول لم يكتمل. استخدم تسجيل الدخول للمتابعة.';

  @override
  String get careerTitle => 'التفضيلات المهنية';

  @override
  String get careerExperienceLevel => 'مستوى الخبرة (اختياري)';

  @override
  String get careerExperienceLevelHint =>
      'صف مستواك إذا كان ذلك مناسبًا لمجالك';

  @override
  String get careerHeading => 'ما خطوتك المهنية القادمة؟';

  @override
  String get careerSubtitle =>
      'أخبرنا بما تبحث عنه، أيًا كان مجالك. المسمى الوظيفي المفضل هو الحقل المطلوب الوحيد.';

  @override
  String get careerJobTitle => 'المسمى الوظيفي المفضل *';

  @override
  String get careerJobTitleHint => 'أدخل أي وظيفة تهتم بها';

  @override
  String get careerIndustry => 'المجال أو القطاع (اختياري)';

  @override
  String get careerIndustryHint => 'أدخل مجالك المهني';

  @override
  String get careerExperience => 'سنوات الخبرة (اختياري)';

  @override
  String get careerExperienceHint => 'أدخل عدد السنوات، ويمكن إدخال صفر';

  @override
  String get careerLocation => 'الموقع المفضل (اختياري)';

  @override
  String get careerLocationHint => 'مدينة أو منطقة أو دولة أو أي مكان';

  @override
  String get careerArrangement => 'نظام العمل المفضل';

  @override
  String get careerArrangementAny => 'أي نظام عمل';

  @override
  String get careerArrangementOnSite => 'من مقر العمل';

  @override
  String get careerArrangementHybrid => 'هجين';

  @override
  String get careerArrangementRemote => 'عن بُعد';

  @override
  String get careerQualifications => 'المهارات أو المؤهلات (اختياري)';

  @override
  String get careerQualificationsHint =>
      'أضف المهارات أو التراخيص أو التدريب أو المؤهلات ذات الصلة';

  @override
  String get careerSave => 'حفظ ومتابعة';

  @override
  String get careerSaved => 'تم حفظ تفضيلاتك المهنية.';

  @override
  String get careerTitleRequired => 'أدخل المسمى الوظيفي المفضل.';

  @override
  String careerTextTooLong(int length) {
    return 'استخدم $length حرفًا أو أقل.';
  }

  @override
  String get careerExperienceInvalid =>
      'أدخل عددًا من ٠ إلى ١٠٠. يمكن استخدام الكسور العشرية.';

  @override
  String careerYearsSummary(double years) {
    final intl.NumberFormat yearsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String yearsString = yearsNumberFormat.format(years);

    return 'الخبرة: $yearsString سنة';
  }

  @override
  String get careerLoadError =>
      'التفضيلات المهنية غير متاحة. يُرجى المحاولة لاحقًا.';

  @override
  String get careerSaveError => 'تعذّر حفظ التفضيلات. يُرجى المحاولة لاحقًا.';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeSubtitle => 'فرصتك القادمة تبدأ من هنا.';

  @override
  String get homeCv => 'سيرتي';

  @override
  String get homeJobs => 'الوظائف';

  @override
  String get homeSaved => 'المحفوظات';

  @override
  String get homeNotifications => 'الإشعارات';

  @override
  String get homeCvTitle => 'أبرز خبراتك ومهاراتك';

  @override
  String get homeCvDescription =>
      'تبدأ رحلتك مع السيرة الذاتية هنا. الرفع والتحليل متاحان قريبًا؛ لم تُرفع أو تُحلّل أي سيرة ذاتية بعد.';

  @override
  String get homeUploadCv => 'رفع السيرة الذاتية';

  @override
  String get homePreferencesTitle => 'توجّهك المهني';

  @override
  String get homePreferencesEmpty =>
      'أضف اهتماماتك لتوضيح خطوتك المهنية القادمة.';

  @override
  String get homeAddPreferences => 'تحديد التفضيلات المهنية';

  @override
  String get homeEditPreferences => 'تعديل التفضيلات';

  @override
  String get homeRecommendations => 'وظائف مقترحة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeViewDetails => 'عرض التفاصيل';

  @override
  String get homeSaveJob => 'حفظ الوظيفة';

  @override
  String get homeJobDetails => 'تفاصيل الوظيفة';

  @override
  String get homeJobsEmptyTitle => 'لا توجد وظائف مقترحة بعد';

  @override
  String get homeJobsEmptyMessage =>
      'يمكنك تعديل تفضيلاتك. ستظهر الوظائف المقترحة هنا عندما تتوفر.';

  @override
  String get homeLoadError =>
      'بيانات الصفحة الرئيسية غير متاحة. يُرجى المحاولة لاحقًا.';

  @override
  String get authLoginTitle => 'مرحبًا بعودتك';

  @override
  String get authLoginSubtitle => 'سجّل الدخول واعثر على فرصتك القادمة.';

  @override
  String get authSignupTitle => 'أنشئ حسابك';

  @override
  String get authSignupSubtitle => 'ابدأ رحلتك المهنية، أيًا كان مجالك.';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authFullNameHint => 'أدخل اسمك الكامل';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authPasswordHint => 'أدخل كلمة المرور';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authConfirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authForgotTitle => 'نسيت كلمة المرور؟';

  @override
  String get authForgotMessage =>
      'أدخل بريدك الإلكتروني لطلب تعليمات إعادة تعيين كلمة المرور.';

  @override
  String get authSendResetInstructions => 'إرسال تعليمات إعادة التعيين';

  @override
  String get authRecoveryInstructionsRequested =>
      'إذا كان هناك حساب بهذا البريد، فتحقّق من صندوق الوارد للاطلاع على تعليمات إعادة التعيين.';

  @override
  String get authBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetSubtitle =>
      'اختر كلمة مرور جديدة ثم أدخلها مرة أخرى للتأكيد.';

  @override
  String get authResetAccount => 'بريد الحساب الإلكتروني';

  @override
  String get authNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetSuccessTitle => 'تم تحديث كلمة المرور';

  @override
  String get authResetSuccess => 'تم تحديث كلمة المرور بنجاح.';

  @override
  String get authResetSignInPrompt =>
      'يمكنك الآن تسجيل الدخول باستخدام كلمة المرور الجديدة.';

  @override
  String get authRecoveryExpired =>
      'لم يعد طلب إعادة التعيين هذا متاحًا. ابدأ استعادة كلمة المرور من جديد.';

  @override
  String get authRestartRecovery => 'بدء الاستعادة من جديد';

  @override
  String get authDismiss => 'حسنًا';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authOrContinueWith => 'أو المتابعة باستخدام';

  @override
  String get authGoogle => 'Google';

  @override
  String get authApple => 'Apple';

  @override
  String get authProviderUnavailable =>
      'طريقة تسجيل الدخول هذه غير متاحة حاليًا. يُرجى استخدام البريد الإلكتروني وكلمة المرور.';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authRegistrationSuccess =>
      'تم إنشاء الحساب. سجّل الدخول للمتابعة.';

  @override
  String get authFailureTitle => 'تعذّرت المتابعة';

  @override
  String get authInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة. يُرجى المحاولة مرة أخرى.';

  @override
  String get authEmailInUse =>
      'يوجد حساب بهذا البريد الإلكتروني. سجّل الدخول أو استخدم بريدًا آخر.';

  @override
  String get authUnavailable =>
      'خدمة المصادقة غير متاحة. يُرجى المحاولة لاحقًا.';

  @override
  String get authNameRequired => 'أدخل اسمك الكامل.';

  @override
  String get authEmailRequired => 'أدخل بريدك الإلكتروني.';

  @override
  String get authEmailInvalid =>
      'أدخل بريدًا إلكترونيًا صحيحًا، مثل name@example.com.';

  @override
  String get authPasswordRequired => 'أدخل كلمة المرور.';

  @override
  String authPasswordTooShort(int length) {
    return 'استخدم $length أحرف على الأقل.';
  }

  @override
  String get authConfirmationRequired => 'أكّد كلمة المرور.';

  @override
  String get authPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String authWelcome(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get authAccountTitle => 'حسابك';

  @override
  String get authSignOut => 'تسجيل الخروج';

  @override
  String get appTitle => 'البحث عن الوظائف';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get errorTitle => 'حدث خطأ';

  @override
  String get errorMessage => 'يرجى المحاولة مرة أخرى.';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get emptyTitle => 'لا يوجد محتوى بعد';

  @override
  String get emptyMessage => 'لا يوجد محتوى لعرضه.';

  @override
  String get pageNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundMessage => 'هذه الصفحة غير متاحة.';

  @override
  String get backToStart => 'العودة إلى البداية';

  @override
  String get splashBrandFirst => 'Automated Resume';

  @override
  String get splashBrandSecond => 'Matching & Job Finder App';

  @override
  String get splashTagline =>
      'مساعدك الذكي لتحليل سيرتك والبحث عن فرصتك القادمة';

  @override
  String get splashProgressLabel => 'جارٍ فتح المقدمة';

  @override
  String get onboardingResumeTitle => 'سيرتك الذاتية هي بداية فرصتك';

  @override
  String get onboardingResumeBody =>
      'ارفع ملف السيرة الذاتية، ودع الذكاء الاصطناعي يكتشف مهاراتك وخبراتك.';

  @override
  String get onboardingAnalysisTitle => 'اعرف نقاط قوتك ومهاراتك';

  @override
  String get onboardingAnalysisBody =>
      'اكتشف نقاط قوتك والمهارات الناقصة التي تحتاج إلى تطويرها.';

  @override
  String get onboardingMatchingTitle => 'اكتشف الوظائف المناسبة لخبراتك';

  @override
  String get onboardingMatchingBody =>
      'وظائف مرتبة حسب التوافق مع تفسير واضح للنتائج والمهارات التي تحتاج إلى تطويرها.';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingContinue => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingResumeIllustration => 'رسم توضيحي لسيرة ذاتية';

  @override
  String get onboardingAnalysisIllustration => 'رسم توضيحي لتحليل المهارات';

  @override
  String get onboardingMatchingIllustration =>
      'رسم توضيحي لمثال على توافق وظيفة';

  @override
  String get introCvLabel => 'سيرة';

  @override
  String get introJobTitle => 'فرصة عمل مقترحة';

  @override
  String get introMatchLabel => 'توافق';

  @override
  String onboardingPageLabel(int page, int total) {
    return 'الصفحة $page من $total';
  }

  @override
  String get introExperienceLabel => 'الخبرات';

  @override
  String get introSkillsLabel => 'المهارات';

  @override
  String get introGoalsLabel => 'الأهداف';

  @override
  String get introStrengthsLabel => 'نقاط القوة';

  @override
  String get introJobExample => 'المطابقة المهنية';

  @override
  String introMatchPercentage(double score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return '$scoreString';
  }

  @override
  String get sessionUnavailable =>
      'تعذّر استعادة جلسة تسجيل الدخول. يُرجى المحاولة مجددًا.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsLight => 'الوضع الفاتح';

  @override
  String get settingsDark => 'الوضع الداكن';

  @override
  String get settingsSystem => 'إعدادات النظام';

  @override
  String get introMatchUnavailable => 'غير مُقيّم';
}
