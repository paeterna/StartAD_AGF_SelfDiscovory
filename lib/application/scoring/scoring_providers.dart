import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startad_agf_selfdiscovery/application/scoring/scoring_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the scoring service
final scoringServiceProvider = Provider<ScoringService>((ref) {
  return ScoringService(Supabase.instance.client);
});

/// Provider for user's career matches
final FutureProvider<List<CareerMatchWithDetails>> careerMatchesProvider =
    FutureProvider.autoDispose<List<CareerMatchWithDetails>>((ref) async {
      final scoringService = ref.watch(scoringServiceProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch matches
      final matches = await scoringService.getCareerMatches(
        userId: userId,
        limit: 20,
      );

      if (matches.isEmpty) {
        return [];
      }

      // Fetch career details
      final careerIds = matches.map((m) => m.careerId).toList();
      final careers = await scoringService.getCareers(careerIds);

      // Create a map for quick lookup
      final careersMap = {for (final c in careers) c.id: c};

      // Combine matches with career details
      return matches
          .map((match) {
            final career = careersMap[match.careerId];
            return CareerMatchWithDetails(match: match, career: career);
          })
          .where((m) => m.career != null)
          .toList();
    });

/// Provider for profile completeness
final FutureProvider<double> profileCompletenessProvider =
    FutureProvider.autoDispose<double>((
      ref,
    ) async {
      final scoringService = ref.watch(scoringServiceProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        return 0.0;
      }

      return scoringService.getProfileCompleteness(userId);
    });

/// Provider for user feature scores
final FutureProvider<List<UserFeatureScore>> userFeatureScoresProvider =
    FutureProvider.autoDispose<List<UserFeatureScore>>((ref) async {
      final scoringService = ref.watch(scoringServiceProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        return [];
      }

      return scoringService.getUserFeatureScores(userId);
    });

/// Combined career match with details
class CareerMatchWithDetails {
  const CareerMatchWithDetails({required this.match, required this.career});

  final CareerMatch match;
  final Career? career;

  String get title => career?.title ?? 'Unknown Career';
  String? get description => career?.description;
  List<String> get tags => career?.tags ?? [];
  String? get cluster => career?.cluster;
  double get similarity => match.similarity;
  double get confidence => match.confidence;
  List<FeatureContribution> get topFeatures => match.topFeatures;

  /// Get similarity as percentage
  double get similarityPercent => (similarity * 100).clamp(0, 100);
}
