import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('Careers')),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search careers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            // Career list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CareerCard(
                    title: 'Software Engineer',
                    description:
                        'Design, develop, and maintain software applications',
                    matchScore: 85,
                    cluster: 'Technology',
                  ),
                  const SizedBox(height: 12),
                  _CareerCard(
                    title: 'Data Scientist',
                    description:
                        'Analyze complex data to help organizations make decisions',
                    matchScore: 78,
                    cluster: 'STEM',
                  ),
                  const SizedBox(height: 12),
                  _CareerCard(
                    title: 'Graphic Designer',
                    description: 'Create visual concepts to communicate ideas',
                    matchScore: 65,
                    cluster: 'Arts & Humanities',
                  ),
                  const SizedBox(height: 12),
                  _CareerCard(
                    title: 'Marketing Manager',
                    description: 'Plan and execute marketing strategies',
                    matchScore: 72,
                    cluster: 'Business & Finance',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  const _CareerCard({
    required this.title,
    required this.description,
    required this.matchScore,
    required this.cluster,
  });

  final String title;
  final String description;
  final int matchScore;
  final String cluster;

  @override
  Widget build(BuildContext context) {
    final matchLevel = matchScore >= 70
        ? 'High Match'
        : matchScore >= 40
        ? 'Medium Match'
        : 'Explore More';

    final matchColor = matchScore >= 70
        ? Colors.green
        : matchScore >= 40
        ? Colors.orange
        : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
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
                    color: matchColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$matchScore%',
                    style: TextStyle(
                      color: matchColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cluster,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: matchColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    matchLevel,
                    style: TextStyle(
                      fontSize: 12,
                      color: matchColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('View Details')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
