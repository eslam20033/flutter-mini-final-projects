// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authRegistrationSignInFailed =>
      'Your account was created, but sign-in did not finish. Use Sign in to continue.';

  @override
  String get careerTitle => 'Career preferences';

  @override
  String get careerExperienceLevel => 'Experience level (optional)';

  @override
  String get careerExperienceLevelHint =>
      'Describe your level, if relevant to your field';

  @override
  String get careerHeading => 'What comes next for you?';

  @override
  String get careerSubtitle =>
      'Tell us what you’re looking for, in any profession. Only your preferred job title is required.';

  @override
  String get careerJobTitle => 'Preferred job title *';

  @override
  String get careerJobTitleHint => 'Enter any role you’re interested in';

  @override
  String get careerIndustry => 'Field or industry (optional)';

  @override
  String get careerIndustryHint => 'Enter your professional field';

  @override
  String get careerExperience => 'Years of experience (optional)';

  @override
  String get careerExperienceHint => 'Enter years, including zero';

  @override
  String get careerLocation => 'Preferred location (optional)';

  @override
  String get careerLocationHint => 'City, region, country, or anywhere';

  @override
  String get careerArrangement => 'Preferred work arrangement';

  @override
  String get careerArrangementAny => 'Any arrangement';

  @override
  String get careerArrangementOnSite => 'On-site';

  @override
  String get careerArrangementHybrid => 'Hybrid';

  @override
  String get careerArrangementRemote => 'Remote';

  @override
  String get careerQualifications => 'Skills or qualifications (optional)';

  @override
  String get careerQualificationsHint =>
      'Add relevant skills, licences, training, or qualifications';

  @override
  String get careerSave => 'Save and continue';

  @override
  String get careerSaved => 'Career preferences saved.';

  @override
  String get careerTitleRequired => 'Enter your preferred job title.';

  @override
  String careerTextTooLong(int length) {
    return 'Use $length characters or fewer.';
  }

  @override
  String get careerExperienceInvalid =>
      'Enter a number from 0 to 100. Decimals are welcome.';

  @override
  String careerYearsSummary(double years) {
    final intl.NumberFormat yearsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String yearsString = yearsNumberFormat.format(years);

    return 'Experience: $yearsString years';
  }

  @override
  String get careerLoadError =>
      'Career preferences are unavailable. Please try again later.';

  @override
  String get careerSaveError =>
      'Preferences could not be saved. Please try again later.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeSubtitle => 'Your next opportunity starts with you.';

  @override
  String get homeCv => 'My CV';

  @override
  String get homeJobs => 'Jobs';

  @override
  String get homeSaved => 'Saved';

  @override
  String get homeNotifications => 'Notifications';

  @override
  String get homeCvTitle => 'Bring your experience to life';

  @override
  String get homeCvDescription =>
      'Your CV journey starts here. Upload and analysis will be available soon; no CV has been uploaded or analysed yet.';

  @override
  String get homeUploadCv => 'Upload CV';

  @override
  String get homePreferencesTitle => 'Your career direction';

  @override
  String get homePreferencesEmpty =>
      'Add your interests to keep your next career move in focus.';

  @override
  String get homeAddPreferences => 'Set career preferences';

  @override
  String get homeEditPreferences => 'Edit preferences';

  @override
  String get homeRecommendations => 'Job recommendations';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeViewDetails => 'View details';

  @override
  String get homeSaveJob => 'Save job';

  @override
  String get homeJobDetails => 'Job details';

  @override
  String get homeJobsEmptyTitle => 'No recommendations yet';

  @override
  String get homeJobsEmptyMessage =>
      'Your preferences are ready to edit. New recommendations will appear here when available.';

  @override
  String get homeLoadError =>
      'Dashboard data is unavailable. Please try again later.';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Sign in to find your next opportunity.';

  @override
  String get authSignupTitle => 'Create your account';

  @override
  String get authSignupSubtitle => 'Start your career journey, in any field.';

  @override
  String get authFullName => 'Full name';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get authEmail => 'Email address';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authForgotTitle => 'Forgot password?';

  @override
  String get authForgotMessage =>
      'Enter your email address to request password reset instructions.';

  @override
  String get authSendResetInstructions => 'Send reset instructions';

  @override
  String get authRecoveryInstructionsRequested =>
      'If an account exists for this email, check your inbox for reset instructions.';

  @override
  String get authBackToLogin => 'Back to sign in';

  @override
  String get authResetTitle => 'Reset password';

  @override
  String get authResetSubtitle =>
      'Choose a new password and enter it again to confirm.';

  @override
  String get authResetAccount => 'Account email';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authConfirmNewPassword => 'Confirm new password';

  @override
  String get authResetPassword => 'Reset password';

  @override
  String get authResetSuccessTitle => 'Password updated';

  @override
  String get authResetSuccess => 'Your password was updated successfully.';

  @override
  String get authResetSignInPrompt =>
      'You can now sign in with your new password.';

  @override
  String get authRecoveryExpired =>
      'This reset request is no longer available. Start password recovery again.';

  @override
  String get authRestartRecovery => 'Start recovery again';

  @override
  String get authDismiss => 'Got it';

  @override
  String get authNoAccount => 'New here?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authGoogle => 'Google';

  @override
  String get authApple => 'Apple';

  @override
  String get authProviderUnavailable =>
      'This sign-in method is currently unavailable. Please use your email and password.';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authRegistrationSuccess => 'Account created. Sign in to continue.';

  @override
  String get authFailureTitle => 'Unable to continue';

  @override
  String get authInvalidCredentials =>
      'Email or password is incorrect. Please try again.';

  @override
  String get authEmailInUse =>
      'An account already uses this email. Sign in or use another email address.';

  @override
  String get authUnavailable =>
      'Authentication is unavailable. Please try again later.';

  @override
  String get authNameRequired => 'Enter your full name.';

  @override
  String get authEmailRequired => 'Enter your email address.';

  @override
  String get authEmailInvalid =>
      'Enter a valid email address, such as name@example.com.';

  @override
  String get authPasswordRequired => 'Enter your password.';

  @override
  String authPasswordTooShort(int length) {
    return 'Use at least $length characters.';
  }

  @override
  String get authConfirmationRequired => 'Confirm your password.';

  @override
  String get authPasswordMismatch => 'Passwords do not match.';

  @override
  String authWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get authAccountTitle => 'Your account';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get appTitle => 'Resume Job Finder';

  @override
  String get loading => 'Loading…';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorMessage => 'Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptyMessage => 'There is no content to display.';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundMessage => 'This page is unavailable.';

  @override
  String get backToStart => 'Back to start';

  @override
  String get splashBrandFirst => 'Automated Resume';

  @override
  String get splashBrandSecond => 'Matching & Job Finder App';

  @override
  String get splashTagline => 'Your AI-powered career companion';

  @override
  String get splashProgressLabel => 'Opening the introduction';

  @override
  String get onboardingResumeTitle => 'One resume. Smarter opportunities.';

  @override
  String get onboardingResumeBody =>
      'Upload your CV once. AI extracts your skills and experience to help you find the right opportunities.';

  @override
  String get onboardingAnalysisTitle => 'Understand your strengths';

  @override
  String get onboardingAnalysisBody =>
      'Explore your strengths, opportunities and skills that need improvement.';

  @override
  String get onboardingMatchingTitle =>
      'Discover jobs that match your experience';

  @override
  String get onboardingMatchingBody =>
      'Get ranked job matches with clear scores and actionable skill gaps.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingResumeIllustration => 'Illustration of a resume';

  @override
  String get onboardingAnalysisIllustration => 'Illustration of skill analysis';

  @override
  String get onboardingMatchingIllustration =>
      'Illustration of an example job match';

  @override
  String get introCvLabel => 'CV';

  @override
  String get introJobTitle => 'Recommended opportunity';

  @override
  String get introMatchLabel => 'Match';

  @override
  String onboardingPageLabel(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get introExperienceLabel => 'Experience';

  @override
  String get introSkillsLabel => 'Skills';

  @override
  String get introGoalsLabel => 'Goals';

  @override
  String get introStrengthsLabel => 'Strengths';

  @override
  String get introJobExample => 'Career matching';

  @override
  String introMatchPercentage(double score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return '$scoreString';
  }

  @override
  String get sessionUnavailable =>
      'Your session could not be restored. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLight => 'Light mode';

  @override
  String get settingsDark => 'Dark mode';

  @override
  String get settingsSystem => 'System default';

  @override
  String get introMatchUnavailable => 'Not rated';
}
