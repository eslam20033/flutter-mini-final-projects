import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../models/onboarding_step.dart';
import 'analysis_illustration.dart';
import 'matching_illustration.dart';
import 'resume_illustration.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({required this.step, super.key});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (title, message, artwork) = switch (step) {
      OnboardingStep.resume => (
        l10n.onboardingResumeTitle,
        l10n.onboardingResumeBody,
        const ResumeIllustration(),
      ),
      OnboardingStep.analysis => (
        l10n.onboardingAnalysisTitle,
        l10n.onboardingAnalysisBody,
        const AnalysisIllustration(),
      ),
      OnboardingStep.matching => (
        l10n.onboardingMatchingTitle,
        l10n.onboardingMatchingBody,
        const MatchingIllustration(),
      ),
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        // At the reference size this places artwork at y=190 and copy at y=507.
        // On smaller screens or with large text, the page scrolls vertically.
        final topSpace = math.max(16.0, (constraints.maxHeight - 451) * 0.6);
        return SingleChildScrollView(
          key: PageStorageKey(step),
          padding: EdgeInsets.only(top: topSpace, bottom: 24),
          child: Column(
            children: [
              artwork,
              const SizedBox(height: 37),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 27),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Center(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        key: ValueKey('onboarding_title_${step.index}'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 29),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 62),
                  child: Center(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
