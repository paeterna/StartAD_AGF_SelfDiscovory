import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../data/repositories_impl/ai_insight_repository_impl.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/repositories/ai_insight_repository.dart';
import 'ai_insight_service.dart';

/// Provider for AI insight repository
final aiInsightRepositoryProvider = Provider<AIInsightRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AIInsightRepositoryImpl(supabase);
});

/// Provider for AI insight service
final aiInsightServiceProvider = Provider<AIInsightService>((ref) {
  final repository = ref.watch(aiInsightRepositoryProvider);
  return AIInsightService(repository);
});

/// Provider for latest AI insight for current user
final latestAIInsightProvider = FutureProvider<AIInsight?>((ref) async {
  final service = ref.watch(aiInsightServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return null;
  }

  return await service.getLatestInsight(userId);
});

/// Provider for all AI insights for current user
final allAIInsightsProvider = FutureProvider<List<AIInsight>>((ref) async {
  final service = ref.watch(aiInsightServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return [];
  }

  return await service.getAllInsights(userId);
});

/// Provider for AI insight eligibility check
final aiInsightEligibilityProvider = FutureProvider<InsightEligibility>((ref) async {
  final service = ref.watch(aiInsightServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return const InsightEligibility(
      canGenerate: false,
      reason: 'Not logged in',
      assessments: 0,
      activities: 0,
      features: 0,
    );
  }

  return await service.checkEligibility(userId);
});

/// State notifier for AI insight generation
class AIInsightGenerationNotifier extends StateNotifier<AsyncValue<AIInsight?>> {
  AIInsightGenerationNotifier(this._service, this._userId)
      : super(const AsyncValue.data(null));

  final AIInsightService _service;
  final String? _userId;

  /// Generate a new AI insight
  Future<void> generateInsight() async {
    if (_userId == null) {
      state = AsyncValue.error(
        Exception('User not logged in'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final insight = await _service.generateInsight(_userId);
      state = AsyncValue.data(insight);
    } on InsufficientDataException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reset the state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for AI insight generation notifier
final aiInsightGenerationProvider =
    StateNotifierProvider<AIInsightGenerationNotifier, AsyncValue<AIInsight?>>(
  (ref) {
    final service = ref.watch(aiInsightServiceProvider);
    final userId = ref.watch(currentUserIdProvider);
    return AIInsightGenerationNotifier(service, userId);
  },
);

/// Helper provider to get current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.currentUser?.id;
});

