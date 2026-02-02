import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double? titleFontSize;
  final double? subtitleFontSize;
  const SectionHeader({super.key, required this.title, this.subtitle, this.subtitleFontSize, this.titleFontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 14),
      child: Column(
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: titleFontSize ?? 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          // Subtitle
          if(subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.grey,
              fontSize: subtitleFontSize ?? 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}