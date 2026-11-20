import 'package:go_router/go_router.dart';
import 'package:resume_job_finder/features/auth/data/unavailable_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/home/presentation/pages/home_page.dart';

import '../../../support/test_auth_repository.dart';

import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/password_recovery.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/reset_password_page.dart';

import '../../../support/app_test_harness.dart';
import '../../../support/controlled_auth_repository.dart';
import 'auth_flow_test.dart'
    show keyed, field, enter, tap, messages, fillSignup;

Future<TestAuthRepository> registeredRepository(WidgetTester tester) async {
  final repository = TestAuthRepository(delay: Duration.zero);
  await tester.runAsync(
    () => repository.register(
      fullName: 'Amina',
      email: 'amina@example.com',
      password: 'old-password',
    ),
  );
  return repository;
}

Future<void> startRecovery(WidgetTester tester) async {
  await enter(tester, 'forgot_email', 'amina@example.com');
  await tap(tester, 'forgot_submit');
  expect(find.byType(ForgotPasswordPage), findsOneWidget);
  expect(
    find.text(messages(tester).authRecoveryInstructionsRequested),
    findsOneWidget,
  );
  // Model opening the provider's external email link, never a locally issued token.
  GoRouter.of(tester.element(find.byType(ForgotPasswordPage))).push(
    '/reset-password?mode=resetPassword&oobCode=test-recovery-code',
    extra: const PasswordResetRequest(
      email: 'amina@example.com',
      code: 'test-recovery-code',
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(ResetPasswordPage), findsOneWidget);
}

void main() {
  setUpAll(loadDesignFonts);
  for (final language in ['en', 'ar']) {
    testWidgets(
      'forgot password validation and unavailable service feedback in $language',
      (tester) async {
        await pumpApp(
          tester,
          initialLocation: AppRoutes.forgotPassword,
          authRepository: UnavailableAuthRepository(),
          locale: Locale(language),
          size: const Size(390, 844),
        );
        final l10n = messages(tester);
        expect(find.text(l10n.authForgotMessage), findsOneWidget);
        expect(find.text(l10n.authSendResetInstructions), findsOneWidget);
        await tap(tester, 'forgot_submit');
        expect(find.text(l10n.authEmailRequired), findsOneWidget);
        await enter(tester, 'forgot_email', 'invalid@');
        await tap(tester, 'forgot_submit');
        expect(find.text(l10n.authEmailInvalid), findsOneWidget);
        await enter(tester, 'forgot_email', 'unknown@example.com');
        await tap(tester, 'forgot_submit');
        expect(find.text(l10n.authUnavailable), findsOneWidget);
        expect(find.byType(ResetPasswordPage), findsNothing);
        await tap(tester, 'recovery_login');
        expect(find.byType(LoginPage), findsOneWidget);
      },
    );

    testWidgets(
      'reset validation and independent visibility controls in $language',
      (tester) async {
        final repository = await registeredRepository(tester);
        await pumpApp(
          tester,
          initialLocation: AppRoutes.forgotPassword,
          locale: Locale(language),
          size: const Size(390, 844),
          authRepository: repository,
        );
        await startRecovery(tester);
        final l10n = messages(tester);
        expect(find.text(l10n.authResetSubtitle), findsOneWidget);
        await tap(tester, 'reset_submit');
        expect(find.text(l10n.authPasswordRequired), findsOneWidget);
        expect(find.text(l10n.authConfirmationRequired), findsOneWidget);
        await enter(tester, 'reset_password', 'short');
        await enter(tester, 'reset_confirmation', 'different');
        await tap(tester, 'reset_submit');
        expect(find.text(l10n.authPasswordTooShort(8)), findsWidgets);
        expect(find.text(l10n.authPasswordMismatch), findsOneWidget);
        for (final key in ['reset_password', 'reset_confirmation']) {
          final editable = find.descendant(
            of: keyed(key),
            matching: find.byType(EditableText),
          );
          final toggle = find.descendant(
            of: keyed(key),
            matching: find.byType(IconButton),
          );
          expect(tester.widget<EditableText>(editable).obscureText, isTrue);
          await tester.ensureVisible(toggle);
          await tester.tap(toggle);
          await tester.pump();
          expect(tester.widget<EditableText>(editable).obscureText, isFalse);
          expect(tester.widget<EditableText>(editable).autocorrect, isFalse);
          expect(
            tester.widget<EditableText>(editable).enableSuggestions,
            isFalse,
          );
          await tester.tap(toggle);
          await tester.pump();
          expect(tester.widget<EditableText>(editable).obscureText, isTrue);
        }
        expect(repository.currentUser, isNull);
      },
    );

    testWidgets(
      'register, recover, return to Login and sign in with new password in $language',
      (tester) async {
        final repository = TestAuthRepository();
        final app = await pumpApp(
          tester,
          initialLocation: AppRoutes.login,
          locale: Locale(language),
          size: const Size(390, 844),
          authRepository: repository,
        );
        await tap(tester, 'auth_open_signup');
        await fillSignup(tester);
        await tap(tester, 'signup_submit');
        await tap(tester, 'career_back');
        await tap(tester, 'auth_sign_out');
        await tap(tester, 'auth_forgot_password');
        await startRecovery(tester);
        await enter(tester, 'reset_password', 'new-password');
        await enter(tester, 'reset_confirmation', 'new-password');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        final l10n = messages(tester);
        expect(find.text(l10n.authResetSuccessTitle), findsOneWidget);
        expect(find.text(l10n.authResetSuccess), findsOneWidget);
        expect(find.text('new-password'), findsNothing);
        expect(find.byType(TextFormField), findsNothing);
        expect(repository.currentUser, isNull);
        if (language == 'en') {
          await tap(tester, 'reset_success_login');
        } else {
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        }
        expect(find.byType(LoginPage), findsOneWidget);
        expect(app.router.canPop(), isFalse);
        await enter(tester, 'login_email', 'amina@example.com');
        await enter(tester, 'login_password', 'demo-password');
        await tap(tester, 'login_submit');
        expect(find.text(l10n.authInvalidCredentials), findsWidgets);
        await enter(tester, 'login_password', 'new-password');
        await tap(tester, 'login_submit');
        expect(find.byType(HomePage), findsOneWidget);
        expect(repository.currentUser?.email, 'amina@example.com');
      },
    );
  }

  testWidgets(
    'Android and visible Back preserve Login and Forgot form values',
    (tester) async {
      final repository = await registeredRepository(tester);
      await pumpApp(
        tester,
        initialLocation: AppRoutes.login,
        locale: const Locale('en'),
        size: const Size(390, 844),
        authRepository: repository,
      );
      await enter(tester, 'login_email', 'preserved@example.com');
      await tap(tester, 'auth_forgot_password');
      await startRecovery(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('forgot_email')).controller!.text,
        'amina@example.com',
      );
      await startRecovery(tester);
      await tap(tester, 'auth_back');
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('login_email')).controller!.text,
        'preserved@example.com',
      );
    },
  );

  testWidgets(
    'direct reset without request returns to Forgot and direct Back returns to Login',
    (tester) async {
      final app = await pumpApp(
        tester,
        initialLocation:
            '${AppRoutes.resetPassword}?email=amina@example.com&code=invented',
        size: const Size(390, 844),
      );
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(
        app.router.routeInformationProvider.value.uri.path,
        AppRoutes.forgotPassword,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      app.router.go(AppRoutes.resetPassword, extra: 'amina@example.com');
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    },
  );

  testWidgets('signed-in recovery routes preserve the existing session guard', (
    tester,
  ) async {
    final repository = await registeredRepository(tester);
    await tester.runAsync(
      () => repository.signIn(
        email: 'amina@example.com',
        password: 'old-password',
      ),
    );
    final app = await pumpApp(
      tester,
      initialLocation: AppRoutes.forgotPassword,
      authRepository: repository,
    );
    expect(find.byType(HomePage), findsOneWidget);
    app.router.go(
      AppRoutes.resetPassword,
      extra: PasswordResetRequest(
        email: 'amina@example.com',
        code: 'test-recovery-code',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(repository.currentUser, isNotNull);
  });

  for (final reset in [false, true]) {
    testWidgets(
      '${reset ? 'reset' : 'forgot'} disables controls and Android Back while loading, then exposes retry',
      (tester) async {
        final repository = ControlledAuthRepository();
        final app = await pumpApp(
          tester,
          initialLocation: AppRoutes.forgotPassword,
          locale: const Locale('en'),
          size: const Size(390, 844),
          authRepository: repository,
        );
        if (reset) {
          app.router.go(
            AppRoutes.resetPassword,
            extra: PasswordResetRequest(
              email: 'amina@example.com',
              code: 'test-recovery-code',
            ),
          );
          await tester.pumpAndSettle();
          await enter(tester, 'reset_password', 'new-password');
          await enter(tester, 'reset_confirmation', 'new-password');
        } else {
          await enter(tester, 'forgot_email', 'amina@example.com');
        }
        final submit = keyed(reset ? 'reset_submit' : 'forgot_submit');
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.descendant(
                  of: submit,
                  matching: find.byType(FilledButton),
                ),
              )
              .onPressed,
          isNull,
        );
        expect(tester.widget<IconButton>(keyed('auth_back')).onPressed, isNull);
        expect(
          tester.widget<TextButton>(keyed('recovery_login')).onPressed,
          isNull,
        );
        for (final field in tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        )) {
          expect(field.enabled, isFalse);
        }
        for (final toggle in tester.widgetList<IconButton>(
          find.byType(IconButton),
        )) {
          expect(toggle.onPressed, isNull);
        }
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(
          reset
              ? find.byType(ResetPasswordPage)
              : find.byType(ForgotPasswordPage),
          findsOneWidget,
        );
        if (reset) {
          repository.resetResult.completeError(
            const AuthException(AuthFailure.unavailable),
          );
        } else {
          repository.recoveryResult.completeError(
            StateError('Private backend detail'),
          );
        }
        await tester.pumpAndSettle();
        expect(find.text(messages(tester).authUnavailable), findsOneWidget);
        expect(find.textContaining('Private backend'), findsNothing);
        expect(
          tester
              .widget<FilledButton>(
                find.descendant(
                  of: submit,
                  matching: find.byType(FilledButton),
                ),
              )
              .onPressed,
          isNotNull,
        );
        expect(
          tester.widget<IconButton>(keyed('app_settings')).onPressed,
          isNotNull,
        );
        await tap(tester, 'app_settings');
        expect(keyed('settings_language_ar'), findsOneWidget);
        await tap(tester, 'settings_language_ar');
        await tap(tester, 'settings_theme_dark');
        await tap(tester, 'settings_close');
        expect(app.settings.state.locale, const Locale('ar'));
        expect(app.settings.state.themeMode, ThemeMode.dark);
        await tap(tester, 'recovery_login');
        expect(find.byType(LoginPage), findsOneWidget);
      },
    );
  }

  testWidgets('expired provider reset offers a working restart action', (
    tester,
  ) async {
    final repository = await registeredRepository(tester);
    final app = await pumpApp(
      tester,
      initialLocation: AppRoutes.forgotPassword,
      size: const Size(390, 844),
      authRepository: repository,
    );
    app.router.go(
      AppRoutes.resetPassword,
      extra: PasswordResetRequest(
        email: 'amina@example.com',
        code: 'expired-code',
      ),
    );
    await tester.pumpAndSettle();
    await enter(tester, 'reset_password', 'new-password');
    await enter(tester, 'reset_confirmation', 'new-password');
    await tap(tester, 'reset_submit');
    expect(find.text(messages(tester).authRecoveryExpired), findsOneWidget);
    await tap(tester, 'recovery_restart');
    expect(find.byType(ForgotPasswordPage), findsOneWidget);
    await startRecovery(tester);
  });

  testWidgets(
    'email-link adapter displays instructions without opening a simulated reset',
    (tester) async {
      final repository = ControlledAuthRepository();
      await pumpApp(
        tester,
        initialLocation: AppRoutes.forgotPassword,
        locale: const Locale('en'),
        size: const Size(390, 844),
        authRepository: repository,
      );
      final l10n = messages(tester);
      expect(find.text(l10n.authSendResetInstructions), findsOneWidget);
      await enter(tester, 'forgot_email', 'amina@example.com');
      await tester.ensureVisible(keyed('forgot_submit'));
      await tester.tap(keyed('forgot_submit'));
      await tester.pump();
      repository.recoveryResult.complete();
      await tester.pumpAndSettle();
      expect(find.text(l10n.authRecoveryInstructionsRequested), findsOneWidget);
      expect(find.byType(ResetPasswordPage), findsNothing);
      expect(repository.resetCalls, 0);
      await enter(tester, 'forgot_email', 'another@example.com');
      expect(find.text(l10n.authRecoveryInstructionsRequested), findsNothing);
    },
  );

  testWidgets(
    'reset passes the supplied provider code and only reports confirmed success',
    (tester) async {
      final repository = ControlledAuthRepository();
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.forgotPassword,
        locale: const Locale('en'),
        size: const Size(390, 844),
        authRepository: repository,
      );
      final request = PasswordResetRequest(
        email: 'amina@example.com',
        code: 'provider-code',
      );
      app.router.go(AppRoutes.resetPassword, extra: request);
      await tester.pumpAndSettle();
      final l10n = messages(tester);
      expect(
        find.descendant(
          of: keyed('reset_submit'),
          matching: find.text(l10n.authResetPassword),
        ),
        findsOneWidget,
      );
      await enter(tester, 'reset_password', 'new-password');
      await enter(tester, 'reset_confirmation', 'new-password');
      await tester.ensureVisible(keyed('reset_submit'));
      await tester.tap(keyed('reset_submit'));
      await tester.pump();
      expect(repository.resetRequest, same(request));
      expect(repository.resetRequest!.code, 'provider-code');
      repository.resetResult.complete();
      await tester.pumpAndSettle();
      expect(find.text(l10n.authResetSuccess), findsOneWidget);
      await tap(tester, 'reset_success_login');
      expect(find.byType(LoginPage), findsOneWidget);
    },
  );

  testWidgets(
    'changing language and theme preserves reset inputs and translates validation',
    (tester) async {
      final repository = await registeredRepository(tester);
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.forgotPassword,
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        size: const Size(390, 844),
        authRepository: repository,
      );
      await startRecovery(tester);
      await enter(tester, 'reset_password', 'new-password');
      await enter(tester, 'reset_confirmation', 'different');
      await tap(tester, 'reset_submit');
      final english = messages(tester).authPasswordMismatch;
      app.settings.setLocale(const Locale('ar'));
      app.settings.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text(english), findsNothing);
      expect(find.text(messages(tester).authPasswordMismatch), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('reset_password')).controller!.text,
        'new-password',
      );
      final context = tester.element(find.byType(ResetPasswordPage));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Theme.of(context).brightness, Brightness.dark);
    },
  );
}
