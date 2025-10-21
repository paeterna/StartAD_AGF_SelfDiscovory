import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/activity/activity_providers.dart';
import '../../../core/assets/app_icons.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/logo_app_bar.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      child: Scaffold(
        appBar: LogoAppBar(title: l10n.discoverTitle),
        body: DefaultTabController(
          length: 2,
          initialIndex: initialTabIndex,
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
                  children: [
                    _buildQuizzesList(context, ref, l10n),
                    _buildGamesList(context, ref, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizzesList(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final quizzesAsync = ref.watch(availableActivitiesProvider('quiz'));

    return quizzesAsync.when(
      data: (quizzes) {
        // Ensure asset-backed assessments are visible even if not seeded in DB
        final hasRiasec = quizzes.any(
          (q) =>
              q.id == 'quiz_riasec_mini' ||
              q.title.toLowerCase().contains('career') ||
              q.title.toLowerCase().contains('riasec'),
        );
        final hasIpip = quizzes.any(
          (q) =>
              q.id == 'quiz_ipip50' ||
              q.title.toLowerCase().contains('personality') ||
              q.title.toLowerCase().contains('ipip'),
        );

        // Build a list that may contain synthetic entries for asset instruments
        final List<Widget> items = [];

        if (!hasRiasec) {
          items.add(
            _AssessmentCard(
              title: l10n.quizInterestTitle,
              description: l10n.quizGenericDescription,
              duration: l10n.discoverDurationMinutes(5),
              progress: 0.0,
              onTap: () => context.push('/quiz/quiz_riasec_mini'),
              iconPath: AppIcons.quizOutlined,
            ),
          );
        }

        if (!hasIpip) {
          items.add(
            _AssessmentCard(
              title: l10n.quizPersonalityTitle,
              description: l10n.quizGenericDescription,
              duration: l10n.discoverDurationMinutes(10),
              progress: 0.0,
              onTap: () => context.push('/quiz/quiz_ipip50'),
              iconPath: AppIcons.psychologyOutlined,
            ),
          );
        }

        if (quizzes.isEmpty && items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.discoverNoQuizzesAvailable,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        // Append DB quizzes after synthetic ones
        items.addAll(
          List.generate(quizzes.length, (index) {
            final quiz = quizzes[index];
            return _AssessmentCard(
              title: quiz.title,
              description: l10n.quizGenericDescription,
              duration: quiz.estimatedMinutes != null
                  ? l10n.discoverDurationMinutes(quiz.estimatedMinutes!)
                  : l10n.discoverDurationMinutes(5),
              progress: 0.0,
              onTap: () => context.push('/quiz/${quiz.id}'),
              iconPath: AppIcons.quizOutlined,
            );
          }),
        );

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => items[index],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
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
              l10n.discoverErrorLoadingQuizzes,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(availableActivitiesProvider('quiz')),
              child: Text(l10n.discoverRetryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesList(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final gamesAsync = ref.watch(availableActivitiesProvider('game'));

    return gamesAsync.when(
      data: (games) {
        // Ensure Memory Match is visible even if not seeded in DB
        final hasMemoryMatch = games.any(
          (g) =>
              g.id == 'memory_match' ||
              g.title.toLowerCase().contains('memory match'),
        );

        final List<Widget> items = [];

        // Add Memory Match if not in DB
        if (!hasMemoryMatch) {
          items.add(
            _AssessmentCard(
              title: l10n.memoryMatchTitle,
              description: l10n.gameGenericDescription,
              duration: l10n.discoverDurationMinutes(7),
              progress: 0.0,
              onTap: () => context.push('/games/memory-match'),
              iconPath: AppIcons.sportsEsports,
            ),
          );
        }

        if (games.isEmpty && items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.games_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.discoverNoGamesAvailable,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        // Add DB games
        items.addAll(
          List.generate(games.length, (index) {
            final game = games[index];
            String route = '/games/memory-match';

            // Determine route based on game type
            if (game.id == 'memory_match' ||
                game.title.toLowerCase().contains('memory match')) {
              route = '/games/memory-match';
            } else {
              route = '/game/${game.id}';
            }

            return _AssessmentCard(
              title: game.title,
              description: l10n.gameGenericDescription,
              duration: game.estimatedMinutes != null
                  ? l10n.discoverDurationMinutes(game.estimatedMinutes!)
                  : l10n.discoverDurationMinutes(5),
              progress: 0.0, // TODO: Get actual progress from user data
              onTap: () => context.push(route),
              iconPath: AppIcons.gamesOutlined,
            );
          }),
        );

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => items[index],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
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
              l10n.discoverErrorLoadingGames,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(availableActivitiesProvider('game')),
              child: Text(l10n.discoverRetryButton),
            ),
          ],
        ),
      ),
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
    this.iconPath,
  });

  final String title;
  final String description;
  final String duration;
  final double progress;
  final VoidCallback onTap;
  final String? iconPath;

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
                  if (iconPath != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppIcon(
                        iconPath!,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
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
                    child: Text(
                      isStarted
                          ? l10n.discoverResumeButton
                          : l10n.discoverStartButton,
                    ),
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
