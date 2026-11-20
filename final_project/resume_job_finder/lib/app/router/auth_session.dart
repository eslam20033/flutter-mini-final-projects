import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/auth_user.dart';

/// Router bridge for restoration and provider-driven expiry/account changes.
/// The DI container owns this subscription and disposes it after the router.
class AuthSession extends ChangeNotifier {
  AuthSession(this.repository) {
    _subscription = repository.userChanges.listen(
      (user) {
        if (_disposed) return;
        this.user = user;
        notifyListeners();
      },
      onError: (Object error, StackTrace stack) {
        if (_disposed) return;
        user = null;
        failed = true;
        notifyListeners();
      },
    );
    unawaited(restore());
  }

  final AuthRepository repository;
  late final StreamSubscription<AuthUser?> _subscription;
  AuthUser? user;
  bool ready = false;
  bool failed = false;
  bool introductionFinished = false;
  String? pendingLocation;
  bool _restoring = false;
  bool _disposed = false;

  Future<void> restore() async {
    if (_restoring || _disposed) return;
    _restoring = true;
    ready = false;
    failed = false;
    notifyListeners();
    try {
      await repository.restoreSession();
      if (_disposed) return;
      user = repository.currentUser;
      ready = true;
    } catch (_) {
      if (_disposed) return;
      user = null;
      failed = true;
    } finally {
      _restoring = false;
      if (!_disposed) notifyListeners();
    }
  }

  void finishIntroduction() {
    introductionFinished = true;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
