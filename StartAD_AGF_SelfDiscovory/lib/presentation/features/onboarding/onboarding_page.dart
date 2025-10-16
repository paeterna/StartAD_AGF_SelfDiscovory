import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/activity/activity_providers.dart';
import '../../../application/assessment/assessment_providers.dart';
import '../../../application/auth/auth_controller.dart';
import '../../../application/quiz/quiz_providers.dart';
import '../../../application/quiz/quiz_scoring_helper.dart';
import '../../../application/scoring/scoring_providers.dart';
import '../../../application/traits/traits_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/feature_score.dart';
import '../../../data/models/quiz_instrument.dart';
import 'widgets/welcome_screen.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool _showWelcome = true;
  int _currentStep = 0;
  final Map<String, String> _selectedOptions = {}; // itemId -> optionId
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(QuizInstrument metadata) async {
    // Show loading dialog
    if (!mounted) return;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing your responses...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      // Build feature scores from selected options
      final featureScores = <String, double>{};

      for (final item in metadata.items) {
        final selectedOptionId = _selectedOptions[item.id];
        if (selectedOptionId == null) continue;

        // Find the selected option
        ForcedChoiceOption? selectedOption;
        if (item is ForcedChoiceItem) {
          selectedOption = item.options.firstWhere(
            (opt) => opt.id == selectedOptionId,
          );
        }

        if (selectedOption != null) {
          // Add weight to the feature key
          final currentScore = featureScores[selectedOption.featureKey] ?? 0.0;
          featureScores[selectedOption.featureKey] =
              currentScore + selectedOption.weight;
        }
      }

      // Normalize scores to 0-100 scale
      // Since each question contributes 1.0, max score per feature is number of times it appears
      // We'll normalize based on the number of responses
      final normalizedScores = <String, double>{};
      final responseCount = _selectedOptions.length;

      for (final entry in featureScores.entries) {
        // Normalize: (score / total_questions) * 100
        // This gives us a percentage-based score
        normalizedScores[entry.key] = (entry.value / responseCount) * 100;
      }

      // Compute confidence for quality score
      final confidence = QuizScoringHelper.computeOverallConfidence(
        totalItems: metadata.items.length,
        answeredItems: _selectedOptions.length,
      );

      // Convert to FeatureScore objects
      final featureScoresList = normalizedScores.entries.map((e) {
        return FeatureScore(
          key: e.key,
          mean: e.value,
          n: 1,
          quality: confidence, // Use overall confidence
        );
      }).toList();

      // Submit feature scores directly (onboarding doesn't use activity system)
      final scoringService = ref.read(scoringServiceProvider);
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId != null) {
        await scoringService.updateProfileAndMatch(
          userId: userId,
          batchFeatures: featureScoresList,
        );
      }

      // Mark onboarding as complete
      await ref
          .read(authControllerProvider.notifier)
          .completeOnboarding(answers: {});

      // Close loading dialog
      if (!mounted) return;
      context.pop();

      // Invalidate providers to refresh dashboard data
      ref.invalidate(discoveryProgressProvider);
      ref.invalidate(radarDataByFamilyProvider);

      // Navigate to dashboard
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } on Exception catch (e) {
      debugPrint('🔴 [ONBOARDING] Error: $e');

      if (mounted) {
        context.pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    // Show welcome screen first
    if (_showWelcome) {
      return WelcomeScreen(
        onGetStarted: () {
          setState(() {
            _showWelcome = false;
          });
        },
      );
    }

    // Load quiz metadata from JSON
    final metadataAsync = ref.watch(
      quizMetadataProvider(
        QuizItemsParams(
          instrument: 'selfmap_onboarding_forced_choice',
          language: locale,
        ),
      ),
    );

    return metadataAsync.when(
      data: (metadata) => _buildQuizScreen(context, metadata),
      loading: () => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Error loading onboarding',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen(BuildContext context, QuizInstrument metadata) {
    final totalSteps = metadata.items.length;
    final currentItem = metadata.items[_currentStep];

    // Get current item as ForcedChoiceItem
    if (currentItem is! ForcedChoiceItem) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid item type'),
        ),
      );
    }

    final forcedChoiceItem = currentItem;
    final selectedOptionId = _selectedOptions[currentItem.id];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentStep + 1) / totalSteps,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),

                // Step indicator
                Text(
                  'Question ${_currentStep + 1} of $totalSteps',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Question prompt
                Text(
                  forcedChoiceItem.prompt,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Options
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: forcedChoiceItem.options.length,
                    itemBuilder: (context, index) {
                      final option = forcedChoiceItem.options[index];
                      final isSelected = selectedOptionId == option.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedOptions[currentItem.id] = option.id;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            side: BorderSide(
                              width: isSelected ? 2 : 1,
                              color: isSelected ? Colors.white : Colors.white38,
                            ),
                            backgroundColor: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.05),
                          ),
                          child: Text(
                            option.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                            // Scroll to top
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedOptions.containsKey(currentItem.id)
                            ? () {
                                if (_currentStep < totalSteps - 1) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                  // Scroll to top
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                } else {
                                  _completeOnboarding(metadata);
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.deepPurple,
                        ),
                        child: Text(
                          _currentStep < totalSteps - 1 ? 'Next' : 'Finish',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
