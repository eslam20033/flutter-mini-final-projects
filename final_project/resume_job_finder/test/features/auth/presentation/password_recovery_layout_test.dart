import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/auth/domain/password_recovery.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/reset_password_page.dart';

import '../../../support/app_test_harness.dart';
import 'auth_flow_test.dart' show keyed;

void main() {
  setUpAll(loadDesignFonts);
  final layouts = [
    (name: 'phone', size: const Size(390, 844), scale: 1.0, keyboard: 0.0),
    (
      name: 'compact keyboard',
      size: const Size(320, 568),
      scale: 2.0,
      keyboard: 200.0,
    ),
    (
      name: 'landscape keyboard',
      size: const Size(844, 390),
      scale: 2.0,
      keyboard: 140.0,
    ),
    (name: 'tablet', size: const Size(1024, 1366), scale: 1.0, keyboard: 0.0),
  ];
  for (final language in ['en', 'ar']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final layout in layouts) {
        testWidgets(
          'recovery screens $language ${theme.name} ${layout.name} scroll safely after validation',
          (tester) async {
            final app = await pumpApp(
              tester,
              initialLocation: AppRoutes.forgotPassword,
              locale: Locale(language),
              themeMode: theme,
              size: layout.size,
              textScale: layout.scale,
            );
            tester.view.viewInsets = FakeViewPadding(bottom: layout.keyboard);
            addTearDown(tester.view.resetViewInsets);
            await tester.pumpAndSettle();
            for (final reset in [false, true]) {
              if (reset) {
                app.router.go(
                  AppRoutes.resetPassword,
                  extra: PasswordResetRequest(
                    code: 'test-recovery-code',
                    email: 'a-very-long-address+recovery@example.com',
                  ),
                );
                await tester.pumpAndSettle();
              }
              final context = tester.element(
                reset
                    ? find.byType(ResetPasswordPage)
                    : find.byType(ForgotPasswordPage),
              );
              expect(
                Directionality.of(context),
                language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              );
              expect(
                Theme.of(context).brightness,
                theme == ThemeMode.dark ? Brightness.dark : Brightness.light,
              );
              final submit = keyed(reset ? 'reset_submit' : 'forgot_submit');
              await tester.ensureVisible(submit);
              await tester.pumpAndSettle();
              expect(submit.hitTestable(), findsOneWidget);
              await tester.tap(submit);
              await tester.pumpAndSettle();
              await tester.ensureVisible(submit);
              await tester.pumpAndSettle();
              expect(submit.hitTestable(), findsOneWidget);
              await tester.ensureVisible(keyed('recovery_login'));
              await tester.pumpAndSettle();
              expect(keyed('recovery_login').hitTestable(), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
          },
        );
      }
    }
  }
}
