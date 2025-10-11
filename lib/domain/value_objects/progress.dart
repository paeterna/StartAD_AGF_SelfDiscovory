import 'package:flutter/foundation.dart';

/// Discovery progress value object
@immutable
class DiscoveryProgress {
  const DiscoveryProgress({
    required this.userId,
    required this.percent,
    required this.streakDays,
    this.lastActivityDate,
  });

  final String userId;

  /// Progress percentage (0-100)
  final int percent;

  /// Consecutive days with activity
  final int streakDays;

  /// Last date of activity
  final DateTime? lastActivityDate;

  bool get isComplete => percent >= 100;

  bool get hasStreakToday {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    return today == lastActivity;
  }

  DiscoveryProgress copyWith({
    String? userId,
    int? percent,
    int? streakDays,
    DateTime? lastActivityDate,
  }) {
    return DiscoveryProgress(
      userId: userId ?? this.userId,
      percent: percent ?? this.percent,
      streakDays: streakDays ?? this.streakDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  /// Update progress with new activity
  DiscoveryProgress addProgress(int delta) {
    final newPercent = (percent + delta).clamp(0, 100);
    final now = DateTime.now();

    // Check if we need to update streak
    int newStreak = streakDays;
    if (!hasStreakToday) {
      // Check if last activity was yesterday
      if (lastActivityDate != null) {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final lastDate = DateTime(
          lastActivityDate!.year,
          lastActivityDate!.month,
          lastActivityDate!.day,
        );

        if (lastDate == yesterdayDate) {
          newStreak = streakDays + 1;
        } else {
          newStreak = 1; // Reset streak
        }
      } else {
        newStreak = 1; // First activity
      }
    }

    return DiscoveryProgress(
      userId: userId,
      percent: newPercent,
      streakDays: newStreak,
      lastActivityDate: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveryProgress &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          percent == other.percent &&
          streakDays == other.streakDays;

  @override
  int get hashCode => userId.hashCode ^ percent.hashCode ^ streakDays.hashCode;

  @override
  String toString() {
    return 'DiscoveryProgress(userId: $userId, percent: $percent%, '
        'streakDays: $streakDays)';
  }
}
