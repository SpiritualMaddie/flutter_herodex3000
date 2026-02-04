import 'package:flutter/material.dart';

/// Reusable cyan section header used throughout the app.
/// Provides consistent spacing and styling.
class SectionHeader extends StatelessWidget { // TODO colors by theme
  final IconData? icon;
  final String title;
  final String? subtitle;
  final double titleFontSize;
  final double subtitleFontSize;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.titleFontSize = 12,
    this.subtitleFontSize = 10,
    this.padding = const EdgeInsets.only(bottom: 12, top: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: titleFontSize + 4,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: subtitleFontSize,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}