import 'package:flutter/material.dart';

/// A headline where words wrapped in `**double asterisks**` are bold
/// and the rest stays light, e.g.
///
/// `AccentHeadline('Understand **yourself** better')`
///
/// This recreates the "Hello, **Sara** How are you **feeling today**?"
/// style from the design reference.
class AccentHeadline extends StatelessWidget {
  const AccentHeadline(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;

  /// Base style. Defaults to `displaySmall` from the theme.
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ?? Theme.of(context).textTheme.displaySmall!;
    final TextStyle bold = base.copyWith(fontWeight: FontWeight.w700);

    // Splitting on ** gives: [normal, bold, normal, bold, ...]
    final List<String> parts = text.split('**');
    final List<TextSpan> spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(TextSpan(text: parts[i], style: i.isOdd ? bold : base));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
    );
  }
}
