import 'package:flutter_herodex3000/barrel_files/routing.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/utils.dart';

/// Bottom navigation bar that wraps authenticated screens.
class RootNavigation extends StatelessWidget {
  final Widget child;
  
  const RootNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith("/home")) currentIndex = 0;
    if (location.startsWith("/roster")) currentIndex = 1;
    if (location.startsWith("/search")) currentIndex = 2;
    if (location.startsWith("/settings")) currentIndex = 3;

    final useRailOnLeft = context.isDesktop;

    if (useRailOnLeft) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go("/home");
                    break;
                  case 1:
                    context.go("/roster");
                    break;
                  case 2:
                    context.go("/search");
                    break;
                  case 3:
                    context.go("/settings");
                    break;
                }
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 48,
                  child: Image.asset(
                    "assets/icons/app_icon.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('HUB'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shield_outlined),
                  selectedIcon: Icon(Icons.shield),
                  label: Text('ROSTER'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.radar),
                  selectedIcon: Icon(Icons.radar),
                  label: Text('SEARCH'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('SETTINGS'),
                ),
              ],
            ),
            const VerticalDivider(width: 4),
            // main content expands to take remaining space
            Expanded(child: child),
          ],
        ),
      );
    } else {
      // Mobile / narrow tablet: bottom navigation bar
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go("/home");
                break;
              case 1:
                context.go("/roster");
                break;
              case 2:
                context.go("/search");
                break;
              case 3:
                context.go("/settings");
                break;
            }
          },
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "HUB"),
            NavigationDestination(icon: Icon(Icons.shield), label: "ROSTER"),
            NavigationDestination(icon: Icon(Icons.radar), label: "SEARCH"),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: "SETTINGS",
            ),
          ],
        ),
      );
  }
}}