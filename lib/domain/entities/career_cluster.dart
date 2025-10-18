import 'package:flutter/foundation.dart';
import 'career.dart';

/// Career cluster with top matching careers
@immutable
class CareerCluster {
  const CareerCluster({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.topCareers,
    required this.maxMatchScore,
  });

  final String id;
  final String name;
  final String description;
  final String icon;

  /// Top 3 careers in this cluster (sorted by match score)
  final List<Career> topCareers;

  /// Highest match score among all careers in this cluster
  final int maxMatchScore;

  factory CareerCluster.fromJson(Map<String, dynamic> json) {
    return CareerCluster(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '💼',
      topCareers: (json['top_careers'] as List<dynamic>?)
              ?.map((c) => Career(
                    id: c['id'] as String,
                    title: c['title'] as String,
                    description: c['description'] as String? ?? '',
                    tags: (c['tags'] as List<dynamic>?)?.cast<String>() ?? [],
                    matchScore: (c['match_score'] as num?)?.toInt() ?? 0,
                    cluster: json['name'] as String,
                  ))
              .toList() ??
          [],
      maxMatchScore: (json['max_match_score'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'top_careers': topCareers
          .map((c) => {
                'id': c.id,
                'title': c.title,
                'description': c.description,
                'tags': c.tags,
                'match_score': c.matchScore,
              })
          .toList(),
      'max_match_score': maxMatchScore,
    };
  }

  CareerCluster copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    List<Career>? topCareers,
    int? maxMatchScore,
  }) {
    return CareerCluster(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      topCareers: topCareers ?? this.topCareers,
      maxMatchScore: maxMatchScore ?? this.maxMatchScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerCluster && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CareerCluster(id: $id, name: $name, topCareers: ${topCareers.length}, '
        'maxMatchScore: $maxMatchScore)';
  }
}
