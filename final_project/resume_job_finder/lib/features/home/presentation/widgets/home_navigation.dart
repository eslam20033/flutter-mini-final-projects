import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';

class HomeNavigation extends StatelessWidget {
  const HomeNavigation({required this.onHome, super.key});
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = [
      (key: 'home', label: l10n.homeTitle, icon: Icons.home_rounded),
      (key: 'cv', label: l10n.homeCv, icon: Icons.description_outlined),
      (key: 'jobs', label: l10n.homeJobs, icon: Icons.work_outline_rounded),
      (
        key: 'saved',
        label: l10n.homeSaved,
        icon: Icons.bookmark_border_rounded,
      ),
    ];
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Expanded(
                child: Semantics(
                  selected: item.key == 'home',
                  child: TextButton(
                    key: ValueKey('home_nav_${item.key}'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      foregroundColor: item.key == 'home'
                          ? null
                          : theme.colorScheme.onSurfaceVariant,
                      textStyle: theme.textTheme.labelMedium,
                    ),
                    onPressed: item.key == 'home'
                        ? onHome
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon),
                        Text(item.label, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
