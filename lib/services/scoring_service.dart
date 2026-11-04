import '../models/assessment_result_model.dart';
import '../models/question_model.dart';
import '../models/report_model.dart';
import '../models/trait_score_model.dart';

/// Turns a set of answers into an [AssessmentResult].
///
/// There is no UI code here. Each scoring method is its own function, so
/// every assessment is scored by the rules that fit it:
///
/// * traitProfile – Big Five: five separate trait scores, no total.
/// * spectrum     – Introversion/Extroversion: one position from 0 to 100.
/// * average      – Self-Esteem, Anxiety, Autism-related: average of all
///                  answers, plus a breakdown by area.
/// * tendencyIndex– Narcissistic traits: average of trait tendencies, with
///                  Empathy counted in reverse.
/// * asrs         – ADHD: official ASRS v1.1 total (0–24), unchanged.
///                  Extra MindCheck questions only add trait areas.
/// * sum          – Low mood: the official PHQ-9 total (0–27).
///
/// Any question marked `safety` (PHQ-9 question 9) answered above its
/// lowest value sets `extras['safetyFlag'] = 1`, so the report can show
/// support information first.
///
/// Reverse-worded questions are flipped before scoring. Unanswered
/// questions are skipped (the review screen normally prevents them).
class ScoringService {
  const ScoringService();

  AssessmentResult score({
    required QuestionSet set,
    required ReportConfig report,
    required Map<String, int> answers,
    required DateTime startedAt,
    DateTime? completedAt,
  }) {
    final DateTime finished = completedAt ?? DateTime.now();
    final List<TraitScore> traits = traitScores(set, answers);

    final _Outcome outcome = switch (report.method) {
      ScoringMethod.traitProfile => _traitProfile(traits),
      ScoringMethod.spectrum => _spectrum(traits, report),
      ScoringMethod.average => _average(set, answers, report),
      ScoringMethod.tendencyIndex => _tendencyIndex(traits, report),
      ScoringMethod.asrs => _asrs(set, answers, report),
      ScoringMethod.sum => _sum(set, answers, report),
    };

    final Map<String, int> extras = <String, int>{
      ...outcome.extras,
      if (safetyConcern(set, answers)) 'safetyFlag': 1,
    };

    return AssessmentResult(
      id: '${set.assessmentId}_${finished.millisecondsSinceEpoch}',
      assessmentId: set.assessmentId,
      completedAt: finished,
      durationSeconds: finished.difference(startedAt).inSeconds,
      questionSetVersion: set.version,
      headline: outcome.headline,
      traits: traits,
      answers: Map<String, int>.unmodifiable(answers),
      overall: outcome.overall,
      extras: extras,
    );
  }

  /// True when any safety question was answered above its lowest value.
  bool safetyConcern(QuestionSet set, Map<String, int> answers) {
    for (final QuestionModel q in set.questions) {
      if (!q.safety) continue;
      final int? answer = answers[q.id];
      if (answer != null && answer > set.minValue) return true;
    }
    return false;
  }

  // ---------- Building blocks ----------

  /// The scored value of one answer (reverse-worded questions flipped).
  int itemValue(QuestionSet set, QuestionModel question, int answer) {
    return question.reverse ? set.minValue + set.maxValue - answer : answer;
  }

  /// One score per trait, summing only the questions that were answered.
  List<TraitScore> traitScores(QuestionSet set, Map<String, int> answers) {
    return <TraitScore>[
      for (final TraitInfo trait in set.traits)
        () {
          int sum = 0;
          int count = 0;
          for (final QuestionModel q in set.questions) {
            final int? answer = answers[q.id];
            if (q.traitId != trait.id || answer == null) continue;
            sum += itemValue(set, q, answer);
            count++;
          }
          return TraitScore(
            traitId: trait.id,
            name: trait.name,
            description: trait.description,
            rawScore: sum,
            minScore: count * set.minValue,
            maxScore: count * set.maxValue,
            answered: count,
            inverse: trait.inverse,
          );
        }(),
    ];
  }

