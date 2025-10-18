import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories_impl/ai_roadmap_repository_impl.dart';
import '../../domain/entities/ai_career_roadmap.dart';
import '../../domain/repositories/ai_roadmap_repository.dart';
import '../analytics/analytics_service.dart';
import 'roadmap_service.dart';

/// Provider for AIRoadmapRepository
final aiRoadmapRepositoryProvider = Provider<AIRoadmapRepository>((ref) {
  return AIRoadmapRepositoryImpl(Supabase.instance.client);
});

/// Provider to watch user's roadmap summaries in real-time
final AutoDisposeStreamProvider<List<AICareerRoadmapSummary>> userRoadmapsStreamProvider = StreamProvider.autoDispose<List<AICareerRoadmapSummary>>((ref) {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.watchUserRoadmaps(userId);
});

/// Provider to get roadmap count for a user
final AutoDisposeFutureProvider<int> userRoadmapCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return 0;
  }

  return repository.getUserRoadmapCount(userId);
});

/// Provider to check if user has a roadmap for a specific career
final AutoDisposeFutureProviderFamily<bool, String> hasRoadmapForCareerProvider = FutureProvider.autoDispose.family<bool, String>((ref, careerId) async {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return false;
  }

  return repository.hasRoadmapForCareer(userId: userId, careerId: careerId);
});

/// Provider to get a specific roadmap by ID
final AutoDisposeFutureProviderFamily<AICareerRoadmap?, String> roadmapByIdProvider = FutureProvider.autoDispose.family<AICareerRoadmap?, String>((ref, roadmapId) async {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  return repository.getRoadmapById(roadmapId);
});

/// Provider to get roadmap for a specific career
final AutoDisposeFutureProviderFamily<AICareerRoadmap?, String> roadmapForCareerProvider = FutureProvider.autoDispose.family<AICareerRoadmap?, String>((ref, careerId) async {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return null;
  }

  return repository.getRoadmapForCareer(userId: userId, careerId: careerId);
});

/// State notifier for roadmap generation
class RoadmapGenerationNotifier extends StateNotifier<AsyncValue<String>> {
  RoadmapGenerationNotifier(this._repository) : super(const AsyncValue.data(''));

  final AIRoadmapRepository _repository;

  /// Generate a roadmap for a career
  Future<String?> generateRoadmap({
    required String careerId,
    String? locale,
  }) async {
    state = const AsyncValue.loading();
    try {
      final roadmapId = await _repository.generateRoadmap(
        careerId: careerId,
        locale: locale,
      );
      state = AsyncValue.data(roadmapId);
      return roadmapId;
    } on RoadmapLimitExceededException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    } on RoadmapAlreadyExistsException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    } on AIGenerationFailedException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Delete a roadmap
  Future<bool> deleteRoadmap(String roadmapId) async {
    try {
      await _repository.deleteRoadmap(roadmapId);
      return true;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data('');
  }
}

/// Provider for roadmap generation state
final AutoDisposeStateNotifierProvider<RoadmapGenerationNotifier, AsyncValue<String>> roadmapGenerationProvider = StateNotifierProvider.autoDispose<RoadmapGenerationNotifier, AsyncValue<String>>((ref) {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  return RoadmapGenerationNotifier(repository);
});

/// Provider for RoadmapService (handles complete generation flow)
final roadmapServiceProvider = Provider<RoadmapService>((ref) {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final analyticsService = MockAnalyticsService(); // Replace with actual analytics provider
  return RoadmapService(
    roadmapRepository: repository,
    analyticsService: analyticsService,
  );
});
