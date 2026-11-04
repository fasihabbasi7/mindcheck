import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/assessment_model.dart';
import '../../models/assessment_result_model.dart';
import '../../models/journal_entry_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/result_provider.dart';
import '../../providers/today_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/assessment_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/journal_editor_sheet.dart';
import '../../widgets/mind_background.dart';

enum _HistoryTab { results, journal }

/// History tab: saved assessment results and the private reflection journal.
/// Everything shown here is stored only on this device.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _HistoryTab _tab = _HistoryTab.results;

  /// Assessment filter for the results list; null = all.
  String? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MindBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.historyTitle,
                      style: context.textStyles.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.historySubtitle,
                          style: context.textStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<_HistoryTab>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<_HistoryTab>>[
                          ButtonSegment<_HistoryTab>(
                            value: _HistoryTab.results,
                            label: Text(AppStrings.historyResults),
                            icon: Icon(Icons.insights_rounded),
                          ),
                          ButtonSegment<_HistoryTab>(
                            value: _HistoryTab.journal,
                            label: Text(AppStrings.historyJournal),
                            icon: Icon(Icons.edit_note_rounded),
                          ),
                        ],
                        selected: <_HistoryTab>{_tab},
                        onSelectionChanged: (Set<_HistoryTab> value) =>
                            setState(() => _tab = value.first),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _tab == _HistoryTab.results
                    ? _ResultsList(
                        filter: _filter,
                        onFilter: (String? id) => setState(() => _filter = id),
                      )
                    : const _JournalList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Results
// ---------------------------------------------------------------------------

class _ResultsList extends ConsumerWidget {
  const _ResultsList({required this.filter, required this.onFilter});

  final String? filter;
  final ValueChanged<String?> onFilter;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AssessmentResult result,
    String title,
  ) async {
    final bool ok = await confirmAction(
      context,
      title: AppStrings.deleteResultTitle,
      message: 'Delete your $title result from '
          '${Helpers.formatDate(result.completedAt)}? This cannot be undone.',
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (ok) await ref.read(resultsProvider.notifier).delete(result.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<AssessmentResult> all = ref.watch(resultsProvider);
    final List<AssessmentModel> assessments = ref.watch(allAssessmentsProvider);

    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.navBarClearance),
        child: Center(
          child: EmptyState(
            icon: Icons.history_rounded,
            title: AppStrings.noResultsTitle,
            message: AppStrings.noResultsBody,
            action: PrimaryButton(
              expanded: false,
              label: AppStrings.exploreSection,
              onPressed: () => context.go(AppRoutes.assessments),
            ),
          ),
        ),
      );
    }

    AssessmentModel? find(String id) {
      for (final AssessmentModel a in assessments) {
        if (a.id == id) return a;
      }
      return null;
    }

    // Only offer filters for assessments that have results.
    final List<AssessmentModel> taken = assessments
        .where((AssessmentModel a) =>
            all.any((AssessmentResult r) => r.assessmentId == a.id))
        .toList();
    // If the filtered assessment no longer has results, show everything.
    final String? active =
        taken.any((AssessmentModel a) => a.id == filter) ? filter : null;
    final List<AssessmentResult> shown = active == null
        ? all
        : all.where((AssessmentResult r) => r.assessmentId == active).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.navBarClearance),
      children: <Widget>[
        if (taken.length > 1)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              children: <Widget>[
                _Pill(
                  label: AppStrings.filterAll,
                  selected: active == null,
                  onTap: () => onFilter(null),
                ),
                for (final AssessmentModel a in taken)
                  _Pill(
                    label: a.title,
                    selected: active == a.id,
                    onTap: () => onFilter(a.id),
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        for (final AssessmentResult result in shown)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.sm + 2,
            ),
            child: _ResultTile(
              result: result,
              assessment: find(result.assessmentId),
              onDelete: () => _delete(
                context,
                ref,
                result,
                find(result.assessmentId)?.title ?? '',
              ),
            ),
          ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.assessment,
    required this.onDelete,
  });

  final AssessmentResult result;
  final AssessmentModel? assessment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final OverallScore? overall = result.overall;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
      onTap: () => context.push(AppRoutes.resultPath(result.id)),
      child: Row(
        children: <Widget>[
          if (assessment != null) ...<Widget>[
            AssessmentIcon(assessment: assessment!, size: 44),
            const SizedBox(width: AppSpacing.md + 2),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  assessment?.title ?? '',
                  style: context.textStyles.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  result.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  Helpers.formatDateTime(result.completedAt),
                  style: context.textStyles.labelSmall,
                ),
              ],
            ),
          ),
          if (overall != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${overall.display}/${overall.max.round()}',
                style: context.textStyles.labelMedium?.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: AppStrings.moreOptions,
            onSelected: (String value) {
              if (value == 'open') {
                context.push(AppRoutes.resultPath(result.id));
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'open',
                child: Text(AppStrings.viewReport),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text(AppStrings.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Journal
// ---------------------------------------------------------------------------

class _JournalList extends ConsumerWidget {
  const _JournalList();

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    final bool ok = await confirmAction(
      context,
      title: AppStrings.deleteEntryTitle,
      message: 'Delete your reflection from '
          '${Helpers.formatDate(entry.createdAt)}? This cannot be undone.',
      confirmLabel: AppStrings.delete,
      destructive: true,
    );
    if (ok) await ref.read(journalProvider.notifier).delete(entry.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<JournalEntry> entries = ref.watch(journalProvider);
    final DateTime today = ref.watch(todayProvider);
    final String todaysPrompt =
        Helpers.dailyPick(AppStrings.reflectionPrompts, today);
    final bool answeredToday =
        entries.any((JournalEntry e) => e.id == JournalEntry.idFor(today));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.navBarClearance,
      ),
      children: <Widget>[
        if (!answeredToday) ...<Widget>[
          GlassCard(
            frosted: true,
            onTap: () =>
                showJournalEditor(context, prompt: todaysPrompt, date: today),
            child: Row(
              children: <Widget>[
                Icon(Icons.edit_outlined, color: context.colors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppStrings.todaysReflection,
                        style: context.textStyles.labelMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        todaysPrompt,
                        style: context.textStyles.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyState(
              icon: Icons.edit_note_rounded,
              title: AppStrings.noJournalTitle,
              message: AppStrings.noJournalBody,
            ),
          ),
        for (final JournalEntry entry in entries) ...<Widget>[
          GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 4, 16),
            onTap: () => showJournalEditor(
              context,
              prompt: entry.prompt,
              date: entry.createdAt,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Helpers.formatDate(entry.createdAt),
                        style: context.textStyles.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(entry.prompt, style: context.textStyles.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        entry.text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.deleteEntry,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _delete(context, ref, entry),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
        ],
      ],
    );
  }
}
