import 'package:flutter/material.dart';

/// Design tokens shared across all four app roles.
///
/// Exact hex values from the shared architecture / implementation plan.
/// Painters and feature widgets reference these directly.
class AgriColors {
  AgriColors._();

  // Primary greens — used across all roles
  static const green50 = Color(0xFFEAF3DE);
  static const green100 = Color(0xFFC0DD97);
  static const green400 = Color(0xFF639922);
  static const green600 = Color(0xFF3B6D11);
  static const green800 = Color(0xFF27500A);
  static const green900 = Color(0xFF173404);

  // Amber — warnings, in-progress states, mango crops
  static const amber100 = Color(0xFFFAC775);
  static const amber400 = Color(0xFFEF9F27);
  static const amber600 = Color(0xFFBA7517);
  static const amber800 = Color(0xFF633806);

  // Blue — B2B portal, info states
  static const blue50 = Color(0xFFE6F1FB);
  static const blue400 = Color(0xFF378ADD);
  static const blue600 = Color(0xFF185FA5);
  static const blue900 = Color(0xFF042C53);

  // Teal — worker ping screen, available states
  static const teal100 = Color(0xFF9FE1CB);
  static const teal400 = Color(0xFF1D9E75);
  static const teal600 = Color(0xFF0F6E56);

  // Neutrals
  static const surface = Color(0xFFF5F5F0);
  static const border = Color(0xFFEEEEEE);
}

/// App-wide [ThemeData] seeded from [AgriColors.green400].
///
/// NOTE: `fontFamily: 'Poppins'` is declared per the plan but the Poppins
/// font is not yet bundled — Flutter falls back to the platform sans font
/// until the font asset (or the google_fonts package) is added.
ThemeData buildAgriTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AgriColors.green400,
    brightness: Brightness.light,
    primary: AgriColors.green400,
    secondary: AgriColors.teal400,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AgriColors.green900,
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AgriColors.green400,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AgriColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AgriColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AgriColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AgriColors.green400, width: 1.5),
      ),
    ),
  );
}
