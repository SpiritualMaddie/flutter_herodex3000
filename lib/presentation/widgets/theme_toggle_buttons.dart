import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/core/theme/cubit/theme_cubit.dart';
import 'package:flutter_herodex3000/data/managers/settings_manager.dart';

class ThemeToggleButtons extends StatelessWidget {
  const ThemeToggleButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppTheme>(
      builder: (context, themeState) {
        return Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Color(0xFF121F2B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF1A2E3D)),
          ),
          child: Row(
            spacing: 33,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.read<ThemeCubit>().setTheme(AppTheme.light);
                    context.read<SettingsManager>().saveCurrentAppTheme(
                      value: "light",
                    );
                  },
                  borderRadius: .circular(8),
                  child: _buildToggleButton(
                    "HERO (LIGHT)",
                    themeState == AppTheme.light,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.read<ThemeCubit>().setTheme(AppTheme.dark);
                    context.read<SettingsManager>().saveCurrentAppTheme(
                      value: "dark",
                    );
                  },
                  borderRadius: .circular(8),
                  child: _buildToggleButton(
                    "VILLAIN (DARK)",
                    themeState == AppTheme.dark,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF00E5FF).withAlpha(20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: const Color(0xFF00E5FF).withAlpha(40))
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
