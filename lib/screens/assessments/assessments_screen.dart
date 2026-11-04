import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../models/assessment_model.dart';
import '../../providers/assessment_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/assessment_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/motion/reveal.dart';
import '../../widgets/search_field.dart';

/// "Explore" tab: every assessment, with search and category filters.
class AssessmentsScreen extends ConsumerStatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  ConsumerState<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends ConsumerState<AssessmentsScreen> {
  late final TextEditingController _searchController = TextEditingController(
    text: ref.read(exploreFilterProvider).query,
  );
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleFocusRequest());
  }

  /// Home's search bar asks this screen to focus its search field.
  void _handleFocusRequest() {
    if (!mounted || !ref.read(exploreSearchFocusProvider)) return;
    ref.read(exploreSearchFocusProvider.notifier).consume();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(exploreFilterProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final List<AssessmentModel> results =
        ref.watch(filteredAssessmentsProvider);
    final ExploreFilter filter = ref.watch(exploreFilterProvider);
    final int total = ref.watch(allAssessmentsProvider).length;

    ref.listen<bool>(exploreSearchFocusProvider, (bool? previous, bool next) {
      if (next) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _handleFocusRequest());
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MindBackground(
        child: SafeArea(
          bottom: false,
          child: GestureDetector(
            // Tapping outside the search field closes the keyboard.
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.lg,
                    AppSpacing.screen,
                    0,
                  ),
                  sliver: SliverList.list(
                    children: <Widget>[
                      Text(
                        AppStrings.exploreTitle,
                        style: context.textStyles.headlineLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$total ${AppStrings.exploreSubtitle}',
                        style: context.textStyles.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      MindSearchField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: ref
                            .read(exploreFilterProvider.notifier)
                            .setQuery,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FilterChips(
                    filter: filter,
                    onCategory:
                        ref.read(exploreFilterProvider.notifier).setCategory,
                    onSaved:
                        ref.read(exploreFilterProvider.notifier).showSavedOnly,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
                if (results.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.navBarClearance,
                      ),
                      child: Center(
                        child: EmptyState(
                          icon: Icons.search_off_rounded,
                          title: filter.savedOnly
                              ? AppStrings.noSavedTitle
                              : AppStrings.noMatchesTitle,
                          message: filter.savedOnly
                              ? AppStrings.noSavedBody
                              : AppStrings.noMatchesBody,
                          action: SecondaryButton(
                            expanded: false,
                            label: AppStrings.clearFilters,
                            onPressed: _clearFilters,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.navBarClearance,
                    ),
                    sliver: SliverList.separated(
                      itemCount: results.length + 1,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == results.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              AppStrings.exploreFootnote,
                              textAlign: TextAlign.center,
                              style: context.textStyles.bodySmall,
                            ),
                          );
                        }
                        // Cards glide in one after another.
                        return Reveal(
                          key: ValueKey<String>(results[index].id),
                          delay: Duration(
                            milliseconds: 60 * math.min(index, 6),
                          ),
                          child: AssessmentCard(assessment: results[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "All / Saved / Personality / Wellbeing / Neurodiversity" filter pills.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.onCategory,
    required this.onSaved,
  });

  final ExploreFilter filter;
  final ValueChanged<AssessmentCategory?> onCategory;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pills = <Widget>[
      _FilterPill(
        label: AppStrings.filterAll,
        selected: filter.isAll,
        onTap: () => onCategory(null),
      ),
      _FilterPill(
        label: AppStrings.filterSaved,
        icon: Icons.bookmark_rounded,
        selected: filter.savedOnly,
        onTap: onSaved,
      ),
      for (final AssessmentCategory category in AssessmentCategory.values)
        _FilterPill(
          label: category.label,
          selected: !filter.savedOnly && filter.category == category,
          onTap: () => onCategory(category),
        ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        itemCount: pills.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) => pills[index],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final MindColors mind = context.mind;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.primary : mind.glassFill,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? colors.primary : mind.glassBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? colors.onPrimary : colors.primary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: context.textStyles.labelLarge?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
