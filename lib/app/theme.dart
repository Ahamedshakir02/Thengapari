import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

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

/// App-wide [ThemeData] built from the ThengaPari design system
/// ([AppColors] / [AppText] in `design_tokens.dart`): warm-paper background,
/// forest-green brand, amber accent, Baloo Chettan 2 (display) + Noto Sans
/// (text) via `google_fonts`.
ThemeData buildAgriTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    brightness: Brightness.light,
    primary: AppColors.brand,
    onPrimary: AppColors.onBrand,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    surface: AppColors.surface,
    onSurface: AppColors.fg1,
    error: AppColors.statusErrorFg,
  );

  final textTheme = GoogleFonts.notoSansTextTheme(base.textTheme).apply(
    bodyColor: AppColors.fg1,
    displayColor: AppColors.fg1,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.fg1,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.h3(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.onBrand,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        textStyle: AppText.button(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppText.body().copyWith(color: AppColors.ink400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
      ),
    ),
  );
}
