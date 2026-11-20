import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';

/// The MindCurio logo.
///
/// [markOnly] shows just the "mc" symbol; otherwise the symbol and the
/// "mindcurio" wordmark. In dark mode the logo is drawn in a lighter
/// lavender so it stays readable on the dark background.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 240, this.markOnly = false});

  static const String _fullAsset = 'assets/images/logo.png';
  static const String _markAsset = 'assets/images/logo_mark.png';

  /// Width / height of each image file.
  static const double _fullAspect = 1843 / 399;
  static const double _markAspect = 1083 / 998;

  final double width;
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    final double aspect = markOnly ? _markAspect : _fullAspect;

    return Semantics(
      label: 'MindCurio',
      image: true,
      excludeSemantics: true,
      child: Image.asset(
        markOnly ? _markAsset : _fullAsset,
        width: width,
        height: width / aspect,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        // The file uses the brand lavender gradient; in dark mode it is
        // drawn in one light lavender so it stays readable.
        color: context.isDarkMode ? const Color(0xFFC9C2FF) : null,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
