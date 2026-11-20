import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import '../../support/test_career_preferences_repository.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences_validation.dart';
import 'package:resume_job_finder/features/career_preferences/presentation/cubit/career_preferences_cubit.dart';
import 'package:resume_job_finder/features/career_preferences/presentation/cubit/career_preferences_state.dart';

import '../../support/controlled_career_repositories.dart';

void main() {
  test(
    'mock stores edits separately by account and a new instance is empty',
    () async {
      final repository = TestCareerPreferencesRepository(delay: Duration.zero);
      expect(await repository.load('one'), isNull);
      await repository.save('one', const CareerPreferences(jobTitle: 'Nurse'));
      await repository.save('two', const CareerPreferences(jobTitle: 'نجّار'));
      await repository.save(
        'one',
        const CareerPreferences(
          jobTitle: 'Midwife',
          qualifications: 'Training',
          arrangement: WorkArrangement.onSite,
        ),
      );
      expect((await repository.load('one'))!.jobTitle, 'Midwife');
      expect((await repository.load('two'))!.jobTitle, 'نجّار');
      expect(
        await TestCareerPreferencesRepository(delay: Duration.zero).load('one'),
        isNull,
      );
    },
  );

  test('validation accepts any profession, optional fields and Arabic decimal years', () {
    for (final title in [
      'Artist',
      'مزارع',
      'Marine biologist',
      'Baker',
      'Teacher',
      'Flutter Developer',
    ]) {
      for (final years in ['', '0', '3.5', '٣٫٥', '۴.۵', '100']) {
        expect(
          CareerPreferencesValidation.validate(
            jobTitle: title,
            industry: '',
            experience: years,
            location: '',
            qualifications: '',
          ),
          isEmpty,
        );
      }
    }
    expect(CareerPreferencesValidation.parseYears('٣٫٥'), 3.5);
    expect(
      CareerPreferencesValidation.validate(
        jobTitle: ' ',
        industry: '',
        experience: '-1',
        location: '',
        qualifications: '',
      ),
      {
        CareerField.jobTitle: CareerValidationError.required,
        CareerField.experience: CareerValidationError.invalidExperience,
      },
    );
    for (final years in ['101', 'NaN', 'Infinity', '1e4', 'three']) {
      expect(
        CareerPreferencesValidation.validate(
          jobTitle: 'Teacher',
          industry: '',
          experience: years,
          location: '',
          qualifications: '',
        ),
        contains(CareerField.experience),
      );
    }
    expect(
      CareerPreferencesValidation.validate(
        jobTitle: 'A' * 121,
        industry: 'B' * 121,
        experience: '',
        location: 'C' * 161,
        qualifications: 'D' * 1001,
      ).length,
      4,
    );
  });

  late ControlledPreferencesRepository repository;
  late CareerPreferencesCubit cubit;
  setUp(() {
    repository = ControlledPreferencesRepository();
    cubit = CareerPreferencesCubit(repository, 'one');
  });
  tearDown(() => cubit.close());
  Future<void> save({String title = '  Carpenter  ', String years = '٢٫٥'}) =>
      cubit.save(
        jobTitle: title,
        industry: ' Construction ',
        experience: years,
        location: ' Cairo ',
        arrangement: WorkArrangement.onSite,
        qualifications: ' Licensed ',
      );

  test(
    'load failure can retry; saving validates before touching storage',
    () async {
      repository.failLoad = true;
      await cubit.load();
      expect(cubit.state.status, CareerPreferencesStatus.loadFailure);
      await save();
      expect(repository.saveCalls, 0);
      repository.failLoad = false;
      await cubit.load();
      await save(title: ' ', years: 'invalid');
      expect(repository.saveCalls, 0);
      expect(cubit.state.errors.length, 2);
      cubit.clearError(CareerField.jobTitle);
      expect(cubit.state.errors.keys, [CareerField.experience]);
      await save();
      expect(cubit.state.status, CareerPreferencesStatus.saved);
      expect(repository.stored['one']!.jobTitle, 'Carpenter');
      expect(repository.stored['one']!.experienceYears, 2.5);
      expect(repository.stored['one']!.qualifications, 'Licensed');
    },
  );

  test('save failure retains previous values and retry succeeds', () async {
    repository.stored['one'] = const CareerPreferences(jobTitle: 'Teacher');
    await cubit.load();
    repository.failSave = true;
    await save();
    expect(cubit.state.status, CareerPreferencesStatus.saveFailure);
    expect(cubit.state.preferences!.jobTitle, 'Teacher');
    expect(repository.stored['one']!.jobTitle, 'Teacher');
    repository.failSave = false;
    await save();
    expect(cubit.state.status, CareerPreferencesStatus.saved);
  });

  test(
    'experience level is optional free text, bounded, trimmed and editable',
    () async {
      await cubit.load();
      Future<void> saveLevel(String level) => cubit.save(
        jobTitle: 'Book conservator',
        industry: 'Cultural heritage',
        experience: '',
        experienceLevel: level,
        location: '',
        arrangement: WorkArrangement.any,
        qualifications: '',
      );
      await saveLevel('L' * 121);
      expect(
        cubit.state.errors[CareerField.experienceLevel],
        CareerValidationError.tooLong,
      );
      expect(repository.saveCalls, 0);
      await saveLevel('  حرفي متمرس  ');
      expect(repository.stored['one']!.experienceLevel, 'حرفي متمرس');
      await cubit.load();
      expect(cubit.state.preferences!.experienceLevel, 'حرفي متمرس');
      await saveLevel('');
      expect(repository.stored['one']!.experienceLevel, isEmpty);
    },
  );

  test('loading and saving block overlapping operations', () async {
    final loadGate = Completer<void>();
    repository.loadGate = loadGate.future;
    final load = cubit.load();
    await cubit.load();
    await save();
    expect(repository.loadCalls, 1);
    expect(repository.saveCalls, 0);
    loadGate.complete();
    await load;
    final saveGate = Completer<void>();
    repository.saveGate = saveGate.future;
    final pending = save();
    expect(cubit.state.status, CareerPreferencesStatus.saving);
    await save();
    await cubit.load();
    expect(repository.saveCalls, 1);
    expect(repository.loadCalls, 1);
    saveGate.complete();
    await pending;
  });

  for (final saving in [false, true]) {
    test(
      '${saving ? 'save' : 'load'} finishing after disposal is safe',
      () async {
        final gate = Completer<void>();
        if (saving) {
          await cubit.load();
          repository.saveGate = gate.future;
        } else {
          repository.loadGate = gate.future;
        }
        final pending = saving ? save() : cubit.load();
        await cubit.close();
        gate.complete();
        await expectLater(pending, completes);
      },
    );
  }
}
