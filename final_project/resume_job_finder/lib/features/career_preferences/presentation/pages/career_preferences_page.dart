import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../app_settings/presentation/widgets/app_settings_button.dart';
import '../cubit/career_preferences_cubit.dart';
import '../cubit/career_preferences_state.dart';
import '../widgets/career_preferences_form.dart';

class CareerPreferencesPage extends StatelessWidget {
  const CareerPreferencesPage({
    required this.onBack,
    required this.onSaved,
    super.key,
  });
  final VoidCallback onBack;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CareerPreferencesCubit, CareerPreferencesState>(
        listener: (context, state) {
          if (state.status == CareerPreferencesStatus.saved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.l10n.careerSaved)));
            onSaved();
          }
        },
        builder: (context, state) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !state.isBusy) onBack();
          },
          child: Scaffold(
            appBar: AppBar(
              actions: const [AppSettingsButton()],
              title: Text(context.l10n.careerTitle),
              leading: IconButton(
                key: const ValueKey('career_back'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: state.isBusy ? null : onBack,
                icon: const BackButtonIcon(),
              ),
            ),
            body: SafeArea(
              top: false,
              child: switch (state.status) {
                CareerPreferencesStatus.initial ||
                CareerPreferencesStatus.loading => const AppLoading(),
                CareerPreferencesStatus.loadFailure => AppErrorState(
                  message: context.l10n.careerLoadError,
                  onRetry: context.read<CareerPreferencesCubit>().load,
                ),
                _ => Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsetsDirectional.all(AppSpacing.page),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.careerHeading,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            context.l10n.careerSubtitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.large),
                          CareerPreferencesForm(state: state),
                        ],
                      ),
                    ),
                  ),
                ),
              },
            ),
          ),
        ),
      );
}
