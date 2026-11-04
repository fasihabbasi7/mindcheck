import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_check/data/assessment_data.dart';
import 'package:mind_check/models/assessment_model.dart';
import 'package:mind_check/models/question_model.dart';

/// Checks every question file against the assessment catalog.
/// Run with: flutter test
void main() {
  for (final AssessmentModel assessment in assessmentCatalog) {
    test('${assessment.id}.json is valid and matches the catalog', () {
      final File file = File('assets/questions/${assessment.id}.json');
      expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');

      final QuestionSet set = QuestionSet.fromJson(
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
      );

      expect(set.assessmentId, assessment.id);
      expect(set.length, assessment.questionCount);
      expect(set.scale.length, greaterThanOrEqualTo(2));

      final Set<String> traitIds =
          set.traits.map((TraitInfo t) => t.id).toSet();
      final Set<String> questionIds = <String>{};
      for (final QuestionModel q in set.questions) {
        expect(traitIds, contains(q.traitId), reason: q.id);
        expect(questionIds.add(q.id), isTrue, reason: 'duplicate ${q.id}');
      }
    });
  }
}
