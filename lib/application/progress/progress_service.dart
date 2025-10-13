import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for reading discovery progress
/// Purpose: dashboard progress ring (0–100), streaks, last activity date
/// Owner key: user_id
/// Write path: NEVER write from client; Trigger fn_update_progress_after_run updates after each activity_runs insert
/// Read path: Dashboard
class ProgressService {
  ProgressService(this._supabase);

  final SupabaseClient _supabase;

  /// Get current user's discovery progress
  /// Returns null if user has not started any activities yet
  Future<DiscoveryProgress?> getMyProgress() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('discovery_progress')
        .select('percent, streak_days, last_activity_date, updated_at')
        .eq('user_id', userId)
        .maybeSingle();

    return response != null ? DiscoveryProgress.fromJson(response) : null;
  }

  /// Get profile completeness using Postgres function
  /// Returns percentage 0-100
  Future<double> getProfileCompleteness() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0.0;

    final response = await _supabase.rpc<double>(
      'get_profile_completeness',
      params: {'p_user_id': userId},
    );

    return response;
  }
}

/// Discovery progress model
class DiscoveryProgress {
  const DiscoveryProgress({
    required this.percent,
    required this.streakDays,
    this.lastActivityDate,
    required this.updatedAt,
  });

  final int percent; // 0-100
  final int streakDays;
  final DateTime? lastActivityDate;
  final DateTime updatedAt;

  /// Check if user completed an activity today
  bool get isActiveToday {
    if (lastActivityDate == null) return false;
    final today = DateTime.now();
    return lastActivityDate!.year == today.year &&
        lastActivityDate!.month == today.month &&
        lastActivityDate!.day == today.day;
  }

  /// Check if streak is at risk (last activity was yesterday or before)
  bool get streakAtRisk {
    if (lastActivityDate == null) return true;
    if (isActiveToday) return false;

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return lastActivityDate!.isBefore(yesterday);
  }

  factory DiscoveryProgress.fromJson(Map<String, dynamic> json) {
    return DiscoveryProgress(
      percent: json['percent'] as int,
      streakDays: json['streak_days'] as int,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percent': percent,
      'streak_days': streakDays,
      'last_activity_date': lastActivityDate?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
