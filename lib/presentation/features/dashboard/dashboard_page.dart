import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/scoring/scoring_providers.dart';
import '../../../application/activity/activity_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/radar_traits_card.dart';
import '../../widgets/ai_insights_dashboard_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(discoveryProgressProvider);

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.dashboardTitle),
          actions: [
            // Streak indicator
            progressAsync.when(
              data: (progress) {
                if (progress == null || progress.streakDays == 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.streakDays}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                l10n.dashboardWelcome(user?.displayName ?? 'Student'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Profile completeness card
              _ProfileProgressCard(),
              const SizedBox(height: 24),

              // Quick navigation buttons
              _QuickNavigationButtons(),
              const SizedBox(height: 24),

              // Personality traits radar chart
              const RadarTraitsCard(
                title: 'Your Personality Profile',
                showLegend: true,
              ),
              const SizedBox(height: 24),

              // AI-generated insights
              const AIInsightsDashboardCard(),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                l10n.dashboardWhatsNext,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _QuickActionCard(
                icon: Icons.explore,
                title: l10n.dashboardContinueDiscovery,
                subtitle: l10n.dashboardContinueDiscoverySubtitle,
                onTap: () => context.push(AppRoutes.discover),
              ),
              const SizedBox(height: 12),

              _QuickActionCard(
                icon: Icons.work_outline,
                title: l10n.dashboardViewCareers,
                subtitle: l10n.dashboardViewCareersSubtitle,
                onTap: () => context.push(AppRoutes.careers),
              ),
              const SizedBox(height: 12),

              _QuickActionCard(
                icon: Icons.map_outlined,
                title: l10n.dashboardStartRoadmap,
                subtitle: l10n.dashboardStartRoadmapSubtitle,
                onTap: () => context.push(AppRoutes.roadmap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickNavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NavButton(
            icon: Icons.sports_esports,
            label: 'Games',
            onTap: () => context.push('/games/memory-match'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavButton(
            icon: Icons.quiz,
            label: 'Quizzes',
            onTap: () => context.push(AppRoutes.discover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavButton(
            icon: Icons.work_outline,
            label: 'Careers',
            onTap: () => context.push(AppRoutes.careers),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavButton(
            icon: Icons.map_outlined,
            label: 'Roadmap',
            onTap: () => context.push(AppRoutes.roadmap),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileProgressCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completenessAsync = ref.watch(profileCompletenessProvider);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.dashboardProfileProgress,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            completenessAsync.when(
              data: (completeness) {
                final percent = completeness.round();
                final level = percent < 30
                    ? l10n.dashboardProgressJustStarted
                    : percent < 60
                    ? l10n.dashboardProgressGettingThere
                    : percent < 90
                    ? l10n.dashboardProgressAlmostDone
                    : l10n.dashboardProgressComplete;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          level,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$percent%',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completeness / 100.0,
                        minHeight: 12,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      percent < 90
                          ? l10n.dashboardProgressHint
                          : l10n.dashboardProgressCompleteHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
