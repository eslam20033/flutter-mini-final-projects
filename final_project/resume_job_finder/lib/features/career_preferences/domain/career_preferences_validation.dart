enum CareerField {
  jobTitle,
  industry,
  experience,
  experienceLevel,
  location,
  qualifications,
}

enum CareerValidationError { required, tooLong, invalidExperience }

abstract final class CareerPreferencesValidation {
  static int limit(CareerField field) => switch (field) {
    CareerField.qualifications => 1000,
    CareerField.location => 160,
    _ => 120,
  };

  static double? parseYears(String value) {
    var normalized = value.trim().replaceAll('٫', '.');
    for (var i = 0; i < 10; i++) {
      normalized = normalized
          .replaceAll('٠١٢٣٤٥٦٧٨٩'[i], '$i')
          .replaceAll('۰۱۲۳۴۵۶۷۸۹'[i], '$i');
    }
    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(normalized)) return null;
    return double.tryParse(normalized);
  }

  static Map<CareerField, CareerValidationError> validate({
    required String jobTitle,
    required String industry,
    required String experience,
    required String location,
    required String qualifications,
    String experienceLevel = '',
  }) {
    final errors = <CareerField, CareerValidationError>{};
    final fields = {
      CareerField.jobTitle: jobTitle,
      CareerField.industry: industry,
      CareerField.experienceLevel: experienceLevel,
      CareerField.location: location,
      CareerField.qualifications: qualifications,
    };
    for (final entry in fields.entries) {
      if (entry.value.trim().runes.length > limit(entry.key)) {
        errors[entry.key] = CareerValidationError.tooLong;
      }
    }
    if (jobTitle.trim().isEmpty) {
      errors[CareerField.jobTitle] = CareerValidationError.required;
    }
    if (experience.trim().isNotEmpty) {
      final years = parseYears(experience);
      if (years == null || !years.isFinite || years > 100) {
        errors[CareerField.experience] =
            CareerValidationError.invalidExperience;
      }
    }
    return errors;
  }
}
