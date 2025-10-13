/// Feature score data model
class FeatureScore {
  const FeatureScore({
    required this.key,
    required this.mean,
    required this.n,
    required this.quality,
  });

  /// Feature key (e.g., 'trait_creativity')
  final String key;

  /// Mean score [0..100]
  final double mean;

  /// Number of observations
  final int n;

  /// Quality/confidence [0..1]
  final double quality;

  Map<String, dynamic> toJson() => {
        'key': key,
        'mean': mean,
        'n': n,
        'quality': quality,
      };

  factory FeatureScore.fromJson(Map<String, dynamic> json) => FeatureScore(
        key: json['key'] as String,
        mean: (json['mean'] as num).toDouble(),
        n: json['n'] as int,
        quality: (json['quality'] as num).toDouble(),
      );
}

/// Batch of feature scores to send to Edge Function
class FeatureScoreBatch {
  const FeatureScoreBatch({
    required this.userId,
    required this.features,
  });

  final String userId;
  final List<FeatureScore> features;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'batch_features': features.map((f) => f.toJson()).toList(),
      };
}
