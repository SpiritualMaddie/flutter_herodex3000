import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/authentication.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';
import 'package:flutter_herodex3000/barrel_files/services.dart';
import 'package:flutter_herodex3000/barrel_files/theme.dart';
import 'package:provider/provider.dart';

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