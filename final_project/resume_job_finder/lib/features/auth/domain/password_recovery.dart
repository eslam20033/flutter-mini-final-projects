/// Input for the reset form. This is not proof of identity or verification.
/// A real adapter must validate [code] with its provider before changing anything.
final class PasswordResetRequest {
  const PasswordResetRequest({required this.code, this.email = ''});

  final String email;
  final String code;
}
