import 'package:flutter/foundation.dart';

/// The state of one assessment the user is currently taking.
///
/// Answers are stored by question id, so going back and forth never loses
/// an answer. It is saved to the device after every change, so an
/// unfinished assessment can be resumed after closing the app.
@immutable
class AssessmentSession {
  const AssessmentSession({
    required this.assessmentId,
    required this.totalQuestions,
    required this.startedAt,
    this.currentIndex = 0,
    this.answers = const <String, int>{},
    this.updatedAt,
  });

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    return AssessmentSession(
      assessmentId: json['assessmentId'] as String,
      totalQuestions: json['totalQuestions'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      currentIndex: json['currentIndex'] as int? ?? 0,
      answers: (json['answers'] as Map<String, dynamic>? ??
              <String, dynamic>{})
          .map((String k, dynamic v) => MapEntry<String, int>(k, v as int)),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String assessmentId;
  final int totalQuestions;
  final DateTime startedAt;

  /// Index of the question on screen (0-based).
  final int currentIndex;

  /// questionId -> chosen scale value.
  final Map<String, int> answers;

  /// When the last answer was given (used to show the newest unfinished
  /// assessment first).
  final DateTime? updatedAt;

  int get answeredCount => answers.length;
  bool get isComplete => answers.length >= totalQuestions;

  /// 0.0 to 1.0, based on answered questions.
  double get progress =>
      totalQuestions == 0 ? 0 : answeredCount / totalQuestions;

  AssessmentSession copyWith({
    int? currentIndex,
    Map<String, int>? answers,
  }) {
    return AssessmentSession(
      assessmentId: assessmentId,
      totalQuestions: totalQuestions,
      startedAt: startedAt,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'assessmentId': assessmentId,
        'totalQuestions': totalQuestions,
        'startedAt': startedAt.toIso8601String(),
        'currentIndex': currentIndex,
        'answers': answers,
        'updatedAt': (updatedAt ?? startedAt).toIso8601String(),
      };
}
