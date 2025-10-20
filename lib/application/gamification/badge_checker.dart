import '../../data/repositories/gamification_repository.dart';
import '../../domain/entities/gamification.dart';

/// Service for checking and awarding badges based on activities
class BadgeChecker {
  BadgeChecker(this._repository);

  final GamificationRepository _repository;

  /// Check and award badges based on activity completion
  /// Returns list of newly earned badges
  Future<List<BadgeDefinition>> checkActivityBadges({
    required String activityType,
    required Map<String, dynamic> metadata,
  }) async {
    final newlyEarned = <BadgeDefinition>[];

    switch (activityType) {
      case 'first_activity':
        final badge = await _tryAwardBadge('first_steps');
        if (badge != null) newlyEarned.add(badge);
        break;

      case 'perfect_score':
        final badge = await _tryAwardBadge('perfect_score');
        if (badge != null) newlyEarned.add(badge);
        break;

      case 'memory_match_fast':
        final badge = await _tryAwardBadge('speed_demon');
        if (badge != null) newlyEarned.add(badge);
        break;

      case 'memory_match_count':
        final count = metadata['count'] as int? ?? 0;
        if (count >= 10) {
          final badge = await _tryAwardBadge('memory_master');
          if (badge != null) newlyEarned.add(badge);
        }
        break;

      case 'quiz_count':
        final count = metadata['count'] as int? ?? 0;
        if (count >= 5) {
          final badge = await _tryAwardBadge('quiz_ace');
          if (badge != null) newlyEarned.add(badge);
        }
        break;

      case 'roadmap_generated':
        final count = metadata['total_roadmaps'] as int? ?? 0;
        if (count == 1) {
          final badge = await _tryAwardBadge('career_explorer');
          if (badge != null) newlyEarned.add(badge);
        } else if (count >= 5) {
          final badge = await _tryAwardBadge('roadmap_collector');
          if (badge != null) newlyEarned.add(badge);
        }
        break;

      case 'high_score_streak':
        final count = metadata['count'] as int? ?? 0;
        if (count >= 10) {
          final badge = await _tryAwardBadge('perfectionist');
          if (badge != null) newlyEarned.add(badge);
        }
        break;
    }

    return newlyEarned;
  }

  /// Check and award streak-based badges
  Future<List<BadgeDefinition>> checkStreakBadges(int streakDays) async {
    final newlyEarned = <BadgeDefinition>[];

    if (streakDays >= 7) {
      final badge = await _tryAwardBadge('week_warrior');
      if (badge != null) newlyEarned.add(badge);
    }

    return newlyEarned;
  }

  /// Check and award level-based badges
  Future<List<BadgeDefinition>> checkLevelBadges(int newLevel) async {
    final newlyEarned = <BadgeDefinition>[];

    if (newLevel >= 5) {
      final badge = await _tryAwardBadge('level_five');
      if (badge != null) newlyEarned.add(badge);
    }

    if (newLevel >= 10) {
      final badge = await _tryAwardBadge('level_ten');
      if (badge != null) newlyEarned.add(badge);
    }

    return newlyEarned;
  }

  /// Check and award theme-based badges
  Future<List<BadgeDefinition>> checkThemeBadges(int themeSwitchCount) async {
    final newlyEarned = <BadgeDefinition>[];

    if (themeSwitchCount >= 3) {
      final badge = await _tryAwardBadge('theme_switcher');
      if (badge != null) newlyEarned.add(badge);
    }

    return newlyEarned;
  }

  /// Check and award time-based badges
  Future<List<BadgeDefinition>> checkTimeBadges({
    required DateTime activityTime,
  }) async {
    final newlyEarned = <BadgeDefinition>[];
    final hour = activityTime.hour;

    // Early bird (before 9 AM)
    if (hour < 9) {
      final badge = await _tryAwardBadge('early_bird');
      if (badge != null) newlyEarned.add(badge);
    }

    // Night owl (after 9 PM)
    if (hour >= 21) {
      final badge = await _tryAwardBadge('night_owl');
      if (badge != null) newlyEarned.add(badge);
    }

    return newlyEarned;
  }

  /// Try to award a badge, returns BadgeDefinition if newly earned
  Future<BadgeDefinition?> _tryAwardBadge(String badgeKey) async {
    // Check if already earned
    final hasIt = await _repository.hasBadge(badgeKey);
    if (hasIt) return null;

    // Award the badge
    final badge = await _repository.awardBadge(badgeKey);
    if (badge == null) return null;

    // Get badge definition from remote config
    final config = await _repository.getRemoteConfig('badge_catalog');
    if (config == null) return null;

    final catalogMap = config as Map<String, dynamic>;
    final badgeData = catalogMap[badgeKey];
    if (badgeData == null) return null;

    return BadgeDefinition.fromJson(badgeData as Map<String, dynamic>);
  }
}
