import 'dart:math';
import '../../presentation/features/games/memory_match/memory_match_controller.dart';

/// Service for calculating XP rewards from activities
class XpCalculator {
  /// XP reward constants
  static const int dailyLogin = 10;
  static const int profileComplete = 50;
  static const int assessmentComplete = 100;
  static const int roadmapGenerated = 75;
  static const int badgeUnlock = 100;

  // Streak milestones
  static const int weekStreak = 100;
  static const int twoWeekStreak = 200;
  static const int monthStreak = 500;

  /// Calculate XP from Memory Match game
  /// Base XP: 25
  /// Perfect bonus: +25 (100% accuracy)
  /// Speed bonus: +15 (under 60 seconds)
  /// Combo bonus: up to +10 (based on streak)
  static int calculateMemoryMatchXp(GameScores scores, int totalSeconds) {
    int xp = 25; // Base XP

    // Perfect score bonus (100% matches)
    final accuracy = scores.cognitionMemory / 100.0;
    if (accuracy >= 0.95) {
      xp += 25; // Perfect or near-perfect
    } else if (accuracy >= 0.80) {
      xp += 15; // Very good
    } else if (accuracy >= 0.60) {
      xp += 5; // Good
    }

    // Speed bonus (complete under 60 seconds)
    if (totalSeconds <= 60) {
      xp += 15;
    } else if (totalSeconds <= 90) {
      xp += 10;
    } else if (totalSeconds <= 120) {
      xp += 5;
    }

    // Composite score bonus (overall performance)
    final composite = scores.composite;
    if (composite >= 90) {
      xp += 10;
    } else if (composite >= 75) {
      xp += 5;
    }

    return xp;
  }

  /// Calculate XP from Quiz completion
  /// Base XP: 30
  /// Per correct answer: +5
  /// Perfect bonus: +20
  static int calculateQuizXp({
    required int totalQuestions,
    required int correctAnswers,
    required int timeSeconds,
  }) {
    int xp = 30; // Base XP

    // Per correct answer
    xp += correctAnswers * 5;

    // Perfect score bonus
    if (correctAnswers == totalQuestions) {
      xp += 20;
    }

    // Speed bonus (under 2 minutes)
    if (timeSeconds <= 120) {
      xp += 10;
    }

    return xp;
  }

  /// Calculate XP from Assessment completion
  /// Base XP: 100 (assessments are longer)
  static int calculateAssessmentXp() {
    return assessmentComplete;
  }

  /// Calculate streak milestone XP
  static int? calculateStreakMilestoneXp(int streakDays) {
    if (streakDays == 7) return weekStreak;
    if (streakDays == 14) return twoWeekStreak;
    if (streakDays == 30) return monthStreak;
    if (streakDays % 30 == 0 && streakDays > 0) {
      // Every additional month
      return monthStreak;
    }
    return null;
  }

  /// Check if this streak is a milestone
  static bool isStreakMilestone(int streakDays) {
    return streakDays == 7 ||
        streakDays == 14 ||
        streakDays == 30 ||
        (streakDays % 30 == 0 && streakDays > 0);
  }

  /// Get milestone message for streak
  static String getStreakMilestoneMessage(int streakDays) {
    if (streakDays == 7) return 'One week strong! Keep it up! 🔥';
    if (streakDays == 14) return 'Two weeks! You\'re on fire! 🔥🔥';
    if (streakDays == 30) return 'One month streak! Incredible! 🔥🔥🔥';
    if (streakDays % 30 == 0) {
      final months = streakDays ~/ 30;
      return '$months month${months > 1 ? 's' : ''} streak! Unstoppable! 🔥🔥🔥';
    }
    return 'Amazing streak! Keep going! 🔥';
  }

  /// Calculate level from total XP
  /// Formula: level = floor(sqrt(xp / 100)) + 1
  /// This gives a smooth curve:
  /// - Level 1: 0-99 XP
  /// - Level 2: 100-399 XP (300 XP needed)
  /// - Level 3: 400-899 XP (500 XP needed)
  /// - Level 4: 900-1599 XP (700 XP needed)
  /// - Level 5: 1600-2499 XP (900 XP needed)
  static int calculateLevel(int totalXp) {
    if (totalXp < 0) return 1;
    final level = sqrt(totalXp / 100.0).floor() + 1;
    return level.clamp(1, 999); // Max level 999
  }

  /// Calculate XP needed for next level
  static int xpForNextLevel(int currentLevel) {
    if (currentLevel >= 999) return 0;
    final nextLevel = currentLevel + 1;
    // Inverse of level formula: xp = (level - 1)^2 * 100
    return ((nextLevel - 1) * (nextLevel - 1) * 100);
  }

  /// Calculate XP needed from current XP to next level
  static int xpUntilNextLevel(int currentXp, int currentLevel) {
    final xpForNext = xpForNextLevel(currentLevel);
    return (xpForNext - currentXp).clamp(0, double.infinity).toInt();
  }

  /// Calculate current level progress (0.0 to 1.0)
  static double calculateLevelProgress(int currentXp, int currentLevel) {
    final xpForCurrent = currentLevel == 1 ? 0 : xpForNextLevel(currentLevel - 1);
    final xpForNext = xpForNextLevel(currentLevel);
    final xpIntoLevel = currentXp - xpForCurrent;
    final xpNeeded = xpForNext - xpForCurrent;

    if (xpNeeded <= 0) return 1.0;
    return (xpIntoLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Get XP amount for a reason string
  static int getXpForReason(String reason) {
    switch (reason) {
      case 'daily_login':
        return dailyLogin;
      case 'profile_complete':
        return profileComplete;
      case 'assessment_complete':
        return assessmentComplete;
      case 'roadmap_generated':
        return roadmapGenerated;
      case 'badge_unlock':
        return badgeUnlock;
      case 'week_streak':
        return weekStreak;
      case 'two_week_streak':
        return twoWeekStreak;
      case 'month_streak':
        return monthStreak;
      default:
        return 0;
    }
  }

  /// Get display name for XP reason
  static String getReasonDisplayName(String reason) {
    switch (reason) {
      case 'daily_login':
        return 'Daily Login';
      case 'memory_match':
        return 'Memory Match';
      case 'quiz':
        return 'Quiz Complete';
      case 'assessment_complete':
        return 'Assessment Complete';
      case 'roadmap_generated':
        return 'Roadmap Created';
      case 'badge_unlock':
        return 'Badge Unlocked';
      case 'week_streak':
        return 'Week Streak';
      case 'two_week_streak':
        return '2 Week Streak';
      case 'month_streak':
        return 'Month Streak';
      case 'profile_complete':
        return 'Profile Complete';
      default:
        return reason.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }
}
