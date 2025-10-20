import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/gamification.dart';

/// Repository for gamification operations: XP, levels, streaks, badges
class GamificationRepository {
  GamificationRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _userId => _supabase.auth.currentUser!.id;

  // ============================================================================
  // Gamification Profile
  // ============================================================================

  /// Fetch user's gamification profile
  Future<GamificationProfile?> getProfile() async {
    final data = await _supabase
        .from('gamification_profiles')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    if (data == null) return null;
    return GamificationProfile.fromJson(data);
  }

  /// Award XP and update level
  /// Returns new profile after update and whether level increased
  Future<({GamificationProfile profile, bool leveledUp, int oldLevel})>
  awardXp({
    required String reason,
    required int amount,
  }) async {
    final currentProfile = await getProfile();

    if (currentProfile == null) {
      throw Exception(
        'Gamification profile not found. User may not be initialized.',
      );
    }

    final oldLevel = currentProfile.level;
    final newTotalXp = currentProfile.totalXp + amount;
    final newLevel = _calculateLevel(newTotalXp);

    final updated = await _supabase
        .from('gamification_profiles')
        .update({
          'total_xp': newTotalXp,
          'level': newLevel,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', _userId)
        .select()
        .single();

    // Log telemetry event
    await logEvent(
      'xp_awarded',
      metadata: {
        'reason': reason,
        'amount': amount,
        'old_level': oldLevel,
        'new_level': newLevel,
        'total_xp': newTotalXp,
      },
    );

    final newProfile = GamificationProfile.fromJson(updated);
    return (
      profile: newProfile,
      leveledUp: newLevel > oldLevel,
      oldLevel: oldLevel,
    );
  }

  /// Calculate level from total XP
  /// Formula: level = floor(sqrt(xp / 100)) + 1
  /// Level 1: 0 XP
  /// Level 2: 100 XP (1² × 100)
  /// Level 3: 400 XP (2² × 100)
  /// Level 5: 1,600 XP (4² × 100)
  /// Level 10: 8,100 XP (9² × 100)
  int _calculateLevel(int xp) {
    if (xp < 0) return 1;
    // Formula: level = floor(sqrt(xp / 100)) + 1
    // sqrt(xp/100) gives us the "level - 1"
    // e.g., 100 XP -> sqrt(1) = 1 -> level 2
    //       400 XP -> sqrt(4) = 2 -> level 3
    //       1,600 XP -> sqrt(16) = 4 -> level 5
    //       8,100 XP -> sqrt(81) = 9 -> level 10
    return math.sqrt(xp / 100.0).floor() + 1;
  }

  /// Update streak using database function
  /// This should be called once per day on first activity
  Future<void> updateStreak() async {
    await _supabase.rpc<void>('update_streak', params: {'p_user_id': _userId});
  }

  /// Update theme preference
  Future<void> updateTheme(String themeKey) async {
    await _supabase
        .from('gamification_profiles')
        .update({
          'theme_key': themeKey,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', _userId);
  }

  /// Update avatar configuration
  Future<void> updateAvatar(Map<String, dynamic> avatarConfig) async {
    await _supabase
        .from('gamification_profiles')
        .update({
          'avatar_config': avatarConfig,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', _userId);
  }

  // ============================================================================
  // Badges
  // ============================================================================

  /// Get all badges earned by user
  Future<List<Badge>> getBadges() async {
    final data = await _supabase
        .from('badges')
        .select()
        .eq('user_id', _userId)
        .order('earned_at', ascending: false);

    return data.map((json) => Badge.fromJson(json)).toList();
  }

  /// Award a badge to user
  /// Returns null if badge already earned (due to UNIQUE constraint)
  Future<Badge?> awardBadge(
    String badgeKey, {
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final data = await _supabase
          .from('badges')
          .insert({
            'user_id': _userId,
            'badge_key': badgeKey,
            'metadata': metadata,
          })
          .select()
          .single();

      return Badge.fromJson(data);
    } on PostgrestException catch (e) {
      // Unique constraint violation (badge already earned)
      if (e.code == '23505') return null;
      rethrow;
    }
  }

  /// Check if user has earned a specific badge
  Future<bool> hasBadge(String badgeKey) async {
    final data = await _supabase
        .from('badges')
        .select('id')
        .eq('user_id', _userId)
        .eq('badge_key', badgeKey)
        .maybeSingle();

    return data != null;
  }

  // ============================================================================
  // Telemetry Events
  // ============================================================================

  /// Log a telemetry event
  Future<void> logEvent(
    String eventKind, {
    Map<String, dynamic> metadata = const {},
  }) async {
    await _supabase.from('events').insert({
      'user_id': _userId,
      'event_kind': eventKind,
      'metadata': metadata,
    });
  }

  /// Get recent events for user (for analytics/debugging)
  Future<List<TelemetryEvent>> getRecentEvents({int limit = 50}) async {
    final data = await _supabase
        .from('events')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return data.map((json) => TelemetryEvent.fromJson(json)).toList();
  }

  // ============================================================================
  // Remote Config
  // ============================================================================

  /// Fetch XP constants from remote config
  Future<XpConstants> getXpConstants() async {
    final data = await _supabase
        .from('remote_config')
        .select('value')
        .eq('key', 'xp_constants')
        .single();

    return XpConstants.fromJson(data['value'] as Map<String, dynamic>);
  }

  /// Fetch any remote config value
  Future<dynamic> getRemoteConfig(String key) async {
    final data = await _supabase
        .from('remote_config')
        .select('value')
        .eq('key', key)
        .maybeSingle();

    return data?['value'];
  }

  /// Get copy tone setting
  Future<String> getCopyTone() async {
    final value = await getRemoteConfig('copy_tone');
    return value as String? ?? 'friendly';
  }

  /// Get feature flag
  Future<bool> getFeatureFlag(String key) async {
    final value = await getRemoteConfig(key);
    return value as bool? ?? false;
  }

  /// Get cluster labels (for career display)
  Future<Map<String, dynamic>> getClusterLabels() async {
    final value = await getRemoteConfig('cluster_labels');
    return value as Map<String, dynamic>? ?? {};
  }

  // ============================================================================
  // Leaderboards (optional)
  // ============================================================================

  /// Get top users by XP (global leaderboard)
  Future<List<GamificationProfile>> getLeaderboard({int limit = 10}) async {
    final data = await _supabase
        .from('gamification_profiles')
        .select()
        .order('total_xp', ascending: false)
        .limit(limit);

    return data.map((json) => GamificationProfile.fromJson(json)).toList();
  }

  // ============================================================================
  // A/B Testing (Experiments)
  // ============================================================================

  /// Get user's bucket assignment for an experiment
  /// If not assigned, randomly assign and persist
  Future<String> getExperimentBucket(String experimentKey) async {
    // Check existing assignment
    final existing = await _supabase
        .from('experiments')
        .select('bucket')
        .eq('key', experimentKey)
        .eq('user_id', _userId)
        .maybeSingle();

    if (existing != null) {
      return existing['bucket'] as String;
    }

    // Assign random bucket (A or B)
    final bucket = DateTime.now().millisecondsSinceEpoch.isEven ? 'A' : 'B';

    await _supabase.from('experiments').insert({
      'key': experimentKey,
      'user_id': _userId,
      'bucket': bucket,
    });

    return bucket;
  }
}
