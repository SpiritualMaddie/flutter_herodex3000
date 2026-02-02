import 'package:flutter/material.dart';

/// Reusable cyan section header used throughout the app.
/// Provides consistent spacing and styling.
class SectionHeader extends StatelessWidget { // TODO colors by theme
  final String title;
  final String? subtitle;
  final double titleFontSize;
  final double subtitleFontSize;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
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
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: titleFontSize,
              fontWeight: .bold,
              letterSpacing: 1.5,
            ),
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

// import 'package:flutter/material.dart';

// class SectionHeader extends StatelessWidget {
//   final String title;
//   final String? subtitle;
//   final double? titleFontSize;
//   final double? subtitleFontSize;
//   const SectionHeader({super.key, required this.title, this.subtitle, this.subtitleFontSize, this.titleFontSize});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0, top: 14),
//       child: Column(
//         children: [
//           // Title
//           Text(
//             title,
//             style: TextStyle(
//               color: Color(0xFF00E5FF),
//               fontSize: titleFontSize ?? 12,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.5,
//             ),
//           ),
//           // Subtitle
//           if(subtitle != null)
//           Text(
//             subtitle!,
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: subtitleFontSize ?? 9,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }