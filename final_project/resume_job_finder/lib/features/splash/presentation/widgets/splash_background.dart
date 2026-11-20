import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/intro_assets.dart';
import '../../../../core/theme/app_colors.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [
                  theme.scaffoldBackgroundColor,
                  Color.alphaBlend(
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    theme.scaffoldBackgroundColor,
                  ),
                ]
              : [AppColors.splashBlueStart, AppColors.splashBlueEnd],
        ),
      ),
      child: ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 390,
              height: 844,
              child: Stack(
                children: [
                  Positioned(
                    left: -86,
                    top: 450,
                    width: 300,
                    height: 300,
                    child: SvgPicture.asset(IntroAssets.splashCircleLarge),
                  ),
                  Positioned(
                    left: 242,
                    top: 65,
                    width: 244,
                    height: 244,
                    child: SvgPicture.asset(IntroAssets.splashCircleSmall),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
