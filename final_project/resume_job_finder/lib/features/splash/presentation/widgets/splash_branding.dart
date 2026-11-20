import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/intro_assets.dart';
import '../../../../core/localization/l10n_extension.dart';

class SplashBranding extends StatelessWidget {
  const SplashBranding({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: ExcludeSemantics(
            child: SizedBox.square(
              dimension: 47,
              child: SvgPicture.asset(IntroAssets.sparkBlue),
            ),
          ),
        ),
        const SizedBox(height: 44),
        Semantics(
          header: true,
          child: Column(
            children: [
              _BrandLine(text: l10n.splashBrandFirst, size: 27),
              _BrandLine(text: l10n.splashBrandSecond, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 21),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: Center(
            child: Text(
              l10n.splashTagline,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFFE5F2FF),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandLine extends StatelessWidget {
  const _BrandLine({required this.text, required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 37),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: size,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
