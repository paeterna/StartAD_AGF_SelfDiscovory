import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/ai_insight/ai_insight_providers.dart';
import '../../../domain/entities/career_roadmap.dart';
import '../../widgets/gradient_background.dart';

class AIRoadmapPage extends ConsumerWidget {
  const AIRoadmapPage({super.key, this.careerTitle});

  final String? careerTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestInsight = ref.watch(latestAIInsightProvider);

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Career Roadmap'),
        ),
        body: latestInsight.when(
          data: (insight) {
            if (insight == null) {
              return _buildNoInsightView(context);
            }

            // If a specific career is requested, show that roadmap
            if (careerTitle != null && insight.careerRoadmaps.containsKey(careerTitle)) {
              return _buildRoadmapView(context, careerTitle!, insight.careerRoadmaps[careerTitle]!);
            }

            // Otherwise, show all roadmaps
            return _buildAllRoadmapsView(context, insight.careerRoadmaps);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildErrorView(context),
        ),
      ),
    );
  }

  Widget _buildNoInsightView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Career Roadmap Yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete quizzes and games to generate your personalized career roadmap',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Text(
        'Error loading roadmap',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildAllRoadmapsView(BuildContext context, Map<String, CareerRoadmap> roadmaps) {
    if (roadmaps.isEmpty) {
      return _buildNoInsightView(context);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Your Career Roadmaps',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Detailed paths for your recommended careers',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        ...roadmaps.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.map, size: 32),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text('Tap to view detailed roadmap'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIRoadmapPage(careerTitle: entry.key),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRoadmapView(BuildContext context, String title, CareerRoadmap roadmap) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Career Title
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your personalized roadmap for UAE',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),

        // School Level
        _buildSection(
          context,
          icon: Icons.school,
          title: 'School Level (Grades 9-12)',
          color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubsection('Focus Subjects', roadmap.schoolSubjects.join(', ')),
              const SizedBox(height: 12),
              _buildSubsection('Advice', roadmap.schoolAdvice),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // University Level
        _buildSection(
          context,
          icon: Icons.account_balance,
          title: 'University Level',
          color: Colors.purple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: roadmap.universityPrograms.map((program) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.degree,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('Duration: ${program.duration}'),
                    const SizedBox(height: 4),
                    Text(
                      'Universities: ${program.universities.join(', ')}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Skills & Certifications
        _buildSection(
          context,
          icon: Icons.verified,
          title: 'Skills & Certifications',
          color: Colors.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: roadmap.skillsCertifications.map((skill) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: skill.importance == 'high'
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (skill.importance == 'high')
                            const Icon(Icons.star, size: 16, color: Colors.orange),
                          if (skill.importance == 'high') const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              skill.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Provider: ${skill.provider}'),
                      const SizedBox(height: 4),
                      Text(
                        skill.uaeRelevance,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Career Progression
        _buildSection(
          context,
          icon: Icons.trending_up,
          title: 'Career Progression',
          color: Colors.green,
          child: Column(
            children: roadmap.careerProgression.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == roadmap.careerProgression.length - 1;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getLevelColor(step.level),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 60,
                              color: Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text(step.level),
                                  backgroundColor: _getLevelColor(step.level).withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: _getLevelColor(step.level),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  step.years,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step.responsibilities,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '💰 ${step.salaryRangeAed}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
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

  Widget _buildSubsection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'entry':
        return Colors.blue;
      case 'mid':
        return Colors.orange;
      case 'senior':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

