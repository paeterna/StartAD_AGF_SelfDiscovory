import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.discoverTitle)),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: l10n.discoverQuizzesTab),
                  Tab(text: l10n.discoverGamesTab),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [_buildQuizzesList(l10n), _buildGamesList(l10n)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizzesList(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AssessmentCard(
          title: l10n.quizPersonalityTitle,
          description: l10n.quizPersonalityDescription,
          duration: l10n.discoverDurationMinutes(5),
          progress: 0.0,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentCard(
          title: l10n.quizInterestTitle,
          description: l10n.quizInterestDescription,
          duration: l10n.discoverDurationMinutes(4),
          progress: 0.0,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentCard(
          title: l10n.quizSkillsTitle,
          description: l10n.quizSkillsDescription,
          duration: l10n.discoverDurationMinutes(6),
          progress: 0.5,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGamesList(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AssessmentCard(
          title: l10n.gamePatternTitle,
          description: l10n.gamePatternDescription,
          duration: l10n.discoverDurationMinutes(3),
          progress: 0.0,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _AssessmentCard(
          title: l10n.gameCreativeTitle,
          description: l10n.gameCreativeDescription,
          duration: l10n.discoverDurationMinutes(5),
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
    final l10n = AppLocalizations.of(context)!;
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
                      child: Text(
                          l10n.discoverCompletedBadge,
                          style: const TextStyle(
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
                    child: Text(isStarted ? l10n.discoverResumeButton : l10n.discoverStartButton),
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
