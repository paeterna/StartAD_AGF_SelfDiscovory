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

/// Grouped radar data by feature family (RIASEC, Cognition, Traits)
class RadarDataByFamily {
  final List<RadarDataPoint> riasec;
  final List<RadarDataPoint> cognition;
  final List<RadarDataPoint> traits;

  const RadarDataByFamily({
    required this.riasec,
    required this.cognition,
    required this.traits,
  });

  factory RadarDataByFamily.fromList(List<RadarDataPoint> allPoints) {
    final riasec = <RadarDataPoint>[];
    final cognition = <RadarDataPoint>[];
    final traits = <RadarDataPoint>[];

    for (final point in allPoints) {
      switch (point.family.toLowerCase()) {
        case 'riasec':
          riasec.add(point);
        case 'cognition':
          cognition.add(point);
        case 'traits':
          traits.add(point);
      }
    }

    return RadarDataByFamily(
      riasec: riasec,
      cognition: cognition,
      traits: traits,
    );
  }

  /// Get all data points in a single list
  List<RadarDataPoint> get all => [...riasec, ...cognition, ...traits];

  /// Check if user has any data
  bool get hasData =>
      riasec.isNotEmpty || cognition.isNotEmpty || traits.isNotEmpty;
}
