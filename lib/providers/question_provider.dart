import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/answer_model.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';
import 'storage_provider.dart';

final Provider<QuestionService> questionServiceProvider =
    Provider<QuestionService>((Ref ref) => QuestionService());

/// The questions for one assessment, loaded from its JSON file.
/// Use: `ref.watch(questionSetProvider('big_five'))`.
final questionSetProvider = FutureProvider.family<QuestionSet, String>(
  (Ref ref, String assessmentId) =>
      ref.watch(questionServiceProvider).load(assessmentId),
);

/// Unfinished assessments saved on the device, by assessment id.
/// Lets the user resume later, even after closing the app.
class SavedSessionsNotifier extends Notifier<Map<String, AssessmentSession>> {
  @override
  Map<String, AssessmentSession> build() =>
      ref.read(storageServiceProvider).savedSessions;

  Future<void> save(AssessmentSession session) async {
    state = <String, AssessmentSession>{
      ...state,
      session.assessmentId: session,
    };
    await ref.read(storageServiceProvider).saveSession(session);
  }

  Future<void> remove(String assessmentId) async {
    if (!state.containsKey(assessmentId)) return;
    state = <String, AssessmentSession>{...state}..remove(assessmentId);
    await ref.read(storageServiceProvider).removeSession(assessmentId);
  }

  /// Re-reads from storage (used after deleting all data).
  void reload() => state = ref.read(storageServiceProvider).savedSessions;

  /// The most recently updated unfinished assessment, if any.
  AssessmentSession? get latest {
    if (state.isEmpty) return null;
    final List<AssessmentSession> list = state.values.toList()
      ..sort(
        (AssessmentSession a, AssessmentSession b) =>
            (b.updatedAt ?? b.startedAt).compareTo(a.updatedAt ?? a.startedAt),
      );
    return list.first;
  }
}

final NotifierProvider<SavedSessionsNotifier, Map<String, AssessmentSession>>
    savedSessionsProvider =
    NotifierProvider<SavedSessionsNotifier, Map<String, AssessmentSession>>(
  SavedSessionsNotifier.new,
);

/// The assessment currently being answered (only one at a time).
/// `null` when no assessment is on screen.
///
/// Every change is saved straight away, so progress survives the app
/// being closed.
class AssessmentSessionNotifier extends Notifier<AssessmentSession?> {
  @override
  AssessmentSession? build() => null;

  SavedSessionsNotifier get _saved => ref.read(savedSessionsProvider.notifier);

  /// Starts from the first question, replacing any saved progress.
  void start(String assessmentId, int totalQuestions) {
    _saved.remove(assessmentId);
    state = AssessmentSession(
      assessmentId: assessmentId,
      totalQuestions: totalQuestions,
      startedAt: DateTime.now(),
    );
  }

  /// Continues a saved, unfinished assessment.
  void resume(AssessmentSession saved) => state = saved;

  void _update(AssessmentSession next) {
    state = next;
    // Only worth saving once something has been answered.
    if (next.answeredCount > 0) _saved.save(next);
  }

  /// Saves the answer immediately, replacing any earlier answer.
  void answer(String questionId, int value) {
    final AssessmentSession? session = state;
    if (session == null) return;
    _update(
      session.copyWith(
        answers: <String, int>{...session.answers, questionId: value},
      ),
    );
  }

  void goTo(int index) {
    final AssessmentSession? session = state;
    if (session == null) return;
    _update(
      session.copyWith(
        currentIndex: index.clamp(0, session.totalQuestions - 1),
      ),
    );
  }

  void next() {
    final AssessmentSession? session = state;
    if (session != null) goTo(session.currentIndex + 1);
  }

  void previous() {
    final AssessmentSession? session = state;
    if (session != null) goTo(session.currentIndex - 1);
  }

  /// Leaves the screen but keeps the saved progress for later.
  void suspend() => state = null;

  /// Ends the session and deletes its saved progress
  /// (after submitting, or when the user discards their answers).
  void clear() {
    final AssessmentSession? session = state;
    if (session != null) _saved.remove(session.assessmentId);
    state = null;
  }
}

final NotifierProvider<AssessmentSessionNotifier, AssessmentSession?>
    assessmentSessionProvider =
    NotifierProvider<AssessmentSessionNotifier, AssessmentSession?>(
  AssessmentSessionNotifier.new,
);
