import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'features_registry.dart';

// =====================================================
// Scoring Pipeline - Single Unified Pipeline
// =====================================================

/// Represents a single item outcome from a quiz or game
class ItemOutcome {
  /// Unique identifier for the item (e.g., question ID, game segment)
  final String itemId;

  /// Raw value from the item (normalized to -1..+1 or 0..1 depending on context)
  final double value;

  /// Duration in milliseconds (optional)
  final int? durationMs;

  /// Additional metadata (optional)
  final Map<String, dynamic>? metadata;

  const ItemOutcome({
    required this.itemId,
    required this.value,
    this.durationMs,
    this.metadata,
  });
}

/// Output from the scoring pipeline
class ScoringOutput {
  /// Normalized feature scores (0..100) for canonical keys only
  final Map<String, double> means0to100;

  /// Number of observations per feature
  final Map<String, int> nByKey;

  /// Quality score per feature (0..1)
  final Map<String, double> qualityByKey;

  /// Progress delta suggestion (0..20)
  final int deltaProgress;

  /// Overall composite score (0..100) - optional summary
  final int composite;

  const ScoringOutput({
    required this.means0to100,
    required this.nByKey,
    required this.qualityByKey,
    required this.deltaProgress,
    required this.composite,
  });

  /// Convert to batch_features format for Edge Function
  List<Map<String, dynamic>> toBatchFeatures() {
    return means0to100.entries.map((e) {
      return {
        'key': e.key,
        'mean': e.value,
        'n': nByKey[e.key] ?? 0,
        'quality': qualityByKey[e.key] ?? 0.5,
      };
    }).toList();
  }
}

/// Main scoring pipeline
class ScoringPipeline {
  /// Compute scores from item outcomes
  ///
  /// [items] - List of item outcomes from quiz/game
  /// [itemContributions] - Map of item IDs to their feature contributions
  /// [instrumentName] - Name of the instrument (e.g., "Mini RIASEC")
  /// [kind] - Type of assessment: "quiz" or "game"
  /// [baselineNPerKey] - Expected number of observations per key for quality calculation
  static ScoringOutput computeScores({
    required List<ItemOutcome> items,
    required Map<String, List<FeatureContribution>> itemContributions,
    required String instrumentName,
    required String kind,
    int baselineNPerKey = 5,
  }) {
    if (items.isEmpty) {
      throw ArgumentError('Cannot compute scores with empty items list');
    }

    // Step 1: Aggregate raw contributions per feature
    final Map<String, List<double>> rawByKey = {};
    final Map<String, int> countByKey = {};

    for (final item in items) {
      final contributions = itemContributions[item.itemId];
      if (contributions == null || contributions.isEmpty) {
        debugPrint(
          '⚠️ No feature contributions defined for item: ${item.itemId}',
        );
        continue;
      }

      for (final contrib in contributions) {
        // Validate canonical key
        if (!isCanonicalKey(contrib.key)) {
          throw StateError(
            'Non-canonical feature key in itemContributions: "${contrib.key}". '
            'Item: ${item.itemId}, Instrument: $instrumentName',
          );
        }

        // Compute weighted contribution
        final weightedValue = item.value * contrib.weight;

        rawByKey.putIfAbsent(contrib.key, () => []).add(weightedValue);
        countByKey[contrib.key] = (countByKey[contrib.key] ?? 0) + 1;
      }
    }

    if (rawByKey.isEmpty) {
      throw StateError(
        'No valid feature contributions computed. '
        'Check itemContributions mapping for instrument: $instrumentName',
      );
    }

    // Step 2: Normalize to 0..100 scale
    final Map<String, double> means0to100 = {};
    final Map<String, int> nByKey = {};
    final Map<String, double> qualityByKey = {};

    for (final entry in rawByKey.entries) {
      final key = entry.key;
      final values = entry.value;

      // Compute mean of raw values
      final rawMean = values.reduce((a, b) => a + b) / values.length;

      // Normalize to 0..100
      // Assuming raw values are in -1..+1 range (from Likert scales, etc.)
      // Map: -1 → 0, 0 → 50, +1 → 100
      final normalized = _normalizeToZeroHundred(rawMean);

      means0to100[key] = normalized;
      nByKey[key] = values.length;

      // Compute quality: more observations = higher quality
      // Quality = 0.3 + 0.7 * min(1.0, n / baseline)
      final quality = _computeQuality(values.length, baselineNPerKey);
      qualityByKey[key] = quality;
    }

    // Step 3: Compute delta progress
    // Base it on number of items completed, clamped to 0..20
    final deltaProgress = _computeDeltaProgress(items.length, kind);

    // Step 4: Compute composite score (average of all feature scores)
    final composite = means0to100.values.isEmpty
        ? 50
        : (means0to100.values.reduce((a, b) => a + b) / means0to100.length)
              .round()
              .clamp(0, 100);

    return ScoringOutput(
      means0to100: means0to100,
      nByKey: nByKey,
      qualityByKey: qualityByKey,
      deltaProgress: deltaProgress,
      composite: composite,
    );
  }

