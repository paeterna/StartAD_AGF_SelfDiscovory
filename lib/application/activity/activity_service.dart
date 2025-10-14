import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing activity runs and discovery progress
/// Implements the data contract flow:
/// 1. Insert activity_run → Trigger updates discovery_progress
/// 2. Compute feature scores → Call upsert_feature_ema
/// 3. Background job → Update career matches
class ActivityService {
  ActivityService(this._supabase);

  final SupabaseClient _supabase;

  /// Get current authenticated user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  static const List<_SeededActivity> _defaultSeededActivities = [
    _SeededActivity(
      id: '11111111-2222-3333-8888-555555555555',
      slug: 'quiz_riasec_mini',
      title: 'Career Interest Explorer',
      kind: 'quiz',
      estimatedMinutes: 5,
      traitsWeight: {'creativity': 2, 'curiosity': 1},
    ),
    _SeededActivity(
      id: '66666666-7777-4444-9999-000000000000',
      slug: 'quiz_ipip50',
      title: 'Personality Traits Assessment',
      kind: 'quiz',
      estimatedMinutes: 10,
      traitsWeight: {'communication': 1, 'adaptability': 1},
    ),
    _SeededActivity(
      id: '22222222-3333-4444-5555-666666666666',
      slug: 'memory_match',
      title: 'Memory Match',
      kind: 'game',
      estimatedMinutes: 7,
      traitsWeight: {'cognition_memory': 2, 'cognition_attention': 1},
    ),
  ];

  /// Start an activity run
  /// Returns the run ID
  Future<int> startActivityRun({required String activityId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final resolvedActivityId = await _resolveActivityId(activityId);

    final response = await _supabase
        .from('activity_runs')
        .insert({
          'user_id': userId,
          'activity_id': resolvedActivityId,
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
    try {
      await _ensureSeededActivities(kind: kind);

      final response = await _buildActivitiesQuery(
        kind,
        activeOnly,
      ).order('created_at', ascending: false);

      final activities = (response as List<dynamic>)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList();

      return _mergeSeededActivities(activities, kind);
    } on PostgrestException catch (error) {
      developer.log(
        'Failed to load activities',
        name: 'ActivityService',
        error: error,
        stackTrace: StackTrace.current,
      );

      // Older schemas may not include created_at or traits_weight; retry without them.
      if (error.code == '42703') {
        try {
          final fallbackResponse = await _buildActivitiesQuery(
            kind,
            activeOnly,
          );
          final activities = (fallbackResponse as List<dynamic>)
              .map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList();

          return _mergeSeededActivities(activities, kind);
        } on PostgrestException catch (fallbackError) {
          developer.log(
            'Fallback activities query also failed',
            name: 'ActivityService',
            error: fallbackError,
            stackTrace: StackTrace.current,
          );
          return _buildSyntheticActivities(kind);
        }
      }

      if (_shouldReturnSynthetic(error.code)) {
        developer.log(
          'Returning synthetic activities due to Postgrest error ${error.code}',
          name: 'ActivityService',
        );
        return _buildSyntheticActivities(kind);
      }

      rethrow;
    }
  }

  /// Get a specific activity by ID
  Future<Activity?> getActivity(String activityId) async {
    final resolvedId = await _resolveActivityId(activityId);

    try {
      final response = await _supabase
          .from('activities')
          .select(
            'id, title, kind, estimated_minutes, active, traits_weight, created_at',
          )
          .eq('id', resolvedId)
          .maybeSingle();

      if (response == null) {
        return _findSeededActivityById(resolvedId)?.toActivity();
      }

      return Activity.fromJson(response);
    } on PostgrestException catch (error) {
      developer.log(
        'Failed to load activity $activityId',
        name: 'ActivityService',
        error: error,
        stackTrace: StackTrace.current,
      );

      if (error.code == '42703') {
        try {
          final fallback = await _supabase
              .from('activities')
              .select('*')
              .eq('id', resolvedId)
              .maybeSingle();

          if (fallback == null) {
            return _findSeededActivityById(resolvedId)?.toActivity();
          }

          return Activity.fromJson(fallback);
        } on PostgrestException catch (fallbackError) {
          developer.log(
            'Fallback activity query also failed',
            name: 'ActivityService',
            error: fallbackError,
            stackTrace: StackTrace.current,
          );
          return _findSyntheticActivity(activityId);
        }
      }

      if (_shouldReturnSynthetic(error.code)) {
        developer.log(
          'Returning synthetic activity for $activityId due to Postgrest error ${error.code}',
          name: 'ActivityService',
        );
        return _findSyntheticActivity(activityId);
      }

      rethrow;
    }
  }

  PostgrestFilterBuilder<dynamic> _buildActivitiesQuery(
    String? kind,
    bool activeOnly,
  ) {
    var query = _supabase.from('activities').select('*');

    if (activeOnly) {
      query = query.eq('active', true);
    }

    if (kind != null) {
      query = query.eq('kind', kind);
    }

    return query;
  }

  bool _shouldReturnEmptyList(String? code) {
    // 42P01: undefined table, 42501: insufficient privilege, PGRST302: RLS violation
    return code == '42P01' || code == '42501' || code == 'PGRST302';
  }

  bool _shouldReturnSynthetic(String? code) {
    return _shouldReturnEmptyList(code) || code == null || code.isEmpty;
  }

  List<Activity> _buildSyntheticActivities(String? kind) {
    final seeds = kind == null
        ? _defaultSeededActivities
        : _defaultSeededActivities
              .where((activity) => activity.kind == kind)
              .toList(growable: false);

    return seeds.map((seed) => seed.toActivity()).toList(growable: false);
  }

  Activity? _findSyntheticActivity(String activityId) {
    final seedBySlug = _findSeededActivityBySlug(activityId);
    if (seedBySlug != null) {
      return seedBySlug.toActivity();
    }
    final seedById = _findSeededActivityById(activityId);
    return seedById?.toActivity();
  }

  Future<void> _ensureSeededActivities({String? kind}) async {
    final seeds = kind == null
        ? _defaultSeededActivities
        : _defaultSeededActivities.where((seed) => seed.kind == kind);

    for (final seed in seeds) {
      try {
        await _ensureSeededActivity(seed);
      } on PostgrestException {
        // Already logged inside _ensureSeededActivity; continue with other seeds.
      }
    }
  }

  Future<void> _ensureSeededActivity(_SeededActivity seed) async {
    try {
      // First check if activity exists
      final existing = await _supabase
          .from('activities')
          .select('id')
          .eq('id', seed.id)
          .maybeSingle();

      if (existing != null) {
        // Activity exists, update it
        await _supabase
            .from('activities')
            .update({
              'title': seed.title,
              'kind': seed.kind,
              'estimated_minutes': seed.estimatedMinutes,
              'traits_weight': seed.traitsWeight,
              'active': true,
            })
            .eq('id', seed.id);
      } else {
        // Activity doesn't exist, insert it
        await _supabase.from('activities').insert({
          'id': seed.id,
          'title': seed.title,
          'kind': seed.kind,
          'estimated_minutes': seed.estimatedMinutes,
          'traits_weight': seed.traitsWeight,
          'active': true,
        });
      }
    } on PostgrestException catch (error) {
      // Log but don't fail - the activity might already exist from a previous seed
      developer.log(
        'Failed to ensure seeded activity ${seed.slug}: ${error.code} ${error.message}',
        name: 'ActivityService',
        error: error,
        stackTrace: StackTrace.current,
      );
      // Don't rethrow - this is not critical for the app to function
    }
  }

  Future<String> _resolveActivityId(String activityIdOrSlug) async {
    if (_isUuid(activityIdOrSlug)) {
      return activityIdOrSlug;
    }

    final seed = _findSeededActivityBySlug(activityIdOrSlug);
    if (seed == null) {
      return activityIdOrSlug;
    }

    try {
      await _ensureSeededActivity(seed);
    } on PostgrestException {
      // Already logged in _ensureSeededActivity; allow fall-through to return ID
    }
    return seed.id;
  }

  List<Activity> _mergeSeededActivities(
    List<Activity> existing,
    String? kind,
  ) {
    final ids = existing.map((activity) => activity.id).toSet();
    final seeds = kind == null
        ? _defaultSeededActivities
        : _defaultSeededActivities.where((seed) => seed.kind == kind);

    final merged = List<Activity>.from(existing);
    for (final seed in seeds) {
      if (!ids.contains(seed.id)) {
        merged.add(seed.toActivity());
      }
    }
    return merged;
  }

  _SeededActivity? _findSeededActivityBySlug(String slug) {
    for (final seed in _defaultSeededActivities) {
      if (seed.slug == slug) {
        return seed;
      }
    }
    return null;
  }

  _SeededActivity? _findSeededActivityById(String id) {
    for (final seed in _defaultSeededActivities) {
      if (seed.id == id) {
        return seed;
      }
    }
    return null;
  }

  bool _isUuid(String value) {
    const pattern =
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$';
    return RegExp(pattern).hasMatch(value);
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
    this.traitsWeight = const {},
    this.createdAt,
  });

  final String id;
  final String title;
  final String kind; // 'quiz' or 'game'
  final int? estimatedMinutes;
  final bool active;
  final Map<String, dynamic> traitsWeight;
  final DateTime? createdAt;

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      kind: json['kind'] as String,
      estimatedMinutes: json['estimated_minutes'] as int?,
      active: json['active'] as bool? ?? true,
      traitsWeight: _parseTraitsWeight(json['traits_weight']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static Map<String, dynamic> _parseTraitsWeight(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class _SeededActivity {
  const _SeededActivity({
    required this.id,
    required this.slug,
    required this.title,
    required this.kind,
    required this.estimatedMinutes,
    this.traitsWeight = const <String, dynamic>{},
  });

  final String id;
  final String slug;
  final String title;
  final String kind;
  final int estimatedMinutes;
  final Map<String, dynamic> traitsWeight;

  Activity toActivity() {
    return Activity(
      id: id,
      title: title,
      kind: kind,
      estimatedMinutes: estimatedMinutes,
      active: true,
      traitsWeight: traitsWeight,
      createdAt: DateTime.now(),
    );
  }
}
