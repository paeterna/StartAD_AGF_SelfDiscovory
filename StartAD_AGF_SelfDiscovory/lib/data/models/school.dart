/// School model for multi-tenant school system
class School {
  final String id;
  final String name;
  final String? code;
  final String? country;
  final String locale;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const School({
    required this.id,
    required this.name,
    this.code,
    this.country,
    required this.locale,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      country: json['country'] as String?,
      locale: json['locale'] as String? ?? 'en',
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country,
      'locale': locale,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Display label for dropdowns
  String get displayLabel {
    if (code != null) {
      return '$name ($code)';
    }
    return name;
  }

  School copyWith({
    String? id,
    String? name,
    String? code,
    String? country,
    String? locale,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      country: country ?? this.country,
      locale: locale ?? this.locale,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// School KPIs for dashboard
class SchoolKpis {
  final int totalStudents;
  final double avgProfileCompletion;
  final double avgMatchConfidence;
  final String? topCareerCluster;

  const SchoolKpis({
    required this.totalStudents,
    required this.avgProfileCompletion,
    required this.avgMatchConfidence,
    this.topCareerCluster,
  });

  factory SchoolKpis.fromJson(Map<String, dynamic> json) {
    return SchoolKpis(
      totalStudents: json['total_students'] as int? ?? 0,
      avgProfileCompletion:
          (json['avg_profile_completion'] as num?)?.toDouble() ?? 0.0,
      avgMatchConfidence:
          (json['avg_match_confidence'] as num?)?.toDouble() ?? 0.0,
      topCareerCluster: json['top_career_cluster'] as String?,
    );
  }
}

/// Top student model for school dashboard
class TopStudent {
  final String userId;
  final String? displayName;
  final String? email;
  final double profileCompletion;
  final double overallStrength;
  final DateTime? lastActivity;

  const TopStudent({
    required this.userId,
    this.displayName,
    this.email,
    required this.profileCompletion,
    required this.overallStrength,
    this.lastActivity,
  });

  factory TopStudent.fromJson(Map<String, dynamic> json) {
    return TopStudent(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      profileCompletion:
          (json['profile_completion'] as num?)?.toDouble() ?? 0.0,
      overallStrength: (json['overall_strength'] as num?)?.toDouble() ?? 0.0,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'] as String)
          : null,
    );
  }
}

/// Career distribution for school cohort
class CareerDistribution {
  final String cluster;
  final int careerCount;
  final double avgSimilarity;
  final int studentCount;

  const CareerDistribution({
    required this.cluster,
    required this.careerCount,
    required this.avgSimilarity,
    required this.studentCount,
  });

  factory CareerDistribution.fromJson(Map<String, dynamic> json) {
    return CareerDistribution(
      cluster: json['cluster'] as String,
      careerCount: json['career_count'] as int? ?? 0,
      avgSimilarity: (json['avg_similarity'] as num?)?.toDouble() ?? 0.0,
      studentCount: json['student_count'] as int? ?? 0,
    );
  }
}

/// School student list item
class SchoolStudent {
  final String userId;
  final String? displayName;
  final String? email;
  final double profileCompletion;
  final int discoveryPercent;
  final DateTime? lastActivity;
  final String? topCareer;

  const SchoolStudent({
    required this.userId,
    this.displayName,
    this.email,
    required this.profileCompletion,
    required this.discoveryPercent,
    this.lastActivity,
    this.topCareer,
  });

  factory SchoolStudent.fromJson(Map<String, dynamic> json) {
    return SchoolStudent(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      profileCompletion:
          (json['profile_completion'] as num?)?.toDouble() ?? 0.0,
      discoveryPercent: json['discovery_percent'] as int? ?? 0,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'] as String)
          : null,
      topCareer: json['top_career'] as String?,
    );
  }
}

/// School feature averages for radar chart
class SchoolFeatureAverage {
  final String featureKey;
  final String featureFamily;
  final double avgScore;

  const SchoolFeatureAverage({
    required this.featureKey,
    required this.featureFamily,
    required this.avgScore,
  });

  /// Alias for featureFamily for consistency
  String get family => featureFamily;

  /// Get label from feature key (simple formatting)
  String get label {
    // Convert "interest_creative" -> "Creative"
    // Convert "cognition_memory" -> "Memory"
    // Convert "trait_grit" -> "Grit"
    final parts = featureKey.split('_');
    if (parts.length > 1) {
      return parts[1][0].toUpperCase() + parts[1].substring(1);
    }
    return featureKey[0].toUpperCase() + featureKey.substring(1);
  }

  factory SchoolFeatureAverage.fromJson(Map<String, dynamic> json) {
    return SchoolFeatureAverage(
      featureKey: json['feature_key'] as String,
      featureFamily: json['feature_family'] as String,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 50.0,
    );
  }
}
