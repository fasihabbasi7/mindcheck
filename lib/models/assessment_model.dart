import 'package:flutter/material.dart';

/// Groups used by the filter chips on the Explore screen.
enum AssessmentCategory {
  personality('Personality'),
  wellbeing('Wellbeing'),
  neurodiversity('Neurodiversity');

  const AssessmentCategory(this.label);
  final String label;
}

/// Where an assessment's questions come from. Shown on every assessment so
/// users always know how much weight to give the result.
enum SourceType {
  /// A published, validated screening questionnaire used unchanged.
  validatedScreener(
    'Validated screening tool',
    'A published questionnaire used in research and healthcare to flag '
        'experiences worth discussing with a professional. It is a screening '
        'tool, not a diagnosis.',
  ),

  /// A published, research-based questionnaire in the public domain.
  researchQuestionnaire(
    'Research questionnaire',
    'A published questionnaire widely used in psychological research. '
        'Results describe tendencies, not fixed labels.',
  ),

  /// A published questionnaire combined with questions written for
  /// MindCheck, scored together. The combined score is not validated.
  adaptedQuestionnaire(
    'Adapted questionnaire',
    'Combines a published questionnaire with extra questions written by '
        'MindCheck, scored together. The combined score has not been '
        'scientifically validated and cannot screen for or diagnose any '
        'condition.',
  ),

  /// Questions written for MindCheck. Not scientifically validated.
  selfReflection(
    'MindCheck self-reflection',
    'Questions written by MindCheck to help you reflect. They have not been '
        'scientifically validated and cannot screen for or diagnose any '
        'condition.',
  );

  const SourceType(this.label, this.explanation);
  final String label;
  final String explanation;
}

/// Everything the app needs to show about one assessment *before* it starts:
/// cards, the details screen, search and filters.
///
/// The questions themselves live in JSON files (assets/questions/) and are
/// loaded separately, so this class stays small.
@immutable
class AssessmentModel {
  const AssessmentModel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.explores,
    required this.category,
    required this.icon,
    required this.colors,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.answerFormat,
    required this.resultLabel,
    required this.sourceType,
    required this.sourceName,
    required this.citation,
    this.timeframe,
    this.audienceNote,
    this.copyrightNotice,
    this.officialUrl,
    this.keywords = const <String>[],
  });

  /// Matches the JSON file name, e.g. 'big_five' -> big_five.json.
  final String id;
  final String title;

  /// One short line shown on cards.
  final String tagline;

  /// A paragraph shown on the details screen.
  final String description;

  /// Areas the assessment looks at, shown as chips.
  final List<String> explores;

  final AssessmentCategory category;
  final IconData icon;

  /// Two colours for the icon gradient (light, dark).
  final List<Color> colors;

  final int questionCount;
  final int estimatedMinutes;

  /// How questions are answered, e.g. "4 options, Not at all → Nearly every day".
  final String answerFormat;

  /// What the user gets at the end, e.g. "Five-dimension personality profile".
  final String resultLabel;

  final SourceType sourceType;
  final String sourceName;
  final String citation;

  /// Period the questions ask about, e.g. "Over the last 2 weeks".
  final String? timeframe;

  /// Who the questionnaire was designed for, e.g. "Adults aged 18 and over".
  final String? audienceNote;

  /// Copyright line that must be shown with some instruments.
  final String? copyrightNotice;

  /// Official web page of the questionnaire, shown on the details screen.
  final String? officialUrl;

  /// Extra words that should match in search.
  final List<String> keywords;

  /// True when [query] appears in the title, tagline, areas or keywords.
  bool matches(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return <String>[
      title,
      tagline,
      category.label,
      ...explores,
      ...keywords,
    ].any((String text) => text.toLowerCase().contains(q));
  }
}
