import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';
import 'package:flutter_herodex3000/barrel_files/theme.dart';
import 'package:flutter_herodex3000/barrel_files/authentication.dart';

/// Settings screen for managing app preferences and permissions.
/// 
/// Sections:
/// 1. Data Protocols - Toggle Analytics, Crashlytics, iOS ATT
/// 2. System Manifest - App version, creator info, year
/// 3. App Alignment - Theme picker (Hero/Villain/Neutral × Dark/Light)
/// 4. Logout - Sign out button
/// 
/// Features:
/// - Real-time permission updates (saves to SharedPreferences + Firebase)
/// - Version display with DEV/STABLE suffix based on build mode
/// - iOS ATT informational dialog (can't change programmatically)
/// - Responsive layout with CustomScrollView
/// 

/// Late-initialized package info future (fetched once on screen load).
late Future<PackageInfo> _packageInfo;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch app version info once when screen loads
    _packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();

    return ResponsiveScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar as sliver (allows scrolling under it)
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: false, // Scrolls away with content
              title:
              const SectionHeader(
                icon: Icons.settings,
                title: "SETTINGS",
                titleFontSize: 22,
                padding: EdgeInsets.only(bottom: 12, top: 38),
              ),
            ),

            // All content in single sliver
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === DATA PROTOCOLS SECTION ===
                    const SectionHeader(
                      title: "DATA PROTOCOLS",
                      subtitle: "Manage tracking permissions",
                    ),

                    // Analytics toggle
                    _ProtocolTile(
                      icon: Icons.analytics,
                      title: "Analytics Tracking",
                      subtitle:
                          "STATUS: ${settings.analyticsEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                      value: settings.analyticsEnabled,
                      onChanged: (val) =>
                          settings.saveAnalyticsPreferences(value: val),
                    ),

                    // Crashlytics toggle
                    _ProtocolTile(
                      icon: Icons.bug_report,
                      title: "Crash Tracking",
                      subtitle:
                          "STATUS: ${settings.crashlyticsEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                      value: settings.crashlyticsEnabled,
                      onChanged: (val) =>
                          settings.saveCrashAnalyticsPreferences(value: val),
                    ),

                    // Location toggle
                    // _ProtocolTile(
                    //   icon: Icons.location_on,
                    //   title: "Location Tracking",
                    //   subtitle:
                    //       "STATUS: ${settings.locationEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                    //   value: settings.locationEnabled,
                    //   onChanged: (val) =>
                    //       settings.saveLocationAnalyticsPreferences(value: val),
                    // ),

                    // iOS ATT tile (read-only, shows dialog on tap)
                    if (defaultTargetPlatform == TargetPlatform.iOS)
                      _ProtocolTile(
                        icon: Icons.privacy_tip,
                        title: "App Tracking (iOS)",
                        subtitle:
                            "STATUS: ${settings.iosAttEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                        value: settings.iosAttEnabled,
                        onChanged: (val) {
                          // Can't change ATT programmatically after initial request
                          // Show dialog explaining user must go to iOS Settings
                          _showATTDialog(context);
                        },
                      ),

                    // === SYSTEM MANIFEST SECTION ===
                    const SectionHeader(title: "SYSTEM MANIFEST"),
                    InfoCard(
                      child: Column(
                        children: [
                          _ManifestRow(
                            label: "APPLICATION",
                            value: "HERODEX 3000",
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(40),
                            height: 24,
                          ),
                          // Version row (async, waits for PackageInfo)
                          buildVersionRow(),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(40),
                            height: 24,
                          ),
                          _ManifestRow(
                            label: "CREATOR",
                            value: "SPIRITUALMADDIE",
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(40),
                            height: 24,
                          ),
                          _ManifestRow(label: "YEAR", value: "2025 / 2026"),
                        ],
                      ),
                    ),
                    
                    // === THEME PICKER SECTION ===
                    const SectionHeader(
                      title: "APP ALIGNMENT",
                      subtitle: "Manage app theme",
                    ),
                    ThemePicker(
                      onThemeSelected: (theme) {
                        // Update theme immediately via Cubit
                        context.read<ThemeCubit>().setTheme(theme);
                        // Save to SharedPreferences for persistence
                        settings.saveCurrentAppTheme(value: theme.name);
                      },
                    ),
                    const SizedBox(height: 32),

                    // === LOGOUT BUTTON ===
                    _LogoutButton(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds version row with async PackageInfo fetch.
  /// 
  /// Displays:
  /// - Version number (e.g., "v1.0.0")
  /// - Build suffix: "DEV" (debug mode) or "STABLE" (release mode)
  /// 
  /// Why FutureBuilder:
  /// - PackageInfo.fromPlatform() is async (reads from native code)
  /// - Shows placeholder "v–" while loading
  /// - Rebuilds when future completes
Widget buildVersionRow() {
  return FutureBuilder<PackageInfo>(
    future: PackageInfo.fromPlatform(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const _ManifestRow(
          label: "VERSION",
          value: "v–",
        );
      }

      final info = snapshot.data!;
      // Debug builds show "DEV", release builds show "STABLE"
      final suffix = kReleaseMode ? " STABLE" : " DEV";

      return _ManifestRow(
        label: "VERSION",
        value: "v${info.version} - $suffix",
      );
    },
  );
}

  /// Shows dialog explaining iOS ATT must be changed in iOS Settings.
  /// 
  /// Why this dialog:
  /// - Apple's ATT can only prompt once per app install
  /// - After initial prompt, permission can only be changed in iOS Settings
  /// - This dialog informs users where to go if they want to change it
  void _showATTDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121F2B),
        title: Text(
          "App Tracking",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(
          "To change App Tracking permissions, please go to:\n\n"
          "Settings > Privacy & Security > Tracking > HeroDex 3000",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PRIVATE WIDGETS
// ===========================================================================

/// Toggle tile for data protocol permissions.
/// 
/// Layout:
/// - Icon in colored square on left
/// - Title and status subtitle in middle
/// - Switch toggle on right
/// 
/// Used for Analytics, Crashlytics, and iOS ATT toggles.
class _ProtocolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _ProtocolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Switch toggle
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            activeTrackColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(60),
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}

/// Label/value row in system manifest section.
/// 
/// Displays app metadata like version, creator, year.
/// Uses monospace font for values (terminal aesthetic).
class _ManifestRow extends StatelessWidget {
  final String label;
  final String value;

  const _ManifestRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            fontFamily: 'monospace', // Terminal-style font
            letterSpacing: 1
          ),
        ),
      ],
    );
  }
}

/// Logout button that calls AuthCubit.signOut().
/// 
/// On success:
/// - AuthCubit emits AuthUnauthenticated
/// - Router automatically redirects to /login
/// - SharedPreferences cleared (see AuthCubit implementation)
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        // Sign out via AuthCubit (handles all cleanup)
        await context.read<AuthCubit>().signOut();
        // Router handles navigation automatically
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            "LOGOUT",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
