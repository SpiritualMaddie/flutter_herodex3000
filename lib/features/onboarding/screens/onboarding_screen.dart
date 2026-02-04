import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';
import 'package:flutter_herodex3000/data/managers/settings_manager.dart';
import 'package:flutter_herodex3000/presentation/widgets/responsive_scaffold.dart';
import 'package:flutter_herodex3000/presentation/widgets/section_header.dart';
import 'package:flutter_herodex3000/presentation/widgets/theme_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  // Permission states
  bool _analyticsEnabled = false;
  bool _crashlyticsEnabled = false;
  bool _locationEnabled = false;
  bool _attEnabled = false;
  String _themePicked = "heroDark";

  @override
  void initState() {
    super.initState();

    // Check ATT status on iOS only
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkATTStatus());
    }
  }

  // Check existing ATT status whithout prompting
  Future<void> _checkATTStatus() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (!mounted) return;
    setState(() {
      _attEnabled = status == TrackingStatus.authorized;
    });
  }

  /// Request ATT permission (shows Apple's system dialog if not determined)
  Future<void> _requestATT() async {
    final currentStatus =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    if (currentStatus == TrackingStatus.notDetermined) {
      // Request Apple's system dialog
      final newStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      if (!mounted) return;
      setState(() {
        _attEnabled = newStatus == TrackingStatus.authorized;
      });
    } else {
      // Already determined (authorized, denied, or restricted)
      // Updates the toggle to reflect current status
      if (!mounted) return;
      setState(() {
        _attEnabled = currentStatus == TrackingStatus.authorized;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: const Color(0xFF0A111A),
      child: SafeArea(
        child: Column(
          children: [
            // Progress bar stays fixed at top
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 0,
              ),
              child: _SegmentedProgressBar(
                currentPage: _currentPage,
                totalPages: _totalPages,
              ),
            ),
            // Pages scroll under it, wrapped in Expanded + LayoutBuilder
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildScrollablePage(_buildStoryPage()),
                  _buildScrollablePage(_buildHowToUsePage()),
                  _buildScrollablePage(_buildPermissionsPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE 1: Story ---
  Widget _buildStoryPage() {
    return _OnboardingPageLayout(
      title: "THE INVASION\nIS NOT OVER YET",
      body:
          "Heroes and villains are re-appearing across the world.\n\n"
          "HERODEX 3000 is your command interface — track, search, and recruit "
          "your forces to rebuild the world again.",
      buttonText: "NEXT",
      onNext: _nextPage,
      onBack: null, // first page, no back
    );
  }

  // --- PAGE 2: How to use ---
  Widget _buildHowToUsePage() {
    return _OnboardingPageLayout(
      title: "HOW IT WORKS",
      body: null, // We pass null and use the custom builder instead
      buttonText: "NEXT",
      onNext: _nextPage,
      onBack: _previousPage,
      bodyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _HowToRow(
            icon: Icons.home,
            text:
                "The HUB is the status overview of your roster and the invasion so far",
          ),
          _HowToRow(
            icon: Icons.search,
            text:
                "SEARCH to discover new agent allies & build your roster of heroes and villains",
          ),
          _HowToRow(
            icon: Icons.shield,
            text: "View and operate your ROSTER of agents",
          ),
          _HowToRow(
            icon: Icons.settings,
            text: "SETTINGS for customizing your experience",
          ),
          // _HowToRow(icon: Icons.people, text: "Track heroes and villains"),
          // _HowToRow(icon: Icons.bolt, text: "Manage operations in real time"),
        ],
      ),
    );
  }

  // --- PAGE 3: Permissions ---
  Widget _buildPermissionsPage() {
    final settings = context.watch<SettingsManager>();
    return _OnboardingPageLayout(
      title: "ESTABLISH PROTOCOLS",
      body:
          "Configure your data protocols to begin operations. "
          "You can change these at any time in Settings.",
      buttonText: "ESTABLISH SECURE LINK",
      onNext: _onEstablishLink,
      onBack: _previousPage,
      isLastPage: true,
      bodyWidget: Column(
        children: [
          _buildPermissionTile(
            "ANALYTICS TRACKING",
            "Helps us improve the app by gathering usage data.",
            _analyticsEnabled,
            (val) => setState(() => _analyticsEnabled = val),
          ),
          _buildPermissionTile(
            "CRASH REPORTING",
            "Helps us fix issues by sending crash reports.",
            _crashlyticsEnabled,
            (val) => setState(() => _crashlyticsEnabled = val),
          ),
          _buildPermissionTile(
            "LOCATION",
            "Maps your location for local hero support.",
            _locationEnabled,
            (val) => setState(() => _locationEnabled = val),
          ),
          // ATT - iOS only
          if (defaultTargetPlatform == TargetPlatform.iOS) _buildATTTile(),
          SectionHeader(
            title: "WHATS YOUR ALIGNMENT?",
            subtitle: "(choose app theme)",
            titleFontSize: 16,
            subtitleFontSize: 12,
          ),
          ThemePicker(onThemeSelected: (theme) {
                        context.read<ThemeCubit>().setTheme(theme);
                        settings.saveCurrentAppTheme(value: theme.name);
                      },),
        ],
      ),
    );
  }

  Widget _buildATTTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121F2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _attEnabled
              ? Colors.cyan.withAlpha(40)
              : const Color(0xFF1A2E3D),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "APP TRACKING (iOS)",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Allow HeroDex 3000 to track your activity across other apps.",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _attEnabled,
            onChanged: (val) {
              if (val) {
                // Turning on → show Apple's system dialog
                _requestATT();
              }
              // Turning off is not allowed programmatically on iOS,
              // so we just ignore it — the switch won't move
            },
            activeThumbColor: Colors.cyan,
            activeTrackColor: Colors.cyan.withAlpha(60),
            inactiveTrackColor: const Color(0xFF1A2E3D),
          ),
        ],
      ),
    );
  }


  Widget _buildPermissionTile(
    String title,
    String desc,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121F2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.cyan.withAlpha(40) : const Color(0xFF1A2E3D),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.cyan,
            activeTrackColor: Colors.cyan.withAlpha(60),
            inactiveTrackColor: const Color(0xFF1A2E3D),
          ),
        ],
      ),
    );
  }

  Future<void> _onEstablishLink() async {
    // Save all permission choices
    await context.read<SettingsManager>().saveOnboardingPreferences(
      analytics: _analyticsEnabled,
      crashlytics: _crashlyticsEnabled,
      location: _locationEnabled,
      iosAtt: _attEnabled,
      appThemeChosen: _themePicked
    );

    if (!mounted) return;
    context.go("/home");
  }

  /// Wraps page content in SingleChildScrollView with height constraints
  Widget _buildScrollablePage(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented progress bar
// ---------------------------------------------------------------------------
/// Draws a row of segments, filled up to [currentPage].
/// Each segment is a rounded rectangle with a small gap between them.
class _SegmentedProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _SegmentedProgressBar({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPages, (index) {
        final isCompleted = index <= currentPage;
        return Expanded(
          child: Padding(
            // Small gap between segments (skip left padding on first, right on last)
            padding: EdgeInsets.only(right: index < totalPages - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 3,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.cyan : const Color(0xFF1A2E3D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable page layout
// ---------------------------------------------------------------------------
/// Standard layout for each onboarding page.
/// If [bodyWidget] is provided it's used instead of [body] text.
/// [isLastPage] changes the button style to the outlined "establish" look.
class _OnboardingPageLayout extends StatelessWidget {
  final String title;
  final String? body;
  final Widget? bodyWidget;
  final String buttonText;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool isLastPage;

  const _OnboardingPageLayout({
    required this.title,
    this.body,
    this.bodyWidget,
    required this.buttonText,
    required this.onNext,
    this.onBack,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: .spaceBetween,
        children: [
          Column(
            children: [
              // Top content
              // Back button row — invisible placeholder on first page to keep layout stable
              SizedBox(
                height: 40,
                child: onBack != null
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: onBack,
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              // Title
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Body — either plain text or a custom widget
              if (body != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    body!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
              if (bodyWidget != null) bodyWidget!,
            ],
          ),

          // Bottom button
          Column(
            children: [
              isLastPage ? _buildEstablishButton() : _buildNextButton(context),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEstablishButton() {
    return OutlinedButton(
      onPressed: onNext,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Colors.cyan, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.cyan.withAlpha(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cell_tower, size: 20, color: Colors.white),
          SizedBox(width: 12),
          Text(
            "ESTABLISH SECURE LINK",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// How-to row (used on page 2)
// ---------------------------------------------------------------------------
class _HowToRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HowToRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.cyan.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: Colors.cyan, size: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_cubit.dart';
// import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_state.dart';
// import 'package:flutter_herodex3000/data/managers/settings_manager.dart';
// import 'package:go_router/go_router.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   bool _analyticsEnabled = true;
//   bool _crashlyticsEnabled = true;
//   bool _locationEnabled = false;

//   void _nextPage() {
//     if (_currentPage < 2) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A111A),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: PageView(
//             controller: _pageController,
//             physics: const NeverScrollableScrollPhysics(), // button-only nav
//             onPageChanged: (index) {
//               setState(() => _currentPage = index);
//             },
//             children: [
//               _buildStoryPage(),
//               _buildHowToUsePage(),
//               _buildPermissionsPage(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(VoidCallback? onBack) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         if (onBack != null)
//                 IconButton(
//                   onPressed: onBack,
//                   icon: Icon(Icons.arrow_back_ios),
//                   color: Colors.white,
//                   alignment: .topLeft,
//                 ),
//         const Text(
//           "SYSTEM INITIALIZATION",
//           style: TextStyle(
//             color: Colors.cyan,
//             fontSize: 10,
//             fontFamily: 'monospace',
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(4),
//           decoration: BoxDecoration(border: Border.all(color: Colors.cyan)),
//           child: const Text(
//             "STEP 01 / 03",
//             style: TextStyle(color: Colors.cyan, fontSize: 10),
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _buildStoryPage() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       const Text(
//   //         "INITIALIZING\nSYSTEM",
//   //         style: TextStyle(
//   //           color: Colors.white,
//   //           fontSize: 32,
//   //           fontWeight: FontWeight.bold,
//   //           height: 1.1,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 16),
//   //       Text(
//   //         "HeroDex 3000 connects the remaining heroes and villains to coordinate Earth's defense. Establish your data protocols to begin.",
//   //         style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
//   //       ),
//   //     ],
//   //   );
//   // }

//   Widget _buildStoryPage() {
//     return _OnboardingPageLayout(
//       title: "THE INVASION IS NOT OVER YET",
//       body:
//           "Heroes and villains are re-appearing across the world.\n\n"
//           "HERODEX3000 is your command interface — track, scan, and recruit "
//           "your fellow to rebuild the world again.",
//       buttonText: "NEXT",
//       onNext: _nextPage,
//     );
//   }

//   Widget _buildHowToUsePage() {
//     return _OnboardingPageLayout(
//       title: "HOW IT WORKS",
//       body:
//           "• Scan to discover new allies\n"
//           "• Build your roster\n"
//           "• Track heroes and villains\n"
//           "• Manage your operations in real time",
//       buttonText: "NEXT",
//       onNext: _nextPage,
//       onBack: _previousPage,
//     );
//   }

//   //   Widget _buildHowToUsePage() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       const Text(
//   //         "INITIALIZING\nSYSTEM",
//   //         style: TextStyle(
//   //           color: Colors.white,
//   //           fontSize: 32,
//   //           fontWeight: FontWeight.bold,
//   //           height: 1.1,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 16),
//   //       Text(
//   //         "HeroDex 3000 connects the remaining heroes and villains to coordinate Earth's defense. Establish your data protocols to begin.",
//   //         style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
//   //       ),
//   //     ],
//   //   );
//   // }
//   Widget _buildPermissionsPage() {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A111A),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(_previousPage),
//               const SizedBox(height: 10),
//               _buildPermissionSection(),
//               const Spacer(),
//               _buildEstablishLinkButton(), // saves + completes onboarding
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPermissionSection() {

//     return Column(
//       children: [
//         Text(
//           "The time has come to make a decision. Are you ready to join the forces to rebuild?",
//           style: const TextStyle(
//             color: Colors.cyan,
//             fontSize: 24,
//             letterSpacing: 2,
//           ),
//         ),
//         const SizedBox(height: 34),
//         _buildPermissionTile(
//           "ANALYTICS TRACKING",
//           "Helps us gather analytics about your usage.",
//           _analyticsEnabled,
//           (val) => setState(() => _analyticsEnabled = val),
//         ),
//         _buildPermissionTile(
//           "CRASH TRACKING",
//           "Helps us gather analytics about crash reports.",
//           _crashlyticsEnabled,
//           (val) => setState(() => _crashlyticsEnabled = val),
//         ),
//         _buildPermissionTile(
//           "LOCATION TRACKING",
//           "Maps your location for local hero support.",
//           _locationEnabled,
//           (val) => setState(() => _locationEnabled = val),
//         ),
//       ],
//     );
//   }

//   Widget _buildPermissionTile(
//     String title,
//     String desc,
//     bool value,
//     Function(bool) onChanged,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF121F2B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: value ? Colors.cyan.withAlpha(40) : const Color(0xFF1A2E3D),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   desc,
//                   style: TextStyle(color: Colors.grey[500], fontSize: 10),
//                 ),
//               ],
//             ),
//           ),
//           Switch(
//             value: value,
//             onChanged: onChanged,
//             activeThumbColor: Colors.cyan,
//             activeTrackColor: Colors.cyan.withAlpha(20),
//           ),
//         ],
//       ),
//     );
//   }

//   // När användaren trycker på **"ESTABLISH SECURE LINK"**, anropar vi managern innan vi går till hemvyn.
//   Widget _buildEstablishLinkButton() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
//       child: OutlinedButton(
//         onPressed: () async { // TODO splash and/or spinner?
//           // Saves values locally
//           await context.read<SettingsManager>().saveOnboardingPreferences(
//             analytics: _analyticsEnabled,
//             crashlytics: _crashlyticsEnabled,
//             location: _locationEnabled,
//           );

//           if(!mounted) return; // TODO good or bad idea?
//           final authState = context.read<AuthCubit>().state;
//           if(authState is AuthAuthenticated){
//             context.go("/home");
//           }else{
//             context.go("login");
//           }
//         },
//         style: OutlinedButton.styleFrom(
//           minimumSize: const Size(double.infinity, 56),
//           side: const BorderSide(
//             color: Color.fromARGB(255, 6, 217, 245),
//             width: 1,
//             style: .solid,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Colors.cyan.withAlpha(90),
//         ),
//         child: Row(
//           mainAxisAlignment: .center,
//           children: [
//             Icon(Icons.cell_tower, size: 20, color: Colors.white),
//             SizedBox(width: 12),
//             const Text(
//               "ESTABLISH SECURE LINK",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _OnboardingPageLayout extends StatelessWidget {
//   final String title;
//   final String body;
//   final String buttonText;
//   final VoidCallback onNext;
//   final VoidCallback? onBack;

//   const _OnboardingPageLayout({
//     required this.title,
//     required this.body,
//     required this.buttonText,
//     required this.onNext,
//     this.onBack,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A111A),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (onBack != null)
//                 IconButton(
//                   onPressed: onBack,
//                   icon: Icon(Icons.arrow_back_ios),
//                   color: Colors.white,
//                   alignment: .topLeft,
//                 ), 
//                 if (onBack == null)
//                 IconButton(
//                   onPressed: (){},
//                   icon: Icon(Icons.arrow_back_ios),
//                   color: const Color(0xFF0A111A),
//                   alignment: .topLeft,
//                 ), 
//               const SizedBox(height: 10),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.cyan,
//                   fontSize: 24,
//                   letterSpacing: 2,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 body,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 16,
//                   height: 1.5,
//                 ),
//               ),
//               const Spacer(),
//               Row(
//                 mainAxisAlignment: .end,
//                 children: [
//                   ElevatedButton(onPressed: onNext, child: Text(buttonText)),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
