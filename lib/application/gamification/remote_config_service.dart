import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/gamification_repository.dart';
import 'gamification_providers.dart';

/// Service for accessing remote configuration values
/// Provides convenience methods for common config patterns
class RemoteConfigService {
  RemoteConfigService(this._repository);

  final GamificationRepository _repository;

  // ============================================================================
  // XP Configuration
  // ============================================================================

  /// Get XP calculation constants
  Future<Map<String, dynamic>> getXpConfig() async {
    final constants = await _repository.getXpConstants();
    return constants.toJson();
  }

  /// Get base XP amount
  Future<int> getBaseXp() async {
    final constants = await _repository.getXpConstants();
    return constants.base;
  }

  // ============================================================================
  // UI/UX Configuration
  // ============================================================================

  /// Get copy tone (friendly, neutral, coach)
  Future<String> getCopyTone() async {
    return _repository.getCopyTone();
  }

  /// Check if animations are enabled globally
  Future<bool> areAnimationsEnabled() async {
    return _repository.getFeatureFlag('animations_enabled');
  }

  /// Check if haptics are enabled
  Future<bool> areHapticsEnabled() async {
    return _repository.getFeatureFlag('haptics_enabled');
  }

  /// Check if confetti animations are enabled
  Future<bool> isConfettiEnabled() async {
    return _repository.getFeatureFlag('confetti_enabled');
  }

  // ============================================================================
  // Career Configuration
  // ============================================================================

  /// Get career cluster labels with emojis
  Future<Map<String, dynamic>> getClusterLabels() async {
    return _repository.getClusterLabels();
  }

  /// Get label for specific cluster
  Future<Map<String, dynamic>?> getClusterLabel(String clusterKey) async {
    final labels = await getClusterLabels();
    return labels[clusterKey] as Map<String, dynamic>?;
  }

  // ============================================================================
  // Generic Configuration
  // ============================================================================

  /// Get any remote config value by key
  Future<dynamic> getValue(String key) async {
    return _repository.getRemoteConfig(key);
  }

  /// Get string value with fallback
  Future<String> getString(String key, {String fallback = ''}) async {
    final value = await getValue(key);
    return value as String? ?? fallback;
  }

  /// Get int value with fallback
  Future<int> getInt(String key, {int fallback = 0}) async {
    final value = await getValue(key);
    return value as int? ?? fallback;
  }

  /// Get bool value with fallback
  Future<bool> getBool(String key, {bool fallback = false}) async {
    final value = await getValue(key);
    return value as bool? ?? fallback;
  }

  /// Get map value with fallback
  Future<Map<String, dynamic>> getMap(
    String key, {
    Map<String, dynamic> fallback = const {},
  }) async {
    final value = await getValue(key);
    return value as Map<String, dynamic>? ?? fallback;
  }

  // ============================================================================
  // Badge Configuration
  // ============================================================================

  /// Get badge catalog from remote config
  Future<Map<String, dynamic>?> getBadgeCatalog() async {
    return await getMap('badge_catalog');
  }
}

// ============================================================================
// Riverpod Provider
// ============================================================================

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  final repository = ref.watch(gamificationRepositoryProvider);
  return RemoteConfigService(repository);
});
