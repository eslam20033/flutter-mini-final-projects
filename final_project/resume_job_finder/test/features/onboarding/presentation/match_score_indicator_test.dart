import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/core/theme/app_colors.dart';
import 'package:resume_job_finder/core/theme/app_theme.dart';
import 'package:resume_job_finder/features/onboarding/presentation/widgets/match_score_indicator.dart';
import 'package:resume_job_finder/features/onboarding/presentation/widgets/matching_illustration.dart';
import 'package:resume_job_finder/l10n/generated/app_localizations.dart';

import '../../../support/app_test_harness.dart';

Widget host(
  Widget child, {
  Locale locale = const Locale('en'),
  bool dark = false,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: dark ? AppTheme.dark : AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(loadDesignFonts);

  for (final language in ['en', 'ar']) {
    for (final dark in [false, true]) {
      testWidgets('92% paints one continuous arc in $language dark=$dark', (
        tester,
      ) async {
        final key = GlobalKey();
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            host(
              RepaintBoundary(
                key: key,
                child: const MatchScoreIndicator(percentage: 92),
              ),
              locale: Locale(language),
              dark: dark,
            ),
          );
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(MatchScoreIndicator));
          final l10n = AppLocalizations.of(context);
          expect(find.text(l10n.introMatchPercentage(0.92)), findsOneWidget);
          expect(find.bySemanticsLabel(l10n.introMatchLabel), findsOneWidget);
          expect(
            tester.getSize(find.byType(MatchScoreIndicator)),
            const Size(80, 80),
          );
          final indicator = tester.widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
          expect(indicator.strokeCap, StrokeCap.round);

          // Sample the painted stroke around its circumference, not just widget
          // configuration. A segmented SVG or gapped arc fails this regression.
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            int pixelAt(double degrees) {
              final radians = (degrees - 90) * math.pi / 180;
              final x = (40 + 37 * math.cos(radians)).round();
              final y = (40 + 37 * math.sin(radians)).round();
              final offset = (y * image.width + x) * 4;
              return Color.fromARGB(
                bytes.getUint8(offset + 3),
                bytes.getUint8(offset),
                bytes.getUint8(offset + 1),
                bytes.getUint8(offset + 2),
              ).toARGB32();
            }

            for (var degrees = 10; degrees <= 320; degrees += 10) {
              expect(
                pixelAt(degrees.toDouble()),
                AppColors.matchSuccess.toARGB32(),
                reason:
                    'The progress arc must be continuous at $degrees degrees.',
              );
            }
            expect(
              pixelAt(344),
              Theme.of(context).colorScheme.outlineVariant.toARGB32(),
              reason: 'The remaining percentage must show the neutral track.',
            );
            image.dispose();
          });
        } finally {
          semantics.dispose();
        }
      });
    }
  }

  testWidgets('percentage input updates the arc and centered label', (
    tester,
  ) async {
    for (final percentage in [0, 50, 100]) {
      await tester.pumpWidget(
        host(MatchScoreIndicator(percentage: percentage)),
      );
      await tester.pumpAndSettle();
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, percentage / 100);
      expect(find.text('$percentage%'), findsOneWidget);
      final scoreCenter = tester.getCenter(find.text('$percentage%'));
      final ringCenter = tester.getCenter(
        find.byType(CircularProgressIndicator),
      );
      expect(scoreCenter.dx, ringCenter.dx);
      expect(tester.takeException(), isNull);
    }
  });

  for (final language in ['en', 'ar']) {
    for (final dark in [false, true]) {
      testWidgets('missing and invalid scores remain neutral $language $dark', (
        tester,
      ) async {
        for (final score in [null, -1, 101]) {
          await tester.pumpWidget(
            host(
              MatchScoreIndicator(percentage: score),
              locale: Locale(language),
              dark: dark,
            ),
          );
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(MatchScoreIndicator));
          final l10n = AppLocalizations.of(context);
          expect(find.text(l10n.introMatchUnavailable), findsOneWidget);
          expect(find.text('—'), findsNothing);
          expect(
            tester
                .widget<CircularProgressIndicator>(
                  find.byType(CircularProgressIndicator),
                )
                .value,
            0,
          );
          final label = tester.getRect(find.text(l10n.introMatchUnavailable));
          final ring = tester.getRect(find.byType(CircularProgressIndicator));
          expect(ring.deflate(6).contains(label.topLeft), isTrue);
          expect(ring.deflate(6).contains(label.bottomRight), isTrue);
          expect(tester.takeException(), isNull);
        }
      });

      for (final size in [const Size(320, 568), const Size(390, 844)]) {
        testWidgets(
          'opportunity circle stays inside card $language $dark $size large text',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = 2;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            await tester.pumpWidget(
              host(
                const MatchingIllustration(),
                locale: Locale(language),
                dark: dark,
              ),
            );
            await tester.pumpAndSettle();
            final card = tester.getRect(
              find.byKey(const ValueKey('recommended_opportunity_card')),
            );
            final ring = tester.getRect(find.byType(CircularProgressIndicator));
            final l10n = AppLocalizations.of(
              tester.element(find.byType(MatchingIllustration)),
            );
            final subtitle = tester.getRect(find.text(l10n.introJobExample));
            expect(ring.width, closeTo(ring.height, 0.01));
            expect(card.deflate(10).contains(ring.topLeft), isTrue);
            expect(card.deflate(10).contains(ring.bottomRight), isTrue);
            expect(ring.top - subtitle.bottom, greaterThan(8));
            expect(tester.takeException(), isNull);

            // Outside the fixed illustration canvas, the reusable score grows
            // with accessibility text size rather than clipping its label.
            await tester.pumpWidget(
              host(
                const MatchScoreIndicator(percentage: 100),
                locale: Locale(language),
                dark: dark,
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.getSize(find.byType(MatchScoreIndicator)),
              const Size(160, 160),
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
