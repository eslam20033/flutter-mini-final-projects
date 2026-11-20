import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import 'app_settings_sheet.dart';

class AppSettingsButton extends StatelessWidget {
  const AppSettingsButton({this.enabled = true, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context) => IconButton(
    key: const ValueKey('app_settings'),
    tooltip: context.l10n.settingsTitle,
    icon: const Icon(Icons.settings_outlined),
    onPressed: enabled
        ? () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            constraints: const BoxConstraints(maxWidth: 560),
            builder: (_) => const AppSettingsSheet(),
          )
        : null,
  );
}
