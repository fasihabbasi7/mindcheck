import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';

/// Main call-to-action button (filled purple).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;

  /// Pass `null` to show the button as disabled.
  final VoidCallback? onPressed;
  final IconData? icon;

  /// When true the button fills the available width.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = icon == null
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : FilledButton(
            onPressed: onPressed,
            // Label first, icon after it (e.g. "Next  →").
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(label),
                const SizedBox(width: 8),
                Icon(icon, size: 20),
              ],
            ),
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary button with an outline.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = icon == null
        ? OutlinedButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Small round icon button with a frosted background,
/// like the bell and menu buttons in the design reference.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final MindColors mind = context.mind;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: mind.glassFill,
        shape: CircleBorder(side: BorderSide(color: mind.glassBorder)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 20, color: context.colors.onSurface),
          ),
        ),
      ),
    );
  }
}
