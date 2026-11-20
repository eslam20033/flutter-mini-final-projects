import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/sign_up_page.dart';

import '../../../support/app_test_harness.dart';

void main() {
  setUpAll(loadDesignFonts);
  final layouts = [
    (name: 'phone', size: const Size(390, 844), scale: 1.0, keyboard: 0.0),
    (
      name: 'compact with keyboard',
      size: const Size(320, 568),
      scale: 2.0,
      keyboard: 200.0,
    ),
    (
      name: 'landscape with keyboard',
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
          '$language ${theme.name} ${layout.name} renders both auth screens without overflow',
          (tester) async {
            final app = await pumpApp(
              tester,
              initialLocation: AppRoutes.login,
              locale: Locale(language),
              themeMode: theme,
              size: layout.size,
              textScale: layout.scale,
            );
            tester.view.viewInsets = FakeViewPadding(bottom: layout.keyboard);
            addTearDown(tester.view.resetViewInsets);
            await tester.pumpAndSettle();
            for (final signup in [false, true]) {
              if (signup) {
                app.router.go(AppRoutes.signUp);
                await tester.pumpAndSettle();
              }
              final context = tester.element(
                signup ? find.byType(SignUpPage) : find.byType(LoginPage),
              );
              expect(
                Directionality.of(context),
                language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              );
              expect(
                Theme.of(context).brightness,
                theme == ThemeMode.dark ? Brightness.dark : Brightness.light,
              );
              final submit = find.byKey(
                ValueKey(signup ? 'signup_submit' : 'login_submit'),
              );
              expect(
                find.textContaining(
                  RegExp(r'demo|تجريب', caseSensitive: false),
                ),
                findsNothing,
              );
              await tester.ensureVisible(submit);
              await tester.pumpAndSettle();
              expect(submit.hitTestable(), findsOneWidget);
              await tester.tap(submit);
              await tester.pumpAndSettle();
              // Validation grows fields; the action must remain reachable.
              await tester.ensureVisible(submit);
              await tester.pumpAndSettle();
              expect(submit.hitTestable(), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
          },
        );
      }
    }
  }
}
