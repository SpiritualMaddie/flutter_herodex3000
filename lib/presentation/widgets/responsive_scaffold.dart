import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/utils.dart';

///
/// Responsive scaffold that centers content on larger screens.
/// 
/// Breakpoint behavior (defined in screen_utils.dart):
/// - Mobile (<600px): Content fills screen width
/// - Tablet (600-1200px): Content centered with 800px max width
/// - Desktop (>1200px): Content centered with 1000px max width
/// 
/// Features:
/// - Automatic responsive layout based on screen width
/// - Optional centering (centerContent: false for full-width)
/// - Shadow effect on centered content (gives depth on large screens)
/// - Compatible with standard Scaffold params (appBar, bottomNav, etc.)
/// 

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool centerContent; // If false, acts like normal scaffold

  const ResponsiveScaffold({
    super.key,
    required this.child,
    this.backgroundColor,
    this.appBar,
    this.bottomNavigationBar,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile; // From screen_utils extension

    // On mobile, or if centering disabled → use normal full-width scaffold
    if (isMobile || !centerContent) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          appBar: appBar,
          body: child,
          bottomNavigationBar: bottomNavigationBar,
        ),
      );
    }

    // On tablet/desktop, center the content with max width
    // Background fills screen, content is constrained
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: Center(
        child: Container(
          width: context.maxContentWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(50),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}