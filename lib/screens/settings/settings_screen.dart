import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
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
import '../../widgets/brand_logo.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';

/// Settings tab: profile, appearance, experience switches, privacy & data,
/// and about. Every row uses the same layout (glossy icon, title, subtitle,
/// trailing control) so everything lines up on one grid.
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
    final int results = ref.watch(resultsProvider).length;
    final int entries = ref.watch(journalProvider).length;

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
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.settingsSubtitle,
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Profile ----------
              _ProfileCard(name: name, onTap: () => _editName(context, ref)),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Appearance ----------
              const _SectionLabel(AppStrings.appearance),
              _ThemePicker(
                selected: themeMode,
                onSelected: ref.read(themeModeProvider.notifier).setThemeMode,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Experience ----------
              const _SectionLabel(AppStrings.assessmentsSettings),
              _Group(
                children: <Widget>[
                  _SettingsRow(
                    icon: Icons.keyboard_double_arrow_right_rounded,
                    title: AppStrings.autoNextLabel,
                    subtitle: AppStrings.autoNextDescription,
                    trailing: Switch(
                      value: ref.watch(autoAdvanceProvider),
                      onChanged: ref.read(autoAdvanceProvider.notifier).set,
                    ),
                    onTap: ref.read(autoAdvanceProvider.notifier).toggle,
                  ),
                  _SettingsRow(
                    icon: Icons.motion_photos_off_outlined,
                    title: AppStrings.reduceEffects,
                    subtitle: AppStrings.reduceEffectsBody,
                    trailing: Switch(
                      value: ref.watch(reduceEffectsProvider),
                      onChanged: ref.read(reduceEffectsProvider.notifier).set,
                    ),
                    onTap: () => ref
                        .read(reduceEffectsProvider.notifier)
                        .set(!ref.read(reduceEffectsProvider)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- Privacy & data ----------
              const _SectionLabel(AppStrings.privacyData),
              _Group(
                children: <Widget>[
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    title: AppStrings.privacyTitle,
                    subtitle: AppStrings.privacySubtitle,
                    onTap: () => context.push(AppRoutes.privacyInfo),
                  ),
                  _SettingsRow(
                    icon: Icons.history_rounded,
                    title: AppStrings.deleteHistoryTitle,
                    subtitle: results == 1 ? '1 saved result' : '$results saved results',
                    onTap: () => _deleteHistory(context, ref),
                  ),
                  _SettingsRow(
                    icon: Icons.menu_book_outlined,
                    title: AppStrings.deleteJournalTitle,
                    subtitle: entries == 1 ? '1 entry' : '$entries entries',
                    onTap: () => _deleteJournal(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _Group(
                danger: true,
                children: <Widget>[
                  _SettingsRow(
                    icon: Icons.delete_forever_rounded,
                    title: AppStrings.deleteAllTitle,
                    subtitle: AppStrings.deleteAllSubtitle,
                    danger: true,
                    onTap: () => _deleteAll(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ---------- About ----------
              const _SectionLabel(AppStrings.about),
              _Group(
                children: <Widget>[
                  _SettingsRow(
                    icon: Icons.favorite_outline_rounded,
                    title: AppStrings.aboutTitle,
                    subtitle: AppStrings.aboutSubtitle,
                    onTap: () => context.push(AppRoutes.aboutInfo),
                  ),
                  _SettingsRow(
                    icon: Icons.replay_rounded,
                    title: AppStrings.replayOnboarding,
                    subtitle: AppStrings.replaySubtitle,
                    onTap: () => _replayOnboarding(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ---------- Footer ----------
              const Center(child: BrandLogo(width: 34, markOnly: true)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${AppStrings.appName} · ${AppStrings.version} ${AppInfo.version}',
                textAlign: TextAlign.center,
                style: context.textStyles.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.madeWithCare,
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large card at the top: a gradient avatar with the first letter of the
/// name, the name itself, and a pencil to edit it.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasName = name.trim().isNotEmpty;
    final String initial = hasName ? name.trim()[0].toUpperCase() : '';

    return GlassCard(
      frosted: true,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.secondary, AppColors.primaryDeep],
              ),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: hasName
                ? Text(
                    initial,
                    style: context.textStyles.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.person_rounded, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hasName ? name : AppStrings.addYourName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.tapToEditName,
                  style: context.textStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const GlowIcon(icon: Icons.edit_rounded, size: 36),
        ],
      ),
    );
  }
}

/// Three equal tiles (System, Light, Dark); the chosen one lights up.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.selected, required this.onSelected});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  static const List<(ThemeMode, IconData, String)> _options =
      <(ThemeMode, IconData, String)>[
    (ThemeMode.system, Icons.brightness_auto_rounded, AppStrings.themeSystem),
    (ThemeMode.light, Icons.light_mode_rounded, AppStrings.themeLight),
    (ThemeMode.dark, Icons.dark_mode_rounded, AppStrings.themeDark),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: <Widget>[
          for (final (ThemeMode mode, IconData icon, String label)
              in _options)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: _ThemeTile(
                  icon: icon,
                  label: label,
                  selected: mode == selected,
                  onTap: () => onSelected(mode),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color text = selected ? Colors.white : context.colors.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[AppColors.secondary, AppColors.primary],
                )
              : null,
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, color: selected ? Colors.white : context.colors.primary),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    style: context.textStyles.labelMedium?.copyWith(
                      color: text,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One glass card holding several rows, with thin dividers that start
/// where the text starts, so icons and text line up down the screen.
class _Group extends StatelessWidget {
  const _Group({required this.children, this.danger = false});

  final List<Widget> children;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      accent: danger ? context.colors.error : null,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: _SettingsRow.textInset,
                endIndent: AppSpacing.lg,
                color: context.colors.outlineVariant.withValues(alpha: 0.5),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A settings row: glossy icon, title and subtitle, and a trailing control
/// (a chevron by default). All rows share the same spacing.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  /// Where the text begins: padding + icon + gap. Dividers start here.
  static const double textInset = AppSpacing.lg + 36 + 14;

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color error = context.colors.error;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              GlowIcon(
                icon: icon,
                size: 36,
                colors: danger
                    ? <Color>[const Color(0xFFF29AA8), error]
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: context.textStyles.titleSmall?.copyWith(
                        color: danger ? error : null,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: context.textStyles.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: danger ? error : context.colors.onSurfaceVariant,
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
      padding: const EdgeInsets.only(left: 6, bottom: AppSpacing.sm + 2),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.labelSmall?.copyWith(
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
        ),
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
