import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/theme.dart';

// // Map AppTheme enum -> ThemeData and expose convenience accessors.
extension AppThemeData on AppTheme {
  ThemeData get themeData {
    switch (this) {
      case AppTheme.heroDark:
        return AppThemes.heroDark;
      case AppTheme.heroLight:
        return AppThemes.heroLight;
      case AppTheme.villainDark:
        return AppThemes.villainDark;
      case AppTheme.villainLight:
        return AppThemes.villainLight;
      case AppTheme.neutralDark:
        return AppThemes.neutralDark;
      case AppTheme.neutralLight:
        return AppThemes.neutralLight;
    }
  }

  Color get primaryColor => themeData.colorScheme.primary;
  Color get scaffoldBackgroundColor => themeData.scaffoldBackgroundColor;
  bool get isDark => themeData.brightness == Brightness.dark;
}

/// Grid of theme cards showing all available themes.
/// Calls [onThemeSelected] when user taps a theme.
class ThemePicker extends StatelessWidget {
  final Function(AppTheme) onThemeSelected;

  const ThemePicker({
    super.key,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppTheme>(
      builder: (context, currentTheme) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true, // Important: lets it size itself
            physics: const NeverScrollableScrollPhysics(), // Parent handles scroll
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: AppTheme.values.map((theme) {
              final isSelected = theme == currentTheme;
              return _ThemeCard(
                theme: theme,
                isSelected: isSelected,
                onTap: () => onThemeSelected(theme),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  // Color previews for each theme
  Color get _primaryColor {
    switch (theme) {
      case AppTheme.heroDark:
      case AppTheme.heroLight:
      case AppTheme.villainDark:
      case AppTheme.villainLight:
      case AppTheme.neutralDark:
      case AppTheme.neutralLight:
        return theme.primaryColor;
    }
  }

  Color get _backgroundColor {
    switch (theme) {
      case AppTheme.heroDark:
      case AppTheme.heroLight:
      case AppTheme.villainDark:
      case AppTheme.villainLight:
      case AppTheme.neutralDark:
      case AppTheme.neutralLight:
        return theme.scaffoldBackgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : _primaryColor.withAlpha(60),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Color preview bar at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: _primaryColor.withAlpha(40),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Container(
                    height: 4,
                    width: 50,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            // Theme name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.alignment.toUpperCase(),
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.isDark ? 'DARK' : 'LIGHT',
                    style: TextStyle(
                      color: theme.isDark ? Colors.white : Colors.black,
                      fontSize: 9,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
            ),
            // Selected checkmark
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_herodex3000/core/theme/app_theme.dart';
// import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';

// // Map AppTheme enum -> ThemeData and expose convenience accessors.
// extension AppThemeData on AppTheme {
//   ThemeData get themeData {
//     switch (this) {
//       case AppTheme.heroDark:
//         return AppThemes.heroDark;
//       case AppTheme.heroLight:
//         return AppThemes.heroLight;
//       case AppTheme.villainDark:
//         return AppThemes.villainDark;
//       case AppTheme.villainLight:
//         return AppThemes.villainLight;
//       case AppTheme.neutralDark:
//         return AppThemes.neutralDark;
//       case AppTheme.neutralLight:
//         return AppThemes.neutralLight;
//     }
//   }

//   Color get primaryColor => themeData.colorScheme.primary;
//   Color get scaffoldBackgroundColor => themeData.scaffoldBackgroundColor;
//   bool get isDark => themeData.brightness == Brightness.dark;
// }

// // TODO Change name!
// /// Grid of theme cards showing all available themes.
// /// User taps one to switch the entire app's theme.
// class ThemePicker extends StatelessWidget {
//   final Function(String) themePicked;
//   const ThemePicker({super.key, required this.themePicked});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, AppTheme>(
//       builder: (context, currentTheme) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: GridView.count(
//             crossAxisCount: 2,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             childAspectRatio: 1.4,
//             children: AppTheme.values.map((theme) {
//               final isSelected = theme == currentTheme;
//               return _ThemeCard(
//                 theme: theme,
//                 isSelected: isSelected,
//                 onTap: () => themePicked,
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

// class _ThemeCard extends StatelessWidget {
//   final AppTheme theme;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _ThemeCard({
//     required this.theme,
//     required this.isSelected,
//     required this.onTap,
//   });
  
  

//   // Color previews for each theme
//   Color get _primaryColor {
//     switch (theme) {
//       case AppTheme.heroDark:
//       case AppTheme.heroLight:
//       case AppTheme.villainDark:
//       case AppTheme.villainLight:
//       case AppTheme.neutralDark:
//       case AppTheme.neutralLight:
//         return theme.primaryColor;
//     }
//   }

//   Color get _backgroundColor {
//     switch (theme) {
//       case AppTheme.heroDark:
//       case AppTheme.heroLight:
//       case AppTheme.villainDark:
//       case AppTheme.villainLight:
//       case AppTheme.neutralDark:
//       case AppTheme.neutralLight:
//         return theme.scaffoldBackgroundColor;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: _backgroundColor,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? _primaryColor : _primaryColor.withAlpha(60),
//             width: isSelected ? 3 : 1,
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Color preview bars
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: _primaryColor.withAlpha(40),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(12),
//                     bottomRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Center(
//                   child: Container(
//                     height: 4,
//                     width: 50,
//                     decoration: BoxDecoration(
//                       color: _primaryColor,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Theme name
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     theme.alignment.toUpperCase(),
//                     style: TextStyle(
//                       color: _primaryColor,
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     theme.isDark ? 'DARK' : 'LIGHT',
//                     style: TextStyle(
//                       color: theme.isDark ? Colors.white70 : Colors.black,
//                       fontWeight: .bold,
//                       fontSize: 9,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Selected checkmark
//             if (isSelected)
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: _primaryColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.check,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';
// import 'package:flutter_herodex3000/data/managers/settings_manager.dart';

// class ThemeToggleButtons extends StatelessWidget {
//   const ThemeToggleButtons({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, AppTheme>(
//       builder: (context, themeState) {
//         return Container(
//           padding: EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             color: Color(0xFF121F2B),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Color(0xFF1A2E3D)),
//           ),
//           child: Row(
//             spacing: 33,
//             children: [
//               Expanded(
//                 child: InkWell(
//                   onTap: () {
//                     context.read<ThemeCubit>().setTheme(AppTheme.light);
//                     context.read<SettingsManager>().saveCurrentAppTheme(
//                       value: "light",
//                     );
//                   },
//                   borderRadius: .circular(8),
//                   child: _buildToggleButton(
//                     "HERO (LIGHT)",
//                     themeState == AppTheme.light,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: InkWell(
//                   onTap: () {
//                     context.read<ThemeCubit>().setTheme(AppTheme.dark);
//                     context.read<SettingsManager>().saveCurrentAppTheme(
//                       value: "dark",
//                     );
//                   },
//                   borderRadius: .circular(8),
//                   child: _buildToggleButton(
//                     "VILLAIN (DARK)",
//                     themeState == AppTheme.dark,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildToggleButton(String label, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         color: isSelected
//             ? const Color(0xFF00E5FF).withAlpha(20)
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//         border: isSelected
//             ? Border.all(color: const Color(0xFF00E5FF).withAlpha(40))
//             : null,
//       ),
//       child: Center(
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? const Color(0xFF00E5FF) : Colors.grey[600],
//             fontWeight: FontWeight.bold,
//             fontSize: 12,
//             letterSpacing: 1.1,
//           ),
//         ),
//       ),
//     );
//   }
// }
