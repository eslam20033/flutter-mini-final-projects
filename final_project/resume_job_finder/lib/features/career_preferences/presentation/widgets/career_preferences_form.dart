import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/career_preferences.dart';
import '../../domain/career_preferences_validation.dart';
import '../career_preferences_messages.dart';
import '../cubit/career_preferences_cubit.dart';
import '../cubit/career_preferences_state.dart';

class CareerPreferencesForm extends StatefulWidget {
  const CareerPreferencesForm({required this.state, super.key});
  final CareerPreferencesState state;

  @override
  State<CareerPreferencesForm> createState() => _CareerPreferencesFormState();
}

class _CareerPreferencesFormState extends State<CareerPreferencesForm> {
  late final _title = TextEditingController(
    text: widget.state.preferences?.jobTitle,
  );
  late final _industry = TextEditingController(
    text: widget.state.preferences?.industry,
  );
  late final _experience = TextEditingController(
    text: widget.state.preferences?.experienceYears?.toString().replaceFirst(
      RegExp(r'\.0$'),
      '',
    ),
  );
  late final _location = TextEditingController(
    text: widget.state.preferences?.location,
  );
  late final _experienceLevel = TextEditingController(
    text: widget.state.preferences?.experienceLevel,
  );
  late final _qualifications = TextEditingController(
    text: widget.state.preferences?.qualifications,
  );
  late WorkArrangement _arrangement =
      widget.state.preferences?.arrangement ?? WorkArrangement.any;

  @override
  void dispose() {
    for (final controller in [
      _title,
      _industry,
      _experience,
      _experienceLevel,
      _location,
      _qualifications,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<CareerPreferencesCubit>().save(
      jobTitle: _title.text,
      industry: _industry.text,
      experience: _experience.text,
      experienceLevel: _experienceLevel.text,
      location: _location.text,
      arrangement: _arrangement,
      qualifications: _qualifications.text,
    );
  }

  Widget _field(
    CareerField field,
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboard,
    int lines = 1,
    IconData? icon,
  }) => AppTextField(
    key: ValueKey('career_${field.name}'),
    controller: controller,
    label: label,
    hint: hint,
    enabled: !widget.state.isBusy,
    errorText: context.l10n.careerError(field, widget.state.errors[field]),
    keyboardType: keyboard,
    maxLines: lines,
    textInputAction: lines > 1 ? TextInputAction.newline : TextInputAction.next,
    prefixIcon: icon == null ? null : Icon(icon),
    onChanged: (_) => context.read<CareerPreferencesCubit>().clearError(field),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: AppSpacing.medium);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsetsDirectional.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                CareerField.jobTitle,
                _title,
                l10n.careerJobTitle,
                l10n.careerJobTitleHint,
                icon: Icons.work_outline_rounded,
              ),
              gap,
              _field(
                CareerField.industry,
                _industry,
                l10n.careerIndustry,
                l10n.careerIndustryHint,
                icon: Icons.business_outlined,
              ),
              gap,
              _field(
                CareerField.experience,
                _experience,
                l10n.careerExperience,
                l10n.careerExperienceHint,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
              gap,
              _field(
                CareerField.experienceLevel,
                _experienceLevel,
                l10n.careerExperienceLevel,
                l10n.careerExperienceLevelHint,
              ),
            ],
          ),
        ),
        gap,
        AppCard(
          padding: const EdgeInsetsDirectional.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                CareerField.location,
                _location,
                l10n.careerLocation,
                l10n.careerLocationHint,
                icon: Icons.location_on_outlined,
              ),
              gap,
              Text(
                l10n.careerArrangement,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final arrangement in WorkArrangement.values)
                    ChoiceChip(
                      key: ValueKey('career_arrangement_${arrangement.name}'),
                      label: Text(l10n.arrangementLabel(arrangement)),
                      selected: _arrangement == arrangement,
                      onSelected: widget.state.isBusy
                          ? null
                          : (_) => setState(() => _arrangement = arrangement),
                    ),
                ],
              ),
              gap,
              _field(
                CareerField.qualifications,
                _qualifications,
                l10n.careerQualifications,
                l10n.careerQualificationsHint,
                keyboard: TextInputType.multiline,
                lines: 3,
              ),
            ],
          ),
        ),
        if (widget.state.status == CareerPreferencesStatus.saveFailure) ...[
          gap,
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.careerSaveError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.large),
        AppButton(
          key: const ValueKey('career_save'),
          label: widget.state.isBusy ? l10n.loading : l10n.careerSave,
          isLoading: widget.state.isBusy,
          onPressed: _save,
        ),
      ],
    );
  }
}
