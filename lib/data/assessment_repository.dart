import '../models/assessment_model.dart';
import 'assessment_data.dart';

/// The single place screens ask for assessment information.
///
/// Today it reads the built-in catalog. Phase 3 adds loading the questions
/// for an assessment from its JSON file.
class AssessmentRepository {
  const AssessmentRepository();

  List<AssessmentModel> getAll() => assessmentCatalog;

  /// Returns null when no assessment has this id.
  AssessmentModel? getById(String id) {
    for (final AssessmentModel assessment in assessmentCatalog) {
      if (assessment.id == id) return assessment;
    }
    return null;
  }

  /// Assessments matching the search text and (optionally) a category.
  List<AssessmentModel> search({
    String query = '',
    AssessmentCategory? category,
  }) {
    return assessmentCatalog
        .where((AssessmentModel a) =>
            (category == null || a.category == category) && a.matches(query))
        .toList();
  }
}
