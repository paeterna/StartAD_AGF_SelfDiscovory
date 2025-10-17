
/// V2 Scoring for Memory Match (multi-factor)
/// This module is self-contained and does not rely on V1 helpers.
library memory_match_scoring_v2;

import 'dart:math' as math;

double _clamp01(num x) => x < 0 ? 0.0 : (x > 1 ? 1.0 : x.toDouble());

class MMV2Inputs {
  MMV2Inputs({
    required this.pairs,
    required this.moves,
    required this.matches,
    required this.mismatches,
    required this.totalSeconds,
    this.avgFlipIntervalMs,
    this.peakFocusStreak,
    this.earlyMistakes,
    this.lateMistakes,
    // Optional advanced telemetry (neutral defaults will be used if null)
    this.repeatMismatches,
    this.uniqueSinglesBeforeFirstMatch,
    this.spatialPathEntropy,
    this.systematicSweepFlips,
    this.coefVarFlipInterval,
    this.coefVarInterMatch,
    this.normalizedMismatchSlope,
    this.progressPercent,
    this.completed,
  });

  final int pairs;
  final int moves;
  final int matches;
  final int mismatches;
  final int totalSeconds;
  final int? avgFlipIntervalMs;
  final int? peakFocusStreak;
  final int? earlyMistakes;
  final int? lateMistakes;

  // Optional
  final int? repeatMismatches;
  final int? uniqueSinglesBeforeFirstMatch;
  /// 0..1 (0 systematic, 1 random). If null we infer from heuristics.
  final double? spatialPathEntropy;
  final int? systematicSweepFlips;
  /// 0..1
  final double? coefVarFlipInterval;
  /// 0..1
  final double? coefVarInterMatch;
  /// -1..1 (negative is good). If null, neutral 0.
  final double? normalizedMismatchSlope;
  /// 0..1
  final double? progressPercent;
  final bool? completed;
}

class MMV2Scores {
  MMV2Scores({
    required this.wm,
    required this.attn,
    required this.spd,
    required this.strat,
    required this.meta,
    required this.cons,
    required this.cognitionMemory,
    required this.cognitionAttention,
    required this.composite,
    required this.deltaProgress,
    this.confidence,
  });

  final double wm;
  final double attn;
  final double spd;
  final double strat;
  final double meta;
  final double cons;

  final int cognitionMemory;
  final int cognitionAttention;
  final int composite;
  final int deltaProgress;
  final double? confidence;
}

class MemoryMatchScoringV2 {
  static MMV2Scores compute(MMV2Inputs i) {
    final pairs = i.pairs;
    final optimalMoves = pairs;
    final randomMoves = (pairs + (pairs * math.log(pairs))).toDouble();

    // Efficiency vs random → optimal
    final effMoves = (randomMoves - i.moves) / (randomMoves - optimalMoves + 1e-6);
    final acc = _clamp01(i.matches / (i.moves == 0 ? 1.0 : i.moves.toDouble()));
    final wm = _clamp01(0.7 * _clamp01(effMoves) + 0.3 * acc);

    // Attention control
    final mmRate = _clamp01(i.mismatches / (pairs * 2.0));
    final repeatMM = _clamp01((i.repeatMismatches ?? 0) / (i.mismatches == 0 ? 1.0 : i.mismatches.toDouble()));
    final lateBias = _clamp01((i.lateMistakes ?? 0) / (i.mismatches == 0 ? 1.0 : i.mismatches.toDouble()));
    final attn = _clamp01(1.0 - 0.5 * mmRate - 0.3 * repeatMM - 0.2 * lateBias);

    // Speed
    final baselineSeconds = math.max(60, 12 * pairs);
    final speedFactor = _clamp01(baselineSeconds / (i.totalSeconds + 1.0));
    final cvFlip = _clamp01(i.coefVarFlipInterval ?? 0.5);
    final spd = _clamp01(0.85 * speedFactor + 0.15 * (1.0 - cvFlip));

    // Strategy / Planning
    final pathEntropy = _clamp01(i.spatialPathEntropy ?? 0.6); // neutral-ish
    final sweepRate = _clamp01((i.systematicSweepFlips ?? 0) / (i.moves == 0 ? 1.0 : i.moves.toDouble()));
    final probeEff = _clamp01(1.0 - (i.uniqueSinglesBeforeFirstMatch ?? (pairs ~/ 2)) / (pairs * 0.5));
    final strat = _clamp01(0.45 * (1.0 - pathEntropy) + 0.35 * sweepRate + 0.20 * probeEff);

    // Metacognition / Learning
    final mmSlope = (i.normalizedMismatchSlope ?? 0.0); // -1..1; negative good
    final withinSession = _clamp01(0.5 * (1.0 - mmRate) + 0.5 * (1.0 - _clamp01(0.5 * (mmSlope + 1.0))));
    // No history in this module ⇒ neutral 0.5 for across-session
    final acrossSession = 0.5;
    final meta = _clamp01(0.6 * withinSession + 0.4 * acrossSession);

    // Consistency / Persistence
    final difficultyFactor = _clamp01((pairs - 8) / (15 - 8));
    final persisted = (i.completed ?? true) ? 1.0 : (0.2 + 0.6 * (i.progressPercent ?? 0.5));
    final cvInterMatch = _clamp01(i.coefVarInterMatch ?? 0.5);
    final volatility = _clamp01(0.5 * cvFlip + 0.5 * cvInterMatch);
    final cons = _clamp01(0.6 * (persisted * (0.5 + 0.5 * difficultyFactor)) + 0.4 * (1.0 - volatility));

    // Trait mappings
    final cognitionMemory01 = _clamp01(0.45 * wm + 0.25 * strat + 0.20 * meta + 0.10 * attn);
    final cognitionAttention01 = _clamp01(0.40 * attn + 0.30 * spd + 0.20 * cons + 0.10 * wm);

    final composite01 = _clamp01(
      0.30 * wm + 0.20 * attn + 0.20 * spd + 0.15 * strat + 0.10 * meta + 0.05 * cons,
    );

    // Confidence
    final boardScale = _clamp01((pairs - 6) / 10.0);
    final sessionDur = _clamp01(i.totalSeconds / 90.0);
    final signalQuality = _clamp01(1.0 - cvFlip);
    final confidence = _clamp01(0.35 * boardScale + 0.35 * sessionDur + 0.30 * signalQuality);

    // Delta progress: keep original rule
    final deltaProgress = math.min(8, (pairs / 2).round());

    return MMV2Scores(
      wm: wm,
      attn: attn,
      spd: spd,
      strat: strat,
      meta: meta,
      cons: cons,
      cognitionMemory: (100 * cognitionMemory01).round(),
      cognitionAttention: (100 * cognitionAttention01).round(),
      composite: (100 * composite01).round(),
      deltaProgress: deltaProgress,
      confidence: confidence,
    );
  }
}
