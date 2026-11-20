import 'package:flutter/material.dart';

import '../localization/l10n_extension.dart';
import 'app_button.dart';
import 'app_empty_state.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({this.title, this.message, this.onRetry, super.key});

  final String? title;

  /// Supply a localized, user-facing message, not a raw exception.
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: title ?? context.l10n.errorTitle,
      message: message ?? context.l10n.errorMessage,
      action: onRetry == null
          ? null
          : AppButton(label: context.l10n.retry, onPressed: onRetry),
    );
  }
}
