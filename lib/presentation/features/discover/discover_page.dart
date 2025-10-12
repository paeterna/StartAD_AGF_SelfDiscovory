import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('Discover')),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Quizzes'),
                  Tab(text: 'Games'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [_buildQuizzesList(), _buildGamesList()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizzesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AssessmentCard(
          title: 'Personality Discovery',
          description: 'Discover your core personality traits',
          duration: '5 min',
          progress: 0.0,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentCard(
          title: 'Interest Explorer',
          description: 'Identify your key interests',
          duration: '4 min',
          progress: 0.0,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentCard(
          title: 'Skills Assessment',
          description: 'Evaluate your current skills',
          duration: '6 min',
          progress: 0.5,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGamesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AssessmentCard(
          title: 'Pattern Recognition',
          description: 'Test your analytical skills',
          duration: '3 min',
          progress: 0.0,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentCard(
          title: 'Creative Challenge',
          description: 'Explore your creativity',
          duration: '5 min',
          progress: 0.0,
          onTap: () {},
        ),
      ],
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.title,
    required this.description,
    required this.duration,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String description;
  final String duration;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress >= 1.0;
    final isStarted = progress > 0 && progress < 1.0;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(description),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                    ),
                    child: Text(isStarted ? 'Resume' : 'Start'),
                  ),
                ],
              ),
              if (isStarted) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
