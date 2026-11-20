import 'package:flutter/material.dart';

/// Typography for MindCurio.
///
/// The design uses a light, airy look: big headlines are thin (w300) and
/// important words are bold. See `AccentHeadline` in
/// lib/widgets/accent_headline.dart for the mixed-weight headings.
class AppTextStyles {
  AppTextStyles._();

  /// Poppins, bundled in assets/fonts: the same geometric typeface as the
  /// MindCurio logo, so text and logo feel like one brand. Sizes below are
  /// a touch smaller than usual because Poppins is a wide font.
  static const String fontFamily = 'Poppins';

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      // Large thin headlines ("Hello, Sara. How are you feeling today?")
      displayLarge: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w300,
        height: 1.15,
        letterSpacing: -1.0,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        height: 1.18,
        letterSpacing: -0.8,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w300,
        height: 1.2,
        letterSpacing: -0.6,
        color: primary,
      ),

      // Section titles
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.5,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.4,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
        color: primary,
      ),

      // Card titles
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primary,
      ),

      // Body text
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: secondary,
      ),

      // Buttons, chips, small labels
      labelLarge: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: secondary,
      ),
    ).apply(fontFamily: fontFamily);
  }
}
