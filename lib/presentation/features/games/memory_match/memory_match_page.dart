import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../../../../application/activity/activity_providers.dart';
import '../../../../application/scoring/scoring_providers.dart';
import '../../../../application/traits/traits_providers.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../widgets/gradient_background.dart';
import 'memory_match_controller.dart';
import 'memory_match_telemetry.dart';
import '../common/game_result_sheet.dart';

class MemoryMatchPage extends ConsumerStatefulWidget {
  const MemoryMatchPage({super.key});

  @override
  ConsumerState<MemoryMatchPage> createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends ConsumerState<MemoryMatchPage> {
  bool _isStarted = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryMatchControllerProvider);

    if (!_isStarted) {
      return _buildStartScreen(context);
    }

    if (state.isCompleted && !_isSubmitting) {
      // Show result sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultSheet(context);
      });
    }

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.memoryMatchTitle),
          actions: [
            if (state.isStarted && !state.isCompleted)
              IconButton(
                icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: () {
                  final controller = ref.read(
                    memoryMatchControllerProvider.notifier,
                  );
                  if (state.isPaused) {
                    controller.resume();
                  } else {
                    controller.pause();
                  }
                },
              ),
          ],
        ),
        body: state.isPaused
            ? _buildPauseOverlay(context)
            : _buildGameScreen(context, state),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.memoryMatchTitle),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.memoryMatchTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.memoryMatchDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                Text(
                  l10n.memoryMatchSelectDifficulty,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildDifficultyButton(
                  context,
                  GameDifficulty.easy,
                  l10n.memoryMatchDifficultyEasyDesc,
                ),
                const SizedBox(height: 12),
                _buildDifficultyButton(
                  context,
                  GameDifficulty.normal,
                  l10n.memoryMatchDifficultyNormalDesc,
                ),
                const SizedBox(height: 12),
                _buildDifficultyButton(
                  context,
                  GameDifficulty.hard,
                  l10n.memoryMatchDifficultyHardDesc,
                ),
                const SizedBox(height: 40),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.memoryMatchHowToPlay,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildHowToPlayItem(l10n.memoryMatchHowToPlayStep1),
                        _buildHowToPlayItem(l10n.memoryMatchHowToPlayStep2),
                        _buildHowToPlayItem(l10n.memoryMatchHowToPlayStep3),
                        _buildHowToPlayItem(l10n.memoryMatchHowToPlayStep4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    GameDifficulty difficulty,
    String description,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String difficultyName;

    switch (difficulty) {
      case GameDifficulty.easy:
        difficultyName = l10n.memoryMatchDifficultyEasy;
        break;
      case GameDifficulty.normal:
        difficultyName = l10n.memoryMatchDifficultyNormal;
        break;
      case GameDifficulty.hard:
        difficultyName = l10n.memoryMatchDifficultyHard;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ref.read(memoryMatchControllerProvider.notifier).start(difficulty);
          setState(() {
            _isStarted = true;
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Text(
              difficultyName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToPlayItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context, MemoryMatchState state) {
    return Column(
      children: [
        _buildHUD(context, state),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildGrid(context, state),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHUD(BuildContext context, MemoryMatchState state) {
    final l10n = AppLocalizations.of(context)!;
    final minutes = state.elapsedSeconds ~/ 60;
    final seconds = state.elapsedSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHUDItem(context, Icons.timer, l10n.memoryMatchTime, timeString),
              _buildHUDItem(
                context,
                Icons.touch_app,
                l10n.memoryMatchMoves,
                '${state.moves}',
              ),
              _buildHUDItem(
                context,
                Icons.check_circle,
                l10n.memoryMatchMatches,
                '${state.matches}/${state.difficulty.pairs}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: state.progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildHUDItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, MemoryMatchState state) {
    final columns = state.difficulty.gridColumns;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.cards.length,
          itemBuilder: (context, index) {
            return _buildCard(context, state.cards[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    MemoryCard card,
    int index,
  ) {
    final isRevealed = card.isRevealed || card.isMatched;

    return GestureDetector(
      onTap: () {
        if (!isRevealed && !card.isMatched) {
          ref.read(memoryMatchControllerProvider.notifier).flip(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isRevealed
              ? (card.isMatched
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.secondaryContainer)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRevealed
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth.clamp(60.0, 100.0);
            return Center(
              child: isRevealed
                  ? Padding(
                      padding: EdgeInsets.all(size * 0.15),
                      child: Image.asset(
                        card.imagePath,
                        fit: BoxFit.contain,
                        color: Theme.of(context).colorScheme.primary,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image not found
                          return Icon(
                            Icons.image_not_supported,
                            size: size * 0.5,
                            color: Theme.of(context).colorScheme.error,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.question_mark,
                      size: size * 0.4,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle, size: 64),
                const SizedBox(height: 16),
                Text(
                  l10n.memoryMatchPaused,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(memoryMatchControllerProvider.notifier).resume();
                  },
                  child: Text(l10n.memoryMatchResume),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResultSheet(BuildContext context) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final controller = ref.read(memoryMatchControllerProvider.notifier);
    final scores = controller.calculateScores();
    final telemetry = controller.getTelemetry();

    try {
      // Submit to database
      await _submitGameResults(scores, telemetry);

      if (!mounted) return;

      // Invalidate providers to refresh dashboard data
      ref.invalidate(discoveryProgressProvider);
      ref.invalidate(profileCompletenessProvider);
      ref.invalidate(radarDataByFamilyProvider);

      // Show result sheet
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => GameResultSheet(
          title: 'Great Job!',
          score: scores.composite,
          traitScores: {
            'Memory': scores.cognitionMemory,
            'Attention': scores.cognitionAttention,
          },
          stats: {
            'Time': _formatTime(telemetry?.totalSeconds ?? 0),
            'Moves': '${telemetry?.moves ?? 0}',
            'Accuracy':
                '${((telemetry?.matches ?? 0) / max(1, telemetry?.moves ?? 1) * 100).toStringAsFixed(1)}%',
          },
          onTryAgain: () {
            context.pop(); // Close sheet
            setState(() {
              _isStarted = false;
              _isSubmitting = false;
            });
          },
          onBackToDiscovery: () {
            context.pop(); // Close sheet
            context.pop(); // Back to discovery
          },
        ),
      );
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to submit game results',
        error: error,
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      // Show error but still allow user to continue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.memoryMatchSaveFailed),
          backgroundColor: Colors.orange,
        ),
      );

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _submitGameResults(
    GameScores scores,
    MemoryMatchTelemetry? telemetry,
  ) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null || telemetry == null) {
      throw Exception('User not authenticated or telemetry missing');
    }

    // 1. Get activity ID
    final activityService = ref.read(activityServiceProvider);
    final activity = await activityService.getActivity('memory_match');
    final activityId = activity?.id ?? 'memory_match';

    // 2. Insert activity run
    final runId = await activityService.startActivityRun(
      activityId: activityId,
    );
    await activityService.completeActivityRun(
      runId: runId,
      score: scores.composite,
      traitScores: scores.toTraitScores(),
      deltaProgress: scores.deltaProgress,
    );

    // 3. Insert assessment (optional mirror)
    final assessment = await supabase
        .from('assessments')
        .insert({
          'user_id': userId,
          'trait_scores': scores.toTraitScores(),
          'confidence': 0.65,
          'delta_progress': scores.deltaProgress,
        })
        .select('id')
        .single();

    final assessmentId = assessment['id'] as int;

    // 4. Insert assessment item
    await supabase.from('assessment_items').insert({
      'assessment_id': assessmentId,
      'item_id': 'memory_match_v1',
      'response': telemetry.toJson(),
      'score_raw': scores.composite,
      'score_norm': scores.composite,
      'duration_ms': telemetry.totalSeconds * 1000,
      'metadata': {
        'difficulty': ref.read(memoryMatchControllerProvider).difficulty.name,
        'seed': telemetry.seed,
      },
    });

    // 5. Call Edge Function to update profile
    try {
      await supabase.functions.invoke(
        'update_profile_and_match',
        body: {
          'user_id': userId,
          'batch_features': [
            {
              'key': 'cognition_memory',
              'mean': scores.cognitionMemory.toDouble(),
              'n': telemetry.gridPairs * 2,
              'quality': 0.7,
            },
            {
              'key': 'cognition_attention',
              'mean': scores.cognitionAttention.toDouble(),
              'n': telemetry.gridPairs * 2,
              'quality': 0.6,
            },
          ],
          'instrument': 'Memory Match',
          'activity_kind': 'game',
          'delta_progress_hint': scores.deltaProgress,
        },
      );
    } on Exception catch (error) {
      developer.log(
        'Edge function call failed, but activity run was saved',
        error: error,
      );
      // Non-blocking - activity run was already saved
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  int max(int a, int b) => a > b ? a : b;
}
