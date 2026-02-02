import 'package:flutter/material.dart';

/// Defines the three alignment-based themes for HeroDex 3000.
/// Each has a distinct color scheme to match hero/villain/neutral aesthetics.
class AppThemes {
  // ========================================================================
  // HERO THEME (Cyan/Blue)
  // ========================================================================
  
  static final ThemeData heroDark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 0, 188, 212),
      brightness: Brightness.dark,
      primary: const Color.fromARGB(255, 0, 188, 212),
      secondary: const Color.fromARGB(255, 0, 151, 167),
      surface: const Color.fromARGB(255, 10, 17, 26),
      surfaceContainerHighest: const Color.fromARGB(255, 18, 31, 43),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 10, 17, 26),
    cardColor: const Color.fromARGB(255, 18, 31, 43),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static final ThemeData heroLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 0, 86, 97),
      brightness: Brightness.light,
      primary: const Color.fromARGB(255, 0, 86, 97),
      secondary: const Color.fromARGB(255, 0, 126, 143),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 229, 251, 255),
    cardColor: Colors.white,
  );

  // ========================================================================
  // VILLAIN THEME (Red/Orange)
  // ========================================================================
  
  static final ThemeData villainDark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 255, 82, 82), // Red accent
      brightness: Brightness.dark,
      primary: const Color.fromARGB(255, 255, 82, 82),
      secondary: const Color.fromARGB(255, 255, 110, 64), // Deep orange
      surface: const Color.fromARGB(255, 26, 10, 10), // Dark red-tinted background
      surfaceContainerHighest: const Color.fromARGB(255, 43, 18, 18),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 26, 10, 10),
    cardColor: const Color.fromARGB(255, 43, 18, 18),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static final ThemeData villainLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 224, 0, 0),
      brightness: Brightness.light,
      primary: const Color.fromARGB(255, 224, 0, 0),
      secondary: const Color.fromARGB(255, 214, 50, 0),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 245, 245),
    cardColor: const Color.fromARGB(255, 255, 245, 245),
  );

  // ========================================================================
  // NEUTRAL THEME (Purple/Green)
  // ========================================================================
  
  static final ThemeData neutralDark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 190, 63, 213), // Purple
      brightness: Brightness.dark,
      primary: const Color.fromARGB(255, 190, 63, 213),
      secondary: const Color.fromARGB(255, 102, 187, 106), // Green accent
      surface: const Color.fromARGB(255, 15, 10, 26), // Dark purple-tinted
      surfaceContainerHighest: const Color.fromARGB(255, 26, 18, 43),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 15, 10, 26),
    cardColor: const Color.fromARGB(255, 26, 18, 43),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static final ThemeData neutralLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 156, 39, 176),
      brightness: Brightness.light,
      primary: const Color.fromARGB(255, 123, 31, 162),
      secondary: const Color.fromARGB(255, 57, 127, 62),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 249, 245, 255),
    cardColor: const Color.fromARGB(255, 249, 245, 255),
  );

  // ========================================================================
  // LEGACY (for backwards compatibility with existing code) // TODO remove?
  // ========================================================================
  
  /// Alias for heroDark — keeps existing `AppThemes.dark` calls working
  static final ThemeData dark = heroDark;
  
  /// Alias for heroLight — keeps existing `AppThemes.light` calls working
  static final ThemeData light = heroLight;
}

// import 'package:flutter/material.dart';

// class AppThemes {
//   static final light = ThemeData(
//     brightness: Brightness.light,
//     useMaterial3: true,
//     colorSchemeSeed: const Color.fromARGB(255, 118, 175, 250),
//   );

//   static final dark = ThemeData(
//     brightness: Brightness.dark,
//     useMaterial3: true,
//     colorSchemeSeed: const Color(0xFF121F2B),
//   );
// }