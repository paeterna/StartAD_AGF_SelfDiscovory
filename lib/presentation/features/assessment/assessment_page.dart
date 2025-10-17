import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/activity/activity_providers.dart';
import '../../../application/assessment/assessment_providers.dart';
import '../../../application/quiz/quiz_providers.dart';
import '../../../application/quiz/quiz_scoring_helper.dart';
import '../../../application/scoring/scoring_providers.dart';
import '../../../application/traits/traits_providers.dart';
import '../../../data/models/quiz_instrument.dart';
import '../../widgets/gradient_background.dart';

/// Page for taking psychometric assessments with Likert scale questions
class AssessmentPage extends ConsumerStatefulWidget {
  const AssessmentPage({
    super.key,
    required this.instrument,
    required this.language,
  });

  final String instrument;
  final String language;

  @override
  ConsumerState<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends ConsumerState<AssessmentPage> {
  int _currentPage = 0;
  final Map<String, int> _responses = {};
  final int _itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metadataAsync = ref.watch(
      quizMetadataProvider(
        QuizItemsParams(
          instrument: widget.instrument,
          language: widget.language,
        ),
      ),
    );

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: metadataAsync.maybeWhen(
            data: (metadata) => Text(metadata.title),
            orElse: () => const Text('Assessment'),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: metadataAsync.when(
          data: (metadata) => _buildAssessmentContent(context, metadata),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load assessment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentContent(
    BuildContext context,
    QuizInstrument metadata,
  ) {
    final totalPages = (metadata.items.length / _itemsPerPage).ceil();
    final startIdx = _currentPage * _itemsPerPage;
    final endIdx = (startIdx + _itemsPerPage).clamp(0, metadata.items.length);
    final currentItems = metadata.items.sublist(startIdx, endIdx);

    return Column(
      children: [
        // Progress bar
        _buildProgressBar(context, metadata.items.length),

        // Instructions (show only on first page)
        if (_currentPage == 0) ...[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      metadata.instructions,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Questions
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: currentItems.length,
            itemBuilder: (context, index) {
              final item = currentItems[index];
              return _buildQuestionCard(
                context,
                item,
                startIdx + index + 1,
                metadata.scale!,
              );
            },
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(
          context,
          metadata,
          startIdx,
          endIdx,
          totalPages,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, int totalItems) {
    final progress = _responses.length / totalItems;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_responses.length} / $totalItems',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    QuizItem item,
    int questionNumber,
    QuizScale scale,
  ) {
    final response = _responses[item.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number and text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$questionNumber',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Likert scale options
            _buildLikertScale(context, item, scale, response),
          ],
        ),
      ),
    );
  }

  Widget _buildLikertScale(
    BuildContext context,
    QuizItem item,
    QuizScale scale,
    int? currentResponse,
  ) {
    final scaleSize = scale.labels.length;

    return Column(
      children: [
        // Option buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(scaleSize, (index) {
            final value = index + 1;
            final isSelected = currentResponse == value;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _responses[item.id] = value;
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        value.toString(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                scale.labels['1'] ?? '',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: Text(
                scale.labels[scaleSize.toString()] ?? '',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    QuizInstrument metadata,
    int startIdx,
    int endIdx,
    int totalPages,
  ) {
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == totalPages - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirstPage)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentPage--;
                  });
                  // Scroll to top after navigation
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          if (!isFirstPage) const SizedBox(width: 12),

          // Next/Submit button
          Expanded(
            flex: isFirstPage ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _canProceed(metadata, startIdx, endIdx)
                  ? () {
                      if (isLastPage) {
                        _submitAssessment();
                      } else {
                        setState(() {
                          _currentPage++;
                        });
                        // Scroll to top after navigation
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    }
                  : null,
              icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
              label: Text(isLastPage ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  /// Check if user can proceed to next page
  /// For last page, checks if all items are answered
  /// For other pages, checks if all current page items are answered
  bool _canProceed(QuizInstrument metadata, int startIdx, int endIdx) {
    final totalPages = (metadata.items.length / _itemsPerPage).ceil();
    final isLastPage = _currentPage == totalPages - 1;

    if (isLastPage) {
      // On last page, check if ALL items are answered
      return metadata.items.every((item) => _responses.containsKey(item.id));
    } else {
      // On other pages, check if all CURRENT PAGE items are answered
      final currentPageItems = metadata.items.sublist(startIdx, endIdx);
      return currentPageItems.every((item) => _responses.containsKey(item.id));
    }
  }

  Future<void> _submitAssessment() async {
    // Get metadata from the already-loaded provider
    final metadataAsync = ref.read(
      quizMetadataProvider(
        QuizItemsParams(
          instrument: widget.instrument,
          language: widget.language,
        ),
      ),
    );

    // Extract metadata from AsyncValue
    final QuizInstrument metadata;
    if (metadataAsync.hasValue) {
      metadata = metadataAsync.value!;
    } else {
      // This shouldn't happen since we've already loaded it in build()
      throw Exception('Metadata not loaded');
    }

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
      // 1. Compute feature scores from responses
      final featureScores = QuizScoringHelper.computeFeatureScores(
        items: metadata.items,
        responses: _responses,
        instrument: widget.instrument,
      );

      // 2. Compute delta progress
      final deltaProgress = QuizScoringHelper.computeDeltaProgress(
        totalItems: metadata.items.length,
        answeredItems: _responses.length,
      );

      // 3. Compute overall confidence
      final confidence = QuizScoringHelper.computeOverallConfidence(
        totalItems: metadata.items.length,
        answeredItems: _responses.length,
      );

      // 4. Create activity run first (quiz type assessment)
      final activityService = ref.read(activityServiceProvider);

      // For now, we'll use a placeholder activity ID
      // In a real implementation, you'd fetch the activity ID for this instrument
      final activityId = 'quiz_${widget.instrument}';

      // Start activity run
      final runId = await activityService.startActivityRun(
        activityId: activityId,
      );

      // 5. Build trait scores map from feature scores (canonical keys only)
      final traitScores = <String, dynamic>{};
      for (final fs in featureScores) {
        traitScores[fs.key] = fs.mean;
      }

      // 6. Use orchestrator to complete the assessment
      final orchestrator = ref.read(completeAssessmentOrchestratorProvider);

      await orchestrator.completeAssessment(
        activityRunId: runId,
        activityId: activityId,
        traitScores: traitScores,
        featureScores: featureScores,
        deltaProgress: deltaProgress,
        confidence: confidence,
      );

      // Close loading dialog
      if (!mounted) return;
      context.pop();

      // Invalidate providers to refresh dashboard data
      ref.invalidate(discoveryProgressProvider);
      ref.invalidate(profileCompletenessProvider);
      ref.invalidate(radarDataByFamilyProvider);

      // Show success dialog
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('Assessment Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thank you for completing the assessment.'),
              const SizedBox(height: 16),
              Text(
                'Your progress has been updated by $deltaProgress%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tip: Check your dashboard to see your updated profile!',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      // Close loading dialog
      if (!mounted) return;
      context.pop();

      // Show error dialog
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 12),
              Text('Error'),
            ],
          ),
          content: Text('Failed to submit assessment: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
