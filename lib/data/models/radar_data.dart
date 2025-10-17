/// Model for radar chart data point
class RadarDataPoint {
  final int featureIndex;
  final String featureKey;
  final String featureLabel;
  final String family;
  final double userScore;
  final double cohortMean;

  const RadarDataPoint({
    required this.featureIndex,
    required this.featureKey,
    required this.featureLabel,
    required this.family,
    required this.userScore,
    required this.cohortMean,
  });

  factory RadarDataPoint.fromJson(Map<String, dynamic> json) {
    return RadarDataPoint(
      featureIndex: json['feature_index'] as int,
      featureKey: json['feature_key'] as String,
      featureLabel: json['feature_label'] as String,
      family: json['family'] as String,
      userScore: (json['user_score_0_100'] as num).toDouble(),
      cohortMean: (json['cohort_mean_0_100'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature_index': featureIndex,
      'feature_key': featureKey,
      'feature_label': featureLabel,
      'family': family,
      'user_score_0_100': userScore,
      'cohort_mean_0_100': cohortMean,
    };
  }
}

/// Grouped radar data by feature family (Interests, Cognition, Traits)
/// Note: interests = RIASEC-based career interests
class RadarDataByFamily {
  final List<RadarDataPoint> interests; // Holland RIASEC model
  final List<RadarDataPoint> cognition;
  final List<RadarDataPoint> traits;

  const RadarDataByFamily({
    required this.interests,
    required this.cognition,
    required this.traits,
  });

  factory RadarDataByFamily.fromList(List<RadarDataPoint> allPoints) {
    final interests = <RadarDataPoint>[];
    final cognition = <RadarDataPoint>[];
    final traits = <RadarDataPoint>[];

    for (final point in allPoints) {
      switch (point.family.toLowerCase()) {
        case 'interests':
        case 'riasec': // Legacy support
          interests.add(point);
        case 'cognition':
          cognition.add(point);
        case 'traits':
          traits.add(point);
      }
    }

    return RadarDataByFamily(
      interests: interests,
      cognition: cognition,
      traits: traits,
    );
  }

  /// Legacy getter for backward compatibility
  List<RadarDataPoint> get riasec => interests;

  /// Get all data points in a single list
  List<RadarDataPoint> get all => [...interests, ...cognition, ...traits];

  /// Check if user has any data
  bool get hasData =>
      interests.isNotEmpty || cognition.isNotEmpty || traits.isNotEmpty;
}
