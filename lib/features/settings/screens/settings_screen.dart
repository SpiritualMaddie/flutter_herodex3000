import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/data/managers/settings_manager.dart';
import 'package:flutter_herodex3000/presentation/widgets/section_header.dart';
import 'package:flutter_herodex3000/presentation/widgets/info_card.dart';
import 'package:flutter_herodex3000/presentation/widgets/theme_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();

    return Scaffold(
      // TODO change to SectionHeader
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar as sliver
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: false,
              title: Text(
                "SETTINGS",
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // All content in one sliver list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data protocols section
                    const SectionHeader(
                      title: "DATA PROTOCOLS",
                      subtitle: "Manage tracking permissions",
                    ),
                    _ProtocolTile(
                      icon: Icons.analytics,
                      title: "Analytics Tracking",
                      subtitle:
                          "STATUS: ${settings.analyticsEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                      value: settings.analyticsEnabled,
                      onChanged: (val) =>
                          settings.saveAnalyticsPreferences(value: val),
                    ),
                    _ProtocolTile(
                      icon: Icons.bug_report,
                      title: "Crash Tracking",
                      subtitle:
                          "STATUS: ${settings.crashlyticsEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                      value: settings.crashlyticsEnabled,
                      onChanged: (val) =>
                          settings.saveCrashAnalyticsPreferences(value: val),
                    ),
                    _ProtocolTile(
                      icon: Icons.location_on,
                      title: "Location Tracking",
                      subtitle:
                          "STATUS: ${settings.locationEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                      value: settings.locationEnabled,
                      onChanged: (val) =>
                          settings.saveLocationAnalyticsPreferences(value: val),
                    ),

                    // iOS ATT if applicable
                    if (defaultTargetPlatform == TargetPlatform.iOS)
                      _ProtocolTile(
                        icon: Icons.privacy_tip,
                        title: "App Tracking (iOS)",
                        subtitle:
                            "STATUS: ${settings.iosAttEnabled ? 'AUTHORIZED' : 'DISABLED'}",
                        value: settings.iosAttEnabled,
                        onChanged: (val) {
                          // Can't change ATT programmatically after initial request
                          // Show dialog explaining they need to go to Settings
                          _showATTDialog(context);
                        },
                      ),

                    // System manifest section
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
                          _ManifestRow(
                            label: "VERSION",
                            value: "v3.0.1-STABLE",
                          ),
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
                    // Theme picker section
                    const SectionHeader(
                      title: "APP ALIGNMENT",
                      subtitle: "Manage app theme",
                    ),
                    ThemePicker(
                      onThemeSelected: (theme) {
                        context.read<ThemeCubit>().setTheme(theme);
                        settings.saveCurrentAppTheme(value: theme.name);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Logout button
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

// ---------------------------------------------------------------------------
// Protocol toggle tile
// ---------------------------------------------------------------------------
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
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

// ---------------------------------------------------------------------------
// Manifest row
// ---------------------------------------------------------------------------
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
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Logout button
// ---------------------------------------------------------------------------
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        await context.read<AuthCubit>().signOut();
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

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';
// import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_cubit.dart';
// import 'package:flutter_herodex3000/data/managers/settings_manager.dart';
// import 'package:flutter_herodex3000/presentation/widgets/theme_picker.dart';

// // TODO Some error with ParentDataWidget, some Expanded thats at fault? Could be in main?
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final settings = context.watch<SettingsManager>();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "SETTINGS",
//           style: TextStyle(letterSpacing: 2, fontSize: 25, color: Colors.cyan),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: .start,
//                 mainAxisAlignment: .start,
//                 children: [
//                   _buildSectionHeader("APP ALIGNMENT"),
//                   _buildScrollableView(
//                     ThemePicker(themePicked: (val) => settings.saveCurrentAppTheme(value: val))),
//                   _buildSectionHeader(
//                     "DATA PROTOCOLS",
//                   ), // TODO analytics agreement
//                   _buildProtocolTile(
//                     Icons.analytics,
//                     "Analytics Tracking",
//                     "STATUS: ${_authorizedPermission(settings.analyticsEnabled)}",
//                     settings.analyticsEnabled,
//                     (val) => settings.saveAnalyticsPreferences(value: val),
//                   ),
//                   _buildProtocolTile(
//                     Icons.analytics,
//                     "Crash Tracking",
//                     "STATUS: ${_authorizedPermission(settings.crashlyticsEnabled)}",
//                     settings.crashlyticsEnabled,
//                     (val) =>
//                         settings.saveCrashAnalyticsPreferences(value: val),
//                   ),
//                   _buildProtocolTile(
//                     Icons.location_on,
//                     "Location Tracking",
//                     "STATUS: ${_authorizedPermission(settings.locationEnabled)}",
//                     settings.locationEnabled,
//                     (val) =>
//                         settings.saveLocationAnalyticsPreferences(value: val),
//                   ),
//                   // TODO if ios then ATT protocol tile
//                   _buildSectionHeader("SYSTEM MANIFEST"),
//                   _buildSystemManifest(),
//                   SizedBox(height: 40),
//                   _buildLogoutButton(context),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _authorizedPermission(bool permission) {
//     return permission ? "AUTHORIZED" : "DISABLED";
//   }

//   /// Wraps content in SingleChildScrollView with height constraints
//   Widget _buildScrollableView(Widget child) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minHeight: constraints.maxHeight),
//             child: child,
//           ),
//         );
//       },
//     );
//   }


//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0, top: 14),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Color(0xFF00E5FF),
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.5,
//         ),
//       ),
//     );
//   }


//   Widget _buildProtocolTile(
//     IconData icon,
//     String title,
//     String subtitle,
//     bool value,
//     Function(bool) onChanged,
//   ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Color(0xFF121F2B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Color(0xFF1A2E3D)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Color(0xFF0A111A),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: Color(0xFF00E5FF)),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: TextStyle(color: Colors.grey, fontSize: 10),
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

//   Widget _buildSystemManifest() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF121F2B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF1A2E3D)),
//       ),
//       child: Column(
//         children: [
//           _buildManifestRow("APPLICATION", "HERODEX 3000"),
//           const Divider(color: Color(0xFF1A2E3D), height: 24),
//           _buildManifestRow(
//             "VERSION",
//             "v3.0.1-STABLE",
//           ), // TODO change version dynamically?
//           const Divider(color: Color(0xFF1A2E3D), height: 24),
//           _buildManifestRow(
//             "CREATOR",
//             "SPIRITUALMADDIE",
//           ), // TODO link to github?
//           const Divider(color: Color(0xFF1A2E3D), height: 24),
//           _buildManifestRow("YEAR", "2025 / 2026"),
//         ],
//       ),
//     );
//   }

//   Widget _buildManifestRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[500],
//             fontSize: 10,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 11,
//             fontFamily: 'monospace',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLogoutButton(BuildContext context) {
//     return OutlinedButton(
//       onPressed: () async {
//         await context.read<AuthCubit>().signOut();
//       },
//       style: OutlinedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 56),
//         side: const BorderSide(
//           color: Colors.redAccent,
//           width: 1,
//           style: BorderStyle.solid,
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         backgroundColor: Colors.redAccent.withAlpha(10),
//       ),
//       child: const Row(
//         mainAxisAlignment: .center,
//         children: [
//           Icon(Icons.logout, color: Colors.redAccent, size: 20),
//           SizedBox(width: 12),
//           Text(
//             "LOGOUT",
//             style: TextStyle(
//               color: Colors.redAccent,
//               fontWeight: .bold,
//               letterSpacing: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


  // Widget _buildThemeToggle() {
  //   return BlocBuilder<ThemeCubit, AppTheme>(
  //     builder: (context, themeState) {
  //       return Container(
  //         padding: EdgeInsets.all(4),
  //         decoration: BoxDecoration(
  //           color: Color(0xFF121F2B),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: Color(0xFF1A2E3D)),
  //         ),
  //         child: Row(
  //           spacing: 33,
  //           children: [
  //             Expanded(
  //               child: InkWell(
  //                 onTap: () {
  //                   context.read<ThemeCubit>().setTheme(AppTheme.light);
  //                   context.read<SettingsManager>().saveCurrentAppTheme(value: "light");
  //                 },
  //                 borderRadius: .circular(8),
  //                 child: _buildToggleButton(
  //                   "HERO (LIGHT)",
  //                   themeState == AppTheme.light,
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               child: InkWell(
  //                 onTap: () {
  //                   context.read<ThemeCubit>().setTheme(AppTheme.dark);
  //                   context.read<SettingsManager>().saveCurrentAppTheme(
  //                     value: "dark",
  //                   );
  //                 },
  //                 borderRadius: .circular(8),
  //                 child: _buildToggleButton(
  //                   "VILLAIN (DARK)",
  //                   themeState == AppTheme.dark,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildToggleButton(String label, bool isSelected) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 12),
  //     decoration: BoxDecoration(
  //       color: isSelected
  //           ? const Color(0xFF00E5FF).withAlpha(20)
  //           : Colors.transparent,
  //       borderRadius: BorderRadius.circular(8),
  //       border: isSelected
  //           ? Border.all(color: const Color(0xFF00E5FF).withAlpha(40))
  //           : null,
  //     ),
  //     child: Center(
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           color: isSelected ? const Color(0xFF00E5FF) : Colors.grey[600],
  //           fontWeight: FontWeight.bold,
  //           fontSize: 12,
  //           letterSpacing: 1.1,
  //         ),
  //       ),
  //     ),
  //   );
  // }