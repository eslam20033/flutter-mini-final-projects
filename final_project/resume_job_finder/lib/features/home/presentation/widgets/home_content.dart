import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../cubit/home_cubit.dart';
import 'home_job_card.dart';
import 'home_preferences_card.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    required this.fullName,
    required this.state,
    required this.scrollController,
    required this.onEditPreferences,
    super.key,
  });
  final String fullName;
  final HomeState state;
  final ScrollController scrollController;
  final VoidCallback onEditPreferences;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: context.read<HomeCubit>().load,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(AppSpacing.page),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.authWelcome(fullName),
                    key: const ValueKey('home_greeting'),
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(l10n.homeSubtitle, style: theme.textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.large),
                AppCard(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Icon(
                          Icons.upload_file_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(l10n.homeCvTitle, style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.small),
                      Text(l10n.homeCvDescription),
                      const SizedBox(height: AppSpacing.medium),
                      AppButton(
                        key: const ValueKey('home_upload_cv'),
                        label: l10n.homeUploadCv,
                        icon: Icons.add_rounded,
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                HomePreferencesCard(
                  preferences: state.preferences,
                  onEdit: onEditPreferences,
                ),
                const SizedBox(height: AppSpacing.large),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.homeRecommendations,
                      style: theme.textTheme.titleLarge,
                    ),
                    TextButton(
                      key: const ValueKey('home_view_jobs'),
                      onPressed: null,
                      child: Text(l10n.homeViewAll),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                if (state.jobs.isEmpty)
                  AppCard(
                    child: AppEmptyState(
                      title: l10n.homeJobsEmptyTitle,
                      message: l10n.homeJobsEmptyMessage,
                      icon: Icons.work_outline_rounded,
                    ),
                  )
                else
                  for (final job in state.jobs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                      child: HomeJobCard(job: job),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