  /// Average of every answered question, on a 0–100 scale.
  double averagePercent(QuestionSet set, Map<String, int> answers) {
    int sum = 0;
    int count = 0;
    for (final QuestionModel q in set.questions) {
      final int? answer = answers[q.id];
      if (answer == null) continue;
      sum += itemValue(set, q, answer);
      count++;
    }
    if (count == 0) return 0;
    final int range = set.maxValue - set.minValue;
    return (sum - count * set.minValue) / (count * range) * 100;
  }

  OverallScore _overall(ReportConfig report, double value, double max) {
    final ScoreBand? band = report.bandFor(value);
    return OverallScore(
      value: value,
      max: max,
      label: report.overallLabel ?? 'Overall score',
      bandTitle: band?.title ?? '',
      bandSummary: band?.summary ?? '',
      strengths: band?.strengths ?? const <String>[],
    );
  }

  // ---------- One function per scoring method ----------

  _Outcome _traitProfile(List<TraitScore> traits) {
    final List<TraitScore> sorted = <TraitScore>[...traits]
      ..sort((TraitScore a, TraitScore b) => b.percent.compareTo(a.percent));
    final String headline = sorted.length >= 2
        ? 'Your answers point most strongly to ${sorted[0].name} '
            'and ${sorted[1].name}.'
        : 'Here is your personality profile.';
    return _Outcome(headline: headline);
  }

  _Outcome _spectrum(List<TraitScore> traits, ReportConfig report) {
    final double position = traits.isEmpty ? 50 : traits.first.percent;
    final OverallScore overall = _overall(report, position, 100);
    return _Outcome(headline: overall.bandTitle, overall: overall);
  }

  _Outcome _average(
    QuestionSet set,
    Map<String, int> answers,
    ReportConfig report,
  ) {
    final OverallScore overall =
        _overall(report, averagePercent(set, answers), 100);
    return _Outcome(headline: overall.bandTitle, overall: overall);
  }

  _Outcome _tendencyIndex(List<TraitScore> traits, ReportConfig report) {
    final List<TraitScore> answered =
        traits.where((TraitScore t) => t.answered > 0).toList();
    final double index = answered.isEmpty
        ? 0
        : answered.map((TraitScore t) => t.tendency).reduce(
                  (double a, double b) => a + b,
                ) /
            answered.length;
    final OverallScore overall = _overall(report, index, 100);
    return _Outcome(headline: overall.bandTitle, overall: overall);
  }

  /// Official ASRS v1.1 screener scoring (Harvard update, 2024):
  /// Never 0, Rarely 1, Sometimes 2, Often 3, Very often 4; total 0–24.
  /// Also counts answers in the shaded boxes of the original form.
  _Outcome _asrs(
    QuestionSet set,
    Map<String, int> answers,
    ReportConfig report,
  ) {
    int total = 0;
    int shaded = 0;
    int asrsItems = 0;
    for (final QuestionModel q in set.questions) {
      // Only the official ASRS questions (the ones with shading) count.
      // MindCheck's extra "everyday patterns" questions never change it.
      final int? shadedFrom = q.shadedFromValue;
      if (shadedFrom == null) continue;
      asrsItems++;
      final int? answer = answers[q.id];
      if (answer == null) continue;
      total += answer;
      if (answer >= shadedFrom) shaded++;
    }
    final double max =
        report.overallMax ?? (asrsItems * set.maxValue).toDouble();
    final OverallScore overall = _overall(report, total.toDouble(), max);
    return _Outcome(
      headline: overall.bandTitle,
      overall: overall,
      extras: <String, int>{'shadedCount': shaded, 'asrsItems': asrsItems},
    );
  }

  /// Plain total of every answered question (PHQ-9: 0–27).
  _Outcome _sum(
    QuestionSet set,
    Map<String, int> answers,
    ReportConfig report,
  ) {
    int total = 0;
    for (final QuestionModel q in set.questions) {
      final int? answer = answers[q.id];
      if (answer == null) continue;
      total += itemValue(set, q, answer);
    }
    final double max =
        report.overallMax ?? (set.length * set.maxValue).toDouble();
    final OverallScore overall = _overall(report, total.toDouble(), max);
    return _Outcome(headline: overall.bandTitle, overall: overall);
  }
}

class _Outcome {
  const _Outcome({
    required this.headline,
    this.overall,
    this.extras = const <String, int>{},
  });

  final String headline;
  final OverallScore? overall;
  final Map<String, int> extras;
}
