import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../page_transitions.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the light and dark [ThemeData] for MindCheck.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color primary = isDark ? AppColors.darkPrimary : AppColors.primary;
    final Color background = isDark
        ? AppColors.darkBackground
        : AppColors.background;
    final Color surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final Color surfaceSoft = isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.surfaceSoft;
    final Color textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final Color textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final Color border = isDark ? AppColors.darkBorder : AppColors.border;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      // White text on the light-mode purple; dark text on the lighter
      // dark-mode purple, so both pass contrast checks.
      onPrimary: isDark ? const Color(0xFF1A1730) : Colors.white,
      primaryContainer: isDark ? const Color(0xFF342C66) : AppColors.lavender,
      onPrimaryContainer: isDark
          ? const Color(0xFFE6E0FF)
          : const Color(0xFF2E2470),
      secondary: AppColors.secondary,
      onSecondary: const Color(0xFF1F1A3D),
      secondaryContainer: isDark
          ? const Color(0xFF2C2846)
          : const Color(0xFFF0ECFD),
      onSecondaryContainer: isDark
          ? const Color(0xFFE6E0FF)
          : const Color(0xFF3A3170),
      // Warm rose, used for caring support messages (e.g. the safety card).
      tertiary: isDark ? const Color(0xFFF2A7BB) : const Color(0xFFC2557A),
      onTertiary: isDark ? const Color(0xFF3A1222) : Colors.white,
      tertiaryContainer: isDark
          ? const Color(0xFF4A2433)
          : const Color(0xFFFCE4EC),
      onTertiaryContainer: isDark
          ? const Color(0xFFFFD9E3)
          : const Color(0xFF5C1932),
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: surfaceSoft,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black,
    );

    final TextTheme textTheme = AppTextStyles.textTheme(
      primary: textPrimary,
      secondary: textSecondary,
    );

    final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );

    return ThemeData(
      // Calm fade + lift between pages. iOS keeps its native transition so
      // the swipe-back gesture still works.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: MindPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: MindPageTransitionsBuilder(),
          TargetPlatform.linux: MindPageTransitionsBuilder(),
          TargetPlatform.fuchsia: MindPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: AppTextStyles.fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        isDark ? MindColors.dark : MindColors.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 56),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(64, 56),
          shape: buttonShape,
          side: BorderSide(color: border),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: textSecondary, width: 1.5),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
    );
  }
}

/// Extra colours that the Material [ColorScheme] does not cover:
/// the lavender background gradient and the frosted "glass" cards.
@immutable
class MindColors extends ThemeExtension<MindColors> {
  const MindColors({
    required this.gradientTop,
    required this.gradientBottom,
    required this.glow,
    required this.glassFill,
    required this.glassBorder,
    required this.cardShadow,
    required this.frostTop,
    required this.frostBottom,
  });

  final Color gradientTop;
  final Color gradientBottom;
  final Color glow;
  final Color glassFill;
  final Color glassBorder;
  final Color cardShadow;

  /// Top-left and bottom-right fill of frosted glass cards.
  final Color frostTop;
  final Color frostBottom;

  static const MindColors light = MindColors(
    gradientTop: Color(0xFFEAE4FD),
    gradientBottom: Color(0xFFF7F6FC),
    glow: Color(0xFFD5C9FA),
    glassFill: Color(0xD9FFFFFF),
    glassBorder: Color(0xFFFFFFFF),
    cardShadow: Color(0x145B4BC4),
    frostTop: Color(0xB3FFFFFF),
    frostBottom: Color(0x52FFFFFF),
  );

  static const MindColors dark = MindColors(
    gradientTop: Color(0xFF221C3F),
    gradientBottom: Color(0xFF13121F),
    glow: Color(0xFF3B3080),
    glassFill: Color(0xCC1E1C30),
    glassBorder: Color(0x26FFFFFF),
    cardShadow: Color(0x4D000000),
    frostTop: Color(0x2EFFFFFF),
    frostBottom: Color(0x0DFFFFFF),
  );

  @override
  MindColors copyWith({
    Color? gradientTop,
    Color? gradientBottom,
    Color? glow,
    Color? glassFill,
    Color? glassBorder,
    Color? cardShadow,
    Color? frostTop,
    Color? frostBottom,
  }) {
    return MindColors(
      gradientTop: gradientTop ?? this.gradientTop,
      gradientBottom: gradientBottom ?? this.gradientBottom,
      glow: glow ?? this.glow,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      frostTop: frostTop ?? this.frostTop,
      frostBottom: frostBottom ?? this.frostBottom,
    );
  }

  @override
  MindColors lerp(ThemeExtension<MindColors>? other, double t) {
    if (other is! MindColors) return this;
    return MindColors(
      gradientTop: Color.lerp(gradientTop, other.gradientTop, t)!,
      gradientBottom: Color.lerp(gradientBottom, other.gradientBottom, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      frostTop: Color.lerp(frostTop, other.frostTop, t)!,
      frostBottom: Color.lerp(frostBottom, other.frostBottom, t)!,
    );
  }
}

/// Short-cuts so widgets can write `context.colors.primary`
/// instead of `Theme.of(context).colorScheme.primary`.
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  MindColors get mind => Theme.of(this).extension<MindColors>()!;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
