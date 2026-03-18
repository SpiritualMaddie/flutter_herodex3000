import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';
import 'package:flutter_herodex3000/barrel_files/routing.dart';
import 'package:flutter_herodex3000/barrel_files/theme.dart';

/// Three-page onboarding flow for first-time users.
/// 
/// Pages:
/// 1. Story - Explains the invasion narrative and app purpose
/// 2. How It Works - Feature overview with icons
/// 3. Permissions - Analytics, Crashlytics, iOS ATT, and theme selection
/// 
/// Features:
/// - Segmented progress bar at top
/// - Non-swipeable pages (button navigation only)
/// - Scrollable page content for smaller screens
/// - iOS ATT (App Tracking Transparency) integration
/// - Saves all preferences before navigating to home
/// 
/// Navigation flow:
/// Complete onboarding → saves preferences → redirects to /home
/// 
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  // Permission states (defaults to enabled)
  bool _analyticsEnabled = true;
  bool _crashlyticsEnabled = true;
  //bool _locationEnabled = true;
  bool _attEnabled = true; // iOS App Tracking Transparency
  String _themePicked = "heroDark";

  @override
  void initState() {
    super.initState();

    // Check existing ATT status on iOS (doesn't prompt, just reads current state)
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkATTStatus());
    }
  }

  /// Checks existing ATT status without prompting the user.
  /// 
  /// Called on iOS only to initialize the toggle with current permission state.
  /// Does NOT show Apple's system dialog - just reads the status.
  Future<void> _checkATTStatus() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (!mounted) return;
    setState(() {
      _attEnabled = status == TrackingStatus.authorized;
    });
  }

  /// Requests ATT permission (shows Apple's system dialog if not determined).
  /// 
  /// ATT States:
  /// - notDetermined: Never asked → shows Apple's dialog
  /// - authorized: User granted permission → toggle stays on
  /// - denied: User denied permission → toggle can't be turned back on
  /// - restricted: Device/MDM restrictions → toggle disabled
  /// 
  /// Note: Once denied, user must go to iOS Settings to re-enable.
  /// App can only prompt once per install.
  Future<void> _requestATT() async {
    final currentStatus =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    if (currentStatus == TrackingStatus.notDetermined) {
      // Show Apple's system dialog (can only be shown once)
      final newStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      if (!mounted) return;
      setState(() {
        _attEnabled = newStatus == TrackingStatus.authorized;
      });
    } else {
      // Already determined - update toggle to reflect current status
      if (!mounted) return;
      setState(() {
        _attEnabled = currentStatus == TrackingStatus.authorized;
      });
    }
  }

  /// Navigates to next page with animation.
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Navigates to previous page with animation.
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
            // Progress bar (fixed at top)
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
            
            // Pages (scrollable, fills remaining space)
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swipe navigation
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

  // ===========================================================================
  // PAGE BUILDERS
  // ===========================================================================

  /// Page 1: Story and app purpose.
  Widget _buildStoryPage() {
    return _OnboardingPageLayout(
      title: "THE INVASION\nIS NOT OVER YET",
      body:
          "Heroes and villains are re-appearing across the world.\n\n"
          "HERODEX 3000 is your command interface — track, search, and recruit "
          "your forces to rebuild the world again.",
      buttonText: "NEXT",
      onNext: _nextPage,
      onBack: null, // No back button on first page
    );
  }

  /// Page 2: Feature overview with icons.
  Widget _buildHowToUsePage() {
    return _OnboardingPageLayout(
      title: "HOW IT WORKS",
      body: null, // Using custom bodyWidget instead
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

  /// Page 3: Permissions and theme selection.
  /// 
  /// Permissions:
  /// - Analytics: Firebase Analytics tracking
  /// - Crashlytics: Error reporting to Firebase
  /// - ATT (iOS only): Cross-app tracking permission
  /// 
  /// Theme: User selects initial app theme (Hero/Villain/Neutral × Dark/Light)
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
      isLastPage: true, // Changes button style
      bodyWidget: Column(
        children: [
          // Analytics toggle
          _buildPermissionTile(
            "ANALYTICS TRACKING",
            "Helps us improve the app by gathering usage data.",
            _analyticsEnabled,
            (val) => setState(() => _analyticsEnabled = val),
          ),

          // Crashlytics toggle
          _buildPermissionTile(
            "CRASH REPORTING",
            "Helps us fix issues by sending crash reports.",
            _crashlyticsEnabled,
            (val) => setState(() => _crashlyticsEnabled = val),
          ),

          // Location toggle
          // _buildPermissionTile(
          //   "LOCATION",
          //   "Maps your location for local hero support.",
          //   _locationEnabled,
          //   (val) => setState(() => _locationEnabled = val),
          // ),
          
          // ATT toggle (iOS only)
          if (defaultTargetPlatform == TargetPlatform.iOS) _buildATTTile(),

          // Theme picker section
          SectionHeader(
            title: "WHATS YOUR ALIGNMENT?",
            subtitle: "(choose app theme)",
            titleFontSize: 16,
            subtitleFontSize: 12,
          ),
          ThemePicker(onThemeSelected: (theme) { // TODO look over the saving of themes and saved prefs
                        context.read<ThemeCubit>().setTheme(theme);
                        settings.saveCurrentAppTheme(value: theme.name);
                      },),
        ],
      ),
    );
  }

  /// iOS ATT toggle tile.
  /// 
  /// Special handling:
  /// - Turning ON: Shows Apple's system dialog via _requestATT()
  /// - Turning OFF: Not allowed programmatically (iOS restriction)
  /// - Toggle reflects current permission status
  /// 
  /// Note: Apple's ATT can only prompt once per app install.
  /// If user denies, they must enable in iOS Settings → Privacy.
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
              // Turning off is not allowed programmatically on iOS
              // Switch won't move if user tries to disable
            },
            activeThumbColor: Colors.cyan,
            activeTrackColor: Colors.cyan.withAlpha(60),
            inactiveTrackColor: const Color(0xFF1A2E3D),
          ),
        ],
      ),
    );
  }

  /// Generic permission toggle tile (Analytics, Crashlytics).
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

  /// Saves all onboarding choices and navigates to home.
  /// 
  /// Saves to SharedPreferences:
  /// - Analytics enabled/disabled
  /// - Crashlytics enabled/disabled
  /// - iOS ATT status
  /// - Selected theme (TODO does it though?)
  /// - Onboarding completed flag
  /// 
  /// Then navigates to /home (which triggers auth redirect if needed).
  Future<void> _onEstablishLink() async {
    await context.read<SettingsManager>().saveOnboardingPreferences(
      analytics: _analyticsEnabled,
      crashlytics: _crashlyticsEnabled,
      //location: _locationEnabled,
      iosAtt: _attEnabled,
      appThemeChosen: _themePicked,
    );

    if (!mounted) return;
    context.go("/home");
  }

  /// Wraps page content in SingleChildScrollView with height constraints.
  /// 
  /// Why this pattern:
  /// - Allows scrolling if content exceeds screen height
  /// - Ensures minimum height fills screen (for proper spacing)
  /// - LayoutBuilder provides accurate constraints
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

// ===========================================================================
// REUSABLE WIDGETS
// ===========================================================================

/// Segmented progress bar showing current page.
/// 
/// Draws horizontal segments (one per page), filled up to [currentPage].
/// Animates smoothly when page changes.
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

/// Standard layout template for onboarding pages.
/// 
/// Layout structure:
/// - Back button (if onBack provided)
/// - Title (large cyan text)
/// - Body text OR custom bodyWidget
/// - Next/Finish button at bottom
/// 
/// [isLastPage] changes button style to outlined "establish link" variant.
class _OnboardingPageLayout extends StatelessWidget {
  final String title;
  final String? body; // Plain text body
  final Widget? bodyWidget; // Custom widget body (takes precedence over body)
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
          // Top content
          Column(
            children: [
              // Back button (invisible placeholder on first page for layout stability)
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

              // Body content (either plain text or custom widget)
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

  /// Standard "NEXT" button (cyan background, right-aligned).
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

  /// "ESTABLISH SECURE LINK" button (outlined, full-width, with icon).
  /// Used only on final page.
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

/// Icon + text row used in "How It Works" page.
/// 
/// Layout: Icon in colored square on left, description text on right.
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
          // Icon container
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
          
          // Description text
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