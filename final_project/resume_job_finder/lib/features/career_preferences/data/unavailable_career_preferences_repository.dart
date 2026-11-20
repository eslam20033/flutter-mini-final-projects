import '../domain/career_preferences.dart';
import '../domain/career_preferences_repository.dart';

class UnavailableCareerPreferencesRepository implements CareerPreferencesRepository {
  @override
  Future<CareerPreferences?> load(String userId) async =>
      throw const CareerPreferencesUnavailable();

  @override
  Future<void> save(String userId, CareerPreferences preferences) async =>
      throw const CareerPreferencesUnavailable();
}
