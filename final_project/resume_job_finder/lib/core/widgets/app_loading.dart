import 'package:flutter/material.dart';

import '../localization/l10n_extension.dart';
import '../theme/app_spacing.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.large),
        child: Semantics(
          label: label ?? context.l10n.loading,
          liveRegion: true,
          child: const ExcludeSemantics(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
