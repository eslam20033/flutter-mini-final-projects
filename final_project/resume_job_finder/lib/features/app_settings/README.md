# App settings

This presentation-only feature controls the current locale and theme mode through AppSettingsCubit.

Defaults follow the device. A null locale restores device language selection; unsupported device languages fall back to English. Explicit language selection accepts English and Arabic. ThemeMode supports system, light, and dark.

The root BlocProvider creates and owns the Cubit. Pages use the existing instance via context.read<AppSettingsCubit>(); resolving the factory again would create separate state.

The shared settings icon opens a scrollable bottom sheet from onboarding, authentication headers, Home, and career preferences. Language and appearance update immediately, including the open sheet, without replacing the router, repositories, or form state. Arabic uses Noto Sans Arabic and English uses Inter. Radio controls expose the current selection and support keyboard focus and screen readers.

There is no settings storage or repository. Preferences survive navigation, login, and logout within the running app, but reset to device defaults on a full process restart. No persistence dependency is added.
