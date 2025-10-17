import '../../domain/repositories/progress_repository.dart';
import '../../domain/value_objects/progress.dart';

/// Mock implementation of ProgressRepository
class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl();

  // In-memory storage
  final Map<String, DiscoveryProgress> _progress = {};

  @override
  Future<DiscoveryProgress> getUserProgress({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    // Return existing progress or create new one
    return _progress.putIfAbsent(
      userId,
      () => DiscoveryProgress(
        userId: userId,
        percent: 0,
        streakDays: 0,
        lastActivityDate: null,
      ),
    );
  }

  @override
  Future<DiscoveryProgress> updateProgress({
    required String userId,
    required int deltaProgress,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final currentProgress = await getUserProgress(userId: userId);
    final updatedProgress = currentProgress.addProgress(deltaProgress);

    _progress[userId] = updatedProgress;

    return updatedProgress;
  }

  @override
  Future<DiscoveryProgress> resetProgress({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final resetProgress = DiscoveryProgress(
      userId: userId,
      percent: 0,
      streakDays: 0,
      lastActivityDate: null,
    );

    _progress[userId] = resetProgress;

    return resetProgress;
  }
}
