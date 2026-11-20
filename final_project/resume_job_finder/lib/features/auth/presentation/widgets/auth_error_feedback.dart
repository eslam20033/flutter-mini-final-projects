import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../domain/auth_repository.dart';
import '../auth_messages.dart';

class AuthErrorFeedback extends StatelessWidget {
  const AuthErrorFeedback({required this.failure, super.key});

  final AuthFailure? failure;

  @override
  Widget build(BuildContext context) => failure == null
      ? const SizedBox.shrink()
      : Semantics(
          liveRegion: true,
          child: AppErrorState(
            title: context.l10n.authFailureTitle,
            message: context.l10n.authFailureMessage(failure!),
          ),
        );
}
