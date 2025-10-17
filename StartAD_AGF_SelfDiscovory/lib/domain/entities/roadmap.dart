import 'package:flutter/foundation.dart';

/// Roadmap step entity representing a task/milestone in a career path
@immutable
class RoadmapStep {
  const RoadmapStep({
    required this.id,
    required this.careerId,
    required this.title,
    required this.description,
    required this.order,
    this.completed = false,
    this.category = RoadmapStepCategory.subject,
    this.estimatedDuration,
    this.resources = const [],
  });

  final String id;
  final String careerId;
  final String title;
  final String description;
  final int order;
  final bool completed;
  final RoadmapStepCategory category;

  /// Estimated duration in weeks
  final int? estimatedDuration;

  /// List of helpful resources (URLs, book titles, etc.)
  final List<String> resources;

  RoadmapStep copyWith({
    String? id,
    String? careerId,
    String? title,
    String? description,
    int? order,
    bool? completed,
    RoadmapStepCategory? category,
    int? estimatedDuration,
    List<String>? resources,
  }) {
    return RoadmapStep(
      id: id ?? this.id,
      careerId: careerId ?? this.careerId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      completed: completed ?? this.completed,
      category: category ?? this.category,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      resources: resources ?? this.resources,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoadmapStep &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoadmapStep(id: $id, careerId: $careerId, title: $title, '
        'completed: $completed, category: $category)';
  }
}

enum RoadmapStepCategory {
  subject('Subject/Course'),
  activity('Activity'),
  skill('Skill'),
  project('Project'),
  certification('Certification'),
  experience('Experience');

  const RoadmapStepCategory(this.label);
  final String label;

  String toJson() => name;

  static RoadmapStepCategory fromJson(String value) {
    return RoadmapStepCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RoadmapStepCategory.subject,
    );
  }
}

/// Roadmap entity representing a complete career path
@immutable
class Roadmap {
  const Roadmap({
    required this.userId,
    required this.careerId,
    required this.steps,
    this.createdAt,
  });

  final String userId;
  final String careerId;
  final List<RoadmapStep> steps;
  final DateTime? createdAt;

  int get totalSteps => steps.length;
  int get completedSteps => steps.where((s) => s.completed).length;
  double get progressPercent =>
      totalSteps > 0 ? (completedSteps / totalSteps) * 100 : 0;

  Roadmap copyWith({
    String? userId,
    String? careerId,
    List<RoadmapStep>? steps,
    DateTime? createdAt,
  }) {
    return Roadmap(
      userId: userId ?? this.userId,
      careerId: careerId ?? this.careerId,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Roadmap &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          careerId == other.careerId;

  @override
  int get hashCode => userId.hashCode ^ careerId.hashCode;

  @override
  String toString() {
    return 'Roadmap(userId: $userId, careerId: $careerId, '
        'progress: $completedSteps/$totalSteps)';
  }
}
