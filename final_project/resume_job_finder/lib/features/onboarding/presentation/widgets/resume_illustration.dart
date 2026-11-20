import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import 'illustration_canvas.dart';

class ResumeIllustration extends StatelessWidget {
  const ResumeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pale = illustrationAccentSurface(context);
    return IllustrationCanvas(
      label: context.l10n.onboardingResumeIllustration,
      children: [
        Positioned(
          left: 99,
          top: 53,
          width: 194,
          height: 203,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        Positioned(
          left: 118,
          top: 77,
          width: 49,
          height: 49,
          child: DecoratedBox(
            decoration: BoxDecoration(color: pale, shape: BoxShape.circle),
          ),
        ),
        Positioned(
          left: 131,
          top: 89,
          width: 22,
          height: 22,
          // Figma's resume icon export was blocked by its plan limit.
          child: Icon(
            Icons.person_outline_rounded,
            size: 22,
            color: colors.primary,
          ),
        ),
        for (final line in [
          (top: 150.0, width: 103.0),
          (top: 174.0, width: 152.0),
          (top: 198.0, width: 122.0),
        ])
          Positioned(
            left: 121,
            top: line.top,
            width: line.width,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: pale,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        Positioned(
          left: 228,
          top: 203,
          width: 77,
          height: 69,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                context.l10n.introCvLabel,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
