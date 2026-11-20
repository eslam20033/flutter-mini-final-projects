import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Controllers and focus nodes are owned and disposed by the calling widget.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.autofillHints,
    this.obscureText = false,
    this.autocorrect,
    this.enableSuggestions,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    super.key,
  }) : assert(controller == null || initialValue == null),
       assert(!obscureText || maxLines == 1);

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? hint;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final bool enabled;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Announce the label with the field instead of twice.
        ExcludeSemantics(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            focusNode: focusNode,
            validator: validator,
            onChanged: onChanged,
            onSaved: onSaved,
            onFieldSubmitted: onFieldSubmitted,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textDirection: textDirection,
            textAlign: TextAlign.start,
            style: theme.textTheme.bodyMedium,
            autofillHints: autofillHints,
            obscureText: obscureText,
            autocorrect: autocorrect ?? !obscureText,
            enableSuggestions: enableSuggestions ?? !obscureText,
            enabled: enabled,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              errorMaxLines: 8,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
