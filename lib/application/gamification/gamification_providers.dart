import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../domain/entities/gamification.dart';

// ============================================================================
// Repository Provider
// ============================================================================

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final supabase = Supabase.instance.client;
  return GamificationRepository(supabase);
});

// ============================================================================
// Gamification Profile State
// ============================================================================

/// User's gamification profile (XP, level, streaks, theme)
final AutoDisposeStreamProvider<GamificationProfile?>
gamificationProfileProvider = StreamProvider.autoDispose<GamificationProfile?>((
  ref,
) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value(null);
  }

  return supabase
      .from('gamification_profiles')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .map((rows) {
        if (rows.isEmpty) return null;
        return GamificationProfile.fromJson(rows.first);
      });
});

/// Synchronous getter for gamification profile (may be stale)
final AutoDisposeFutureProvider<GamificationProfile?>
gamificationProfileSyncProvider =
    FutureProvider.autoDispose<GamificationProfile?>((ref) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getProfile();
    });

// ============================================================================
// Badges State
// ============================================================================

/// User's earned badges
final AutoDisposeStreamProvider<List<Badge>> badgesProvider =
    StreamProvider.autoDispose<List<Badge>>((ref) {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return Stream.value([]);
      }

      return supabase
          .from('badges')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('earned_at', ascending: false)
          .map((rows) => rows.map((json) => Badge.fromJson(json)).toList());
    });

/// Check if user has specific badge
final AutoDisposeFutureProviderFamily<bool, String> hasBadgeProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, badgeKey) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.hasBadge(badgeKey);
    });

// ============================================================================
// Remote Config State
// ============================================================================

/// XP calculation constants from remote config
final AutoDisposeFutureProvider<XpConstants> xpConstantsProvider =
    FutureProvider.autoDispose<XpConstants>((ref) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getXpConstants();
    });

/// Copy tone setting (friendly, neutral, coach)
final AutoDisposeFutureProvider<String> copyToneProvider =
    FutureProvider.autoDispose<String>((ref) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getCopyTone();
    });

/// Generic remote config value
final AutoDisposeFutureProviderFamily<dynamic, String> remoteConfigProvider =
    FutureProvider.autoDispose.family<dynamic, String>((ref, key) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getRemoteConfig(key);
    });

/// Feature flags
final AutoDisposeFutureProviderFamily<bool, String> featureFlagProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, key) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getFeatureFlag(key);
    });

/// Cluster labels (for career display)
final AutoDisposeFutureProvider<Map<String, dynamic>> clusterLabelsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getClusterLabels();
    });

// ============================================================================
// XP and Level Actions
// ============================================================================

/// Award XP to user
/// Call this after completing activities (games, quizzes, roadmap steps)
/// Returns record with profile, leveledUp status, and oldLevel
final awardXpProvider = Provider<
  Future<({GamificationProfile profile, bool leveledUp, int oldLevel})>
  Function({required String reason, required int amount})
>((ref) {
  return ({required String reason, required int amount}) async {
    final repo = ref.read(gamificationRepositoryProvider);
    final result = await repo.awardXp(reason: reason, amount: amount);

    // Invalidate profile cache to trigger UI update
    ref.invalidate(gamificationProfileProvider);
    ref.invalidate(gamificationProfileSyncProvider);

    return result;
  };
});

// ============================================================================
// Streak Actions
// ============================================================================

/// Update daily streak (call once per day on first activity)
final updateStreakProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repo = ref.read(gamificationRepositoryProvider);
    await repo.updateStreak();

    // Invalidate profile cache to trigger UI update
    ref.invalidate(gamificationProfileProvider);
    ref.invalidate(gamificationProfileSyncProvider);
  };
});

// ============================================================================
// Badge Actions
// ============================================================================

/// Award a badge to user
final awardBadgeProvider =
    Provider<Future<Badge?> Function(String, {Map<String, dynamic> metadata})>((
      ref,
    ) {
      return (
        String badgeKey, {
        Map<String, dynamic> metadata = const {},
      }) async {
        final repo = ref.read(gamificationRepositoryProvider);
        final badge = await repo.awardBadge(badgeKey, metadata: metadata);

        // Invalidate badges cache to trigger UI update
        ref.invalidate(badgesProvider);

        return badge;
      };
    });

// ============================================================================
// Telemetry Actions
// ============================================================================

/// Log telemetry event
final logEventProvider =
    Provider<Future<void> Function(String, {Map<String, dynamic> metadata})>((
      ref,
    ) {
      return (
        String eventKind, {
        Map<String, dynamic> metadata = const {},
      }) async {
        final repo = ref.read(gamificationRepositoryProvider);
        await repo.logEvent(eventKind, metadata: metadata);
      };
    });

// ============================================================================
// Theme Actions
// ============================================================================

/// Update user's theme preference
final updateThemeProvider = Provider<Future<void> Function(String)>((ref) {
  return (String themeKey) async {
    final repo = ref.read(gamificationRepositoryProvider);
    await repo.updateTheme(themeKey);

    // Invalidate profile cache to trigger UI update
    ref.invalidate(gamificationProfileProvider);
    ref.invalidate(gamificationProfileSyncProvider);
  };
});

/// Update user's avatar configuration
final updateAvatarProvider =
    Provider<Future<void> Function(Map<String, dynamic>)>((ref) {
      return (Map<String, dynamic> avatarConfig) async {
        final repo = ref.read(gamificationRepositoryProvider);
        await repo.updateAvatar(avatarConfig);

        // Invalidate profile cache to trigger UI update
        ref.invalidate(gamificationProfileProvider);
        ref.invalidate(gamificationProfileSyncProvider);
      };
    });

// ============================================================================
// Leaderboard State
// ============================================================================

/// Global XP leaderboard
final AutoDisposeFutureProviderFamily<List<GamificationProfile>, int>
leaderboardProvider = FutureProvider.autoDispose
    .family<List<GamificationProfile>, int>((ref, limit) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getLeaderboard(limit: limit);
    });

// ============================================================================
// A/B Testing
// ============================================================================

/// Get user's experiment bucket assignment
final AutoDisposeFutureProviderFamily<String, String> experimentBucketProvider =
    FutureProvider.autoDispose.family<String, String>((
      ref,
      experimentKey,
    ) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getExperimentBucket(experimentKey);
    });
