import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

/// Small frosted card with a title, an icon, a caption and a big value,
/// like the "Stress Level / 70%" cards in the design reference.
///
/// Only show real values here (counts the app actually knows). Never show
/// made-up scores.
class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    super.key,
    required this.title,
    required this.icon,
    required this.caption,
    required this.value,
    this.unit,
    this.width = 150,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String caption;
  final String value;

  /// Optional small word after the value, e.g. "tests".
  final String? unit;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textStyles;

    return SizedBox(
      width: width,
      child: GlassCard(
        frosted: true,
        radius: AppRadius.md + 2,
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium,
                  ),
                ),
                Icon(icon, size: 18, color: context.colors.onSurface),
              ],
            ),
            const SizedBox(height: 18),
            Text(caption, style: text.labelSmall),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: value,
                    style: text.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: text.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
