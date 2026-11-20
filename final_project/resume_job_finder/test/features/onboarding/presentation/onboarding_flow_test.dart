import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:resume_job_finder/features/onboarding/presentation/widgets/onboarding_indicators.dart';
import 'package:resume_job_finder/l10n/generated/app_localizations.dart';

import '../../../support/app_test_harness.dart';

void main() {
  setUpAll(loadDesignFonts);

  int page(WidgetTester tester) => tester
      .widget<OnboardingIndicators>(find.byType(OnboardingIndicators))
      .currentPage;

  testWidgets('Next advances each slide and Get Started opens Login', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      initialLocation: AppRoutes.onboarding,
      locale: const Locale('en'),
      size: const Size(390, 844),
    );
    expect(page(tester), 0);

    await tester.tap(find.byKey(const ValueKey('onboarding_next')));
    await tester.pumpAndSettle();
    expect(page(tester), 1);
    expect(find.text('Understand your strengths'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding_next')));
    await tester.pumpAndSettle();
    expect(page(tester), 2);
    expect(
      find.byKey(const ValueKey('onboarding_get_started')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('onboarding_get_started')));
    await tester.pumpAndSettle();
    expect(app.router.routeInformationProvider.value.uri.path, AppRoutes.login);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(app.router.canPop(), isFalse);
    expect(find.byType(OnboardingPage), findsNothing);
  });

  for (final steps in [0, 2]) {
    testWidgets(
      'Skip from slide ${steps + 1} exits without a navigation loop',
      (tester) async {
        final app = await pumpApp(
          tester,
          initialLocation: AppRoutes.onboarding,
          locale: const Locale('en'),
        );
        for (var index = 0; index < steps; index++) {
          await tester.tap(find.byKey(const ValueKey('onboarding_next')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('onboarding_skip')));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        expect(find.byType(LoginPage), findsOneWidget);
        expect(
          app.router.routeInformationProvider.value.uri.path,
          AppRoutes.login,
        );
        expect(app.router.canPop(), isFalse);
      },
    );
  }

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets(
      'illustrations use career-neutral localized content in ${locale.languageCode}',
      (tester) async {
        await pumpApp(
          tester,
          initialLocation: AppRoutes.onboarding,
          locale: locale,
        );
        await tester.tap(find.byKey(const ValueKey('onboarding_next')));
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(OnboardingPage));
        final l10n = AppLocalizations.of(context);
        for (final label in [
          l10n.introExperienceLabel,
          l10n.introSkillsLabel,
          l10n.introGoalsLabel,
          l10n.introStrengthsLabel,
        ]) {
          expect(find.text(label), findsOneWidget);
        }
        await tester.tap(find.byKey(const ValueKey('onboarding_next')));
        await tester.pumpAndSettle();
        expect(find.text(l10n.introJobTitle), findsOneWidget);
        expect(find.text(l10n.introJobExample), findsOneWidget);
        expect(find.text('Flutter Developer'), findsNothing);
        expect(
          Directionality.of(tester.element(find.text(l10n.introJobTitle))),
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
      },
    );

    testWidgets('swipes, indicators and Back work in ${locale.languageCode}', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpApp(
          tester,
          initialLocation: AppRoutes.onboarding,
          locale: locale,
          size: const Size(390, 844),
        );
        final rtl = locale.languageCode == 'ar';
        final actionFlags = tester
            .getSemantics(find.byKey(const ValueKey('onboarding_next')))
            .getSemanticsData()
            .flagsCollection;
        expect(actionFlags.isButton, isTrue);
        expect(actionFlags.isImage, isFalse);
        await tester.drag(
          find.byKey(const ValueKey('onboarding_pages')),
          Offset(rtl ? 300 : -300, 0),
        );
        await tester.pumpAndSettle();
        expect(page(tester), 1);
        expect(
          find.bySemanticsLabel(rtl ? 'الصفحة 2 من 3' : 'Page 2 of 3'),
          findsOneWidget,
        );

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(page(tester), 0);
        expect(find.byType(OnboardingPage), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });
  }

  testWidgets('rapid Next taps cannot skip a slide', (tester) async {
    await pumpApp(tester, initialLocation: AppRoutes.onboarding);
    final next = find.byKey(const ValueKey('onboarding_next'));
    await tester.tap(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(page(tester), 1);
  });

  testWidgets('changing language and theme preserves the current slide', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      initialLocation: AppRoutes.onboarding,
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
    );
    await tester.tap(find.byKey(const ValueKey('onboarding_next')));
    await tester.pumpAndSettle();
    app.settings
      ..setLocale(const Locale('ar'))
      ..setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(page(tester), 1);
    expect(find.text('اعرف نقاط قوتك ومهاراتك'), findsOneWidget);
    final context = tester.element(find.byType(OnboardingPage));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Theme.of(context).scaffoldBackgroundColor, const Color(0xFF090B0F));
    expect(
      app.router.routeInformationProvider.value.uri.path,
      AppRoutes.onboarding,
    );
  });

  testWidgets('Login Back replays onboarding from the first slide', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      initialLocation: AppRoutes.onboarding,
      locale: const Locale('en'),
    );
    await tester.tap(find.byKey(const ValueKey('onboarding_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onboarding_skip')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('auth_back')));
    await tester.pumpAndSettle();
    expect(page(tester), 0);
    expect(
      app.router.routeInformationProvider.value.uri.path,
      AppRoutes.onboarding,
    );
  });
}
