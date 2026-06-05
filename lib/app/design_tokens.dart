import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Faithful port of the ThengaPari design system
/// (`Designs/.../colors_and_type.css` + `design-system.css`).
///
/// These are the source of truth for the real app screens. Earthy greens,
/// warm amber accent, warm-paper neutrals — never cool gray.
class AppColors {
  AppColors._();

  // Primary — earthy greens
  static const greenForest900 = Color(0xFF15331F); // brand ink / deepest
  static const greenForest800 = Color(0xFF1A4226);
  static const greenForest700 = Color(0xFF1E4D2B); // PRIMARY brand
  static const green600 = Color(0xFF2E6B3E); // complete / hover
  static const greenSage500 = Color(0xFF6E9E5E);
  static const greenSage400 = Color(0xFF94B97F);
  static const greenLeaf300 = Color(0xFFBCD6A3);
  static const greenLeaf200 = Color(0xFFCFE0BC);
  static const greenLeaf100 = Color(0xFFE6EFD9);
  static const greenLeaf50 = Color(0xFFF1F6E9);

  // Accent — warm amber / saffron
  static const amberSaffron600 = Color(0xFFDD8413);
  static const amber500 = Color(0xFFF4A52A); // ACCENT
  static const amber400 = Color(0xFFFBBA4D);
  static const amber200 = Color(0xFFFBDFA6);
  static const amber100 = Color(0xFFFCEBCB);

  // Worker (dark teal) + B2B (deep blue) — kept for cross-role use
  static const teal900 = Color(0xFF08332F);
  static const teal700 = Color(0xFF0E5249);
  static const teal500 = Color(0xFF15786B);
  static const teal300 = Color(0xFF6FB6AB);
  static const teal100 = Color(0xFFD6ECE7);
  static const blue900 = Color(0xFF12273F);
  static const blue700 = Color(0xFF1C3D5E);
  static const blue500 = Color(0xFF2A5F8F);
  static const blue300 = Color(0xFF7FA6C6);
  static const blue100 = Color(0xFFDCE7F0);

  // Warm neutrals
  static const ink900 = Color(0xFF2B2A24); // primary text
  static const ink700 = Color(0xFF4A4840); // secondary text
  static const ink500 = Color(0xFF6E6B60); // tertiary / captions
  static const ink400 = Color(0xFF908C7E); // placeholder / disabled
  static const mist300 = Color(0xFFC9C5B6); // strong border
  static const mist200 = Color(0xFFE2DECF); // border / track
  static const paper100 = Color(0xFFFBF8F1); // APP BACKGROUND
  static const paper50 = Color(0xFFFEFCF6);
  static const paper0 = Color(0xFFFFFFFF); // cards

  // Status
  static const statusInprogressFg = Color(0xFFB86A06);
  static const statusInprogressBg = Color(0xFFFCEBCB);
  static const statusCompleteFg = Color(0xFF2E6B3E);
  static const statusCompleteBg = Color(0xFFDCEBCB);
  static const statusScheduledFg = Color(0xFF4C7A3C);
  static const statusScheduledBg = Color(0xFFECF3E0);
  static const statusErrorFg = Color(0xFFA33523);
  static const statusErrorBg = Color(0xFFF8DED6);

  // Semantic roles (light theme)
  static const bg = paper100;
  static const surface = paper0;
  static const surfaceSunk = greenLeaf50;
  static const fg1 = ink900;
  static const fg2 = ink700;
  static const fg3 = ink500;
  static const border = mist200;
  static const borderStrong = mist300;
  static const brand = greenForest700;
  static const brandInk = greenForest900;
  static const accent = amber500;
  static const onBrand = Color(0xFFFFFFFF);
  static const onAccent = greenForest900;
}

/// Corner radii (generous, friendly).
class AppRadii {
  AppRadii._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14; // inputs, small cards
  static const double lg = 20; // cards
  static const double xl = 28; // sheets, hero cards
  static const double pill = 999;
}

/// 4px-base spacing scale.
class AppSpace {
  AppSpace._();
  static const double s1 = 4, s2 = 8, s3 = 12, s4 = 16, s5 = 20, s6 = 24;
  static const double s8 = 32, s10 = 40, s12 = 48, s16 = 64;
  static const double gutter = 18; // .pad horizontal gutter
}

/// Soft, warm-tinted shadows.
class AppShadows {
  AppShadows._();
  static const sm = [
    BoxShadow(color: Color(0x0F1F4D2B), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D1F4D2B), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const md = [
    BoxShadow(color: Color(0x141F4D2B), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0D1F4D2B), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const lg = [
    BoxShadow(color: Color(0x1F1F4D2B), blurRadius: 28, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0F1F4D2B), blurRadius: 8, offset: Offset(0, 4)),
  ];
  static const accent = [
    BoxShadow(color: Color(0x4DF4A52A), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

/// Typography — Baloo Chettan 2 (display) + Noto Sans (text), via google_fonts.
/// Sizes/weights match the design type scale.
class AppText {
  AppText._();

  static TextStyle display() => GoogleFonts.balooChettan2(
      fontSize: 40, height: 1.15, fontWeight: FontWeight.w700, color: AppColors.fg1, letterSpacing: -0.4);
  static TextStyle h1() => GoogleFonts.balooChettan2(
      fontSize: 32, height: 1.25, fontWeight: FontWeight.w700, color: AppColors.fg1, letterSpacing: -0.3);
  static TextStyle h2() => GoogleFonts.balooChettan2(
      fontSize: 24, height: 1.33, fontWeight: FontWeight.w600, color: AppColors.fg1);
  static TextStyle h3() => GoogleFonts.balooChettan2(
      fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.fg1);

  static TextStyle title() => GoogleFonts.notoSans(
      fontSize: 18, height: 1.44, fontWeight: FontWeight.w600, color: AppColors.fg1);
  static TextStyle bodyLg() => GoogleFonts.notoSans(
      fontSize: 17, height: 1.53, fontWeight: FontWeight.w400, color: AppColors.fg2);
  static TextStyle body() => GoogleFonts.notoSans(
      fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.fg2);
  static TextStyle bodySm() => GoogleFonts.notoSans(
      fontSize: 14, height: 1.43, fontWeight: FontWeight.w400, color: AppColors.fg2);
  static TextStyle caption() => GoogleFonts.notoSans(
      fontSize: 12, height: 1.33, fontWeight: FontWeight.w500, color: AppColors.fg3);
  static TextStyle overline() => GoogleFonts.notoSans(
      fontSize: 12, height: 1.33, fontWeight: FontWeight.w600, color: AppColors.fg3, letterSpacing: 0.96);
  static TextStyle button() => GoogleFonts.notoSans(
      fontSize: 16, height: 1.25, fontWeight: FontWeight.w600);

  /// Numeric/display font used for big values (e.g. ₹4,280).
  static TextStyle displayNum(double size,
          {Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.balooChettan2(
          fontSize: size, height: 1.05, fontWeight: weight, color: color ?? AppColors.fg1, letterSpacing: -0.2);
}
