import 'package:flutter/foundation.dart';

import 'trait_score_model.dart';

/// The single overall score of an assessment (not every assessment has one;
/// the Big Five, for example, is only a profile of five traits).
@immutable
class OverallScore {
  const OverallScore({
    required this.value,
    required this.max,
    required this.label,
    required this.bandTitle,
    required this.bandSummary,
    this.strengths = const <String>[],
  });

  factory OverallScore.fromJson(Map<String, dynamic> json) {
    return OverallScore(
      value: (json['value'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      label: json['label'] as String,
      bandTitle: json['bandTitle'] as String,
      bandSummary: json['bandSummary'] as String,
      strengths: (json['strengths'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>(),
    );
  }

  /// e.g. 16 (ASRS, out of 24) or 62.5 (out of 100).
  final double value;
  final double max;

  /// What the number means, e.g. "ASRS screener score".
  final String label;

  /// Interpretation band, e.g. "Moderate self-esteem".
  final String bandTitle;
  final String bandSummary;

  /// Optional strengths linked to the band (used by the spectrum result).
  final List<String> strengths;

  /// 0.0 to 1.0, for charts.
  double get fraction => max <= 0 ? 0 : (value / max).clamp(0.0, 1.0);

  /// Whole-number display, e.g. "62".
  String get display => value.round().toString();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'value': value,
        'max': max,
        'label': label,
        'bandTitle': bandTitle,
        'bandSummary': bandSummary,
        'strengths': strengths,
      };
}

/// A finished assessment: when it was taken, the answers, and the scores.
/// Saved to the device in Phase 5 (it already converts to and from JSON).
@immutable
class AssessmentResult {
  const AssessmentResult({
    required this.id,
    required this.assessmentId,
    required this.completedAt,
    required this.durationSeconds,
    required this.questionSetVersion,
    required this.headline,
    required this.traits,
    required this.answers,
    this.overall,
    this.extras = const <String, int>{},
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] as String,
      assessmentId: json['assessmentId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      questionSetVersion: json['questionSetVersion'] as int? ?? 1,
      headline: json['headline'] as String,
      traits: (json['traits'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(TraitScore.fromJson)
          .toList(),
      answers: (json['answers'] as Map<String, dynamic>)
          .map((String k, dynamic v) => MapEntry<String, int>(k, v as int)),
      overall: json['overall'] == null
          ? null
          : OverallScore.fromJson(json['overall'] as Map<String, dynamic>),
      extras: (json['extras'] as Map<String, dynamic>? ?? <String, dynamic>{})
          .map((String k, dynamic v) => MapEntry<String, int>(k, v as int)),
    );
  }

  final String id;
  final String assessmentId;
  final DateTime completedAt;
  final int durationSeconds;

  /// Version of the question file used, so old results stay meaningful.
  final int questionSetVersion;

  /// One-sentence summary shown at the top of the report.
  final String headline;
  final List<TraitScore> traits;
  final Map<String, int> answers;
  final OverallScore? overall;

  /// Extra numbers for specific assessments, e.g. {'shadedCount': 4}
  /// for the ASRS screener.
  final Map<String, int> extras;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'assessmentId': assessmentId,
        'completedAt': completedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'questionSetVersion': questionSetVersion,
        'headline': headline,
        'traits': traits.map((TraitScore t) => t.toJson()).toList(),
        'answers': answers,
        'overall': overall?.toJson(),
        'extras': extras,
      };
}
