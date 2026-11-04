import 'package:flutter/foundation.dart';

/// One answer choice, e.g. value 3 = "Agree".
@immutable
class ScaleOption {
  const ScaleOption({required this.value, required this.label});

  factory ScaleOption.fromJson(Map<String, dynamic> json) {
    return ScaleOption(
      value: json['value'] as int,
      label: json['label'] as String,
    );
  }

  /// The number used for scoring.
  final int value;
  final String label;
}

/// A trait or area that questions are grouped into, e.g. "Self-worth".
@immutable
class TraitInfo {
  const TraitInfo({
    required this.id,
    required this.name,
    required this.description,
    this.inverse = false,
  });

  factory TraitInfo.fromJson(Map<String, dynamic> json) {
    return TraitInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      inverse: json['inverse'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String description;

  /// True when a *higher* score on this trait counts *against* the overall
  /// result (e.g. Empathy in the narcissistic traits profile).
  final bool inverse;
}

/// One question. Every assessment uses this same class.
@immutable
class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.text,
    required this.traitId,
    required this.reverse,
    required this.source,
    this.shadedFromValue,
    this.section,
    this.options,
    this.safety = false,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      traitId: json['trait'] as String,
      reverse: json['reverse'] as bool? ?? false,
      source: json['source'] as String? ?? '',
      shadedFromValue: json['shadedFromValue'] as int?,
      section: json['section'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(ScaleOption.fromJson)
          .toList(),
      safety: json['safety'] as bool? ?? false,
    );
  }

  final String id;
  final String text;
  final String traitId;

  /// Reverse-scored: agreeing lowers the trait score instead of raising it.
  final bool reverse;

  /// Where the wording comes from, e.g. "GAD-7" or "MindCheck".
  final String source;

  /// Only for the ASRS screener: answers with this value or higher are
  /// shown shaded, exactly as on the official paper form.
  final int? shadedFromValue;

  /// Optional part label, e.g. "Part 1 · ASRS screener".
  final String? section;

  /// Answer choices for this question only, when they differ from the
  /// set's usual scale (the Burnout questionnaire uses two wordings).
  /// Values must stay in the same range as the usual scale.
  final List<ScaleOption>? options;

  /// True for a question about self-harm (PHQ-9 question 9). Any answer
  /// above the lowest shows support information straight away.
  final bool safety;
}

/// Everything loaded from one assessments/questions/<id>.json file.
@immutable
class QuestionSet {
  const QuestionSet({
    required this.assessmentId,
    required this.version,
    required this.instructions,
    required this.prompt,
    required this.scale,
    required this.traits,
    required this.questions,
    required this.sources,
  });

  factory QuestionSet.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) =>
        (json[key] as List<dynamic>).cast<Map<String, dynamic>>();

    return QuestionSet(
      assessmentId: json['id'] as String,
      version: json['version'] as int? ?? 1,
      instructions: json['instructions'] as String,
      prompt: json['prompt'] as String,
      scale: list('scale').map(ScaleOption.fromJson).toList(),
      traits: list('traits').map(TraitInfo.fromJson).toList(),
      questions: list('questions').map(QuestionModel.fromJson).toList(),
      sources: (json['sources'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>(),
    );
  }

  final String assessmentId;
  final int version;

  /// Shown on the instructions screen.
  final String instructions;

  /// Short line shown above every question, e.g. "How much do you agree?".
  final String prompt;

  /// Answer choices, in the order they are shown.
  final List<ScaleOption> scale;
  final List<TraitInfo> traits;
  final List<QuestionModel> questions;
  final List<String> sources;

  int get length => questions.length;

  int get minValue =>
      scale.map((ScaleOption o) => o.value).reduce((int a, int b) => a < b ? a : b);

  int get maxValue =>
      scale.map((ScaleOption o) => o.value).reduce((int a, int b) => a > b ? a : b);

  /// The answer choices to show for [question].
  List<ScaleOption> optionsFor(QuestionModel question) =>
      question.options ?? scale;

  TraitInfo? traitById(String id) {
    for (final TraitInfo trait in traits) {
      if (trait.id == id) return trait;
    }
    return null;
  }
}
