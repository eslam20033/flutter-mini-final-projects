import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../career_preferences/domain/career_preferences.dart';
import '../../../career_preferences/presentation/career_preferences_messages.dart';

class HomePreferencesCard extends StatelessWidget {
  const HomePreferencesCard({
    required this.preferences,
    required this.onEdit,
    super.key,
  });
  final CareerPreferences? preferences;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = preferences;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.homePreferencesTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          if (value == null)
            Text(l10n.homePreferencesEmpty)
          else ...[
            Text(
              value.jobTitle,
              key: const ValueKey('home_preferred_title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (value.industry.isNotEmpty) Text(value.industry),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                Chip(label: Text(l10n.arrangementLabel(value.arrangement))),
                if (value.location.isNotEmpty)
                  Chip(label: Text(value.location)),
              ],
            ),
            if (value.experienceYears != null)
              Text(l10n.careerYearsSummary(value.experienceYears!)),
            if (value.qualifications.isNotEmpty)
              Text(
                value.qualifications,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
          ],
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey('home_edit_preferences'),
              onPressed: onEdit,
              icon: const Icon(Icons.tune_rounded),
              label: Text(
                value == null
                    ? l10n.homeAddPreferences
                    : l10n.homeEditPreferences,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
