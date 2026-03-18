import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/theme.dart';

///
/// Map AppTheme enum -> ThemeData and expose convenience accessors. TODO - look over
/// 

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
            shrinkWrap: true, /// Lets it size itself
            physics: const NeverScrollableScrollPhysics(), /// Parent handles scroll
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

  /// Color previews for each theme
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
            /// Color preview bar at bottom
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
            /// Theme name
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
            /// Selected checkmark
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