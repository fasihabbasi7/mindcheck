import 'package:flutter/foundation.dart';

import 'trait_score_model.dart';

/// How an assessment is scored. Each method is implemented separately in
/// ScoringService, so assessments never share one generic algorithm.
enum ScoringMethod {
  /// Separate trait scores only, no overall number (Big Five).
  traitProfile,

  /// One position on a two-ended spectrum (Introversion–Extroversion).
  spectrum,

  /// Overall score = average of all answers (Self-Esteem, Anxiety, Autism,
  /// Optimism).
  average,

  /// Overall score = average of trait tendencies, with inverse traits
  /// counted in reverse (Narcissistic traits, Self-Compassion, Burnout).
  tendencyIndex,

  /// Official ASRS v1.1 screener scoring: sum of 0–4 answers, 0–24.
  asrs,

  /// Plain total of all answers, e.g. the PHQ-9 (0–27).
  sum;

  static ScoringMethod parse(String value) =>
      ScoringMethod.values.firstWhere((ScoringMethod m) => m.name == value);
}

/// A score range with its interpretation, e.g. 40–70 "Moderate self-esteem".
@immutable
class ScoreBand {
  const ScoreBand({
    required this.min,
    required this.max,
    required this.title,
    required this.summary,
    this.strengths = const <String>[],
  });

  factory ScoreBand.fromJson(Map<String, dynamic> json) => ScoreBand(
        min: (json['min'] as num).toDouble(),
        max: (json['max'] as num).toDouble(),
        title: json['title'] as String,
        summary: json['summary'] as String,
        strengths: (json['strengths'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      );

  /// Inclusive lower bound, exclusive upper bound.
  final double min;
  final double max;
  final String title;
  final String summary;
  final List<String> strengths;
}

/// Personalised text for one trait.
@immutable
class TraitText {
  const TraitText({
    required this.low,
    required this.moderate,
    required this.high,
    required this.reflect,
    required this.tip,
  });

  factory TraitText.fromJson(Map<String, dynamic> json) => TraitText(
        low: json['low'] as String,
        moderate: json['moderate'] as String,
        high: json['high'] as String,
        reflect: json['reflect'] as String,
        tip: json['tip'] as String,
      );

  final String low;
  final String moderate;
  final String high;

  /// A question to think about.
  final String reflect;

  /// A practical suggestion.
  final String tip;

  /// How this trait may show up, for the given level.
  String forLevel(TraitLevel level) => switch (level) {
        TraitLevel.low => low,
        TraitLevel.moderate => moderate,
        TraitLevel.high => high,
      };
}

/// A titled group of highlighted traits, e.g. "Your strengths".
@immutable
class ReportSection {
  const ReportSection({required this.title, required this.pickHighest});

  factory ReportSection.fromJson(Map<String, dynamic> json) => ReportSection(
        title: json['title'] as String,
        pickHighest: (json['pick'] as String? ?? 'highest') == 'highest',
      );

  final String title;

  /// True: show the highest-scoring traits. False: the lowest.
  final bool pickHighest;
}

/// A supportive message shown when the overall score crosses a threshold.
@immutable
class SupportNote {
  const SupportNote({
    required this.whenAbove,
    required this.threshold,
    required this.text,
  });

  factory SupportNote.fromJson(Map<String, dynamic> json) => SupportNote(
        whenAbove: json['when'] == 'above',
        threshold: (json['threshold'] as num).toDouble(),
        text: json['text'] as String,
      );

  final bool whenAbove;
  final double threshold;
  final String text;

  bool appliesTo(double value) =>
      whenAbove ? value >= threshold : value < threshold;
}

/// Everything in assets/reports/<id>.json: how to score an assessment and
/// how to explain the result.
@immutable
class ReportConfig {
  const ReportConfig({
    required this.assessmentId,
    required this.method,
    required this.levelLabels,
    required this.traitTexts,
    required this.suggestions,
    required this.note,
    this.intro,
    this.overallLabel,
    this.overallMax,
    this.bands = const <ScoreBand>[],
    this.spectrumLeft,
    this.spectrumRight,
    this.topSection,
    this.focusSection,
    this.support,
  });

  factory ReportConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> labels =
        json['levelLabels'] as Map<String, dynamic>;
    final Map<String, dynamic>? spectrum =
        json['spectrum'] as Map<String, dynamic>?;

    return ReportConfig(
      assessmentId: json['id'] as String,
      method: ScoringMethod.parse(json['scoring'] as String),
      levelLabels: <TraitLevel, String>{
        TraitLevel.low: labels['low'] as String,
        TraitLevel.moderate: labels['moderate'] as String,
        TraitLevel.high: labels['high'] as String,
      },
      traitTexts: (json['traits'] as Map<String, dynamic>).map(
        (String k, dynamic v) => MapEntry<String, TraitText>(
          k,
          TraitText.fromJson(v as Map<String, dynamic>),
        ),
      ),
      suggestions:
          (json['suggestions'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      note: json['note'] as String? ?? '',
      intro: json['intro'] as String?,
      overallLabel: json['overallLabel'] as String?,
      overallMax: (json['overallMax'] as num?)?.toDouble(),
      bands: (json['bands'] as List<dynamic>? ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(ScoreBand.fromJson)
          .toList(),
      spectrumLeft: spectrum?['left'] as String?,
      spectrumRight: spectrum?['right'] as String?,
      topSection: json['topSection'] == null
          ? null
          : ReportSection.fromJson(json['topSection'] as Map<String, dynamic>),
      focusSection: json['focusSection'] == null
          ? null
          : ReportSection.fromJson(
              json['focusSection'] as Map<String, dynamic>,
            ),
      support: json['support'] == null
          ? null
          : SupportNote.fromJson(json['support'] as Map<String, dynamic>),
    );
  }

  final String assessmentId;
  final ScoringMethod method;
  final Map<TraitLevel, String> levelLabels;
  final Map<String, TraitText> traitTexts;
  final List<String> suggestions;

  /// Plain-language explanation of how the score is calculated.
  final String note;

  /// Introduction used when there is no overall band (Big Five).
  final String? intro;
  final String? overallLabel;

  /// Highest possible overall score (24 for ASRS, 27 for PHQ-9;
  /// otherwise 100).
  final double? overallMax;
  final List<ScoreBand> bands;
  final String? spectrumLeft;
  final String? spectrumRight;
  final ReportSection? topSection;
  final ReportSection? focusSection;
  final SupportNote? support;

  bool get isSpectrum => method == ScoringMethod.spectrum;

  ScoreBand? bandFor(double value) {
    if (bands.isEmpty) return null;
    for (final ScoreBand band in bands) {
      if (value >= band.min && value < band.max) return band;
    }
    return value < bands.first.min ? bands.first : bands.last;
  }

  String levelLabel(TraitLevel level) => levelLabels[level] ?? level.name;
}
