import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_state.dart';
import 'package:flutter_herodex3000/auth/repository/auth_repository.dart';
import 'package:flutter_herodex3000/firebase_options.dart';
import 'package:flutter_herodex3000/screens/login_screen.dart';
import 'barrel_files/screens.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable debug mode for analytics
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  runApp(HeroDex());
}

class HeroDex extends StatelessWidget {
  const HeroDex({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            final refresh = _AuthChangeNotifier(authCubit);

            final router = GoRouter(
              initialLocation: "/",
              refreshListenable: refresh,
              routes: [
                // splash screen and login are outside shell
                GoRoute(
                  path: "/",
                  name: "Splash",
                  builder: (context, state) => const SplashScreen(),
                ),
                GoRoute(
                  path: "/login",
                  name: "Login",
                  builder: (context, state) => const LoginScreen2(),
                ),

                // bottom tab bar (only for authenticated routes)
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
                      path: "/search",
                      name: "Search",
                      builder: (context, state) => const SearchScreen(),
                    ),
                    GoRoute(
                      path: "/roster",
                      name: "Roster",
                      builder: (context, state) =>
                          const RosterScreen(),
                    ),
                    GoRoute(
                      path: "/settings",
                      name: "Settings",
                      builder: (context, state) => const SettingsScreen(),
                    ),
                  ],
                ),

                // details view (can be navigated to from shell routes)
                GoRoute(
                  path: "/details/:id",
                  name: "details",
                  builder: (context, state) {
                    final id = state.pathParameters["id"]!;
                    return DetailScreen(id: id);
                  },
                ),
              ],
              redirect: (context, state) {
                final authState = context.read<AuthCubit>().state;
                final goingToLogin = state.uri.path == ("/login");
                final atSplash = state.uri.path == "/";

                if (authState is AuthAuthenticated) {
                  // if authenticated, dont allow going to login or splash
                  if (goingToLogin || atSplash) return "/home";
                  return null;
                }

                if (authState is AuthUnauthenticated) {
                  // if unauthenticated, always go to login (unless already there)
                  if (!goingToLogin) return "/login";
                  return null;
                }

                // while unknown/loading --> show splash
                if (!atSplash) return "/";
                return null;
              },
            );

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: "HeroDex3000",
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}

class RootNavigation extends StatelessWidget {
  final Widget child;
  const RootNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;

    if (location.startsWith("/home")) currentIndex = 0;
    if (location.startsWith("/search")) currentIndex = 1;
    if (location.startsWith("/roster")) currentIndex = 2;
    if (location.startsWith("/settings")) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go("/home");
              break;
            case 1:
              context.go("/search");
              break;
            case 2:
              context.go("/roster");
              break;
            case 3:
              context.go("/settings");
              break;
          }
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "HUB"),
          NavigationDestination(icon: Icon(Icons.radar), label: "SCAN"),
          NavigationDestination(
            icon: Icon(Icons.shield),
            label: "AGENTS",
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: "SETTINGS"),
        ],
      ),
    );
  }
}

class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        if (state is AuthUnauthenticated) {
          return const LoginScreen2();
        }
        return const SplashScreen();
      },
    );
  }
}

class _AuthChangeNotifier extends ChangeNotifier {
  final AuthCubit cubit;
  late final StreamSubscription _sub;
  _AuthChangeNotifier(this.cubit) {
    _sub = cubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
