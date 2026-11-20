import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../career_preferences/presentation/career_preferences_messages.dart';
import '../../domain/job_preview.dart';

class HomeJobCard extends StatelessWidget {
  const HomeJobCard({required this.job, super.key});
  final JobPreview job;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.work_outline_rounded),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      job.employer,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('home_save_${job.id}'),
                tooltip: l10n.homeSaveJob,
                onPressed: null,
                icon: const Icon(Icons.bookmark_border_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(job.location),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              Chip(label: Text(l10n.arrangementLabel(job.arrangement))),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: ValueKey('home_details_${job.id}'),
              onPressed: null,
              child: Text(l10n.homeViewDetails),
            ),
          ),
        ],
      ),
    );
  }
}
