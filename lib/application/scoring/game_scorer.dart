import 'dart:math' as math;
import 'package:startad_agf_selfdiscovery/data/models/feature_score.dart';

/// Game telemetry data
class GameTelemetry {
  const GameTelemetry({
    required this.correct,
    required this.total,
    required this.reactionTimes,
    this.targetTime,
    this.metadata,
  });

  final int correct;
  final int total;
  final List<double> reactionTimes; // in milliseconds
  final double? targetTime; // in milliseconds
  final Map<String, dynamic>? metadata;
}

/// Game feature mapping configuration
class GameFeatureMapping {
  const GameFeatureMapping({
    required this.featureKey,
    required this.computeScore,
    this.weight = 1.0,
  });

  final String featureKey;
  final double Function(GameTelemetry telemetry) computeScore;
  final double weight;
}

/// Game scoring service
/// Implements telemetry-based scoring for cognitive games
class GameScorer {
  /// Compute accuracy metric [0..1]
  static double computeAccuracy(GameTelemetry telemetry) {
    if (telemetry.total == 0) return 0.0;
    return telemetry.correct / telemetry.total;
  }

  /// Compute speed metric [0..1]
  /// speed = clamp(target_time / user_time, 0, 1)
  static double computeSpeed(GameTelemetry telemetry) {
    if (telemetry.targetTime == null ||
        telemetry.reactionTimes.isEmpty ||
        telemetry.targetTime! <= 0) {
      return 0.5; // Default
    }

    final avgTime = telemetry.reactionTimes.reduce((a, b) => a + b) /
        telemetry.reactionTimes.length;

    if (avgTime <= 0) return 0.5;

    final speed = telemetry.targetTime! / avgTime;
    return speed.clamp(0, 1);
  }

  /// Compute stability metric [0..1]
  /// stability = 1 - (stddev(reaction_times) / max_std)
  static double computeStability(
    GameTelemetry telemetry, {
    double maxStd = 500.0,
  }) {
    if (telemetry.reactionTimes.length < 2) {
      return 0.5; // Default for single response
    }

    final mean = telemetry.reactionTimes.reduce((a, b) => a + b) /
        telemetry.reactionTimes.length;

    final variance = telemetry.reactionTimes
        .map((rt) => math.pow(rt - mean, 2))
        .reduce((a, b) => a + b) / telemetry.reactionTimes.length;

    final stdDev = math.sqrt(variance);
    final stability = 1.0 - (stdDev / maxStd).clamp(0.0, 1.0);

    return stability;
  }

  /// Compute composite problem-solving score
  /// problem_solving = 0.5*accuracy + 0.3*speed + 0.2*stability
  static double computeProblemSolving(GameTelemetry telemetry) {
    final accuracy = computeAccuracy(telemetry);
    final speed = computeSpeed(telemetry);
    final stability = computeStability(telemetry);

    return 0.5 * accuracy + 0.3 * speed + 0.2 * stability;
  }

  /// Compute attention score (based on consistency)
  static double computeAttention(GameTelemetry telemetry) {
    final accuracy = computeAccuracy(telemetry);
    final stability = computeStability(telemetry);

    return 0.6 * accuracy + 0.4 * stability;
  }

  /// Compute memory score
  static double computeMemory(GameTelemetry telemetry) {
    // Memory is primarily about accuracy
    return computeAccuracy(telemetry);
  }

  /// Compute spatial reasoning score
  static double computeSpatial(GameTelemetry telemetry) {
    final accuracy = computeAccuracy(telemetry);
    final speed = computeSpeed(telemetry);

    return 0.7 * accuracy + 0.3 * speed;
  }

  /// Compute quantitative reasoning score
  static double computeQuantitative(GameTelemetry telemetry) {
    final accuracy = computeAccuracy(telemetry);
    final speed = computeSpeed(telemetry);

    return 0.6 * accuracy + 0.4 * speed;
  }

