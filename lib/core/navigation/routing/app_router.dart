import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/core/navigation/routing/root_navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_state.dart';
import 'package:flutter_herodex3000/data/managers/settings_manager.dart';
import 'package:flutter_herodex3000/data/managers/agent_cache.dart';
import 'package:flutter_herodex3000/barrel_files/screens.dart';

// Creates the GoRouter configuration for the app.
GoRouter createAppRouter(AuthCubit authCubit, SettingsManager settingsManager) {
  final refresh = AppRouterRefresh(authCubit, settingsManager);

  return GoRouter(
    initialLocation: "/",
    refreshListenable: refresh,
    routes: [
      // Splash screen and login are outside shell
      GoRoute(
        path: "/",
        name: "Splash",
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: "/login",
        name: "Login",
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: "/onboarding",
        name: "Onboarding",
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Bottom tab bar (only for authenticated routes)
      ShellRoute(
        builder: (context, state, child) {
          return RootNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: "/home",
            name: "Home",
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: "/roster",
            name: "Roster",
            builder: (context, state) => const RosterScreen(),
          ),
          GoRoute(
            path: "/search",
            name: "Search",
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: "/settings",
            name: "Settings",
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = authCubit.state;
      final onboardingCompleted = settingsManager.onboardingCompleted;

      final goingToLogin = state.uri.path == "/login";
      final goingToOnboarding = state.uri.path == "/onboarding";
      final atSplash = state.uri.path == "/";

      if (authState is AuthAuthenticated) {
        // If authenticated and not completed onboarding, go to onboarding
        if (!onboardingCompleted && !goingToOnboarding) {
          return "/onboarding";
        }
        // If authenticated and completed onboarding, go to home
        if (onboardingCompleted &&
            (goingToLogin || atSplash || goingToOnboarding)) {
          return "/home";
        }
        return null;
      }

      if (authState is AuthUnauthenticated) {
        // If unauthenticated, always go to login (unless already there)
        if (!goingToLogin) return "/login";
        return null;
      }

      // Unknown/loading → show splash
      if (!atSplash) return "/";
      return null;
    },
  );
}

/// Notifies GoRouter when auth or settings change so it can re-evaluate redirects.
class AppRouterRefresh extends ChangeNotifier {
  AppRouterRefresh(this.authCubit, this.settingsManager) {
    // Listen to auth changes
    _authSub = authCubit.stream.listen((_) {
      notifyListeners();
    });

    // Listen to settings changes
    settingsManager.addListener(notifyListeners);
  }

  final AuthCubit authCubit;
  final SettingsManager settingsManager;

  late final StreamSubscription _authSub;

  @override
  void dispose() {
    _authSub.cancel();
    settingsManager.removeListener(notifyListeners);
    super.dispose();
  }
}