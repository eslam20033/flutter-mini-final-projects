import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_validation.dart';
import '../../domain/password_recovery.dart';
import '../auth_messages.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_error_feedback.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_scaffold.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    required this.request,
    required this.onBack,
    required this.onLogin,
    super.key,
  });

  final PasswordResetRequest request;
  final VoidCallback onBack;
  final VoidCallback onLogin;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().resetPassword(
      request: widget.request,
      password: _password.text,
      confirmPassword: _confirmation.text,
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status == AuthStatus.passwordReset) {
        _password.clear();
        _confirmation.clear();
        TextInput.finishAutofillContext(shouldSave: false);
      }
    },
    builder: (context, state) {
      final l10n = context.l10n;
      final cubit = context.read<AuthCubit>();
      final success = state.status == AuthStatus.passwordReset;
      return AuthScaffold(
        title: success ? l10n.authResetSuccessTitle : l10n.authResetTitle,
        subtitle: success
            ? l10n.authResetSuccess
            : l10n.authResetSubtitle,
        onBack: success ? widget.onLogin : widget.onBack,
        isLoading: state.isLoading,
        children: [
          if (success)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.authResetSignInPrompt,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppButton(
                    key: const ValueKey('reset_success_login'),
                    label: l10n.authBackToLogin,
                    onPressed: widget.onLogin,
                  ),
                ],
              ),
            )
          else ...[
            AppCard(
              padding: const EdgeInsetsDirectional.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.request.email.isNotEmpty) ...[
                  Text(
                    l10n.authResetAccount,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(widget.request.email, textDirection: TextDirection.ltr),
                  ],
                  const SizedBox(height: AppSpacing.large),
                  AuthPasswordField(
                    key: const ValueKey('reset_password'),
                    controller: _password,
                    label: l10n.authNewPassword,
                    hint: l10n.authPasswordTooShort(
                      AuthValidation.minimumPasswordLength,
                    ),
                    enabled: !state.isLoading,
                    errorText: l10n.authFieldError(
                      state.errors[AuthField.password],
                    ),
                    onChanged: (_) => cubit.clearError(AuthField.password),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AuthPasswordField(
                    key: const ValueKey('reset_confirmation'),
                    controller: _confirmation,
                    label: l10n.authConfirmNewPassword,
                    hint: l10n.authConfirmPasswordHint,
                    enabled: !state.isLoading,
                    errorText: l10n.authFieldError(
                      state.errors[AuthField.confirmPassword],
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) =>
                        cubit.clearError(AuthField.confirmPassword),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppButton(
                    key: const ValueKey('reset_submit'),
                    label: state.isLoading
                        ? l10n.loading
                        : l10n.authResetPassword,
                    isLoading: state.isLoading,
                    onPressed: _submit,
                  ),
                  AuthErrorFeedback(failure: state.failure),
                  if (state.failure == AuthFailure.recoveryExpired)
                    TextButton(
                      key: const ValueKey('recovery_restart'),
                      onPressed: widget.onBack,
                      child: Text(l10n.authRestartRecovery),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextButton(
              key: const ValueKey('recovery_login'),
              onPressed: state.isLoading ? null : widget.onLogin,
              child: Text(l10n.authBackToLogin),
            ),
          ],
        ],
      );
    },
  );
}
