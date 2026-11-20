import '../../../l10n/generated/app_localizations.dart';
import '../domain/career_preferences.dart';
import '../domain/career_preferences_validation.dart';

extension CareerPreferencesMessages on AppLocalizations {
  String arrangementLabel(WorkArrangement value) => switch (value) {
    WorkArrangement.any => careerArrangementAny,
    WorkArrangement.onSite => careerArrangementOnSite,
    WorkArrangement.hybrid => careerArrangementHybrid,
    WorkArrangement.remote => careerArrangementRemote,
  };

  String? careerError(CareerField field, CareerValidationError? error) =>
      switch (error) {
        null => null,
        CareerValidationError.required => careerTitleRequired,
        CareerValidationError.tooLong => careerTextTooLong(
          CareerPreferencesValidation.limit(field),
        ),
        CareerValidationError.invalidExperience => careerExperienceInvalid,
      };
}
