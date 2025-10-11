import 'package:flutter/foundation.dart';

/// Assessment entity representing a personality/skills assessment
@immutable
class Assessment {
  const Assessment({
    required this.id,
    required this.userId,
    required this.takenAt,
    required this.traitScores,
    required this.deltaProgress,
    this.type = AssessmentType.quiz,
    this.completed = false,
  });

  final String id;
  final String userId;
  final DateTime takenAt;

  /// Map of trait names to scores (0-100)
  /// Examples: curiosity, persistence, creativity, analytical, social, etc.
  final Map<String, int> traitScores;

  /// Progress points earned from this assessment (0-20)
  final int deltaProgress;

  final AssessmentType type;
  final bool completed;

  Assessment copyWith({
    String? id,
    String? userId,
    DateTime? takenAt,
    Map<String, int>? traitScores,
    int? deltaProgress,
    AssessmentType? type,
    bool? completed,
  }) {
    return Assessment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      takenAt: takenAt ?? this.takenAt,
      traitScores: traitScores ?? this.traitScores,
      deltaProgress: deltaProgress ?? this.deltaProgress,
      type: type ?? this.type,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assessment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'Assessment(id: $id, userId: $userId, type: $type, '
        'deltaProgress: $deltaProgress, completed: $completed)';
  }
}

enum AssessmentType {
  quiz,
  game,
  onboarding;

  String toJson() => name;

  static AssessmentType fromJson(String value) {
    return AssessmentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AssessmentType.quiz,
    );
  }
}
