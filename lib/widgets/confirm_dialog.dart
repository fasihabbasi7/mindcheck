import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/app_strings.dart';

/// Asks the user to confirm an action. Returns true only if confirmed.
///
/// Use [destructive] for deletions: the confirm button is shown in red.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          style: destructive
              ? TextButton.styleFrom(foregroundColor: context.colors.error)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
