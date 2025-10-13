import '../../data/models/feature_score.dart';
import '../../data/models/quiz_instrument.dart';

/// Helper class for computing feature scores from quiz responses
class QuizScoringHelper {
  /// Compute feature scores from Likert scale responses
  ///
  /// Formula per item: item_score = weight * direction * (likert - 3) / 2
  /// This maps Likert 1-5 to range [-1, 1]
  /// Then aggregate by feature_key using mean, convert to [0, 100] scale
  static List<FeatureScore> computeFeatureScores({
    required List<QuizItem> items,
    required Map<String, int> responses,
  }) {
    // Group items by feature_key
    final Map<String, List<_ItemScore>> scoresByFeature = {};

    for (final item in items) {
      final likertValue = responses[item.id];
      if (likertValue == null) continue;

      // Compute item score: weight * direction * (likert - 3) / 2
      // Maps [1,5] → [-1, 1]
      final itemScore = item.weight *
          item.direction *
          (likertValue - 3) / 2.0;

      scoresByFeature.putIfAbsent(item.featureKey, () => []);
      scoresByFeature[item.featureKey]!.add(
        _ItemScore(
          score: itemScore,
          weight: item.weight,
        ),
      );
    }

    // Compute mean score for each feature and convert to [0, 100] scale
    final List<FeatureScore> featureScores = [];

    for (final entry in scoresByFeature.entries) {
      final featureKey = entry.key;
      final itemScores = entry.value;

      // Compute weighted mean (in practice, weights are usually 1.0)
      final sumScores = itemScores.fold<double>(
        0.0,
        (sum, item) => sum + item.score * item.weight,
      );
      final sumWeights = itemScores.fold<double>(
        0.0,
        (sum, item) => sum + item.weight,
      );

      final meanNormalized = sumScores / sumWeights; // → [-1, 1]

      // Convert to [0, 1] scale
      final mean01 = ((meanNormalized + 1.0) / 2.0).clamp(0.0, 1.0);

      // Convert to [0, 100] scale
      final mean100 = mean01 * 100.0;

      // Quality/confidence: based on number of items answered for this feature
      // More items = higher quality
      // Use formula: quality = min(1.0, n / 5) where n = number of items
      final quality = (itemScores.length / 5.0).clamp(0.0, 1.0);

      featureScores.add(
        FeatureScore(
          key: featureKey,
          mean: mean100,
          n: itemScores.length,
          quality: quality,
        ),
      );
    }

    return featureScores;
  }

  /// Compute delta progress based on number of items answered
  /// Each item contributes a small amount to overall progress
  /// Cap at 20 per assessment (as per data contract guidelines)
  static int computeDeltaProgress({
    required int totalItems,
    required int answeredItems,
  }) {
    if (answeredItems == 0) return 0;

    // Full completion of assessment gives 20% progress
    final progressPerItem = 20.0 / totalItems;
    final deltaProgress = (progressPerItem * answeredItems).round();

    return deltaProgress.clamp(0, 20);
  }

  /// Compute overall confidence for the assessment
  /// Based on completion percentage
  static double computeOverallConfidence({
    required int totalItems,
    required int answeredItems,
  }) {
    if (totalItems == 0) return 0.0;

    final completionRate = answeredItems / totalItems;

    // Full completion gives confidence of 0.8
    // Partial completion scales proportionally
    return (completionRate * 0.8).clamp(0.0, 0.8);
  }

  /// Validate that all required items have responses
  static bool areAllItemsAnswered({
    required List<QuizItem> items,
    required Map<String, int> responses,
  }) {
    return items.every((item) => responses.containsKey(item.id));
  }

  /// Get list of unanswered item IDs
  static List<String> getUnansweredItems({
    required List<QuizItem> items,
    required Map<String, int> responses,
  }) {
    return items
        .where((item) => !responses.containsKey(item.id))
        .map((item) => item.id)
        .toList();
  }
}

/// Internal class to hold item score and weight
class _ItemScore {
  final double score;
  final double weight;

  const _ItemScore({
    required this.score,
    required this.weight,
  });
}
