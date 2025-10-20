import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/scoring/scoring_providers.dart';
import '../../../application/gamification/gamification_providers.dart';
import '../../../common/widgets/level_badge.dart';
import '../../../common/widgets/streak_chip.dart';
import '../../../core/assets/app_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/radar_traits_card.dart';
import '../../widgets/ai_insights_dashboard_card.dart';
import '../gamification/badges_sheet.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(gamificationProfileProvider);

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.dashboardTitle),
          actions: [
            // New streak and level widgets
            profileAsync.when(
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      // Streak chip
                      if (profile.currentStreak > 0)
                        CompactStreakChip(streakDays: profile.currentStreak),
                      if (profile.currentStreak > 0) const SizedBox(width: 12),
                      // Level badge
                      CompactLevelBadge(level: profile.level, size: 36),
                      const SizedBox(width: 12),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(Icons.emoji_events),
              tooltip: 'Badges',
              onPressed: () => BadgesSheet.show(context),
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

              // Progress cards row (XP and Profile side by side)
              Row(
                children: [
                  Expanded(child: _GamificationCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _ProfileProgressCard()),
                ],
              ),
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
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _NavButton(
            iconPath: AppIcons.sportsEsports,
            label: l10n.discoverGamesTab,
            onTap: () => context.push('${AppRoutes.discover}?tab=1'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavButton(
            iconPath: AppIcons.quizOutlined,
            label: l10n.discoverQuizzesTab,
            onTap: () => context.push(AppRoutes.discover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavButton(
            iconPath: AppIcons.workOutline,
            label: l10n.careersTitle,
            onTap: () => context.push(AppRoutes.careers),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavButton(
            iconPath: AppIcons.mapOutlined,
            label: l10n.roadmapTitle,
            onTap: () => context.push(AppRoutes.roadmap),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
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
              AppIcon(
                iconPath,
                size: 32,
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

    // Get completeness value, default to 0 while loading
    final completeness = completenessAsync.valueOrNull ?? 0.0;
    final percent = completeness.round();
    final level = percent < 30
        ? l10n.dashboardProgressJustStarted
        : percent < 60
            ? l10n.dashboardProgressGettingThere
            : percent < 90
                ? l10n.dashboardProgressAlmostDone
                : l10n.dashboardProgressComplete;

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular progress indicator
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: completeness / 100.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 8,
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: animatedValue,
                          strokeWidth: 8,
                          // color: colorScheme.primary,
                        ),
                      ),
                      // Center content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            // color: colorScheme.secondary,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(animatedValue * 100).round()}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              // color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Status label
            Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    // color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              level,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Gamification XP/Level card showing progress
class _GamificationCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(gamificationProfileProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'No XP data',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }

            final colorScheme = Theme.of(context).colorScheme;

            // Calculate progress manually
            final progress = profile.xpNeededForCurrentLevel > 0
                ? (profile.totalXp / profile.xpNeededForCurrentLevel).clamp(0.0, 1.0)
                : 0.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular progress indicator
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, child) {
                    return SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 8,
                              color: colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          // Progress circle
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: animatedValue,
                              strokeWidth: 8,
                              color: colorScheme.primary,
                            ),
                          ),
                          // Center content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.military_tech,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Level ${profile.level}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // XP Info
                Text(
                  '${profile.totalXp} XP',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.xpNeededForCurrentLevel - profile.currentXp} to Level ${profile.level + 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),

                // Streak badge if active
                if (profile.currentStreak > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.currentStreak} day streak',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 40, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Quick Action Card Widget
