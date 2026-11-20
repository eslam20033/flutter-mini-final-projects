import '../../domain/career_preferences.dart';
import '../../domain/career_preferences_validation.dart';

enum CareerPreferencesStatus {
  initial,
  loading,
  ready,
  saving,
  saved,
  loadFailure,
  saveFailure,
}

class CareerPreferencesState {
  const CareerPreferencesState({
    this.status = CareerPreferencesStatus.initial,
    this.preferences,
    this.errors = const {},
  });

  final CareerPreferencesStatus status;
  final CareerPreferences? preferences;
  final Map<CareerField, CareerValidationError> errors;
  bool get isBusy =>
      status == CareerPreferencesStatus.loading ||
      status == CareerPreferencesStatus.saving;
}
