import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/intro_assets.dart';
import '../../../../core/theme/app_colors.dart';

Color illustrationAccentSurface(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? Color.alphaBlend(
          theme.colorScheme.primary.withValues(alpha: 0.14),
          theme.colorScheme.surface,
        )
      : AppColors.lightPale;
}

/// The artwork has a 390 x 280 design canvas, distinct from responsive page UI.
/// Its sample labels behave like an image; the full description is accessible.
class IllustrationCanvas extends StatelessWidget {
  const IllustrationCanvas({
    required this.label,
    required this.children,
    super.key,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(1.0, constraints.maxWidth / 390);
            return SizedBox(
              height: 280 * scale,
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.contain,
                child: MediaQuery.withNoTextScaling(
                  child: SizedBox(
                    width: 390,
                    height: 280,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 64,
                          top: 11,
                          width: 260,
                          height: 260,
                          child: SvgPicture.asset(
                            IntroAssets.illustrationCircle,
                            colorFilter: dark
                                ? ColorFilter.mode(
                                    illustrationAccentSurface(context),
                                    BlendMode.srcIn,
                                  )
                                : null,
                          ),
                        ),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
