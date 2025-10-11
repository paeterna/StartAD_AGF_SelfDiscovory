import 'package:flutter/foundation.dart';

/// Career entity representing a career option
@immutable
class Career {
  const Career({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    this.matchScore = 0,
    this.cluster = '',
    this.iconPath,
    this.imagePath,
  });

  final String id;
  final String title;
  final String description;

  /// Tags representing interests/traits (e.g., 'creative', 'analytical', 'social')
  final List<String> tags;

  /// Computed match score (0-100) based on user's trait scores
  final int matchScore;

  /// Career cluster (e.g., 'STEM', 'Arts', 'Business', 'Healthcare')
  final String cluster;

  final String? iconPath;
  final String? imagePath;

  Career copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    int? matchScore,
    String? cluster,
    String? iconPath,
    String? imagePath,
  }) {
    return Career(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      matchScore: matchScore ?? this.matchScore,
      cluster: cluster ?? this.cluster,
      iconPath: iconPath ?? this.iconPath,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Career && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Career(id: $id, title: $title, matchScore: $matchScore, '
        'cluster: $cluster, tags: $tags)';
  }
}

/// Career cluster categories
enum CareerCluster {
  stem('STEM'),
  arts('Arts & Humanities'),
  business('Business & Finance'),
  healthcare('Healthcare'),
  education('Education'),
  engineering('Engineering'),
  technology('Technology'),
  social('Social Services'),
  trades('Skilled Trades'),
  other('Other');

  const CareerCluster(this.label);
  final String label;

  String toJson() => name;

  static CareerCluster fromJson(String value) {
    return CareerCluster.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CareerCluster.other,
    );
  }
}