  /// Normalize a raw value (typically -1..+1) to 0..100 scale
  static double _normalizeToZeroHundred(double rawValue) {
    // Clamp input to -1..+1 range first
    final clamped = rawValue.clamp(-1.0, 1.0);

    // Map: -1 → 0, 0 → 50, +1 → 100
    final normalized = (clamped + 1.0) * 50.0;

    return normalized.clamp(0.0, 100.0);
  }

  /// Compute quality score based on number of observations
  static double _computeQuality(int n, int baseline) {
    if (n <= 0) return 0.0;
    final effectiveBaseline = baseline <= 0 ? 5 : baseline;

    // Quality = 0.3 + 0.7 * min(1.0, n / baseline)
    final ratio = math.min(1.0, n / effectiveBaseline);
    final quality = 0.3 + 0.7 * ratio;

    return quality.clamp(0.0, 1.0);
  }

  /// Compute progress delta based on number of items
  static int _computeDeltaProgress(int itemCount, String kind) {
    // Base progress per item
    final basePerItem = kind == 'game' ? 1.5 : 1.0;

    // Total = items * basePerItem, clamped to 0..8 for single session
    final total = (itemCount * basePerItem).round();

    return total.clamp(0, 8);
  }
}

// =====================================================
// Likert Scale Helpers
// =====================================================

/// Convert Likert 5-point scale (1-5) to normalized value (-1..+1)
double likert5ToNormalized(int response, {bool reverse = false}) {
  if (response < 1 || response > 5) {
    throw ArgumentError('Likert 5 response must be 1-5, got: $response');
  }

  // Map 1→-1, 2→-0.5, 3→0, 4→0.5, 5→1
  final normalized = (response - 3) / 2.0;

  return reverse ? -normalized : normalized;
}

/// Convert Likert 7-point scale (1-7) to normalized value (-1..+1)
double likert7ToNormalized(int response, {bool reverse = false}) {
  if (response < 1 || response > 7) {
    throw ArgumentError('Likert 7 response must be 1-7, got: $response');
  }

  // Map 1→-1, 4→0, 7→1
  final normalized = (response - 4) / 3.0;

  return reverse ? -normalized : normalized;
}

/// Convert binary choice (0 or 1) to normalized value
double binaryToNormalized(int response, {bool reverse = false}) {
  if (response != 0 && response != 1) {
    throw ArgumentError('Binary response must be 0 or 1, got: $response');
  }

  final normalized = response == 1 ? 1.0 : -1.0;

  return reverse ? -normalized : normalized;
}

// =====================================================
// Game-Specific Scoring Helpers
// =====================================================

/// Compute a score from a raw percentage (0..1) to normalized value
double percentageToNormalized(double percentage) {
  // Map 0→-1, 0.5→0, 1→1
  return (percentage * 2.0) - 1.0;
}

/// Compute a score from accuracy (correct/total)
double accuracyToNormalized(int correct, int total) {
  if (total == 0) return 0.0;
  final percentage = correct / total;
  return percentageToNormalized(percentage);
}