  /// Compute verbal reasoning score
  static double computeVerbal(GameTelemetry telemetry) {
    final accuracy = computeAccuracy(telemetry);
    final speed = computeSpeed(telemetry);

    return 0.65 * accuracy + 0.35 * speed;
  }

  /// Scale raw metric [0..1] to [0..100]
  static double scaleToHundred(double metric) {
    return (metric * 100).clamp(0, 100);
  }

  /// Normalize using z-score
  /// z = (raw - mean) / stdDev
  /// normalized = clamp(50 + 10*z, 0, 100)
  static double normalizeWithZScore({
    required double rawScore,
    required double cohortMean,
    required double cohortStdDev,
  }) {
    if (cohortStdDev == 0) {
      return 50;
    }

    final z = (rawScore - cohortMean) / cohortStdDev;
    final normalized = 50 + (10 * z);

    return normalized.clamp(0, 100);
  }

  /// Compute batch feature scores from game telemetry
  static List<FeatureScore> computeBatchScores({
    required GameTelemetry telemetry,
    required List<GameFeatureMapping> mappings,
    double qualityMultiplier = 1.0,
  }) {
    final batchScores = <FeatureScore>[];

    // Base quality on number of trials and accuracy
    final accuracy = computeAccuracy(telemetry);
    final trialQuality = math.min(1.0, telemetry.total / 10.0);
    final baseQuality = (0.5 + 0.5 * accuracy) * trialQuality * qualityMultiplier;

    for (final mapping in mappings) {
      final rawScore = mapping.computeScore(telemetry);
      final normalized = scaleToHundred(rawScore);

      batchScores.add(
        FeatureScore(
          key: mapping.featureKey,
          mean: normalized,
          n: telemetry.total,
          quality: baseQuality.clamp(0.3, 0.9),
        ),
      );
    }

    return batchScores;
  }

  /// Clamp value between min and max
  static double clamp(double value, double min, double max) {
    return math.max(min, math.min(max, value));
  }

  /// Common game feature mappings
  static List<GameFeatureMapping> get problemSolvingMappings => [
        GameFeatureMapping(
          featureKey: 'cognition_problem_solving',
          computeScore: computeProblemSolving,
          weight: 1.0,
        ),
        GameFeatureMapping(
          featureKey: 'cognition_attention',
          computeScore: computeAttention,
          weight: 0.8,
        ),
        GameFeatureMapping(
          featureKey: 'trait_grit',
          computeScore: (t) => computeAccuracy(t) * 0.7 + computeStability(t) * 0.3,
          weight: 0.6,
        ),
      ];

  static List<GameFeatureMapping> get memoryMappings => [
        GameFeatureMapping(
          featureKey: 'cognition_memory',
          computeScore: computeMemory,
          weight: 1.0,
        ),
        GameFeatureMapping(
          featureKey: 'cognition_attention',
          computeScore: computeAttention,
          weight: 0.7,
        ),
      ];

  static List<GameFeatureMapping> get spatialMappings => [
        GameFeatureMapping(
          featureKey: 'cognition_spatial',
          computeScore: computeSpatial,
          weight: 1.0,
        ),
        GameFeatureMapping(
          featureKey: 'cognition_problem_solving',
          computeScore: computeProblemSolving,
          weight: 0.6,
        ),
      ];

  static List<GameFeatureMapping> get quantitativeMappings => [
        GameFeatureMapping(
          featureKey: 'cognition_quantitative',
          computeScore: computeQuantitative,
          weight: 1.0,
        ),
        GameFeatureMapping(
          featureKey: 'cognition_problem_solving',
          computeScore: computeProblemSolving,
          weight: 0.7,
        ),
      ];

  static List<GameFeatureMapping> get verbalMappings => [
        GameFeatureMapping(
          featureKey: 'cognition_verbal',
          computeScore: computeVerbal,
          weight: 1.0,
        ),
        GameFeatureMapping(
          featureKey: 'cognition_memory',
          computeScore: computeMemory,
          weight: 0.5,
        ),
      ];
}
