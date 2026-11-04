import 'package:flutter/material.dart';

/// All raw colours used in MindCheck live here.
///
/// Screens should NOT use these directly. Use `Theme.of(context).colorScheme`
/// or `context.mind` (see app_theme.dart) so light and dark mode both work.
class AppColors {
  AppColors._();

  // ---------- Brand ----------
  static const Color primary = Color(0xFF7565D8);
  static const Color primaryDeep = Color(0xFF5B4BC4);
  static const Color secondary = Color(0xFFA99BEF);
  static const Color lavender = Color(0xFFE9E4FB);
  static const Color lilac = Color(0xFFD9CFF8);

  // ---------- Light mode ----------
  static const Color background = Color(0xFFF7F6FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF1EFFA);
  static const Color textPrimary = Color(0xFF25243A);
  static const Color textSecondary = Color(0xFF77758A);
  static const Color border = Color(0xFFE6E3F3);

  // ---------- Dark mode ----------
  static const Color darkPrimary = Color(0xFF9D90F0);
  static const Color darkBackground = Color(0xFF13121F);
  static const Color darkSurface = Color(0xFF1E1C30);
  static const Color darkSurfaceSoft = Color(0xFF29263F);
  static const Color darkTextPrimary = Color(0xFFEDEBFA);
  static const Color darkTextSecondary = Color(0xFFA6A3BC);
  static const Color darkBorder = Color(0xFF34314D);

  // ---------- Feedback ----------
  static const Color success = Color(0xFF3FAE8C);
  static const Color warning = Color(0xFFE5A54B);
  static const Color error = Color(0xFFD9596B);
}
