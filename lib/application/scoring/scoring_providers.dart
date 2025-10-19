import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startad_agf_selfdiscovery/application/scoring/scoring_service.dart';
import 'package:startad_agf_selfdiscovery/domain/entities/career_cluster.dart';
import 'package:startad_agf_selfdiscovery/domain/entities/career.dart'
    as domain;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the scoring service
final Provider<ScoringService> scoringServiceProvider =
    Provider<ScoringService>((ref) {
      return ScoringService(Supabase.instance.client);
    });

/// Provider for user's career matches
final AutoDisposeFutureProvider<List<CareerMatchWithDetails>>
careerMatchesProvider =
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
final AutoDisposeFutureProvider<double> profileCompletenessProvider =
    FutureProvider.autoDispose<double>((ref) async {
      final scoringService = ref.watch(scoringServiceProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        return 0.0;
      }

      return scoringService.getProfileCompleteness(userId);
    });

/// Provider for user feature scores
final AutoDisposeFutureProvider<List<UserFeatureScore>>
userFeatureScoresProvider = FutureProvider.autoDispose<List<UserFeatureScore>>((
  ref,
) async {
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
  String get careerId => match.careerId;
  double get similarity => match.similarity;
  double get confidence => match.confidence;
  List<FeatureContribution> get topFeatures => match.topFeatures;

  /// Get similarity as percentage
  double get similarityPercent => (similarity * 100).clamp(0, 100);

  /// Convert to Career entity
  domain.Career toCareer() {
    return domain.Career(
      id: careerId,
      title: title,
      description: description ?? '',
      tags: tags,
      matchScore: similarityPercent.round(),
      cluster: cluster ?? 'General',
    );
  }
}

/// Provider for career matches grouped by cluster
final AutoDisposeFutureProvider<List<CareerClusterGroup>>
careerClusterGroupsProvider =
    FutureProvider.autoDispose<List<CareerClusterGroup>>((ref) async {
      final matches = await ref.watch(careerMatchesProvider.future);

      if (matches.isEmpty) {
        return [];
      }

      // Group careers by cluster
      final Map<String, List<CareerMatchWithDetails>> clusterMap = {};

      for (final match in matches) {
        final cluster = match.cluster ?? 'General';
        if (!clusterMap.containsKey(cluster)) {
          clusterMap[cluster] = [];
        }
        clusterMap[cluster]!.add(match);
      }

      // Convert to CareerClusterGroup list
      final clusterGroups = <CareerClusterGroup>[];

      for (final entry in clusterMap.entries) {
        final clusterName = entry.key;
        final clusterMatches = entry.value;

        // Sort by match score (highest first)
        clusterMatches.sort(
          (a, b) => b.similarityPercent.compareTo(a.similarityPercent),
        );

        // Take top 3 careers for preview
        final topCareers = clusterMatches
            .take(3)
            .map((m) => m.toCareer())
            .toList();

        // Get max match score
        final maxScore = clusterMatches.first.similarityPercent.round();

        // Get cluster icon and description
        final clusterInfo = _getClusterInfo(clusterName);

        clusterGroups.add(
          CareerClusterGroup(
            id: clusterName.toLowerCase().replaceAll(' ', '_'),
            name: clusterName,
            description: clusterInfo.description,
            icon: clusterInfo.icon,
            topCareers: topCareers,
            maxMatchScore: maxScore,
          ),
        );
      }

      // Sort clusters by max match score
      clusterGroups.sort((a, b) => b.maxMatchScore.compareTo(a.maxMatchScore));

      // Return only top 4 clusters
      return clusterGroups.take(4).toList();
    });

/// Helper to get cluster icon and description
({String icon, String description}) _getClusterInfo(String clusterName) {
  final clusterLower = clusterName.toLowerCase();

  if (clusterLower.contains('tech') ||
      clusterLower.contains('software') ||
      clusterLower.contains('it') ||
      clusterLower.contains('computer')) {
    return (
      icon: '💻',
      description: 'Software, AI, Data, and Digital Innovation',
    );
  } else if (clusterLower.contains('health') ||
      clusterLower.contains('medical') ||
      clusterLower.contains('nursing')) {
    return (icon: '🏥', description: 'Medical, Nursing, and Health Services');
  } else if (clusterLower.contains('business') ||
      clusterLower.contains('finance') ||
      clusterLower.contains('management')) {
    return (icon: '💼', description: 'Business, Finance, and Management');
  } else if (clusterLower.contains('engineering') ||
      clusterLower.contains('engineer')) {
    return (icon: '⚙️', description: 'Engineering and Technical Professions');
  } else if (clusterLower.contains('art') ||
      clusterLower.contains('design') ||
      clusterLower.contains('creative')) {
    return (icon: '🎨', description: 'Creative Arts and Design');
  } else if (clusterLower.contains('education') ||
      clusterLower.contains('teaching')) {
    return (icon: '📚', description: 'Education and Teaching');
  } else if (clusterLower.contains('science') ||
      clusterLower.contains('research')) {
    return (icon: '🔬', description: 'Science and Research');
  } else if (clusterLower.contains('law') || clusterLower.contains('legal')) {
    return (icon: '⚖️', description: 'Law and Legal Services');
  } else {
    return (icon: '🌟', description: 'General Careers');
  }
}
