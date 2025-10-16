import 'package:flutter/foundation.dart';

/// AI-generated career insight entity
@immutable
class AIInsight {
  const AIInsight({
    required this.id,
    required this.userId,
    required this.personalitySummary,
    required this.skillsDetected,
    required this.interestScores,
    required this.careerRecommendations,
    required this.careerReasoning,
    required this.learningPath,
    required this.createdAt,
    this.confidenceScore = 0.0,
    this.dataPointsUsed = 0,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String personalitySummary;
  final List<String> skillsDetected;
  final Map<String, double> interestScores;
  final List<CareerRecommendation> careerRecommendations;
  final Map<String, String> careerReasoning;
  final List<LearningPathStep> learningPath;
  final double confidenceScore;
  final int dataPointsUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AIInsight copyWith({
    String? id,
    String? userId,
    String? personalitySummary,
    List<String>? skillsDetected,
    Map<String, double>? interestScores,
    List<CareerRecommendation>? careerRecommendations,
    Map<String, String>? careerReasoning,
    List<LearningPathStep>? learningPath,
    double? confidenceScore,
    int? dataPointsUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personalitySummary: personalitySummary ?? this.personalitySummary,
      skillsDetected: skillsDetected ?? this.skillsDetected,
      interestScores: interestScores ?? this.interestScores,
      careerRecommendations: careerRecommendations ?? this.careerRecommendations,
      careerReasoning: careerReasoning ?? this.careerReasoning,
      learningPath: learningPath ?? this.learningPath,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      dataPointsUsed: dataPointsUsed ?? this.dataPointsUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIInsight &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'AIInsight(id: $id, userId: $userId, '
        'confidence: $confidenceScore, dataPoints: $dataPointsUsed)';
  }
}

/// Career recommendation from AI analysis
@immutable
class CareerRecommendation {
  const CareerRecommendation({
    required this.title,
    required this.matchScore,
    required this.description,
    required this.whyGoodFit,
  });

  final String title;
  final double matchScore;
  final String description;
  final String whyGoodFit;

  factory CareerRecommendation.fromJson(Map<String, dynamic> json) {
    return CareerRecommendation(
      title: json['title'] as String,
      matchScore: (json['match_score'] as num).toDouble(),
      description: json['description'] as String,
      whyGoodFit: json['why_good_fit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'match_score': matchScore,
      'description': description,
      'why_good_fit': whyGoodFit,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerRecommendation &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}

/// Learning path step from AI analysis
@immutable
class LearningPathStep {
  const LearningPathStep({
    required this.title,
    required this.description,
    required this.type,
    this.priority = 1,
  });

  final String title;
  final String description;
  final String type; // course, activity, challenge, resource
  final int priority;

  factory LearningPathStep.fromJson(Map<String, dynamic> json) {
    return LearningPathStep(
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      priority: json['priority'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'priority': priority,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningPathStep &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}

