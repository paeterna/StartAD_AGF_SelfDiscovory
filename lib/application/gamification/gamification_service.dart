import 'package:flutter/material.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../domain/entities/gamification.dart';
import '../../common/widgets/confetti_overlay.dart';
import '../../common/widgets/xp_popover.dart';
import '../../presentation/features/gamification/badge_unlock_modal.dart';
import '../../presentation/features/games/memory_match/memory_match_controller.dart';
import 'badge_checker.dart';
import 'xp_calculator.dart';

/// High-level service for gamification rewards
/// Combines XP awards, badge checking, and celebration UI
class GamificationService {
  GamificationService(this._repository)
      : _badgeChecker = BadgeChecker(_repository);

  final GamificationRepository _repository;
  final BadgeChecker _badgeChecker;

  /// Award XP and check for badges after Memory Match
  Future<void> handleMemoryMatchCompletion({
    required BuildContext context,
    required int score,
    required int timeSeconds,
    required GameScores scores,
  }) async {
    // Calculate XP
    final xpGained = XpCalculator.calculateMemoryMatchXp(scores, timeSeconds);

    // Award XP and check for level up
    final result = await _repository.awardXp(
      reason: 'memory_match',
      amount: xpGained,
    );

    final profile = result.profile;

    // Show confetti
    if (context.mounted) {
      showConfetti(context);
    }

    // Show XP popover
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      showXpPopover(
        context,
        xpAmount: xpGained,
        reason: 'Memory Match Complete',
      );
    }

    // Check for badges in parallel for better performance
    final badgeChecks = <Future<List<BadgeDefinition>>>[];

    if (profile.totalXp == xpGained) {
      badgeChecks.add(_badgeChecker.checkActivityBadges(
        activityType: 'first_activity',
        metadata: {},
      ));
    }

    if (scores.composite >= 100) {
      badgeChecks.add(_badgeChecker.checkActivityBadges(
        activityType: 'perfect_score',
        metadata: {},
      ));
    }

    if (timeSeconds < 30) {
      badgeChecks.add(_badgeChecker.checkActivityBadges(
        activityType: 'memory_match_fast',
        metadata: {},
      ));
    }

    badgeChecks.add(_badgeChecker.checkTimeBadges(
      activityTime: DateTime.now(),
    ));

    if (result.leveledUp) {
      badgeChecks.add(_badgeChecker.checkLevelBadges(result.profile.level));
    }

    // Run all badge checks in parallel
    final badgeResults = await Future.wait(badgeChecks);
    final badges = badgeResults.expand((list) => list).toList();

    // Show level up modal
    if (result.leveledUp && context.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (context.mounted) {
        showConfettiCelebration(
          context,
          title: 'Level ${result.profile.level}!',
          subtitle: 'You\'re getting stronger! 💪',
        );
      }
    }

    // Show badge unlock modals
    for (final badge in badges) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        await BadgeUnlockModal.show(context, badgeDefinition: badge);
      }
    }
  }

  /// Award XP and check for badges after Quiz completion
  Future<void> handleQuizCompletion({
    required BuildContext context,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSeconds,
  }) async {
    final xpGained = XpCalculator.calculateQuizXp(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      timeSeconds: timeSeconds,
    );

    final result = await _repository.awardXp(
      reason: 'quiz',
      amount: xpGained,
    );

    if (context.mounted) {
      showConfetti(context);
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      showXpPopover(
        context,
        xpAmount: xpGained,
        reason: 'Quiz Complete',
      );
    }

    // Check for badges in parallel for better performance
    final badgeChecks = <Future<List<BadgeDefinition>>>[];

    if (result.profile.totalXp == xpGained) {
      badgeChecks.add(_badgeChecker.checkActivityBadges(
        activityType: 'first_activity',
        metadata: {},
      ));
    }

    if (correctAnswers == totalQuestions) {
      badgeChecks.add(_badgeChecker.checkActivityBadges(
        activityType: 'perfect_score',
        metadata: {},
      ));
    }

    badgeChecks.add(_badgeChecker.checkTimeBadges(
      activityTime: DateTime.now(),
    ));

    if (result.leveledUp) {
      badgeChecks.add(_badgeChecker.checkLevelBadges(result.profile.level));
    }

    // Run all badge checks in parallel
    final badgeResults = await Future.wait(badgeChecks);
    final badges = badgeResults.expand((list) => list).toList();

    if (result.leveledUp && context.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (context.mounted) {
        showConfettiCelebration(
          context,
          title: 'Level ${result.profile.level}!',
          subtitle: 'Keep crushing it! 🎯',
        );
      }
    }

    for (final badge in badges) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        await BadgeUnlockModal.show(context, badgeDefinition: badge);
      }
    }
  }

  /// Award XP for roadmap generation
  Future<void> handleRoadmapGeneration({
    required BuildContext context,
  }) async {
    const xpGained = XpCalculator.roadmapGenerated;

    final result = await _repository.awardXp(
      reason: 'roadmap_generated',
      amount: xpGained,
    );

    if (context.mounted) {
      showConfetti(context);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        showXpPopover(
          context,
          xpAmount: xpGained,
          reason: 'Roadmap Generated',
        );
      }
    }

    final badges = <BadgeDefinition>[];

    badges.addAll(await _badgeChecker.checkActivityBadges(
      activityType: 'roadmap_generated',
      metadata: {'total_roadmaps': 1},
    ));

    if (result.leveledUp) {
      badges.addAll(await _badgeChecker.checkLevelBadges(result.profile.level));

      if (context.mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        if (context.mounted) {
          showConfettiCelebration(
            context,
            title: 'Level ${result.profile.level}!',
            subtitle: 'Career explorer! 🗺️',
          );
        }
      }
    }

    for (final badge in badges) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        await BadgeUnlockModal.show(context, badgeDefinition: badge);
      }
    }
  }

  /// Update streak and check for streak badges
  Future<void> handleDailyLogin({
    required BuildContext context,
  }) async {
    await _repository.updateStreak();

    final profile = await _repository.getProfile();
    if (profile == null) return;

    final milestoneXp = XpCalculator.calculateStreakMilestoneXp(profile.currentStreak);
    if (milestoneXp != null) {
      await _repository.awardXp(
        reason: 'streak_milestone',
        amount: milestoneXp,
      );

      if (context.mounted) {
        showConfetti(context);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          showXpPopover(
            context,
            xpAmount: milestoneXp,
            reason: XpCalculator.getStreakMilestoneMessage(profile.currentStreak),
          );
        }
      }

      final badges = await _badgeChecker.checkStreakBadges(profile.currentStreak);

      for (final badge in badges) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          await BadgeUnlockModal.show(context, badgeDefinition: badge);
        }
      }
    }
  }
}
