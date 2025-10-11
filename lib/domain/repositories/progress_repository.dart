import '../value_objects/progress.dart';

/// Progress repository interface
abstract class ProgressRepository {
  /// Get user's discovery progress
  Future<DiscoveryProgress> getUserProgress({required String userId});

  /// Update user's progress
  Future<DiscoveryProgress> updateProgress({
    required String userId,
    required int deltaProgress,
  });

  /// Reset user's progress
  Future<DiscoveryProgress> resetProgress({required String userId});
}
