import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/assessment_result_model.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../services/scoring_service.dart';
import 'storage_provider.dart';

final Provider<ScoringService> scoringServiceProvider =
    Provider<ScoringService>((Ref ref) => const ScoringService());

final Provider<ReportService> reportServiceProvider =
    Provider<ReportService>((Ref ref) => ReportService());

/// Report content and scoring settings for one assessment.
final reportConfigProvider = FutureProvider.family<ReportConfig, String>(
  (Ref ref, String assessmentId) =>
      ref.watch(reportServiceProvider).load(assessmentId),
);

/// Completed results, newest first, saved on the device.
class ResultsNotifier extends Notifier<List<AssessmentResult>> {
  @override
  List<AssessmentResult> build() =>
      ref.read(historyServiceProvider).loadResults();

  Future<void> add(AssessmentResult result) async {
    state = <AssessmentResult>[result, ...state];
    await ref.read(historyServiceProvider).saveResult(result);
  }

  Future<void> delete(String id) async {
    state = state.where((AssessmentResult r) => r.id != id).toList();
    await ref.read(historyServiceProvider).deleteResult(id);
  }

  Future<void> clearAll() async {
    state = const <AssessmentResult>[];
    await ref.read(historyServiceProvider).clearResults();
  }

  AssessmentResult? byId(String id) {
    for (final AssessmentResult result in state) {
      if (result.id == id) return result;
    }
    return null;
  }

  /// Earlier results of the same assessment (and same question version),
  /// taken before [result]; newest first. Used for comparisons.
  List<AssessmentResult> earlierThan(AssessmentResult result) {
    return state
        .where(
          (AssessmentResult r) =>
              r.assessmentId == result.assessmentId &&
              r.questionSetVersion == result.questionSetVersion &&
              r.completedAt.isBefore(result.completedAt),
        )
        .toList();
  }
}

final NotifierProvider<ResultsNotifier, List<AssessmentResult>>
    resultsProvider =
    NotifierProvider<ResultsNotifier, List<AssessmentResult>>(
  ResultsNotifier.new,
);
