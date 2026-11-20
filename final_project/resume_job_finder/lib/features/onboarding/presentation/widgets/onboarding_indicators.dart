import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/intro_assets.dart';
import '../../../../core/localization/l10n_extension.dart';

class OnboardingIndicators extends StatelessWidget {
  const OnboardingIndicators({
    required this.currentPage,
    required this.pageCount,
    super.key,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      key: const ValueKey('onboarding_indicators'),
      liveRegion: true,
      label: context.l10n.onboardingPageLabel(currentPage + 1, pageCount),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < pageCount; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              SizedBox.square(
                key: ValueKey('onboarding_indicator_$index'),
                dimension: 8,
                child: SvgPicture.asset(
                  index == currentPage
                      ? IntroAssets.indicatorActive
                      : IntroAssets.indicatorInactive,
                  colorFilter: ColorFilter.mode(
                    index == currentPage
                        ? colors.primary
                        : colors.outlineVariant,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
