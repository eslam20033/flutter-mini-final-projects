import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';

/// Displays a supplied percentage. It does not calculate a matching result.
class MatchScoreIndicator extends StatelessWidget {
  const MatchScoreIndicator({this.percentage, super.key});

  final int? percentage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final score = percentage;
    final valid = score != null && score >= 0 && score <= 100;
    final value = valid
        ? l10n.introMatchPercentage(score / 100)
        : l10n.introMatchUnavailable;
    final dimension = 80 * MediaQuery.textScalerOf(context).scale(14) / 14;
    return Semantics(
      label: l10n.introMatchLabel,
      value: value,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: dimension,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: valid ? score / 100 : 0,
                  strokeWidth: 6,
                  strokeAlign: CircularProgressIndicator.strokeAlignInside,
                  strokeCap: StrokeCap.round,
                  trackGap: 0,
                  padding: EdgeInsets.zero,
                  backgroundColor: colors.outlineVariant,
                  color: AppColors.matchSuccess,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: valid ? 20 : 11,
                        fontWeight: FontWeight.w700,
                        color: valid
                            ? AppColors.matchSuccess
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      l10n.introMatchLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
