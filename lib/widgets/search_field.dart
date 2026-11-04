import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/constants.dart';

/// Rounded frosted search bar.
///
/// Use it as a real text field (pass [controller] and [onChanged]) or as a
/// button that opens search elsewhere (pass [onTap] and set [readOnly]).
class MindSearchField extends StatelessWidget {
  const MindSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.hint = 'Search assessments',
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final MindColors mind = context.mind;
    final BorderRadius radius = BorderRadius.circular(AppRadius.pill);
    final OutlineInputBorder noBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: mind.glassFill,
        border: Border.all(color: mind.glassBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: mind.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        textInputAction: TextInputAction.search,
        style: context.textStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          filled: false,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.colors.onSurfaceVariant,
          ),
          suffixIcon: controller == null
              ? null
              : ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller!,
                  builder: (BuildContext context, TextEditingValue value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        controller!.clear();
                        onChanged?.call('');
                      },
                    );
                  },
                ),
          border: noBorder,
          enabledBorder: noBorder,
          focusedBorder: noBorder,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
