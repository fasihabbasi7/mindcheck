import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/journal_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/result_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';

/// Settings tab.
///
/// PHASE 1 VERSION: theme switching (system / light / dark), replaying the
/// introduction, and the app version. Privacy information, the disclaimer
/// page and "delete all data" are added in Phase 5.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          _NameDialog(initialName: ref.read(userNameProvider)),
    );
    if (newName != null) {
      await ref.read(userNameProvider.notifier).setName(newName);
    }
  }

  void _done(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteHistory(BuildContext context, WidgetRef ref) async {
    final bool ok = await confirmAction(
      context,
      title: AppStrings.deleteHistoryTitle,
      message: AppStrings.deleteHistoryBody,
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!ok) return;
    await ref.read(resultsProvider.notifier).clearAll();
    if (context.mounted) _done(context, AppStrings.historyDeleted);
  }

  Future<void> _deleteJournal(BuildContext context, WidgetRef ref) async {
    final bool ok = await confirmAction(
      context,
      title: AppStrings.deleteJournalTitle,
      message: AppStrings.deleteJournalBody,
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (!ok) return;
    await ref.read(journalProvider.notifier).clearAll();
    if (context.mounted) _done(context, AppStrings.journalDeleted);
  }

  /// Deletes results, journal, bookmarks, unfinished assessments and name.
  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final bool ok = await confirmAction(
      context,
      title: AppStrings.deleteAllTitle,
      message: AppStrings.deleteAllBody,
      confirmLabel: AppStrings.deleteEverything,
      destructive: true,
    );
    if (!ok) return;
    await ref.read(resultsProvider.notifier).clearAll();
    await ref.read(journalProvider.notifier).clearAll();
    await ref.read(storageServiceProvider).clearPersonalData();
    ref.read(assessmentSessionProvider.notifier).suspend();
    ref.read(savedSessionsProvider.notifier).reload();
    ref.invalidate(bookmarksProvider);
    ref.invalidate(userNameProvider);
    if (context.mounted) _done(context, AppStrings.allDeleted);
  }

  Future<void> _replayOnboarding(BuildContext context, WidgetRef ref) async {
    await ref.read(storageServiceProvider).setOnboardingComplete(false);
    if (!context.mounted) return;
    context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final String name = ref.watch(userNameProvider);
    final bool autoAdvance = ref.watch(autoAdvanceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MindBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.lg,
              AppSpacing.screen,
              AppSpacing.navBarClearance,
            ),
            children: <Widget>[
              Text(
                AppStrings.tabSettings,
                style: context.textStyles.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Profile ----------
              const _SectionLabel(AppStrings.profile),
              GlassCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text(AppStrings.yourName),
                  subtitle: Text(name.isEmpty ? AppStrings.nameNotSet : name),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editName(context, ref),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Appearance ----------
              const _SectionLabel(AppStrings.appearance),
              GlassCard(
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text(AppStrings.themeSystem),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text(AppStrings.themeLight),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text(AppStrings.themeDark),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: <ThemeMode>{themeMode},
                    onSelectionChanged: (Set<ThemeMode> selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(selection.first);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Assessments ----------
              const _SectionLabel(AppStrings.assessmentsSettings),
              GlassCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  secondary: const Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                  ),
                  title: const Text(AppStrings.autoNextLabel),
                  subtitle: const Text(AppStrings.autoNextDescription),
                  value: autoAdvance,
                  onChanged: ref.read(autoAdvanceProvider.notifier).set,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Privacy & data ----------
              const _SectionLabel(AppStrings.privacyData),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: const Text(AppStrings.privacyTitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.privacyInfo),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.history_toggle_off_rounded),
                      title: const Text(AppStrings.deleteHistoryTitle),
                      subtitle: Text(
                        '${ref.watch(resultsProvider).length} saved results',
                      ),
                      onTap: () => _deleteHistory(context, ref),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.edit_off_outlined),
                      title: const Text(AppStrings.deleteJournalTitle),
                      subtitle: Text(
                        '${ref.watch(journalProvider).length} entries',
                      ),
                      onTap: () => _deleteJournal(context, ref),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: context.colors.error,
                      ),
                      title: Text(
                        AppStrings.deleteAllTitle,
                        style: TextStyle(color: context.colors.error),
                      ),
                      onTap: () => _deleteAll(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- About ----------
              const _SectionLabel(AppStrings.about),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.favorite_outline_rounded),
                      title: const Text(AppStrings.aboutTitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.aboutInfo),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.replay_rounded),
                      title: const Text(AppStrings.replayOnboarding),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _replayOnboarding(context, ref),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    const ListTile(
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text(AppStrings.version),
                      trailing: Text(AppInfo.version),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.labelSmall?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}

/// Small dialog for changing the greeting name.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initialName});

  final String initialName;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.yourName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 30,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _save(),
        decoration: const InputDecoration(
          hintText: AppStrings.nameHint,
          helperText: AppStrings.nameHelper,
          counterText: '',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(onPressed: _save, child: const Text(AppStrings.save)),
      ],
    );
  }
}
