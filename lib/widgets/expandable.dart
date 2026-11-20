import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

/// Text that shows only the first few lines, with a "Read more" link when
/// there is more. Tapping it opens the rest with a smooth size animation.
///
/// Short text that already fits shows no link at all.
class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    super.key,
    this.trimLines = 3,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;

  /// Lines shown before "Read more".
  final int trimLines;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ??
        context.textStyles.bodyMedium!.copyWith(color: context.colors.onSurface);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Measure the text to see if it is longer than [trimLines].
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.trimLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final bool overflows = painter.didExceedMaxLines;
        painter.dispose();

        final CrossAxisAlignment align = widget.textAlign == TextAlign.center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start;

        return AnimatedSize(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: align,
            children: <Widget>[
              Text(
                widget.text,
                style: style,
                textAlign: widget.textAlign,
                maxLines: _expanded ? null : widget.trimLines,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if (overflows)
                _MoreLink(
                  expanded: _expanded,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A section that shows only its [title] until tapped, then slides its
/// [child] open. Used for sources, licences and other fine print.
class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final bool initiallyExpanded;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
    value: widget.initiallyExpanded ? 1 : 0,
  );
  late final Animation<double> _size =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  void _toggle() {
    if (_controller.value > 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.colors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          button: true,
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: <Widget>[
                  if (widget.icon != null) ...<Widget>[
                    GlowIcon(icon: widget.icon!, size: 32),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.textStyles.titleSmall,
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5).animate(_size),
                    child: Icon(Icons.expand_more_rounded, color: accent),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _size,
          axisAlignment: -1,
          child: FadeTransition(
            opacity: _size,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

class _MoreLink extends StatelessWidget {
  const _MoreLink({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            expanded ? AppStrings.showLess : AppStrings.readMore,
            style: context.textStyles.labelLarge?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
