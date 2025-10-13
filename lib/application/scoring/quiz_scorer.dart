import 'dart:math' as math;
import 'package:startad_agf_selfdiscovery/data/models/feature_score.dart';

/// Quiz item configuration
class QuizItem {
  const QuizItem({
    required this.itemId,
    required this.featureKey,
    this.direction = 1.0,
    this.weight = 1.0,
  });

  final String itemId;
  final String featureKey;
  final double direction; // 1.0 or -1.0
  final double weight;
}

/// Quiz response
class QuizResponse {
  const QuizResponse({
    required this.itemId,
    required this.likertValue,
    this.durationMs,
  });

  final String itemId;
  final int likertValue; // 1-5
  final int? durationMs;
}

/// Quiz scoring service
/// Implements Likert scoring: item_score = weight * direction * (likert - 3) / 2
class QuizScorer {
  /// Score a quiz item using Likert scale
  /// Returns normalized score [0..100]
  static double scoreItem({
    required int likertValue,
    required double direction,
    required double weight,
  }) {
    // Validate inputs
    if (likertValue < 1 || likertValue > 5) {
      throw ArgumentError('Likert value must be between 1 and 5');
    }

    // Compute raw score [-1..1]
    final rawScore = weight * direction * (likertValue - 3) / 2;

    // Normalize to [0..100] scale
    // -1 -> 0, 0 -> 50, 1 -> 100
    final normalized = 50 + (rawScore * 50);

    return normalized.clamp(0, 100);
  }

  /// Compute batch feature scores from quiz responses
  /// Returns aggregated scores per feature
  static List<FeatureScore> computeBatchScores({
    required List<QuizResponse> responses,
    required List<QuizItem> items,
    double defaultQuality = 0.7,
  }) {
    // Create item lookup map
    final itemMap = {for (final item in items) item.itemId: item};

    // Accumulate scores by feature
    final featureScores = <String, List<double>>{};
    final responseCounts = <String, int>{};

    for (final response in responses) {
      final item = itemMap[response.itemId];
      if (item == null) {
        continue; // Skip unknown items
      }

      final score = scoreItem(
        likertValue: response.likertValue,
        direction: item.direction,
        weight: item.weight,
      );

      featureScores.putIfAbsent(item.featureKey, () => []).add(score);
      responseCounts[item.featureKey] =
          (responseCounts[item.featureKey] ?? 0) + 1;
    }

    // Compute mean for each feature
    final batchScores = <FeatureScore>[];

    for (final entry in featureScores.entries) {
      final key = entry.key;
      final scores = entry.value;
      final mean = scores.reduce((a, b) => a + b) / scores.length;
      final n = responseCounts[key] ?? scores.length;

      // Quality can be adjusted based on response consistency
      // For now, use default quality
      batchScores.add(
        FeatureScore(
          key: key,
          mean: mean,
          n: n,
          quality: defaultQuality,
        ),
      );
    }

    return batchScores;
  }

  /// Compute quality score based on response consistency
  /// Returns value [0..1]
  static double computeQuality(List<double> scores) {
    if (scores.length < 2) {
      return 0.5; // Default for single response
    }

    // Use inverse of coefficient of variation as quality metric
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    if (mean == 0) return 0.5;

    final variance = scores
        .map((s) => math.pow(s - mean, 2))
        .reduce((a, b) => a + b) / scores.length;
    final stdDev = math.sqrt(variance);
    final cv = stdDev / mean;

    // Lower CV = higher quality
    // CV of 0.5 -> quality 0.5, CV of 0 -> quality 1.0
    final quality = 1.0 - cv.clamp(0, 1);

    return quality;
  }

  /// Normalize raw score using z-score transformation
  /// z = (raw - mean) / stdDev
  /// normalized = clamp(50 + 10*z, 0, 100)
  static double normalizeWithZScore({
    required double rawScore,
    required double cohortMean,
    required double cohortStdDev,
  }) {
    if (cohortStdDev == 0) {
      return 50; // Default if no variance
    }

    final z = (rawScore - cohortMean) / cohortStdDev;
    final normalized = 50 + (10 * z);

    return normalized.clamp(0, 100);
  }
}
