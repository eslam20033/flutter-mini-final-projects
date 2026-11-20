import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/auth_repository.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final bool enabled;
  final ValueChanged<AuthProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.medium,
                ),
                child: Text(
                  l10n.authOrContinueWith,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('auth_google'),
                onPressed: enabled
                    ? () => onSelected(AuthProvider.google)
                    : null,
                child: Text(l10n.authGoogle),
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('auth_apple'),
                onPressed: enabled
                    ? () => onSelected(AuthProvider.apple)
                    : null,
                child: Text(l10n.authApple),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
