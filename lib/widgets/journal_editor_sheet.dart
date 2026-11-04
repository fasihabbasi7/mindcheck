import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/app_theme.dart';
import '../models/journal_entry_model.dart';
import '../providers/journal_provider.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'custom_button.dart';

/// Opens the private journal editor for the reflection question of [date].
Future<void> showJournalEditor(
  BuildContext context, {
  required String prompt,
  required DateTime date,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    builder: (BuildContext context) =>
        _JournalEditor(prompt: prompt, date: date),
  );
}

class _JournalEditor extends ConsumerStatefulWidget {
  const _JournalEditor({required this.prompt, required this.date});

  final String prompt;
  final DateTime date;

  @override
  ConsumerState<_JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends ConsumerState<_JournalEditor> {
  late final JournalEntry? _existing =
      ref.read(journalProvider.notifier).entryFor(widget.date);
  late final TextEditingController _controller =
      TextEditingController(text: _existing?.text ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(journalProvider.notifier)
        .saveFor(widget.date, _existing?.prompt ?? widget.prompt, _controller.text);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final JournalEntry? entry = _existing;
    if (entry != null) {
      await ref.read(journalProvider.notifier).delete(entry.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textStyles;

    return Padding(
      // Keeps the field above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            0,
            AppSpacing.screen,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${AppStrings.todaysReflection.toUpperCase()} · '
                '${Helpers.formatDate(widget.date)}',
                style: text.labelSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _existing?.prompt ?? widget.prompt,
                style: text.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                autofocus: _existing == null,
                minLines: 5,
                maxLines: 10,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: AppStrings.journalHint,
                ),
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      AppStrings.journalPrivate,
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: AppStrings.save,
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
              if (_existing != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: AppStrings.deleteEntry,
                  icon: Icons.delete_outline_rounded,
                  onPressed: _delete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
