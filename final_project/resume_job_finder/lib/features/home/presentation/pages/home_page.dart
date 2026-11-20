import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../app_settings/presentation/widgets/app_settings_button.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_content.dart';
import '../widgets/home_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.onEditPreferences,
    required this.onSignedOut,
    super.key,
  });
  final Future<bool?> Function() onEditPreferences;
  final VoidCallback onSignedOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _editPreferences() async {
    final saved = await widget.onEditPreferences();
    if (mounted && saved == true) await context.read<HomeCubit>().load();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, auth) {
      if (auth.status == AuthStatus.signedOut) widget.onSignedOut();
    },
    builder: (context, auth) {
      final l10n = context.l10n;
      final theme = Theme.of(context);
      return PopScope(
        canPop: !auth.isLoading,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(l10n.homeTitle),
            actions: [
              const AppSettingsButton(),
              IconButton(
                key: const ValueKey('home_notifications'),
                tooltip: l10n.homeNotifications,
                onPressed: null,
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                key: const ValueKey('auth_sign_out'),
                tooltip: l10n.authSignOut,
                onPressed: auth.isLoading
                    ? null
                    : context.read<AuthCubit>().signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          bottomNavigationBar: IgnorePointer(
            ignoring: auth.isLoading,
            child: HomeNavigation(
              onHome: () {
                if (_scroll.hasClients) {
                  _scroll.animateTo(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              },
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                if (auth.isLoading) const LinearProgressIndicator(),
                if (auth.failure != null)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.authFailureMessage(auth.failure!),
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state.status == HomeStatus.initial ||
                          state.status == HomeStatus.loading) {
                        return const AppLoading();
                      }
                      if (state.status == HomeStatus.failure) {
                        return AppErrorState(
                          message: l10n.homeLoadError,
                          onRetry: context.read<HomeCubit>().load,
                        );
                      }
                      return IgnorePointer(
                        ignoring: auth.isLoading,
                        child: HomeContent(
                          fullName: auth.user?.fullName ?? '',
                          state: state,
                          scrollController: _scroll,
                          onEditPreferences: _editPreferences,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
