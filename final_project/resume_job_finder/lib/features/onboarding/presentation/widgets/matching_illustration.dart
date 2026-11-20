import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/widgets/app_card.dart';
import 'illustration_canvas.dart';
import 'match_score_indicator.dart';

class MatchingIllustration extends StatelessWidget {
  const MatchingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return IllustrationCanvas(
      label: l10n.onboardingMatchingIllustration,
      children: [
        const Positioned(
          left: 67,
          top: 55,
          width: 259,
          height: 190,
          child: AppCard(
            key: ValueKey('recommended_opportunity_card'),
            padding: EdgeInsets.zero,
            child: SizedBox.expand(),
          ),
        ),
        Positioned(
          left: 90,
          top: 75,
          width: 50,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: illustrationAccentSurface(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                Icons.work_outline_rounded,
                size: 22,
                color: colors.primary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 148,
          top: 72,
          width: 154,
          height: 38,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.introJobTitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
                height: 1.2,
              ),
            ),
          ),
        ),
        Positioned(
          left: 148,
          top: 109,
          width: 155,
          height: 21,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.introJobExample,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const Positioned(
          left: 163,
          top: 141,
          width: 80,
          height: 80,
          child: MatchScoreIndicator(),
        ),
      ],
    );
  }
}
