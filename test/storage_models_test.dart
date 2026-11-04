import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_check/models/answer_model.dart';
import 'package:mind_check/models/journal_entry_model.dart';

/// Checks that unfinished assessments and journal entries can be saved
/// and loaded again without losing anything.
void main() {
  test('An unfinished assessment survives a round trip through JSON', () {
    final AssessmentSession session = AssessmentSession(
      assessmentId: 'anxiety',
      totalQuestions: 25,
      startedAt: DateTime(2026, 11, 4, 9),
    ).copyWith(
      currentIndex: 3,
      answers: <String, int>{'anx_01': 2, 'anx_02': 0, 'anx_03': 3},
    );

    final AssessmentSession copy = AssessmentSession.fromJson(
      jsonDecode(jsonEncode(session.toJson())) as Map<String, dynamic>,
    );

    expect(copy.assessmentId, 'anxiety');
    expect(copy.totalQuestions, 25);
    expect(copy.currentIndex, 3);
    expect(copy.answers, session.answers);
    expect(copy.answeredCount, 3);
    expect(copy.startedAt, session.startedAt);
  });

  test('Journal entries use one id per day', () {
    expect(JournalEntry.idFor(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');

    final JournalEntry entry = JournalEntry(
      id: '2026-01-05',
      prompt: 'What gave you energy today?',
      text: 'A long walk.',
      createdAt: DateTime(2026, 1, 5, 20),
      updatedAt: DateTime(2026, 1, 5, 20),
    );
    final JournalEntry copy = JournalEntry.fromJson(
      jsonDecode(jsonEncode(entry.toJson())) as Map<String, dynamic>,
    );
    expect(copy.text, 'A long walk.');
    expect(copy.prompt, entry.prompt);
  });
}
