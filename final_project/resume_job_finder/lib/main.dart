import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'app/di/injection_container.dart';
import 'features/app_settings/presentation/cubit/app_settings_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(getIt);

  runApp(
    BlocProvider(
      create: (_) => getIt<AppSettingsCubit>(),
      child: ResumeJobFinderApp(router: getIt<GoRouter>()),
    ),
  );
}
