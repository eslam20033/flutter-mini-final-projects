import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../app_settings/presentation/widgets/app_settings_button.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.isLoading,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final bool isLoading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !isLoading) onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [AppSettingsButton(enabled: !isLoading)],
          leading: IconButton(
            key: const ValueKey('auth_back'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: isLoading ? null : onBack,
            icon: const BackButtonIcon(),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AutofillGroup(
                onDisposeAction: AutofillContextAction.cancel,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.page,
                    12,
                    AppSpacing.page,
                    AppSpacing.large,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
