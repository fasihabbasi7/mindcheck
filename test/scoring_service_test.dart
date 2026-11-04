import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_check/data/assessment_data.dart';
import 'package:mind_check/models/assessment_model.dart';
import 'package:mind_check/models/assessment_result_model.dart';
import 'package:mind_check/models/question_model.dart';
import 'package:mind_check/models/report_model.dart';
import 'package:mind_check/models/trait_score_model.dart';
import 'package:mind_check/services/scoring_service.dart';

QuestionSet loadSet(String id) => QuestionSet.fromJson(
      jsonDecode(File('assets/questions/$id.json').readAsStringSync())
          as Map<String, dynamic>,
    );

ReportConfig loadReport(String id) => ReportConfig.fromJson(
      jsonDecode(File('assets/reports/$id.json').readAsStringSync())
          as Map<String, dynamic>,
    );

/// Answers every question so the trait direction is maximal (or minimal).
Map<String, int> keyedAnswers(QuestionSet set, {required bool high}) {
  return <String, int>{
    for (final QuestionModel q in set.questions)
      q.id: (high != q.reverse) ? set.maxValue : set.minValue,
  };
}

void main() {
  const ScoringService scoring = ScoringService();
  final DateTime start = DateTime(2026, 1, 1, 10);
  final DateTime end = DateTime(2026, 1, 1, 10, 5);

  AssessmentResult run(String id, Map<String, int> answers) => scoring.score(
        set: loadSet(id),
        report: loadReport(id),
        answers: answers,
        startedAt: start,
        completedAt: end,
      );

  group('every assessment', () {
    for (final AssessmentModel a in assessmentCatalog) {
      test('${a.id}: report file matches traits, extremes score 0 and max', () {
        final QuestionSet set = loadSet(a.id);
        final ReportConfig report = loadReport(a.id);
        expect(
          report.traitTexts.keys.toSet(),
          set.traits.map((TraitInfo t) => t.id).toSet(),
        );

        final AssessmentResult high = run(a.id, keyedAnswers(set, high: true));
        final AssessmentResult low = run(a.id, keyedAnswers(set, high: false));
        for (final TraitScore t in high.traits) {
          expect(t.percent, closeTo(100, 0.001), reason: t.traitId);
        }
        for (final TraitScore t in low.traits) {
          expect(t.percent, closeTo(0, 0.001), reason: t.traitId);
        }
        expect(high.durationSeconds, 300);
        expect(high.headline, isNotEmpty);
      });
    }
  });

  test('ADHD uses official ASRS 0–24 scoring and counts shaded answers', () {
    final QuestionSet set = loadSet('adhd');
    // Sometimes (2) for every question: 6 x 2 = 12.
    final AssessmentResult result = run(
      'adhd',
      <String, int>{for (final QuestionModel q in set.questions) q.id: 2},
    );
    expect(result.overall!.value, 12);
    expect(result.overall!.max, 24);
    expect(result.overall!.bandTitle, contains('Below the screening'));
    // Sometimes is shaded for questions 1–3 only.
    expect(result.extras['shadedCount'], 3);

    final AssessmentResult positive = run(
      'adhd',
      <String, int>{for (final QuestionModel q in set.questions) q.id: 3},
    );
    expect(positive.overall!.value, 18);
    expect(positive.overall!.bandTitle, contains('Well above'));
  });

  test('ADHD extra MindCheck questions never change the ASRS score', () {
    final QuestionSet set = loadSet('adhd');
    expect(set.length, 20);
    // ASRS questions (with shading) all "Never", extra questions all
    // "Very often": the screener score must stay 0.
    final AssessmentResult result = run('adhd', <String, int>{
      for (final QuestionModel q in set.questions)
        q.id: q.shadedFromValue != null ? 0 : 4,
    });
    expect(result.overall!.value, 0);
    expect(result.overall!.max, 24);
    expect(result.extras['shadedCount'], 0);
    final TraitScore focus =
        result.traits.firstWhere((TraitScore t) => t.traitId == 'focus');
    expect(focus.percent, closeTo(100, 0.001));
  });

  test('Big Five has no overall score, only five traits', () {
    final QuestionSet set = loadSet('big_five');
    final AssessmentResult result = run(
      'big_five',
      <String, int>{for (final QuestionModel q in set.questions) q.id: 3},
    );
    expect(result.overall, isNull);
    expect(result.traits.length, 5);
    for (final TraitScore t in result.traits) {
      expect(t.percent, closeTo(50, 0.001));
    }
  });

  test('Narcissism counts high empathy against the overall score', () {
    final QuestionSet set = loadSet('narcissism');
    // Maximum on every trait, including maximum empathy.
    final AssessmentResult result = run('narcissism', keyedAnswers(set, high: true));
    // 7 traits at 100 and empathy counted as 0: 700 / 8 = 87.5.
    expect(result.overall!.value, closeTo(87.5, 0.001));
  });

  test('Self-esteem flips negatively worded items', () {
    final QuestionSet set = loadSet('self_esteem');
    final QuestionModel negative =
        set.questions.firstWhere((QuestionModel q) => q.reverse);
    // "Strongly agree" (3) with a negative statement scores 0.
    expect(scoring.itemValue(set, negative, 3), 0);
  });

  test('PHQ-9 is a plain 0–27 total with the official ranges', () {
    final QuestionSet set = loadSet('low_mood');
    // More than half the days (2) for all nine: 18.
    final AssessmentResult result = run(
      'low_mood',
      <String, int>{for (final QuestionModel q in set.questions) q.id: 2},
    );
    expect(result.overall!.value, 18);
    expect(result.overall!.max, 27);
    expect(result.overall!.bandTitle, 'Moderately severe symptoms');

    final AssessmentResult none = run(
      'low_mood',
      <String, int>{for (final QuestionModel q in set.questions) q.id: 0},
    );
    expect(none.overall!.value, 0);
    expect(none.overall!.bandTitle, 'Minimal symptoms');
    expect(none.extras.containsKey('safetyFlag'), isFalse);
  });

  test('PHQ-9 question 9 above "Not at all" always sets the safety flag', () {
    final QuestionSet set = loadSet('low_mood');
    final QuestionModel q9 = set.questions.last;
    expect(q9.safety, isTrue);
    expect(set.questions.where((QuestionModel q) => q.safety).length, 1);

    final AssessmentResult result = run('low_mood', <String, int>{
      for (final QuestionModel q in set.questions) q.id: q.safety ? 1 : 0,
    });
    // Even with a total of only 1, support information must be shown.
    expect(result.overall!.value, 1);
    expect(result.extras['safetyFlag'], 1);
  });

  test('Self-compassion counts the three harsh areas in reverse', () {
    final QuestionSet set = loadSet('self_compassion');
    expect(set.length, 26);
    // Kind areas "Almost always", harsh areas "Almost never": fully
    // self-compassionate.
    final AssessmentResult kind = run('self_compassion', <String, int>{
      for (final QuestionModel q in set.questions)
        q.id: set.traitById(q.traitId)!.inverse ? 1 : 5,
    });
    expect(kind.overall!.value, closeTo(100, 0.001));
    expect(kind.overall!.bandTitle, 'Higher self-compassion');

    final AssessmentResult middle = run(
      'self_compassion',
      <String, int>{for (final QuestionModel q in set.questions) q.id: 3},
    );
    expect(middle.overall!.value, closeTo(50, 0.001));
  });

  test('Burnout uses per-question answer wording and averages the scales',
      () {
    final QuestionSet set = loadSet('burnout');
    final QuestionModel degree = set.questions
        .firstWhere((QuestionModel q) => q.id == 'cbi_07');
    expect(set.optionsFor(degree).last.label, 'To a very high degree');
    expect(set.optionsFor(set.questions.first).last.label, 'Always');

    // Personal burnout at 100, work-related at 0: overall 50.
    final AssessmentResult result = run('burnout', <String, int>{
      for (final QuestionModel q in set.questions)
        q.id: q.traitId == 'personal'
            ? 4
            : (q.reverse ? 4 : 0),
    });
    final TraitScore work =
        result.traits.firstWhere((TraitScore t) => t.traitId == 'work');
    expect(work.percent, closeTo(0, 0.001));
    expect(result.overall!.value, closeTo(50, 0.001));
  });

  test('Optimism keys six of the ten IPIP items in reverse', () {
    final QuestionSet set = loadSet('optimism');
    final List<QuestionModel> ipip = set.questions
        .where((QuestionModel q) => q.source == 'IPIP')
        .toList();
    expect(ipip.length, 10);
    expect(ipip.where((QuestionModel q) => q.reverse).length, 6);
  });

  test('Results survive a round trip through JSON', () {
    final QuestionSet set = loadSet('anxiety');
    final AssessmentResult result =
        run('anxiety', keyedAnswers(set, high: true));
    final AssessmentResult copy =
        AssessmentResult.fromJson(jsonDecode(jsonEncode(result.toJson()))
            as Map<String, dynamic>);
    expect(copy.overall!.value, result.overall!.value);
    expect(copy.traits.length, result.traits.length);
    expect(copy.answers, result.answers);
  });
}
