import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';
import '../utils/constants.dart';

/// Rounded progress bar with a lavender gradient that animates smoothly.
class MindProgressBar extends StatelessWidget {
  const MindProgressBar({super.key, required this.value, this.height = 8});

  /// 0.0 to 1.0
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0);

    return Semantics(
      label: 'Progress',
      value: '${(clamped * 100).round()} percent',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: clamped),
            duration: AppDurations.medium,
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double animated, _) {
              return FractionallySizedBox(
                widthFactor: animated,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.secondary, AppColors.primary],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
