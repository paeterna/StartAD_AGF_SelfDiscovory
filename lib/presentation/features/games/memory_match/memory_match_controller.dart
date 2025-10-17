import 'dart:async';
import 'dart:math';
import './memory_match_scoring.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'memory_match_telemetry.dart';

/// Difficulty levels for the game
enum GameDifficulty {
  easy(pairs: 8, gridColumns: 4, name: 'Easy'), // 4x4 grid
  normal(pairs: 10, gridColumns: 5, name: 'Normal'), // 5x4 grid
  hard(pairs: 15, gridColumns: 6, name: 'Hard'); // 6x5 grid

  const GameDifficulty({
    required this.pairs,
    required this.gridColumns,
    required this.name,
  });

  final int pairs;
  final int gridColumns;
  final String name;

  int get totalCards => pairs * 2;
}

/// Card model
class MemoryCard {
  const MemoryCard({
    required this.id,
    required this.pairId,
    required this.imagePath,
    this.isRevealed = false,
    this.isMatched = false,
  });

  final String id;
  final int pairId;
  final String imagePath;
  final bool isRevealed;
  final bool isMatched;

  MemoryCard copyWith({
    String? id,
    int? pairId,
    String? imagePath,
    bool? isRevealed,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      imagePath: imagePath ?? this.imagePath,
      isRevealed: isRevealed ?? this.isRevealed,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

/// Game state
class MemoryMatchState {
  const MemoryMatchState({
    this.cards = const [],
    this.revealedIndices = const [],
    this.difficulty = GameDifficulty.normal,
    this.isStarted = false,
    this.isPaused = false,
    this.isCompleted = false,
    this.isInitialReveal = false,
    this.elapsedSeconds = 0,
    this.currentFocusStreak = 0,
    this.flipTimestamps = const [],
  });

  final List<MemoryCard> cards;
  final List<int> revealedIndices;
  final GameDifficulty difficulty;
  final bool isStarted;
  final bool isPaused;
  final bool isCompleted;
  final bool isInitialReveal;
  final int elapsedSeconds;
  final int currentFocusStreak;
  final List<int> flipTimestamps; // Timestamps in milliseconds

  int get moves {
    int matched = 0;
    int mismatched = 0;
    for (final card in cards) {
      if (card.isMatched) matched++;
    }
    matched = matched ~/ 2; // Each match counts once (2 cards)

    // Calculate mismatches from revealed pairs that didn't match
    final totalFlips = flipTimestamps.length;
    final pairs = totalFlips ~/ 2;
    mismatched = pairs - matched;

    return matched + mismatched;
  }

  int get matches => cards.where((card) => card.isMatched).length ~/ 2;

  int get mismatches => moves - matches;

  int get matchesRemaining => difficulty.pairs - matches;

  double get progress => matches / difficulty.pairs;

  MemoryMatchState copyWith({
    List<MemoryCard>? cards,
    List<int>? revealedIndices,
    GameDifficulty? difficulty,
    bool? isStarted,
    bool? isPaused,
    bool? isCompleted,
    bool? isInitialReveal,
    int? elapsedSeconds,
    int? currentFocusStreak,
    List<int>? flipTimestamps,
  }) {
    return MemoryMatchState(
      cards: cards ?? this.cards,
      revealedIndices: revealedIndices ?? this.revealedIndices,
      difficulty: difficulty ?? this.difficulty,
      isStarted: isStarted ?? this.isStarted,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      isInitialReveal: isInitialReveal ?? this.isInitialReveal,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentFocusStreak: currentFocusStreak ?? this.currentFocusStreak,
      flipTimestamps: flipTimestamps ?? this.flipTimestamps,
    );
  }
}

/// Memory Match game controller
class MemoryMatchController extends StateNotifier<MemoryMatchState> {
  MemoryMatchController() : super(const MemoryMatchState());

  Timer? _timer;
  MemoryMatchTelemetry? _telemetry;
  int _peakFocusStreak = 0;
  int _earlyMistakes = 0;
  int _lateMistakes = 0;

  // Image pool for cards - Arabian/Emirati themed
  static const List<String> _imagePool = [
    'images/memory_cards/coffee-pot.png',
    'images/memory_cards/palm-tree.png',
    'images/memory_cards/eagle.png',
    'images/memory_cards/burj-khalifa.png',
    'images/memory_cards/burj-al-arab.png',
    'images/memory_cards/united-arab-emirates.png',
    'images/memory_cards/mosque.png',
    'images/memory_cards/sunny.png',
    'images/memory_cards/moon.png',
    'images/memory_cards/pearls.png',
    'images/memory_cards/ship-wheel.png',
    'images/memory_cards/desert.png',
    'images/memory_cards/star.png',
    'images/memory_cards/oryx.png',
    'images/memory_cards/camel.png',
    'images/memory_cards/al-jahili-fort.png',
    'images/memory_cards/cayan-tower.png',
    'images/memory_cards/palm-islands.png',
    'images/memory_cards/united-arab-emirates (1).png',
    'images/memory_cards/united-arab-emirates (2).png',
  ];

  /// Start a new game with the specified difficulty
  void start(GameDifficulty difficulty) {
    final seed = Random().nextInt(1000000);
    final random = Random(seed);

    // Generate card pairs
    final pairs = difficulty.pairs;
    final selectedImages = _imagePool.take(pairs).toList();

    final cards = <MemoryCard>[];
    for (int i = 0; i < pairs; i++) {
      cards.add(
        MemoryCard(
          id: 'card_${i}_a',
          pairId: i,
          imagePath: selectedImages[i],
        ),
      );
      cards.add(
        MemoryCard(
          id: 'card_${i}_b',
          pairId: i,
          imagePath: selectedImages[i],
        ),
      );
    }

    // Shuffle cards
    cards.shuffle(random);

    // Initialize telemetry
    _telemetry = MemoryMatchTelemetry(
      startedAt: DateTime.now(),
      gridPairs: pairs,
      seed: seed,
    );
    _peakFocusStreak = 0;
    _earlyMistakes = 0;
    _lateMistakes = 0;

    // Reveal all cards initially for 1 second
    final revealedCards = cards
        .map((card) => card.copyWith(isRevealed: true))
        .toList();

    state = MemoryMatchState(
      cards: revealedCards,
      difficulty: difficulty,
      isStarted: true,
      isPaused: false, // Don't pause - let the game screen show
      isInitialReveal: true, // Flag to indicate initial reveal phase
      isCompleted: false,
      elapsedSeconds: 0,
      currentFocusStreak: 0,
      flipTimestamps: [],
    );

    // After 1 second, flip all cards back and start gameplay
    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;

      final hiddenCards = revealedCards
          .map((card) => card.copyWith(isRevealed: false))
          .toList();

      state = state.copyWith(
        cards: hiddenCards,
        isInitialReveal: false, // End initial reveal phase
      );
    });

    _startTimer();
  }

  /// Flip a card at the given index
  void flip(int index) {
    if (state.isPaused || state.isCompleted || state.isInitialReveal) return;
    if (state.revealedIndices.length >= 2) return;
    if (state.cards[index].isRevealed || state.cards[index].isMatched) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final newTimestamps = [...state.flipTimestamps, now];

    final newCards = List<MemoryCard>.from(state.cards);
    newCards[index] = newCards[index].copyWith(isRevealed: true);

    final newRevealedIndices = [...state.revealedIndices, index];

    state = state.copyWith(
      cards: newCards,
      revealedIndices: newRevealedIndices,
      flipTimestamps: newTimestamps,
    );

    // Check for match if two cards are revealed
    if (newRevealedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    final index1 = state.revealedIndices[0];
    final index2 = state.revealedIndices[1];
    final card1 = state.cards[index1];
    final card2 = state.cards[index2];

    if (card1.pairId == card2.pairId) {
      // Match found
      final newCards = List<MemoryCard>.from(state.cards);
      newCards[index1] = newCards[index1].copyWith(
        isMatched: true,
        isRevealed: true,
      );
      newCards[index2] = newCards[index2].copyWith(
        isMatched: true,
        isRevealed: true,
      );

      final newStreak = state.currentFocusStreak + 1;
      if (newStreak > _peakFocusStreak) {
        _peakFocusStreak = newStreak;
      }

      state = state.copyWith(
        cards: newCards,
        revealedIndices: [],
        currentFocusStreak: newStreak,
      );

      // Check if game is completed
      if (state.matches == state.difficulty.pairs) {
        _complete();
      }
    } else {
      // No match - flip cards back after delay
      _trackMismatch();

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;

        final newCards = List<MemoryCard>.from(state.cards);
        newCards[index1] = newCards[index1].copyWith(isRevealed: false);
        newCards[index2] = newCards[index2].copyWith(isRevealed: false);

        state = state.copyWith(
          cards: newCards,
          revealedIndices: [],
          currentFocusStreak: 0,
        );
      });
    }
  }

