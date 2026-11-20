import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/widgets/app_text_field.dart';

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.enabled,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: widget.controller,
    label: widget.label,
    hint: widget.hint,
    errorText: widget.errorText,
    enabled: widget.enabled,
    obscureText: _obscured,
    autocorrect: false,
    enableSuggestions: false,
    keyboardType: TextInputType.visiblePassword,
    textInputAction: widget.textInputAction,
    onFieldSubmitted: widget.onSubmitted,
    onChanged: widget.onChanged,
    prefixIcon: const Icon(Icons.lock_outline_rounded),
    suffixIcon: IconButton(
      tooltip: _obscured
          ? context.l10n.authShowPassword
          : context.l10n.authHidePassword,
      onPressed: widget.enabled
          ? () => setState(() => _obscured = !_obscured)
          : null,
      icon: Icon(
        _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    ),
  );
}
