import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/ai_insight/ai_insight_providers.dart';
import '../../domain/entities/ai_insight.dart';
import '../../core/router/app_router.dart';

/// Widget showing AI-recommended careers on the Careers page
class AICareerRecommendationsCard extends ConsumerWidget {
  const AICareerRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestInsight = ref.watch(latestAIInsightProvider);

    return latestInsight.when(
      data: (insight) {
        if (insight == null || insight.careerRecommendations.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildRecommendationsSection(context, insight);
      },
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, AIInsight insight) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'AI-Recommended Careers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your personality, skills, and interests',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Career cards
          ...insight.careerRecommendations.map((career) {
            return _buildCareerCard(context, career, insight);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCareerCard(
    BuildContext context,
    CareerRecommendation career,
    AIInsight insight,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to roadmap page with this career
          context.push('${AppRoutes.roadmap}?career=${Uri.encodeComponent(career.title)}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and match score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      career.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMatchColor(career.matchScore).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars,
                          size: 16,
                          color: _getMatchColor(career.matchScore),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${career.matchScore.toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getMatchColor(career.matchScore),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                career.description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),

              // Why it's a good fit
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Why this fits you:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      career.whyGoodFit,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // View Roadmap button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('${AppRoutes.roadmap}?career=${Uri.encodeComponent(career.title)}');
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('View Career Roadmap'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMatchColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.grey;
  }
}

