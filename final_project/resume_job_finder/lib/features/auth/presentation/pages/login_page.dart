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

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.onBack,
    required this.onSignUp,
    required this.onSignedIn,
    required this.onForgotPassword,
    this.registeredEmail,
    super.key,
  });

  final VoidCallback onBack;
  final Future<String?> Function() onSignUp;
  final VoidCallback onSignedIn;
  final VoidCallback onForgotPassword;
  final String? registeredEmail;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final _email = TextEditingController(text: widget.registeredEmail);
  final _password = TextEditingController();
  late bool _registered = widget.registeredEmail != null;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().signIn(
      email: _email.text,
      password: _password.text,
    );
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    final email = await widget.onSignUp();
    if (!mounted || email == null) return;
    _email.text = email;
    _password.clear();
    context.read<AuthCubit>()
      ..clearError(AuthField.email)
      ..clearError(AuthField.password);
    setState(() => _registered = true);
  }

  void _forgotPassword() {
    FocusScope.of(context).unfocus();
    widget.onForgotPassword();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status == AuthStatus.authenticated) {
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
        title: l10n.authLoginTitle,
        subtitle: l10n.authLoginSubtitle,
        onBack: widget.onBack,
        isLoading: state.isLoading,
        children: [
          if (_registered)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.medium),
              child: Semantics(
                liveRegion: true,
                child: Text(l10n.authRegistrationSuccess),
              ),
            ),
          AppCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: const ValueKey('login_email'),
                  label: l10n.authEmail,
                  hint: l10n.authEmailHint,
                  controller: _email,
                  errorText: l10n.authFieldError(state.errors[AuthField.email]),
                  enabled: !state.isLoading,
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
                  key: const ValueKey('login_password'),
                  controller: _password,
                  label: l10n.authPassword,
                  hint: l10n.authPasswordHint,
                  enabled: !state.isLoading,
                  errorText: l10n.authFieldError(
                    state.errors[AuthField.password],
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) => cubit.clearError(AuthField.password),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    key: const ValueKey('auth_forgot_password'),
                    onPressed: state.isLoading ? null : _forgotPassword,
                    child: Text(l10n.authForgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                AppButton(
                  key: const ValueKey('login_submit'),
                  label: state.isLoading ? l10n.loading : l10n.authSignIn,
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
              Text(l10n.authNoAccount),
              TextButton(
                key: const ValueKey('auth_open_signup'),
                onPressed: state.isLoading ? null : _signUp,
                child: Text(l10n.authSignUp),
              ),
            ],
          ),
        ],
      );
    },
  );
}
