import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/core/theme/app_theme.dart';
import 'package:resume_job_finder/features/splash/presentation/pages/splash_page.dart';
import 'package:resume_job_finder/l10n/generated/app_localizations.dart';

Widget host(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: child!,
    ),
    home: child,
  );
}

void main() {
  testWidgets('splash finishes once after its intro animation', (tester) async {
    var completions = 0;
    await tester.pumpWidget(host(SplashPage(onFinished: () => completions++)));
    final l10n = AppLocalizations.of(tester.element(find.byType(SplashPage)));
    expect(
      tester.widgetList<Text>(find.byType(Text)).map((text) => text.data),
      [l10n.splashBrandFirst, l10n.splashBrandSecond, l10n.splashTagline],
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(completions, 0);
    await tester.pumpAndSettle();
    expect(completions, 1);
    await tester.pump(const Duration(seconds: 4));
    expect(completions, 1);
  });

  testWidgets('unmounting splash cancels its completion callback', (
    tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(host(SplashPage(onFinished: () => completions++)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(completions, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion skips the intro animation safely', (
    tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(
      host(SplashPage(onFinished: () => completions++), reduceMotion: true),
    );
    await tester.pump();
    expect(completions, 1);
    await tester.pump(const Duration(seconds: 3));
    expect(completions, 1);
  });
}
