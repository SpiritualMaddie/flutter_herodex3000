import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

///
/// Reusable dark card container used throughout the app.
/// 
/// Use cases:
/// - War narrative cards (HomeScreen)
/// - System manifest (SettingsScreen)
/// - Protocol permission tiles (SettingsScreen, OnboardingScreen)
/// - Any info display that needs consistent styling
/// 
/// Features:
/// - Optional icon + title header
/// - Optional body text
/// - OR custom child widget for full control
/// - Configurable padding and margin
/// - Theme-aware colors (uses primary color)
/// 
/// Two usage patterns:
/// 1. Simple: Provide title/body/icon → automatic layout
/// 2. Custom: Provide child → full control over content
/// 
class InfoCard extends StatelessWidget {
  final String? title;
  final String? body;
  final IconData? icon;
  final Widget? child;  // For custom content (overrides title/body)
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const InfoCard({
    super.key,
    this.title,
    this.body,
    this.icon,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(20)),
      ),
      // Use custom child if provided, otherwise build from title/body
      child: child ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row (with optional icon)
              if (title != null)
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              if (title != null && body != null) const SizedBox(height: 10),
              // Body text
              if (body != null)
                Text(
                  body!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
            ],
          ),
    );
  }
}