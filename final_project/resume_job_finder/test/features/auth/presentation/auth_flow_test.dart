import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/home/presentation/pages/home_page.dart';
import '../../../support/test_auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_user.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/sign_up_page.dart';
import 'package:resume_job_finder/features/career_preferences/presentation/pages/career_preferences_page.dart';
import 'package:resume_job_finder/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:resume_job_finder/l10n/generated/app_localizations.dart';

import '../../../support/app_test_harness.dart';
import '../../../support/controlled_auth_repository.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));
Finder field(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(TextFormField));

Future<void> enter(WidgetTester tester, String key, String text) async {
  await tester.ensureVisible(field(key));
  await tester.enterText(field(key), text);
  await tester.pump();
}

Future<void> tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(keyed(key));
  await tester.tap(keyed(key));
  await tester.pumpAndSettle();
}

AppLocalizations messages(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).last));

Future<void> fillSignup(
  WidgetTester tester, {
  String email = 'amina@example.com',
  String name = 'أمينة حسن',
}) async {
  await enter(tester, 'signup_name', name);
  await enter(tester, 'signup_email', email);
  await enter(tester, 'signup_password', 'demo-password');
  await enter(tester, 'signup_confirmation', 'demo-password');
}

void main() {
  setUpAll(loadDesignFonts);

  for (final language in ['en', 'ar']) {
    testWidgets('login validation and password visibility in $language', (
      tester,
    ) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.login,
        locale: Locale(language),
        size: const Size(390, 844),
      );
      final l10n = messages(tester);
      await tap(tester, 'login_submit');
      expect(find.text(l10n.authEmailRequired), findsOneWidget);
      expect(find.text(l10n.authPasswordRequired), findsOneWidget);
      await enter(tester, 'login_email', 'wrong@');
      await enter(tester, 'login_password', 'demo-password');
      await tap(tester, 'login_submit');
      expect(find.text(l10n.authEmailInvalid), findsOneWidget);
      final password = tester.widget<TextFormField>(field('login_password'));
      expect(password.controller!.text, 'demo-password');
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: keyed('login_password'),
                matching: find.byType(EditableText),
              ),
            )
            .obscureText,
        isTrue,
      );
      await tester.ensureVisible(keyed('login_password'));
      await tester.tap(find.byTooltip(l10n.authShowPassword));
      await tester.pump();
      final editable = tester.widget<EditableText>(
        find.descendant(
          of: keyed('login_password'),
          matching: find.byType(EditableText),
        ),
      );
      expect(editable.obscureText, isFalse);
      expect(editable.autocorrect, isFalse);
      expect(editable.enableSuggestions, isFalse);
      await tester.tap(find.byTooltip(l10n.authHidePassword));
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: keyed('login_password'),
                matching: find.byType(EditableText),
              ),
            )
            .obscureText,
        isTrue,
      );
    });

    testWidgets(
      'registration validates required fields, strength and confirmation in $language',
      (tester) async {
        await pumpApp(
          tester,
          initialLocation: AppRoutes.signUp,
          locale: Locale(language),
          size: const Size(390, 844),
        );
        final l10n = messages(tester);
        await tap(tester, 'signup_submit');
        for (final message in [
          l10n.authNameRequired,
          l10n.authEmailRequired,
          l10n.authPasswordRequired,
          l10n.authConfirmationRequired,
        ]) {
          expect(find.text(message), findsOneWidget);
        }
        await fillSignup(tester);
        await enter(tester, 'signup_password', 'short');
        await enter(tester, 'signup_confirmation', 'different');
        await tap(tester, 'signup_submit');
        // The same text is also used as the field hint.
        expect(find.text(l10n.authPasswordTooShort(8)), findsWidgets);
        expect(find.text(l10n.authPasswordMismatch), findsOneWidget);
        for (final key in ['signup_password', 'signup_confirmation']) {
          final toggle = find.descendant(
            of: keyed(key),
            matching: find.byType(IconButton),
          );
          await tester.ensureVisible(toggle);
          await tester.tap(toggle);
          await tester.pump();
          expect(
            tester
                .widget<EditableText>(
                  find.descendant(
                    of: keyed(key),
                    matching: find.byType(EditableText),
                  ),
                )
                .obscureText,
            isFalse,
          );
        }
        expect(find.byType(SignUpPage), findsOneWidget);
      },
    );

    testWidgets(
      'register, fail login, sign in with entered name and sign out in $language',
      (tester) async {
        final repository = TestAuthRepository();
        final app = await pumpApp(
          tester,
          initialLocation: AppRoutes.login,
          locale: Locale(language),
          size: const Size(390, 844),
          authRepository: repository,
        );
        final l10n = messages(tester);
        await tap(tester, 'auth_open_signup');
        expect(find.byType(SignUpPage), findsOneWidget);
        await fillSignup(tester);
        await tap(tester, 'signup_submit');
        expect(find.byType(CareerPreferencesPage), findsOneWidget);
        await enter(tester, 'career_jobTitle', 'Teacher');
        await tap(tester, 'career_save');
        expect(find.byType(HomePage), findsOneWidget);
        await tap(tester, 'auth_sign_out');
        expect(repository.currentUser, isNull);
        await enter(tester, 'login_email', 'amina@example.com');
        await enter(tester, 'login_password', 'incorrect');
        await tap(tester, 'login_submit');
        expect(find.text(l10n.authInvalidCredentials), findsWidgets);
        expect(repository.currentUser, isNull);
        await enter(tester, 'login_password', 'demo-password');
        await tap(tester, 'login_submit');
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.text(l10n.authWelcome('أمينة حسن')), findsOneWidget);
        expect(find.text(l10n.homeCvDescription), findsOneWidget);
        expect(repository.currentUser!.fullName, 'أمينة حسن');
        expect(app.router.canPop(), isFalse);
        await tap(tester, 'auth_sign_out');
        expect(repository.currentUser, isNull);
        expect(find.byType(LoginPage), findsOneWidget);
        app.router.go(AppRoutes.home);
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      },
    );

    testWidgets(
      'social and password reset actions give honest feedback in $language',
      (tester) async {
        final repository = TestAuthRepository();
        await pumpApp(
          tester,
          initialLocation: AppRoutes.login,
          locale: Locale(language),
          size: const Size(390, 844),
          authRepository: repository,
        );
        final l10n = messages(tester);
        for (final key in ['auth_google', 'auth_apple']) {
          await tap(tester, key);
          expect(find.text(l10n.authProviderUnavailable), findsWidgets);
          expect(repository.currentUser, isNull);
        }
        await tap(tester, 'auth_forgot_password');
        expect(find.text(l10n.authForgotTitle), findsOneWidget);
 expect(find.text(l10n.authForgotMessage), findsOneWidget);
        await tap(tester, 'recovery_login');
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(LoginPage), findsOneWidget);
      },
    );
  }

  testWidgets(
    'Android Back and visible Back preserve the expected route stack',
    (tester) async {
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.login,
        locale: const Locale('en'),
        size: const Size(390, 844),
      );
      await enter(tester, 'login_email', 'preserved@example.com');
      await tap(tester, 'auth_open_signup');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('login_email')).controller!.text,
        'preserved@example.com',
      );
      await tap(tester, 'auth_open_signup');
      await tap(tester, 'auth_open_login');
      expect(find.byType(LoginPage), findsOneWidget);
      await tap(tester, 'auth_open_signup');
      await tap(tester, 'auth_back');
      expect(find.byType(LoginPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
      app.router.go(AppRoutes.signUp);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        app.router.routeInformationProvider.value.uri.path,
        AppRoutes.login,
      );
    },
  );

  for (final signup in [false, true]) {
    for (final provider in AuthProvider.values) {
      testWidgets(
        '${provider.name} success on ${signup ? 'Sign Up' : 'Login'} uses the existing session route',
        (tester) async {
          final repository = ControlledAuthRepository();
          final app = await pumpApp(
            tester,
            initialLocation: signup ? AppRoutes.signUp : AppRoutes.login,
            locale: Locale(provider == AuthProvider.google ? 'en' : 'ar'),
            size: const Size(390, 844),
            authRepository: repository,
          );
          final button = keyed('auth_${provider.name}');
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pump();
          expect(repository.providerRequests, [provider]);
          expect(repository.registrationCalls, 0);
          expect(repository.signInCalls, 0);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          for (final key in ['auth_google', 'auth_apple']) {
            expect(tester.widget<OutlinedButton>(keyed(key)).onPressed, isNull);
          }
          repository.providerResult.complete(
            const AuthUser(
              id: 'provider-user',
              fullName: 'Sam',
              email: 'sam@example.com',
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(HomePage), findsOneWidget);
          expect(
            find.text(messages(tester).authWelcome('Sam')),
            findsOneWidget,
          );
          expect(
            app.router.routeInformationProvider.value.uri.path,
            AppRoutes.home,
          );
          expect(app.router.canPop(), isFalse);
        },
      );
    }
  }

  for (final signup in [false, true]) {
    testWidgets(
      '${signup ? 'registration' : 'login'} disables input, submit and navigation while loading',
      (tester) async {
        final repository = ControlledAuthRepository();
        await pumpApp(
          tester,
          initialLocation: signup ? AppRoutes.signUp : AppRoutes.login,
          locale: const Locale('en'),
          size: const Size(390, 844),
          authRepository: repository,
        );
        if (signup) {
          await fillSignup(tester);
        } else {
          await enter(tester, 'login_email', 'amina@example.com');
          await enter(tester, 'login_password', 'demo-password');
        }
        final submit = keyed(signup ? 'signup_submit' : 'login_submit');
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
        for (final widget in tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        )) {
          expect(widget.enabled, isFalse);
        }
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(
          signup ? find.byType(SignUpPage) : find.byType(LoginPage),
          findsOneWidget,
        );
        (signup ? repository.registrationResult : repository.signInResult)
            .completeError(const AuthException(AuthFailure.unavailable));
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text(messages(tester).authUnavailable), findsWidgets);
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
      },
    );
  }

  testWidgets(
    'duplicate registration can be corrected and direct sign-up opens preferences',
    (tester) async {
      final repository = TestAuthRepository(delay: Duration.zero);
      await tester.runAsync(
        () => repository.register(
          fullName: 'Original',
          email: 'amina@example.com',
          password: 'original-password',
        ),
      );
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.signUp,
        locale: const Locale('en'),
        size: const Size(390, 844),
        authRepository: repository,
      );
      await fillSignup(tester);
      await tap(tester, 'signup_submit');
      expect(find.text(messages(tester).authEmailInUse), findsWidgets);
      expect(find.byType(SignUpPage), findsOneWidget);
      await enter(tester, 'signup_email', 'new@example.com');
      await tap(tester, 'signup_submit');
      expect(find.byType(CareerPreferencesPage), findsOneWidget);
      expect(repository.currentUser!.email, 'new@example.com');
      expect(app.router.canPop(), isFalse);
    },
  );

  testWidgets(
    'language and theme switches preserve entered text and translate errors',
    (tester) async {
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.signUp,
        locale: const Locale('en'),
        size: const Size(390, 844),
      );
      await enter(tester, 'signup_name', 'Amina Hassan');
      await tap(tester, 'signup_submit');
      app.settings
        ..setLocale(const Locale('ar'))
        ..setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(field('signup_name')).controller!.text,
        'Amina Hassan',
      );
      expect(find.text(messages(tester).authEmailRequired), findsOneWidget);
      final context = tester.element(find.byType(SignUpPage));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        const Color(0xFF090B0F),
      );
      expect(
        app.router.routeInformationProvider.value.uri.path,
        AppRoutes.signUp,
      );
    },
  );

  testWidgets('authenticated auth routes stay guarded without redirect loops', (tester) async {
    final repository = ControlledAuthRepository()
      ..currentUser = const AuthUser(id: 'user', fullName: 'Sam', email: 'sam@example.com');
    final app = await pumpApp(tester, initialLocation: AppRoutes.login, authRepository: repository);
    expect(find.byType(HomePage), findsOneWidget);
    for (final route in [AppRoutes.login, AppRoutes.forgotPassword, AppRoutes.resetPassword]) {
      app.router.go(route);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(app.router.canPop(), isFalse);
    }
  });
}
