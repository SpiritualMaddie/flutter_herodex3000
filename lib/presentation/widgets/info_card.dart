import 'package:flutter/material.dart';

/// Reusable dark card with optional icon, title, and body text.
/// Used for war cards, system manifest, protocol tiles, etc.
class InfoCard extends StatelessWidget {
  final String? title;
  final String? body;
  final IconData? icon;
  final Widget? child; // For custom content
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const InfoCard({
    super.key,
    this.title,
    this.body,
    this.icon,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF121F2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2E3D)),
      ),
      child: child ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.cyan, size: 16),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title!,
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              if (title != null && body != null) const SizedBox(height: 10),
              if (body != null)
                Text(
                  body!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
            ],
          ),
    );
  }
}