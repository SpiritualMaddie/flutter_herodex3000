import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_state.dart';
import 'package:flutter_herodex3000/auth/repository/auth_repository.dart';
import 'package:flutter_herodex3000/firebase_options.dart';
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
  HeroDex({super.key});

  final _router = GoRouter(
    initialLocation: "/login",
    routes: [
      // bottom tab bar
      ShellRoute(
        builder: (context, state, child) {
          return RootNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: "/login",
            name: "Login",
            builder: (context, state) => const LoginScreen(),
          ),
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
            path: "/heroesAndVillains",
            name: "Heroes/Villains",
            builder: (context, state) => const HeroesAndVillainsScreen(),
          ),
          GoRoute(
            path: "/settings",
            name: "Settings",
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // details view
      GoRoute(
        path: "/details/:id",
        name: "details",
        builder: (context, state) {
          final id = state.pathParameters["id"]!;
          return DetailScreen(id: id);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(create: (context) => AuthRepository(),
    child: BlocProvider(create: (context) => AuthCubit(context.read<AuthRepository>()),
    child: MaterialApp.router(
      title: "HeroDex3000",
      //theme:
      routerConfig: _router,
    )),);
  }
}

class RootNavigation extends StatelessWidget {
  final Widget child;
  const RootNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;

    if (location.startsWith("/home")) currentIndex = 1;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go("/login");
              break;
            case 1:
              context.go("/home");
              break;
            case 2:
              context.go("/search");
              break;
            case 3:
              context.go("/heroesAndVillains");
              break;
            case 4:
              context.go("/settings");
              break;
          }
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.login), label: "Login"),
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
          NavigationDestination(
            icon: Icon(Icons.hexagon_rounded),
            label: "Cards",
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
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
        if(state is AuthAuthenticated){
          return const HomeScreen();
        }
        if(state is AuthUnauthenticated){
          return const LoginScreen();
        }
        return const SplashScreen();
      },
    );
  }
}