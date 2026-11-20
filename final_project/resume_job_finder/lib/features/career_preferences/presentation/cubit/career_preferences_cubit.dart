import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/career_preferences.dart';
import '../../domain/career_preferences_repository.dart';
import '../../domain/career_preferences_validation.dart';
import 'career_preferences_state.dart';

class CareerPreferencesCubit extends Cubit<CareerPreferencesState> {
  CareerPreferencesCubit(this._repository, this._userId)
    : super(const CareerPreferencesState());
  final CareerPreferencesRepository _repository;
  final String _userId;

  Future<void> load() async {
    if (isClosed || state.isBusy) return;
    emit(const CareerPreferencesState(status: CareerPreferencesStatus.loading));
    try {
      final preferences = await _repository.load(_userId);
      if (!isClosed) {
        emit(
          CareerPreferencesState(
            status: CareerPreferencesStatus.ready,
            preferences: preferences,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const CareerPreferencesState(
            status: CareerPreferencesStatus.loadFailure,
          ),
        );
      }
    }
  }

  Future<void> save({
    required String jobTitle,
    required String industry,
    required String experience,
    required String location,
    required WorkArrangement arrangement,
    required String qualifications,
    String experienceLevel = '',
  }) async {
    if (isClosed ||
        state.isBusy ||
        state.status == CareerPreferencesStatus.loadFailure ||
        state.status == CareerPreferencesStatus.initial) {
      return;
    }
    final errors = CareerPreferencesValidation.validate(
      jobTitle: jobTitle,
      industry: industry,
      experience: experience,
      location: location,
      qualifications: qualifications,
      experienceLevel: experienceLevel,
    );
    if (errors.isNotEmpty) {
      emit(
        CareerPreferencesState(
          status: CareerPreferencesStatus.ready,
          preferences: state.preferences,
          errors: Map.unmodifiable(errors),
        ),
      );
      return;
    }
    final preferences = CareerPreferences(
      jobTitle: jobTitle.trim(),
      industry: industry.trim(),
      experienceYears: CareerPreferencesValidation.parseYears(experience),
      experienceLevel: experienceLevel.trim(),
      location: location.trim(),
      arrangement: arrangement,
      qualifications: qualifications.trim(),
    );
    emit(
      CareerPreferencesState(
        status: CareerPreferencesStatus.saving,
        preferences: state.preferences,
      ),
    );
    try {
      await _repository.save(_userId, preferences);
      if (!isClosed) {
        emit(
          CareerPreferencesState(
            status: CareerPreferencesStatus.saved,
            preferences: preferences,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          CareerPreferencesState(
            status: CareerPreferencesStatus.saveFailure,
            preferences: state.preferences,
          ),
        );
      }
    }
  }

  void clearError(CareerField field) {
    if (isClosed || state.isBusy) return;
    final errors = Map<CareerField, CareerValidationError>.of(state.errors)
      ..remove(field);
    emit(
      CareerPreferencesState(
        status: CareerPreferencesStatus.ready,
        preferences: state.preferences,
        errors: Map.unmodifiable(errors),
      ),
    );
  }
}
