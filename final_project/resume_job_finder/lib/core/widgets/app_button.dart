import 'package:flutter/material.dart';

import '../localization/l10n_extension.dart';
import '../theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailing,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  /// Optional decorative end adornment in a bounded-width layout.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: trailing == null
          ? _content(context)
          : Row(
              children: [
                const SizedBox(width: 20),
                Expanded(child: Center(child: _content(context))),
                SizedBox.square(
                  dimension: 20,
                  child: ExcludeSemantics(child: trailing!),
                ),
              ],
            ),
    );
  }

  Widget _content(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              semanticsLabel: context.l10n.loading,
            ),
          ),
          const SizedBox(width: AppSpacing.small),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.small),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }
}
