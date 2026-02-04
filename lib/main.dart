import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/core/navigation/routing/app_router.dart';
import 'package:flutter_herodex3000/core/providers/app_providers.dart';
import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';
import 'package:flutter_herodex3000/data/services/firebase_service.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/firebase_options.dart';
import 'package:flutter_herodex3000/data/managers/settings_manager.dart';
import 'package:flutter_herodex3000/data/services/shared_preferences_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize SharedPreferences
  final prefsService = SharedPreferencesService();
  await prefsService.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable debug mode for analytics only on supported platforms.
  try {
    final bool analyticsSupported =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    if (analyticsSupported) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } else {
      // Windows (and other unsupported platforms) skip analytics calls to avoid channel errors.
      debugPrint(
        'FirebaseAnalytics: skipping setAnalyticsCollectionEnabled on unsupported platform: $defaultTargetPlatform',
      );
    }
  } catch (e, st) {
    // Safe fallback: log and continue — do not let platform-channel errors crash the app
    debugPrint('FirebaseAnalytics: error enabling analytics: $e\n$st');
  }

  // Initialize Firebase Analytics & Crashlytics with user permissions
  await FirebaseService.initialize(
    analyticsEnabled: prefsService.analyticsIsApproved,
    crashlyticsEnabled: prefsService.crashlyticsIsApproved,
  );

  // Run app with all providers
  runApp(
    createAppProviders(prefsService: prefsService, child: const HeroDex()),
  );
}

// Root app widget.
class HeroDex extends StatefulWidget {
  const HeroDex({super.key});

  @override
  State<HeroDex> createState() => _HeroDexState();
}

class _HeroDexState extends State<HeroDex> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      context.read<AuthCubit>(),
      context.read<SettingsManager>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppTheme>(
      builder: (context, currentTheme) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "HeroDex3000",
          theme: ThemeCubit.getThemeData(currentTheme),
          routerConfig: _router,
        );
      },
    );
  }
}
