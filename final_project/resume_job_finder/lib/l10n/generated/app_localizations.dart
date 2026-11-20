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
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('ar'),
  ];

  /// Registration: Your account was created, but sign-in did not finish. Use Sign in to continue.
  ///
  /// In en, this message translates to:
  /// **'Your account was created, but sign-in did not finish. Use Sign in to continue.'**
  String get authRegistrationSignInFailed;

  /// Career preferences: Career preferences
  ///
  /// In en, this message translates to:
  /// **'Career preferences'**
  String get careerTitle;

  /// Free-text experience or qualification level, if relevant to the user's profession.
  ///
  /// In en, this message translates to:
  /// **'Experience level (optional)'**
  String get careerExperienceLevel;

  /// Hint for the optional experience level field.
  ///
  /// In en, this message translates to:
  /// **'Describe your level, if relevant to your field'**
  String get careerExperienceLevelHint;

  /// Career preferences: What comes next for you?
  ///
  /// In en, this message translates to:
  /// **'What comes next for you?'**
  String get careerHeading;

  /// Career preferences: Tell us what you’re looking for, in any profession. Only your preferred job title is required.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you’re looking for, in any profession. Only your preferred job title is required.'**
  String get careerSubtitle;

  /// Career preferences: Preferred job title *
  ///
  /// In en, this message translates to:
  /// **'Preferred job title *'**
  String get careerJobTitle;

  /// Career preferences: Enter any role you’re interested in
  ///
  /// In en, this message translates to:
  /// **'Enter any role you’re interested in'**
  String get careerJobTitleHint;

  /// Career preferences: Field or industry (optional)
  ///
  /// In en, this message translates to:
  /// **'Field or industry (optional)'**
  String get careerIndustry;

  /// Career preferences: Enter your professional field
  ///
  /// In en, this message translates to:
  /// **'Enter your professional field'**
  String get careerIndustryHint;

  /// Career preferences: Years of experience (optional)
  ///
  /// In en, this message translates to:
  /// **'Years of experience (optional)'**
  String get careerExperience;

  /// Career preferences: Enter years, including zero
  ///
  /// In en, this message translates to:
  /// **'Enter years, including zero'**
  String get careerExperienceHint;

  /// Career preferences: Preferred location (optional)
  ///
  /// In en, this message translates to:
  /// **'Preferred location (optional)'**
  String get careerLocation;

  /// Career preferences: City, region, country, or anywhere
  ///
  /// In en, this message translates to:
  /// **'City, region, country, or anywhere'**
  String get careerLocationHint;

  /// Career preferences: Preferred work arrangement
  ///
  /// In en, this message translates to:
  /// **'Preferred work arrangement'**
  String get careerArrangement;

  /// Career preferences: Any arrangement
  ///
  /// In en, this message translates to:
  /// **'Any arrangement'**
  String get careerArrangementAny;

  /// Career preferences: On-site
  ///
  /// In en, this message translates to:
  /// **'On-site'**
  String get careerArrangementOnSite;

  /// Career preferences: Hybrid
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get careerArrangementHybrid;

  /// Career preferences: Remote
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get careerArrangementRemote;

  /// Career preferences: Skills or qualifications (optional)
  ///
  /// In en, this message translates to:
  /// **'Skills or qualifications (optional)'**
  String get careerQualifications;

  /// Career preferences: Add relevant skills, licences, training, or qualifications
  ///
  /// In en, this message translates to:
  /// **'Add relevant skills, licences, training, or qualifications'**
  String get careerQualificationsHint;

  /// Career preferences: Save and continue
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get careerSave;

  /// Career preferences: Career preferences saved.
  ///
  /// In en, this message translates to:
  /// **'Career preferences saved.'**
  String get careerSaved;

  /// Career preferences: Enter your preferred job title.
  ///
  /// In en, this message translates to:
  /// **'Enter your preferred job title.'**
  String get careerTitleRequired;

  /// Career preferences: Use {length} characters or fewer.
  ///
  /// In en, this message translates to:
  /// **'Use {length} characters or fewer.'**
  String careerTextTooLong(int length);

  /// Career preferences: Enter a number from 0 to 100. Decimals are welcome.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 0 to 100. Decimals are welcome.'**
  String get careerExperienceInvalid;

  /// Career preferences: Experience: {years} years
  ///
  /// In en, this message translates to:
  /// **'Experience: {years} years'**
  String careerYearsSummary(double years);

  /// Localized status or label; never a generated service result.
  ///
  /// In en, this message translates to:
  /// **'Career preferences are unavailable. Please try again later.'**
  String get careerLoadError;

  /// Localized status or label; never a generated service result.
  ///
  /// In en, this message translates to:
  /// **'Preferences could not be saved. Please try again later.'**
  String get careerSaveError;

  /// Home dashboard: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Home dashboard: Your next opportunity starts with you.
  ///
  /// In en, this message translates to:
  /// **'Your next opportunity starts with you.'**
  String get homeSubtitle;

  /// Home dashboard: My CV
  ///
  /// In en, this message translates to:
  /// **'My CV'**
  String get homeCv;

  /// Home dashboard: Jobs
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get homeJobs;

  /// Home dashboard: Saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get homeSaved;

  /// Home dashboard: Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotifications;

  /// Home dashboard: Bring your experience to life
  ///
  /// In en, this message translates to:
  /// **'Bring your experience to life'**
  String get homeCvTitle;

  /// Home dashboard: Your CV journey starts here. Upload and analysis will be available soon; no CV has been uploaded or analysed yet.
  ///
  /// In en, this message translates to:
  /// **'Your CV journey starts here. Upload and analysis will be available soon; no CV has been uploaded or analysed yet.'**
  String get homeCvDescription;

  /// Home dashboard: Upload CV
  ///
  /// In en, this message translates to:
  /// **'Upload CV'**
  String get homeUploadCv;

  /// Home dashboard: Your career direction
  ///
  /// In en, this message translates to:
  /// **'Your career direction'**
  String get homePreferencesTitle;

  /// Home dashboard: Add your interests to keep your next career move in focus.
  ///
  /// In en, this message translates to:
  /// **'Add your interests to keep your next career move in focus.'**
  String get homePreferencesEmpty;

  /// Home dashboard: Set career preferences
  ///
  /// In en, this message translates to:
  /// **'Set career preferences'**
  String get homeAddPreferences;

  /// Home dashboard: Edit preferences
  ///
  /// In en, this message translates to:
  /// **'Edit preferences'**
  String get homeEditPreferences;

  /// Home dashboard: Job recommendations
  ///
  /// In en, this message translates to:
  /// **'Job recommendations'**
  String get homeRecommendations;

  /// Home dashboard: View all
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// Home dashboard: View details
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get homeViewDetails;

  /// Home dashboard: Save job
  ///
  /// In en, this message translates to:
  /// **'Save job'**
  String get homeSaveJob;

  /// Home dashboard: Job details
  ///
  /// In en, this message translates to:
  /// **'Job details'**
  String get homeJobDetails;

  /// Home dashboard: No recommendations yet
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet'**
  String get homeJobsEmptyTitle;

  /// Home dashboard: Your preferences are ready to edit. New recommendations will appear here when available.
  ///
  /// In en, this message translates to:
  /// **'Your preferences are ready to edit. New recommendations will appear here when available.'**
  String get homeJobsEmptyMessage;

  /// Localized status or label; never a generated service result.
  ///
  /// In en, this message translates to:
  /// **'Dashboard data is unavailable. Please try again later.'**
  String get homeLoadError;

  /// Login heading.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// Career-neutral login introduction.
  ///
  /// In en, this message translates to:
  /// **'Sign in to find your next opportunity.'**
  String get authLoginSubtitle;

  /// Registration heading.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authSignupTitle;

  /// Career-neutral registration introduction.
  ///
  /// In en, this message translates to:
  /// **'Start your career journey, in any field.'**
  String get authSignupSubtitle;

  /// Name field label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// Name input hint without sample personal data.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// Email field label.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmail;

  /// Illustrative email input hint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Password hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// Confirmation field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// Confirmation field hint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// Login action.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Registration action and link.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// Password reset link.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Forgot Password screen title.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotTitle;

  /// Introduction for a future email-link recovery adapter.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to request password reset instructions.'**
  String get authForgotMessage;

  /// Action for a future real email-link adapter.
  ///
  /// In en, this message translates to:
  /// **'Send reset instructions'**
  String get authSendResetInstructions;

  /// Non-enumerating feedback for a real email-link adapter only.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, check your inbox for reset instructions.'**
  String get authRecoveryInstructionsRequested;

  /// Recovery link back to Login.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToLogin;

  /// Reset Password heading.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetTitle;

  /// New password form introduction.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password and enter it again to confirm.'**
  String get authResetSubtitle;

  /// Label for the account being reset.
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get authResetAccount;

  /// New password field label.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// New password confirmation label.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmNewPassword;

  /// Password update action for a real adapter.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPassword;

  /// Successful reset heading.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get authResetSuccessTitle;

  /// Real adapter reset success.
  ///
  /// In en, this message translates to:
  /// **'Your password was updated successfully.'**
  String get authResetSuccess;

  /// Accessible success instruction.
  ///
  /// In en, this message translates to:
  /// **'You can now sign in with your new password.'**
  String get authResetSignInPrompt;

  /// Safe feedback for an unavailable or consumed request.
  ///
  /// In en, this message translates to:
  /// **'This reset request is no longer available. Start password recovery again.'**
  String get authRecoveryExpired;

  /// Restart a failed or expired reset flow.
  ///
  /// In en, this message translates to:
  /// **'Start recovery again'**
  String get authRestartRecovery;

  /// Dismiss informational feedback.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get authDismiss;

  /// Registration link prompt.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get authNoAccount;

  /// Login link prompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// Social sign-in separator.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// Social provider brand.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get authGoogle;

  /// Social provider brand.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get authApple;

  /// Feedback when an authentication provider is unavailable.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is currently unavailable. Please use your email and password.'**
  String get authProviderUnavailable;

  /// Password visibility tooltip.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Password visibility tooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Registration success feedback on login.
  ///
  /// In en, this message translates to:
  /// **'Account created. Sign in to continue.'**
  String get authRegistrationSuccess;

  /// Authentication error heading.
  ///
  /// In en, this message translates to:
  /// **'Unable to continue'**
  String get authFailureTitle;

  /// Login failure without revealing account existence.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect. Please try again.'**
  String get authInvalidCredentials;

  /// Duplicate registration feedback.
  ///
  /// In en, this message translates to:
  /// **'An account already uses this email. Sign in or use another email address.'**
  String get authEmailInUse;

  /// Localized status or label; never a generated service result.
  ///
  /// In en, this message translates to:
  /// **'Authentication is unavailable. Please try again later.'**
  String get authUnavailable;

  /// Required name validation.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get authNameRequired;

  /// Required email validation.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get authEmailRequired;

  /// Email format validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address, such as name@example.com.'**
  String get authEmailInvalid;

  /// Required password validation.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authPasswordRequired;

  /// Minimum registration password length.
  ///
  /// In en, this message translates to:
  /// **'Use at least {length} characters.'**
  String authPasswordTooShort(int length);

  /// Required password confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get authConfirmationRequired;

  /// Password confirmation validation.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatch;

  /// Post-login greeting using the authenticated user's name.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String authWelcome(String name);

  /// Signed-in account page title.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get authAccountTitle;

  /// Clear the temporary demo session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// Application title.
  ///
  /// In en, this message translates to:
  /// **'Resume Job Finder'**
  String get appTitle;

  /// Accessible label for loading indicators.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Default error state heading.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// Default user-facing error message.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get errorMessage;

  /// Retry action label.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Default empty state heading.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// Default empty state message.
  ///
  /// In en, this message translates to:
  /// **'There is no content to display.'**
  String get emptyMessage;

  /// Unknown route heading.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// Unknown route message without internal error details.
  ///
  /// In en, this message translates to:
  /// **'This page is unavailable.'**
  String get pageNotFoundMessage;

  /// Action to return to the startup route.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get backToStart;

  /// First brand line, retained in English in both Figma languages.
  ///
  /// In en, this message translates to:
  /// **'Automated Resume'**
  String get splashBrandFirst;

  /// Second brand line shown in the splash.
  ///
  /// In en, this message translates to:
  /// **'Matching & Job Finder App'**
  String get splashBrandSecond;

  /// Splash tagline; Arabic copy reconstructed from the available truncated Figma metadata.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered career companion'**
  String get splashTagline;

  /// Accessible description of the introductory animation, not backend progress.
  ///
  /// In en, this message translates to:
  /// **'Opening the introduction'**
  String get splashProgressLabel;

  /// Resume slide heading; English completion follows the available truncated reference.
  ///
  /// In en, this message translates to:
  /// **'One resume. Smarter opportunities.'**
  String get onboardingResumeTitle;

  /// Resume introduction; reconstructed where the Figma text was unavailable.
  ///
  /// In en, this message translates to:
  /// **'Upload your CV once. AI extracts your skills and experience to help you find the right opportunities.'**
  String get onboardingResumeBody;

  /// AI analysis slide heading.
  ///
  /// In en, this message translates to:
  /// **'Understand your strengths'**
  String get onboardingAnalysisTitle;

  /// Analysis introduction; Arabic completion follows the available metadata.
  ///
  /// In en, this message translates to:
  /// **'Explore your strengths, opportunities and skills that need improvement.'**
  String get onboardingAnalysisBody;

  /// Career-neutral job matching introduction for every profession.
  ///
  /// In en, this message translates to:
  /// **'Discover jobs that match your experience'**
  String get onboardingMatchingTitle;

  /// Matching introduction; Arabic completion follows the available metadata.
  ///
  /// In en, this message translates to:
  /// **'Get ranked job matches with clear scores and actionable skill gaps.'**
  String get onboardingMatchingBody;

  /// Exit onboarding without visiting all slides.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Move to the next introduction slide.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Finish onboarding and open the temporary destination.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Description of decorative resume artwork.
  ///
  /// In en, this message translates to:
  /// **'Illustration of a resume'**
  String get onboardingResumeIllustration;

  /// Description of decorative skill badges.
  ///
  /// In en, this message translates to:
  /// **'Illustration of skill analysis'**
  String get onboardingAnalysisIllustration;

  /// Makes clear that the illustrated job and score are examples, not real results.
  ///
  /// In en, this message translates to:
  /// **'Illustration of an example job match'**
  String get onboardingMatchingIllustration;

  /// Resume badge in the illustration.
  ///
  /// In en, this message translates to:
  /// **'CV'**
  String get introCvLabel;

  /// Generic illustrated opportunity, not a profession or user data.
  ///
  /// In en, this message translates to:
  /// **'Recommended opportunity'**
  String get introJobTitle;

  /// Caption for the decorative sample score.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get introMatchLabel;

  /// Accessible current slide announcement.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String onboardingPageLabel(int page, int total);

  /// Career-neutral area shown in the analysis illustration.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get introExperienceLabel;

  /// Career-neutral area shown in the analysis illustration.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get introSkillsLabel;

  /// Career-neutral area shown in the analysis illustration.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get introGoalsLabel;

  /// Career-neutral area shown in the analysis illustration.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get introStrengthsLabel;

  /// Localized status or label; never a generated service result.
  ///
  /// In en, this message translates to:
  /// **'Career matching'**
  String get introJobExample;

  /// Formats a supplied fraction as a localized percentage. This is display formatting, not a matching calculation.
  ///
  /// In en, this message translates to:
  /// **'{score}'**
  String introMatchPercentage(double score);

  /// Localized status or label; never a generated service result.
  ///
  /// In en, this message translates to:
  /// **'Your session could not be restored. Please try again.'**
  String get sessionUnavailable;

  /// Settings sheet title and entry tooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language selection heading.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Arabic language name in its own script.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsArabic;

  /// English language name in its own script.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// Theme selection heading.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get settingsLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDark;

  /// Follow device appearance option.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsSystem;

  /// Localized status or label; never a generated service result.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get introMatchUnavailable;
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
