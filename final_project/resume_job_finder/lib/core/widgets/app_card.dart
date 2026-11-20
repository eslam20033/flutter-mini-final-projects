import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The parent controls spacing between cards.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.medium),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding, child: child),
  );
}
