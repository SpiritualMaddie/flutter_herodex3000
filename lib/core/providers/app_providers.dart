import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/repository/auth_repository.dart';
import 'package:flutter_herodex3000/data/managers/settings_manager.dart';
import 'package:flutter_herodex3000/data/services/shared_preferences_service.dart';

// Creates all the providers for the app.

Widget createAppProviders({
  required SharedPreferencesService prefsService,
  required Widget child,
}) {
  return MultiProvider(
    providers: [
      // SharedPreferences service (already initialized in main)
      Provider<SharedPreferencesService>.value(value: prefsService),

      // Settings manager (depends on SharedPreferences)
      ChangeNotifierProvider<SettingsManager>(
        create: (context) =>
            SettingsManager(context.read<SharedPreferencesService>()),
      ),

      // Auth repository
      RepositoryProvider<AuthRepository>(
        create: (_) => AuthRepository(),
      ),

      // Auth cubit (depends on AuthRepository)
      BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
      ),

      // Theme cubit
      BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit(),
      ),
    ],
    child: child,
  );
}