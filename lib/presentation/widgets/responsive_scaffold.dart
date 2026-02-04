import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/core/utils/responsive.dart';

/// Responsive scaffold that centers content on larger screens.
/// 
/// **Mobile (< 600px)**: Content fills the screen
/// **Tablet/Desktop (> 600px)**: Content is centered with max width, background fills screen
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
    final isMobile = context.isMobile;

    // On mobile, just uses normal scaffold (full width)
    if (isMobile || !centerContent) {
      return Scaffold(
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        appBar: appBar,
        body: child,
        bottomNavigationBar: bottomNavigationBar,
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