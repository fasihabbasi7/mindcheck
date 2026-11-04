import 'package:flutter/foundation.dart';

/// Where a 0–100 trait score sits within the questionnaire's range.
/// This is NOT a comparison with other people.
enum TraitLevel {
  low,
  moderate,
  high;

  static TraitLevel fromPercent(double percent) {
    if (percent < 35) return TraitLevel.low;
    if (percent < 65) return TraitLevel.moderate;
    return TraitLevel.high;
  }
}

/// The score for one trait or area, e.g. "Openness: 72".
@immutable
class TraitScore {
  const TraitScore({
    required this.traitId,
    required this.name,
    required this.description,
    required this.rawScore,
    required this.minScore,
    required this.maxScore,
    required this.answered,
    this.inverse = false,
  });

  factory TraitScore.fromJson(Map<String, dynamic> json) {
    return TraitScore(
      traitId: json['traitId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      rawScore: json['rawScore'] as int,
      minScore: json['minScore'] as int,
      maxScore: json['maxScore'] as int,
      answered: json['answered'] as int? ?? 0,
      inverse: json['inverse'] as bool? ?? false,
    );
  }

  final String traitId;
  final String name;
  final String description;

  /// Sum of the (reverse-corrected) answers for this trait.
  final int rawScore;

  /// Lowest and highest possible sums for the answered questions.
  final int minScore;
  final int maxScore;

  /// How many questions were answered for this trait.
  final int answered;

  /// True when a higher score means *less* of what the assessment measures
  /// overall (e.g. Empathy in the narcissistic traits profile).
  final bool inverse;

  /// The score on a 0–100 scale.
  double get percent {
    final int range = maxScore - minScore;
    if (range <= 0) return 0;
    return (rawScore - minScore) / range * 100;
  }

  TraitLevel get level => TraitLevel.fromPercent(percent);

  /// How strongly this trait counts towards the overall result.
  /// Equal to [percent], or flipped for inverse traits.
  double get tendency => inverse ? 100 - percent : percent;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'traitId': traitId,
        'name': name,
        'description': description,
        'rawScore': rawScore,
        'minScore': minScore,
        'maxScore': maxScore,
        'answered': answered,
        'inverse': inverse,
      };
}
