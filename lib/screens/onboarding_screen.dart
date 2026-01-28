import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/managers/settings_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _analyticsEnabled = true;
  bool _crashlyticsEnabled = true;
  bool _locationEnabled = false;

  void _nextPage() {
    if (_currentPage < 2) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // button-only nav
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              _buildStoryPage(),
              _buildHowToUsePage(),
              _buildPermissionsPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VoidCallback? onBack) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  alignment: .topLeft,
                ),
        const Text(
          "SYSTEM INITIALIZATION",
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: Colors.cyan)),
          child: const Text(
            "STEP 01 / 03",
            style: TextStyle(color: Colors.cyan, fontSize: 10),
          ),
        ),
      ],
    );
  }

  // Widget _buildStoryPage() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         "INITIALIZING\nSYSTEM",
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 32,
  //           fontWeight: FontWeight.bold,
  //           height: 1.1,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       Text(
  //         "HeroDex 3000 connects the remaining heroes and villains to coordinate Earth's defense. Establish your data protocols to begin.",
  //         style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildStoryPage() {
    return _OnboardingPageLayout(
      title: "THE INVASION IS NOT OVER YET",
      body:
          "Heroes and villains are re-appearing across the world.\n\n"
          "HERODEX3000 is your command interface — track, scan, and recruit "
          "your fellow to rebuild the world again.",
      buttonText: "NEXT",
      onNext: _nextPage,
    );
  }

  Widget _buildHowToUsePage() {
    return _OnboardingPageLayout(
      title: "HOW IT WORKS",
      body:
          "• Scan to discover new allies\n"
          "• Build your roster\n"
          "• Track heroes and villains\n"
          "• Manage your operations in real time",
      buttonText: "NEXT",
      onNext: _nextPage,
      onBack: _previousPage,
    );
  }

  //   Widget _buildHowToUsePage() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         "INITIALIZING\nSYSTEM",
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 32,
  //           fontWeight: FontWeight.bold,
  //           height: 1.1,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       Text(
  //         "HeroDex 3000 connects the remaining heroes and villains to coordinate Earth's defense. Establish your data protocols to begin.",
  //         style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildPermissionsPage() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(_previousPage),
              const SizedBox(height: 10),
              _buildPermissionSection(),
              const Spacer(),
              _buildEstablishLinkButton(), // saves + completes onboarding
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionSection() {

    return Column(
      children: [
        Text(
          "The time has come to make a decision. Are you ready to join the forces to rebuild?",
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 34),
        _buildPermissionTile(
          "ANALYTICS TRACKING",
          "Helps us gather analytics about your usage.",
          _analyticsEnabled,
          (val) => setState(() => _analyticsEnabled = val),
        ),
        _buildPermissionTile(
          "CRASH TRACKING",
          "Helps us gather analytics about crash reports.",
          _crashlyticsEnabled,
          (val) => setState(() => _crashlyticsEnabled = val),
        ),
        _buildPermissionTile(
          "LOCATION TRACKING",
          "Maps your location for local hero support.",
          _locationEnabled,
          (val) => setState(() => _locationEnabled = val),
        ),
      ],
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
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.cyan,
            activeTrackColor: Colors.cyan.withAlpha(20),
          ),
        ],
      ),
    );
  }

  // När användaren trycker på **"ESTABLISH SECURE LINK"**, anropar vi managern innan vi går till hemvyn.
  Widget _buildEstablishLinkButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: OutlinedButton(
        onPressed: () async { // TODO splash and/or spinner
          // Saves values locally
          await context.read<SettingsManager>().saveOnboardingPreferences(
            analytics: _analyticsEnabled,
            crashlytics: _crashlyticsEnabled,
            location: _locationEnabled,
          );
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(
            color: Color.fromARGB(255, 6, 217, 245),
            width: 1,
            style: .solid,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.cyan.withAlpha(90),
        ),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.cell_tower, size: 20, color: Colors.white),
            SizedBox(width: 12),
            const Text(
              "ESTABLISH SECURE LINK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageLayout extends StatelessWidget {
  final String title;
  final String body;
  final String buttonText;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const _OnboardingPageLayout({
    required this.title,
    required this.body,
    required this.buttonText,
    required this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  alignment: .topLeft,
                ), 
                if (onBack == null)
                IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.arrow_back_ios),
                  color: const Color(0xFF0A111A),
                  alignment: .topLeft,
                ), 
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: .end,
                children: [
                  ElevatedButton(onPressed: onNext, child: Text(buttonText)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
