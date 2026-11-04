import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/assessment_repository.dart';
import '../models/assessment_model.dart';
import 'preferences_provider.dart';

final Provider<AssessmentRepository> assessmentRepositoryProvider =
    Provider<AssessmentRepository>((Ref ref) => const AssessmentRepository());

/// All assessments, in display order.
final Provider<List<AssessmentModel>> allAssessmentsProvider =
    Provider<List<AssessmentModel>>(
  (Ref ref) => ref.watch(assessmentRepositoryProvider).getAll(),
);

/// The search text and filter chip currently selected on Explore.
@immutable
class ExploreFilter {
  const ExploreFilter({this.query = '', this.category, this.savedOnly = false});

  final String query;

  /// `null` means all categories.
  final AssessmentCategory? category;

  /// Show only bookmarked assessments.
  final bool savedOnly;

  bool get isAll => category == null && !savedOnly;
}

class ExploreFilterNotifier extends Notifier<ExploreFilter> {
  @override
  ExploreFilter build() => const ExploreFilter();

  void setQuery(String query) {
    state = ExploreFilter(
      query: query,
      category: state.category,
      savedOnly: state.savedOnly,
    );
  }

  /// Selecting a category (or All) turns the "Saved" filter off.
  void setCategory(AssessmentCategory? category) {
    state = ExploreFilter(query: state.query, category: category);
  }

  void showSavedOnly() {
    state = ExploreFilter(query: state.query, savedOnly: true);
  }

  void clear() => state = const ExploreFilter();
}

final NotifierProvider<ExploreFilterNotifier, ExploreFilter>
    exploreFilterProvider =
    NotifierProvider<ExploreFilterNotifier, ExploreFilter>(
  ExploreFilterNotifier.new,
);

/// Assessments matching the current Explore search and filter.
final Provider<List<AssessmentModel>> filteredAssessmentsProvider =
    Provider<List<AssessmentModel>>((Ref ref) {
  final ExploreFilter filter = ref.watch(exploreFilterProvider);
  final Set<String> bookmarks = ref.watch(bookmarksProvider);
  return ref
      .watch(assessmentRepositoryProvider)
      .search(query: filter.query, category: filter.category)
      .where(
        (AssessmentModel a) => !filter.savedOnly || bookmarks.contains(a.id),
      )
      .toList();
});

/// Set to true by Home's search bar so the Explore tab focuses its search
/// field when it opens. Explore sets it back to false once handled.
class ExploreSearchFocusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void request() => state = true;
  void consume() => state = false;
}

final NotifierProvider<ExploreSearchFocusNotifier, bool>
    exploreSearchFocusProvider =
    NotifierProvider<ExploreSearchFocusNotifier, bool>(
  ExploreSearchFocusNotifier.new,
);
