import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/auth_password_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_social_buttons.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    required this.onBack,
    required this.onRegistered,
    required this.onSignedIn,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onRegistered;
  final VoidCallback onSignedIn;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().register(
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
      confirmPassword: _confirmation.text,
      signInAfterRegistration: true,
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status == AuthStatus.registered) {
        TextInput.finishAutofillContext(shouldSave: false);
        widget.onRegistered(state.user!.email);
      } else if (state.status == AuthStatus.authenticated) {
        TextInput.finishAutofillContext(shouldSave: false);
        widget.onSignedIn();
      } else if (state.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.authFailureMessage(state.failure!)),
            ),
          );
      }
    },
    builder: (context, state) {
      final l10n = context.l10n;
      final cubit = context.read<AuthCubit>();
      return AuthScaffold(
        title: l10n.authSignupTitle,
        subtitle: l10n.authSignupSubtitle,
        onBack: widget.onBack,
        isLoading: state.isLoading,
        children: [
          AppCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const ValueKey('signup_name'),
                  label: l10n.authFullName,
                  hint: l10n.authFullNameHint,
                  controller: _name,
                  enabled: !state.isLoading,
                  errorText: l10n.authFieldError(
                    state.errors[AuthField.fullName],
                  ),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  onChanged: (_) => cubit.clearError(AuthField.fullName),
                ),
                const SizedBox(height: AppSpacing.medium),
                AppTextField(
                  key: const ValueKey('signup_email'),
                  label: l10n.authEmail,
                  hint: l10n.authEmailHint,
                  controller: _email,
                  enabled: !state.isLoading,
                  errorText: l10n.authFieldError(state.errors[AuthField.email]),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  autocorrect: false,
                  enableSuggestions: false,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  onChanged: (_) => cubit.clearError(AuthField.email),
                ),
                const SizedBox(height: AppSpacing.medium),
                AuthPasswordField(
                  key: const ValueKey('signup_password'),
                  controller: _password,
                  label: l10n.authPassword,
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
                  key: const ValueKey('signup_confirmation'),
                  controller: _confirmation,
                  label: l10n.authConfirmPassword,
                  hint: l10n.authConfirmPasswordHint,
                  enabled: !state.isLoading,
                  errorText: l10n.authFieldError(
                    state.errors[AuthField.confirmPassword],
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) => cubit.clearError(AuthField.confirmPassword),
                ),
                const SizedBox(height: AppSpacing.large),
                AppButton(
                  key: const ValueKey('signup_submit'),
                  label: state.isLoading ? l10n.loading : l10n.authSignUp,
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
                AuthErrorFeedback(failure: state.failure),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          AuthSocialButtons(
            enabled: !state.isLoading,
            onSelected: cubit.signInWithProvider,
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l10n.authHaveAccount),
              TextButton(
                key: const ValueKey('auth_open_login'),
                onPressed: state.isLoading ? null : widget.onBack,
                child: Text(l10n.authSignIn),
              ),
            ],
          ),
        ],
      );
    },
  );
}
