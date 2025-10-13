import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing activity runs and discovery progress
/// Implements the data contract flow:
/// 1. Insert activity_run → Trigger updates discovery_progress
/// 2. Compute feature scores → Call upsert_feature_ema
/// 3. Background job → Update career matches
class ActivityService {
  ActivityService(this._supabase);

  final SupabaseClient _supabase;

  /// Start an activity run
  /// Returns the run ID
  Future<int> startActivityRun({required String activityId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('activity_runs')
        .insert({
          'user_id': userId,
          'activity_id': activityId,
          'delta_progress': 0, // Will be updated on completion
        })
        .select('id')
        .single();

    return response['id'] as int;
  }

  /// Complete an activity run
  /// This triggers the discovery_progress update automatically
  Future<void> completeActivityRun({
    required int runId,
    int? score,
    Map<String, dynamic>? traitScores,
    required int deltaProgress, // 0-20
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Validate delta_progress
    if (deltaProgress < 0 || deltaProgress > 20) {
      throw ArgumentError('delta_progress must be between 0 and 20');
    }

    await _supabase
        .from('activity_runs')
        .update({
          'completed_at': DateTime.now().toIso8601String(),
          'score': score,
          'trait_scores': traitScores ?? {},
          'delta_progress': deltaProgress,
        })
        .eq('id', runId)
        .eq('user_id', userId);

    // Note: Trigger fn_update_progress_after_run will automatically update
    // discovery_progress table (percent, streak_days, last_activity_date)
  }

  /// Get user's discovery progress
  Future<DiscoveryProgress?> getDiscoveryProgress() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final response = await _supabase
        .from('discovery_progress')
        .select('percent, streak_days, last_activity_date, updated_at')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return DiscoveryProgress.fromJson(response);
  }

  /// Get user's activity run history
  Future<List<ActivityRun>> getActivityRuns({int? limit}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return [];
    }

    var query = _supabase
        .from('activity_runs')
        .select(
          'id, activity_id, started_at, completed_at, score, trait_scores, delta_progress',
        )
        .eq('user_id', userId)
        .order('started_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;

    return (response as List<dynamic>)
        .map((e) => ActivityRun.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get available activities
  Future<List<Activity>> getActivities({
    String? kind, // 'quiz' or 'game'
    bool activeOnly = true,
  }) async {
    var query = _supabase
        .from('activities')
        .select(
          'id, title, kind, estimated_minutes, active, traits_weight, created_at',
        );

    if (activeOnly) {
      query = query.eq('active', true);
    }

    if (kind != null) {
      query = query.eq('kind', kind);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
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
}

/// Activity run model
class ActivityRun {
  const ActivityRun({
    required this.id,
    required this.activityId,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.traitScores,
    required this.deltaProgress,
  });

  final int id;
  final String activityId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? score;
  final Map<String, dynamic> traitScores;
  final int deltaProgress;

  bool get isCompleted => completedAt != null;

  factory ActivityRun.fromJson(Map<String, dynamic> json) {
    return ActivityRun(
      id: json['id'] as int,
      activityId: json['activity_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      score: json['score'] as int?,
      traitScores: json['trait_scores'] as Map<String, dynamic>? ?? {},
      deltaProgress: json['delta_progress'] as int,
    );
  }
}

/// Activity model
class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.kind,
    this.estimatedMinutes,
    required this.active,
    required this.traitsWeight,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String kind; // 'quiz' or 'game'
  final int? estimatedMinutes;
  final bool active;
  final Map<String, dynamic> traitsWeight;
  final DateTime createdAt;

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      kind: json['kind'] as String,
      estimatedMinutes: json['estimated_minutes'] as int?,
      active: json['active'] as bool,
      traitsWeight: json['traits_weight'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
