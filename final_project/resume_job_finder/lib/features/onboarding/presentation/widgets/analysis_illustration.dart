import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/intro_assets.dart';
import '../../../../core/localization/l10n_extension.dart';
import 'illustration_canvas.dart';

class AnalysisIllustration extends StatelessWidget {
  const AnalysisIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final badges = [
      (label: l10n.introExperienceLabel, x: 30.0, y: 87.0, width: 86.0),
      (label: l10n.introSkillsLabel, x: 252.0, y: 102.0, width: 99.0),
      (label: l10n.introGoalsLabel, x: 46.0, y: 222.0, width: 66.0),
      (label: l10n.introStrengthsLabel, x: 246.0, y: 217.0, width: 104.0),
    ];
    return IllustrationCanvas(
      label: l10n.onboardingAnalysisIllustration,
      children: [
        Positioned(
          left: 111,
          top: 56,
          width: 170,
          height: 170,
          child: SvgPicture.asset(
            IntroAssets.analysisRing,
            colorFilter: dark
                ? ColorFilter.mode(
                    illustrationAccentSurface(context),
                    BlendMode.srcIn,
                  )
                : null,
          ),
        ),
        Positioned(
          left: 144,
          top: 89,
          width: 106,
          height: 106,
          child: SvgPicture.asset(
            IntroAssets.analysisCore,
            colorFilter: dark
                ? ColorFilter.mode(colors.primary, BlendMode.srcIn)
                : null,
          ),
        ),
        Positioned(
          left: 174,
          top: 118,
          width: 47,
          height: 47,
          child: SvgPicture.asset(IntroAssets.sparkWhite),
        ),
        for (final badge in badges)
          Positioned(
            left: badge.x,
            top: badge.y,
            width: badge.width,
            height: 29,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: illustrationAccentSurface(context),
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  badge.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: dark ? colors.onPrimaryContainer : colors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
