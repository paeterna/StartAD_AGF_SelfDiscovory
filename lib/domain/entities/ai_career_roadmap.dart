import 'package:flutter/foundation.dart';

/// Individual step within a roadmap phase
@immutable
class RoadmapStep {
  const RoadmapStep({
    required this.title,
    required this.description,
    required this.details,
    required this.resources,
    this.tip,
    this.isOptional = false,
  });

  final String title;
  final String description;
  final List<String> details;
  final List<String> resources;
  final String? tip;
  final bool isOptional;

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      title: json['title'] as String,
      description: json['description'] as String,
      details: (json['details'] as List<dynamic>).cast<String>(),
      resources: (json['resources'] as List<dynamic>).cast<String>(),
      tip: json['tip'] as String?,
      isOptional: json['is_optional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'details': details,
      'resources': resources,
      'tip': tip,
      'is_optional': isOptional,
    };
  }

  RoadmapStep copyWith({
    String? title,
    String? description,
    List<String>? details,
    List<String>? resources,
    String? tip,
    bool? isOptional,
  }) {
    return RoadmapStep(
      title: title ?? this.title,
      description: description ?? this.description,
      details: details ?? this.details,
      resources: resources ?? this.resources,
      tip: tip ?? this.tip,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoadmapStep &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => title.hashCode ^ description.hashCode;
}

/// Phase type enum
enum PhaseType {
  school,
  university,
  skills,
  career;

  String toJson() => name;

  static PhaseType fromJson(String value) {
    return PhaseType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PhaseType.school,
    );
  }
}

/// Phase within a career roadmap (School, University, Skills, Career)
@immutable
class RoadmapPhase {
  const RoadmapPhase({
    required this.id,
    required this.phaseType,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.duration,
    required this.steps,
  });

  final String id;
  final PhaseType phaseType;
  final String title;
  final String subtitle;
  final String icon;
  final String duration;
  final List<RoadmapStep> steps;

  factory RoadmapPhase.fromJson(Map<String, dynamic> json) {
    return RoadmapPhase(
      id: json['id'] as String,
      phaseType: PhaseType.fromJson(json['phase_type'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: json['icon'] as String,
      duration: json['duration'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((s) => RoadmapStep.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phase_type': phaseType.toJson(),
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
      'duration': duration,
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }

  RoadmapPhase copyWith({
    String? id,
    PhaseType? phaseType,
    String? title,
    String? subtitle,
    String? icon,
    String? duration,
    List<RoadmapStep>? steps,
  }) {
    return RoadmapPhase(
      id: id ?? this.id,
      phaseType: phaseType ?? this.phaseType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      duration: duration ?? this.duration,
      steps: steps ?? this.steps,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoadmapPhase &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Complete AI-generated career roadmap
@immutable
class AICareerRoadmap {
  const AICareerRoadmap({
    required this.id,
    required this.userId,
    required this.careerId,
    required this.careerTitle,
    required this.description,
    required this.estimatedDuration,
    required this.salaryRange,
    required this.icon,
    required this.phases,
    required this.generatedAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String careerId;
  final String careerTitle;
  final String description;
  final String estimatedDuration;
  final String salaryRange;
  final String icon;
  final List<RoadmapPhase> phases;
  final DateTime generatedAt;
  final DateTime? updatedAt;

  factory AICareerRoadmap.fromJson(Map<String, dynamic> json) {
    return AICareerRoadmap(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      careerId: json['career_id'] as String,
      careerTitle: json['career_title'] as String,
      description: json['description'] as String,
      estimatedDuration: json['estimated_duration'] as String,
      salaryRange: json['salary_range'] as String,
      icon: json['icon'] as String,
      phases: (json['phases'] as List<dynamic>)
          .map((p) => RoadmapPhase.fromJson(p as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'career_id': careerId,
      'career_title': careerTitle,
      'description': description,
      'estimated_duration': estimatedDuration,
      'salary_range': salaryRange,
      'icon': icon,
      'phases': phases.map((p) => p.toJson()).toList(),
      'generated_at': generatedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AICareerRoadmap copyWith({
    String? id,
    String? userId,
    String? careerId,
    String? careerTitle,
    String? description,
    String? estimatedDuration,
    String? salaryRange,
    String? icon,
    List<RoadmapPhase>? phases,
    DateTime? generatedAt,
    DateTime? updatedAt,
  }) {
    return AICareerRoadmap(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      careerId: careerId ?? this.careerId,
      careerTitle: careerTitle ?? this.careerTitle,
      description: description ?? this.description,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      salaryRange: salaryRange ?? this.salaryRange,
      icon: icon ?? this.icon,
      phases: phases ?? this.phases,
      generatedAt: generatedAt ?? this.generatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AICareerRoadmap &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AICareerRoadmap(id: $id, careerTitle: $careerTitle, '
        'phases: ${phases.length}, generatedAt: $generatedAt)';
  }
}

/// Summary info about a user's roadmap (for listing)
@immutable
class AICareerRoadmapSummary {
  const AICareerRoadmapSummary({
    required this.id,
    required this.careerId,
    required this.careerTitle,
    required this.description,
    required this.icon,
    required this.estimatedDuration,
    required this.generatedAt,
  });

  final String id;
  final String careerId;
  final String careerTitle;
  final String description;
  final String icon;
  final String estimatedDuration;
  final DateTime generatedAt;

  factory AICareerRoadmapSummary.fromJson(Map<String, dynamic> json) {
    return AICareerRoadmapSummary(
      id: json['id'] as String,
      careerId: json['career_id'] as String,
      careerTitle: json['career_title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      estimatedDuration: json['estimated_duration'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  factory AICareerRoadmapSummary.fromRoadmap(AICareerRoadmap roadmap) {
    return AICareerRoadmapSummary(
      id: roadmap.id,
      careerId: roadmap.careerId,
      careerTitle: roadmap.careerTitle,
      description: roadmap.description,
      icon: roadmap.icon,
      estimatedDuration: roadmap.estimatedDuration,
      generatedAt: roadmap.generatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AICareerRoadmapSummary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
