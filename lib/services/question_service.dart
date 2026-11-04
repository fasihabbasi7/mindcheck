import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question_model.dart';

/// Loads question files from assets/questions/<assessmentId>.json.
///
/// Files are read once and then kept in memory.
class QuestionService {
  QuestionService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, QuestionSet> _cache = <String, QuestionSet>{};

  Future<QuestionSet> load(String assessmentId) async {
    final QuestionSet? cached = _cache[assessmentId];
    if (cached != null) return cached;

    final String raw =
        await _bundle.loadString('assets/questions/$assessmentId.json');
    final QuestionSet set =
        QuestionSet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _validate(set, assessmentId);

    _cache[assessmentId] = set;
    return set;
  }

  /// Catches mistakes in a question file early, with a clear message.
  void _validate(QuestionSet set, String expectedId) {
    final List<String> problems = <String>[];

    if (set.assessmentId != expectedId) {
      problems.add('file id "${set.assessmentId}" != "$expectedId"');
    }
    if (set.scale.length < 2) problems.add('scale needs at least 2 options');
    if (set.questions.isEmpty) problems.add('no questions');

    final Set<String> traitIds = set.traits.map((TraitInfo t) => t.id).toSet();
    final Set<String> seen = <String>{};
    for (final QuestionModel q in set.questions) {
      if (!seen.add(q.id)) problems.add('duplicate question id ${q.id}');
      if (!traitIds.contains(q.traitId)) {
        problems.add('${q.id} uses unknown trait ${q.traitId}');
      }
      for (final ScaleOption option in q.options ?? const <ScaleOption>[]) {
        if (option.value < set.minValue || option.value > set.maxValue) {
          problems.add('${q.id} has an option outside the scale range');
        }
      }
    }

    if (problems.isNotEmpty) {
      throw FormatException(
        'Invalid question file $expectedId.json: ${problems.join('; ')}',
      );
    }
  }
}
