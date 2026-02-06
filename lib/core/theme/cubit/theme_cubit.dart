import 'package:flutter_herodex3000/barrel_files/theme.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

/// The available theme alignments in HeroDex 3000.
/// Each has both a dark and light variant.
enum AppTheme {
  heroDark,
  heroLight,
  villainDark,
  villainLight,
  neutralDark,
  neutralLight;

  /// Returns just the alignment part (hero/villain/neutral)
  String get alignment {
    if (name.startsWith('hero')) return 'hero';
    if (name.startsWith('villain')) return 'villain';
    return 'neutral';
  }

  /// Returns just the brightness part (dark/light)
  bool get isDark => name.endsWith('Dark');

  /// User-friendly display name
  String get displayName {
    switch (this) {
      case AppTheme.heroDark:
        return 'Hero (Dark)';
      case AppTheme.heroLight:
        return 'Hero (Light)';
      case AppTheme.villainDark:
        return 'Villain (Dark)';
      case AppTheme.villainLight:
        return 'Villain (Light)';
      case AppTheme.neutralDark:
        return 'Neutral (Dark)';
      case AppTheme.neutralLight:
        return 'Neutral (Light)';
    }
  }
}


/// Manages the app's current theme.
/// Emits [AppTheme] enum values, which get mapped to actual ThemeData in main.dart.
class ThemeCubit extends Cubit<AppTheme> {
  ThemeCubit({AppTheme initial = AppTheme.heroDark}) : super(initial);

  /// Changes to a specific theme
  void setTheme(AppTheme theme) {
    emit(theme);
  }

  /// Toggles between dark and light within the current alignment
  void toggleBrightness() {
    final current = state;
    switch (current) {
      case AppTheme.heroDark:
        emit(AppTheme.heroLight);
      case AppTheme.heroLight:
        emit(AppTheme.heroDark);
      case AppTheme.villainDark:
        emit(AppTheme.villainLight);
      case AppTheme.villainLight:
        emit(AppTheme.villainDark);
      case AppTheme.neutralDark:
        emit(AppTheme.neutralLight);
      case AppTheme.neutralLight:
        emit(AppTheme.neutralDark);
    }
  }

  /// Switches alignment while preserving brightness
  void setAlignment(String alignment) {
    final isDark = state.isDark;
    switch (alignment.toLowerCase()) {
      case 'hero':
        emit(isDark ? AppTheme.heroDark : AppTheme.heroLight);
      case 'villain':
        emit(isDark ? AppTheme.villainDark : AppTheme.villainLight);
      case 'neutral':
        emit(isDark ? AppTheme.neutralDark : AppTheme.neutralLight);
    }
  }

  /// Maps the current AppTheme enum to actual ThemeData
  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
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
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// enum AppTheme { light, dark }

// class ThemeCubit extends Cubit<AppTheme> {
//   ThemeCubit({AppTheme? initial}) : super(initial ?? AppTheme.light);

//   void themeToggle() {
//     debugPrint("Before toggle $state");

//     emit(state == AppTheme.light ? AppTheme.dark : AppTheme.light);

//     debugPrint("After toggle $state");
//   }

//   void setTheme(AppTheme theme){
//     if(theme != state){
//       emit(theme);
//       debugPrint("Theme set to $theme");
//     }
//   }
// }