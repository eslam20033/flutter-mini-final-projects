import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/auth_validation.dart';
import '../auth_messages.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_error_feedback.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    required this.onBack,
    super.key,
  });

  final VoidCallback onBack;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().requestPasswordRecovery(email: _email.text);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      final l10n = context.l10n;
      final cubit = context.read<AuthCubit>();
      final instructionsRequested = state.status == AuthStatus.recoveryRequested;
      return AuthScaffold(
        title: l10n.authForgotTitle,
        subtitle: l10n.authForgotMessage,
        onBack: widget.onBack,
        isLoading: state.isLoading,
        children: [
          AppCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const ValueKey('forgot_email'),
                  label: l10n.authEmail,
                  hint: l10n.authEmailHint,
                  controller: _email,
                  errorText: l10n.authFieldError(state.errors[AuthField.email]),
                  enabled: !state.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  textDirection: TextDirection.ltr,
                  autocorrect: false,
                  enableSuggestions: false,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  onChanged: (_) => cubit.clearError(AuthField.email),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.large),
                AppButton(
                  key: const ValueKey('forgot_submit'),
                  label: state.isLoading
                      ? l10n.loading
                      : l10n.authSendResetInstructions,
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
                AuthErrorFeedback(failure: state.failure),
                if (instructionsRequested)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.medium),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(l10n.authRecoveryInstructionsRequested),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextButton(
            key: const ValueKey('recovery_login'),
            onPressed: state.isLoading ? null : widget.onBack,
            child: Text(l10n.authBackToLogin),
          ),
        ],
      );
    },
  );
}
