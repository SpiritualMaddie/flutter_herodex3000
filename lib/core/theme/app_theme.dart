import 'package:flutter/material.dart';

class AppThemes {
  static final light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: const Color.fromARGB(255, 118, 175, 250),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF121F2B),
  );
}