  void _trackMismatch() {
    final totalMoves = state.moves + 1; // +1 for current move
    final estimatedTotalMoves = state.difficulty.pairs * 2; // Rough estimate
    final firstQuarter = estimatedTotalMoves * 0.25;
    final lastQuarter = estimatedTotalMoves * 0.75;

    if (totalMoves <= firstQuarter) {
      _earlyMistakes++;
    } else if (totalMoves >= lastQuarter) {
      _lateMistakes++;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPaused && state.isStarted && !state.isCompleted) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void pause() {
    if (!state.isStarted || state.isCompleted) return;
    state = state.copyWith(isPaused: true);
  }

  void resume() {
    if (!state.isStarted || state.isCompleted) return;
    state = state.copyWith(isPaused: false);
  }

  void _complete() {
    _timer?.cancel();

    // Calculate avg flip interval
    int avgInterval = 0;
    if (state.flipTimestamps.length > 1) {
      int totalInterval = 0;
      for (int i = 1; i < state.flipTimestamps.length; i++) {
        totalInterval += state.flipTimestamps[i] - state.flipTimestamps[i - 1];
      }
      avgInterval = totalInterval ~/ (state.flipTimestamps.length - 1);
    }

    // Update telemetry
    _telemetry = _telemetry?.copyWith(
      completedAt: DateTime.now(),
      moves: state.moves,
      matches: state.matches,
      mismatches: state.mismatches,
      totalSeconds: state.elapsedSeconds,
      avgFlipIntervalMs: avgInterval,
      peakFocusStreak: _peakFocusStreak,
      earlyMistakes: _earlyMistakes,
      lateMistakes: _lateMistakes,
    );

    state = state.copyWith(isCompleted: true);
  }

  /// Get telemetry data
  MemoryMatchTelemetry? getTelemetry() => _telemetry;

  /// Calculate scores based on the specification
  GameScores calculateScores() {
    if (_telemetry == null) {
      return const GameScores(
        composite: 0,
        cognitionMemory: 0,
        cognitionAttention: 0,
        deltaProgress: 0,
      );
    }

    final pairs = _telemetry!.gridPairs;
    final moves = max(1, _telemetry!.moves);
    final matches = _telemetry!.matches;
    final mismatches = max(0, _telemetry!.mismatches);
    final totalSeconds = _telemetry!.totalSeconds;
    final avgFlipIntervalMs = _telemetry!.avgFlipIntervalMs;
    final peakFocusStreak = _telemetry!.peakFocusStreak;
    final earlyMistakes = _telemetry!.earlyMistakes;
    final lateMistakes = _telemetry!.lateMistakes;

    // V2 Scoring
    final inputs = MMV2Inputs(
      pairs: pairs,
      moves: moves,
      matches: matches,
      mismatches: mismatches,
      totalSeconds: totalSeconds,
      avgFlipIntervalMs: avgFlipIntervalMs,
      peakFocusStreak: peakFocusStreak,
      earlyMistakes: earlyMistakes,
      lateMistakes: lateMistakes,
    );
    final v2 = MemoryMatchScoringV2.compute(inputs);

    return GameScores(
      composite: v2.composite,
      cognitionMemory: v2.cognitionMemory,
      cognitionAttention: v2.cognitionAttention,
      deltaProgress: v2.deltaProgress,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Game scores model
class GameScores {
  const GameScores({
    required this.composite,
    required this.cognitionMemory,
    required this.cognitionAttention,
    required this.deltaProgress,
  });

  final int composite; // 0-100
  final int cognitionMemory; // 0-100
  final int cognitionAttention; // 0-100
  final int deltaProgress; // 0-20

  Map<String, dynamic> toTraitScores() {
    return {
      'cognition_memory': cognitionMemory,
      'cognition_attention': cognitionAttention,
    };
  }
}

/// Provider for the Memory Match controller
final AutoDisposeStateNotifierProvider<MemoryMatchController, MemoryMatchState> memoryMatchControllerProvider =
    StateNotifierProvider.autoDispose<MemoryMatchController, MemoryMatchState>(
      (ref) => MemoryMatchController(),
    );
