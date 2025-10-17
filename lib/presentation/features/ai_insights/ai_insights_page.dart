import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/ai_insight/ai_insight_providers.dart';
import '../../../domain/entities/ai_insight.dart';
import '../../widgets/enhanced_glassy_card.dart';
import '../../widgets/gradient_background.dart';

class AIInsightsPage extends ConsumerWidget {
  const AIInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestInsightAsync = ref.watch(latestAIInsightProvider);
    final eligibilityAsync = ref.watch(aiInsightEligibilityProvider);
    final generationState = ref.watch(aiInsightGenerationProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                title: const Text(
                  'AI Career Insights',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                floating: true,
                backgroundColor: Colors.transparent,
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Eligibility Check
                    eligibilityAsync.when(
                      data: (eligibility) => _EligibilityCard(
                        eligibility: eligibility,
                        onGenerate: () {
                          ref
                              .read(aiInsightGenerationProvider.notifier)
                              .generateInsight();
                        },
                        isGenerating: generationState.isLoading,
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => _ErrorCard(error: error.toString()),
                    ),

                    const SizedBox(height: 16),

                    // Generation State
                    generationState.when(
                      data: (insight) {
                        if (insight != null) {
                          // Refresh the latest insight after generation
                          Future.microtask(() {
                            ref.invalidate(latestAIInsightProvider);
                            ref
                                .read(aiInsightGenerationProvider.notifier)
                                .reset();
                          });
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const _GeneratingCard(),
                      error: (error, _) => _ErrorCard(error: error.toString()),
                    ),

                    // Latest Insight
                    latestInsightAsync.when(
                      data: (insight) {
                        if (insight == null) {
                          return const _NoInsightCard();
                        }
                        return _InsightDisplay(insight: insight);
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => _ErrorCard(error: error.toString()),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EligibilityCard extends StatelessWidget {
  const _EligibilityCard({
    required this.eligibility,
    required this.onGenerate,
    required this.isGenerating,
  });

  final dynamic eligibility;
  final VoidCallback onGenerate;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final canGenerate = eligibility.canGenerate as bool;
    final progress = eligibility.progressPercentage as int;

    return GlassyCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  canGenerate ? Icons.check_circle : Icons.info_outline,
                  color: canGenerate ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canGenerate ? 'Ready!' : 'Keep Going!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eligibility.userMessage as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                canGenerate ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$progress% complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (canGenerate) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : onGenerate,
                  icon: isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isGenerating
                        ? 'Generating...'
                        : 'Generate AI Career Insight',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GeneratingCard extends StatelessWidget {
  const _GeneratingCard();

  @override
  Widget build(BuildContext context) {
    return GlassyCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Analyzing your profile...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a minute',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoInsightCard extends StatelessWidget {
  const _NoInsightCard();

  @override
  Widget build(BuildContext context) {
    return GlassyCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No insights yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete more activities to unlock AI-powered career insights',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return GlassyCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightDisplay extends StatelessWidget {
  const _InsightDisplay({required this.insight});

  final AIInsight insight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personality Summary
        _SectionCard(
          title: 'Your Personality',
          icon: Icons.psychology,
          child: Text(
            insight.personalitySummary,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),

        const SizedBox(height: 16),

        // Skills
        _SectionCard(
          title: 'Your Strengths',
          icon: Icons.star,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: insight.skillsDetected
                .map((skill) => Chip(
                      label: Text(skill),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Interest Scores
        _SectionCard(
          title: 'Interest Profile',
          icon: Icons.favorite,
          child: _InterestChart(scores: insight.interestScores),
        ),

        const SizedBox(height: 16),

        // Career Recommendations
        _SectionCard(
          title: 'Recommended Careers',
          icon: Icons.work,
          child: Column(
            children: insight.careerRecommendations
                .map((career) => _CareerCard(career: career))
                .toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Learning Path
        _SectionCard(
          title: 'Next Steps',
          icon: Icons.rocket_launch,
          child: Column(
            children: insight.learningPath
                .map((step) => _LearningStepCard(step: step))
                .toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Metadata
        _MetadataCard(insight: insight),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassyCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InterestChart extends StatelessWidget {
  const _InterestChart({required this.scores});

  final Map<String, double> scores;

  /// Convert snake_case or camelCase keys to readable Title Case
  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatLabel(entry.key),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Text(
                    '${entry.value.toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: entry.value / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CareerCard extends StatelessWidget {
  const _CareerCard({required this.career});

  final CareerRecommendation career;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    career.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${career.matchScore.toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              career.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                career.whyGoodFit,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningStepCard extends StatelessWidget {
  const _LearningStepCard({required this.step});

  final LearningPathStep step;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (step.type.toLowerCase()) {
      case 'course':
        icon = Icons.school;
        color = Colors.blue;
        break;
      case 'activity':
        icon = Icons.sports_esports;
        color = Colors.green;
        break;
      case 'challenge':
        icon = Icons.emoji_events;
        color = Colors.orange;
        break;
      default:
        icon = Icons.link;
        color = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          step.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(step.description),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.insight});

  final AIInsight insight;

  @override
  Widget build(BuildContext context) {
    return GlassyCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetadataItem(
                  icon: Icons.analytics,
                  label: 'Confidence',
                  value: '${(insight.confidenceScore * 100).toInt()}%',
                ),
                _MetadataItem(
                  icon: Icons.data_usage,
                  label: 'Data Points',
                  value: '${insight.dataPointsUsed}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generated ${_formatDate(insight.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

