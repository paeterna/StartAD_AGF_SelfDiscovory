import '../../core/scoring/features_registry.dart';
import '../../core/scoring/scoring_pipeline.dart';
import '../../data/models/feature_score.dart';
import '../../data/models/quiz_instrument.dart';

/// Helper class for computing feature scores from quiz responses
/// UPDATED: Now uses canonical features registry and unified scoring pipeline
class QuizScoringHelper {
  /// Build item contributions map from quiz metadata
  ///
  /// Maps quiz item IDs to their canonical feature contributions.
  /// Handles RIASEC → canonical mapping automatically.
  static Map<String, List<FeatureContribution>> buildItemContributions({
    required List<QuizItem> items,
    String? instrument,
  }) {
    final Map<String, List<FeatureContribution>> contributions = {};

    for (final item in items) {
      String canonicalKey;

      // Map to canonical features based on instrument type
      if (instrument != null && instrument.contains('riasec')) {
        try {
          canonicalKey = riasecToCanonical(item.featureKey);
        } catch (e) {
          throw StateError(
            'Invalid RIASEC key in quiz item ${item.id}: "${item.featureKey}". '
            'Error: $e',
          );
        }
      } else if (instrument != null && instrument.contains('ipip')) {
        // IPIP-50 Big Five to canonical traits mapping
        try {
          canonicalKey = bigFiveToCanonical(item.featureKey);
        } catch (e) {
          throw StateError(
            'Invalid Big Five key in quiz item ${item.id}: "${item.featureKey}". '
            'Error: $e',
          );
        }
      } else {
        // For other quizzes, assume feature_key is already canonical
        canonicalKey = item.featureKey;

        // Validate it's canonical
        if (!isCanonicalKey(canonicalKey)) {
          throw StateError(
            'Non-canonical feature key in quiz item ${item.id}: "$canonicalKey". '
            'Valid canonical keys are defined in features_registry.dart',
          );
        }
      }

      contributions[item.id] = [
        FeatureContribution(
          key: canonicalKey,
          weight: item.direction * item.weight,
        ),
      ];
    }

    return contributions;
  }

  /// Compute feature scores from Likert scale responses
  ///
  /// Formula per item: item_score = weight * direction * (likert - 3) / 2
  /// This maps Likert 1-5 to range [-1, 1]
  /// Then aggregate by feature_key using mean, convert to [0, 100] scale
  ///
  /// UPDATED: Now uses unified scoring pipeline and canonical features
  static List<FeatureScore> computeFeatureScores({
    required List<QuizItem> items,
    required Map<String, int> responses,
    String? instrument,
  }) {
    // Build item contributions map
    final itemContributions = buildItemContributions(
      items: items,
      instrument: instrument,
    );

    // Convert quiz responses to ItemOutcomes
    final List<ItemOutcome> outcomes = [];
    for (final item in items) {
      final likertValue = responses[item.id];
      if (likertValue == null) continue;

      // Convert Likert 5-point to normalized value (-1..+1)
      final normalized = likert5ToNormalized(likertValue);

      outcomes.add(
        ItemOutcome(
          itemId: item.id,
          value: normalized,
        ),
      );
    }

    if (outcomes.isEmpty) {
      return [];
    }

    // Use unified scoring pipeline
    final scoringOutput = ScoringPipeline.computeScores(
      items: outcomes,
      itemContributions: itemContributions,
      instrumentName: instrument ?? 'quiz',
      kind: 'quiz',
      baselineNPerKey: 5,
    );

    // Convert to FeatureScore format for compatibility
    final List<FeatureScore> featureScores = [];
    for (final entry in scoringOutput.means0to100.entries) {
      featureScores.add(
        FeatureScore(
          key: entry.key,
          mean: entry.value,
          n: scoringOutput.nByKey[entry.key] ?? 0,
          quality: scoringOutput.qualityByKey[entry.key] ?? 0.5,
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
