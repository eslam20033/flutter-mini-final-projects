import 'career_preferences.dart';

class CareerPreferencesUnavailable implements Exception {
  const CareerPreferencesUnavailable();
}

abstract interface class CareerPreferencesRepository {
  /// Return null only when the authenticated user's document does not exist.
  /// Throw on unavailable storage. Enforce ownership in the backend as well.
  Future<CareerPreferences?> load(String userId);
  Future<void> save(String userId, CareerPreferences preferences);
}
