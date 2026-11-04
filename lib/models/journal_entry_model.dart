import 'package:flutter/foundation.dart';

/// One private answer to a daily reflection question.
@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.prompt,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// One entry per day: the id is the date, e.g. "2026-11-04".
  final String id;
  final String prompt;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The id used for a given day.
  static String idFor(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  JournalEntry copyWith({String? text}) {
    return JournalEntry(
      id: id,
      prompt: prompt,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'prompt': prompt,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
