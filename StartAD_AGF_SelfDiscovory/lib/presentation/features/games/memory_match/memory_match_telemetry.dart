/// Telemetry model for Memory Match game
/// Captures all metrics needed for scoring and database persistence
class MemoryMatchTelemetry {
  MemoryMatchTelemetry({
    required this.startedAt,
    this.completedAt,
    required this.gridPairs,
    this.moves = 0,
    this.matches = 0,
    this.mismatches = 0,
    this.totalSeconds = 0,
    this.avgFlipIntervalMs = 0,
    this.peakFocusStreak = 0,
    this.earlyMistakes = 0,
    this.lateMistakes = 0,
    required this.seed,
    this.version = 'v1.0',
  });

  final DateTime startedAt;
  final DateTime? completedAt;
  final int gridPairs; // Number of pairs in the grid
  int moves; // Every two flips counts as 1 move
  int matches; // Number of successful matches
  int mismatches; // Number of failed matches
  int totalSeconds; // Total time taken
  int avgFlipIntervalMs; // Mean time between flips
  int peakFocusStreak; // Max consecutive correct matches
  int earlyMistakes; // Mismatches during first 25% of moves
  int lateMistakes; // Mismatches during last 25% of moves
  final int seed; // Deck seed for reproducibility
  final String version;

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'grid_pairs': gridPairs,
      'moves': moves,
      'matches': matches,
      'mismatches': mismatches,
      'total_seconds': totalSeconds,
      'avg_flip_interval_ms': avgFlipIntervalMs,
      'peak_focus_streak': peakFocusStreak,
      'early_mistakes': earlyMistakes,
      'late_mistakes': lateMistakes,
      'seed': seed,
      'version': version,
    };
  }

  /// Create a copy with updated fields
  MemoryMatchTelemetry copyWith({
    DateTime? startedAt,
    DateTime? completedAt,
    int? gridPairs,
    int? moves,
    int? matches,
    int? mismatches,
    int? totalSeconds,
    int? avgFlipIntervalMs,
    int? peakFocusStreak,
    int? earlyMistakes,
    int? lateMistakes,
    int? seed,
    String? version,
  }) {
    return MemoryMatchTelemetry(
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      gridPairs: gridPairs ?? this.gridPairs,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      mismatches: mismatches ?? this.mismatches,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      avgFlipIntervalMs: avgFlipIntervalMs ?? this.avgFlipIntervalMs,
      peakFocusStreak: peakFocusStreak ?? this.peakFocusStreak,
      earlyMistakes: earlyMistakes ?? this.earlyMistakes,
      lateMistakes: lateMistakes ?? this.lateMistakes,
      seed: seed ?? this.seed,
      version: version ?? this.version,
    );
  }
}
