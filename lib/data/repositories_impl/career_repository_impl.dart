import 'dart:async';
import 'dart:math';
import '../../domain/entities/career.dart';
import '../../domain/entities/career_cluster.dart';
import '../../domain/repositories/career_repository.dart';
import '../sources/mock_data.dart';

/// Mock implementation of CareerRepository with rule-based matching
/// Extension point: Replace with AI/ML-based matching in Phase-2
class CareerRepositoryImpl implements CareerRepository {
  CareerRepositoryImpl();

  // In-memory storage for saved careers per user
  final Map<String, Set<String>> _savedCareers = {};

  @override
  Future<List<Career>> getCareers() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockData.careers;
  }

  @override
  Future<List<Career>> getCareersByCluster({required String cluster}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockData.careers
        .where((career) => career.cluster == cluster)
        .toList();
  }

  @override
  Future<List<Career>> getMatchedCareers({
    required Map<String, int> traitScores,
    int minMatchScore = 0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Rule-based matching algorithm
    // Calculates match score based on overlap between user traits and career tags
    final matchedCareers = MockData.careers.map((career) {
      final matchScore = _calculateMatchScore(traitScores, career.tags);
      return career.copyWith(matchScore: matchScore);
    }).toList();

    // Filter by minimum score and sort by match score descending
    matchedCareers.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return matchedCareers
        .where((career) => career.matchScore >= minMatchScore)
        .toList();
  }

  /// Rule-based matching: calculates match score (0-100)
  /// based on weighted overlap between user traits and career tags
  int _calculateMatchScore(
    Map<String, int> traitScores,
    List<String> careerTags,
  ) {
    if (traitScores.isEmpty || careerTags.isEmpty) return 0;

    double totalScore = 0;
    int matchCount = 0;

    for (final tag in careerTags) {
      // Find matching or similar traits in user scores
      for (final entry in traitScores.entries) {
        final trait = entry.key;
        final score = entry.value;

        // Exact match
        if (trait.toLowerCase() == tag.toLowerCase()) {
          totalScore += score;
          matchCount++;
        }
        // Partial match (e.g., 'creative' matches 'creativity')
        else if (trait.toLowerCase().contains(tag.toLowerCase()) ||
            tag.toLowerCase().contains(trait.toLowerCase())) {
          totalScore += score * 0.7; // Partial match weight
          matchCount++;
        }
      }
    }

    if (matchCount == 0) {
      // No direct matches, give a base score based on average trait scores
      final avgTraitScore =
          traitScores.values.reduce((a, b) => a + b) / traitScores.length;
      return (avgTraitScore * 0.3).round().clamp(10, 40);
    }

    // Calculate weighted average and normalize to 0-100
    final averageScore = totalScore / matchCount;
    final normalizedScore = min(100, averageScore.round());

    return normalizedScore;
  }

  @override
  Future<Career?> getCareer({required String careerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final matches = MockData.careers.where((c) => c.id == careerId);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<List<Career>> searchCareers({required String query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();

    return MockData.careers.where((career) {
      return career.title.toLowerCase().contains(lowerQuery) ||
          career.description.toLowerCase().contains(lowerQuery) ||
          career.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
          career.cluster.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Career>> getSavedCareers({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final savedIds = _savedCareers[userId] ?? {};
    return MockData.careers.where((c) => savedIds.contains(c.id)).toList();
  }

  @override
  Future<void> saveCareer({
    required String userId,
    required String careerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    _savedCareers.putIfAbsent(userId, () => {});
    _savedCareers[userId]!.add(careerId);

    // In a real app, persist this to a database
  }

  @override
  Future<void> unsaveCareer({
    required String userId,
    required String careerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    _savedCareers[userId]?.remove(careerId);
  }

  @override
  Stream<List<CareerCluster>> watchTopClustersWithCareers({
    required String userId,
    int clusterLimit = 4,
    int careersPerCluster = 3,
  }) {
    // Mock implementation - returns a stream that emits mock data
    // In production, this would query Supabase career_matches table
    return Stream.periodic(const Duration(seconds: 1), (_) {
      // Group careers by cluster
      final careersByCluster = <String, List<Career>>{};

      for (final career in MockData.careers) {
        careersByCluster.putIfAbsent(career.cluster, () => []);
        // Add random match scores for mock data
        final mockMatchScore = 60 + Random().nextInt(40); // 60-100 range
        careersByCluster[career.cluster]!.add(
          career.copyWith(matchScore: mockMatchScore),
        );
      }

      // Sort careers within each cluster by match score
      for (final careers in careersByCluster.values) {
        careers.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      }

      // Create CareerCluster objects with top N careers
      final clusters = careersByCluster.entries.map((entry) {
        final topCareers = entry.value.take(careersPerCluster).toList();
        final maxScore = topCareers.isNotEmpty ? topCareers.first.matchScore : 0;

        return CareerCluster(
          id: entry.key.toLowerCase().replaceAll(' ', '_'),
          name: entry.key,
          description: 'Careers in ${entry.key}',
          icon: _getClusterIcon(entry.key),
          topCareers: topCareers,
          maxMatchScore: maxScore,
        );
      }).toList();

      // Sort clusters by max match score
      clusters.sort((a, b) => b.maxMatchScore.compareTo(a.maxMatchScore));

      // Return top N clusters
      return clusters.take(clusterLimit).toList();
    }).take(1); // Only emit once for mock
  }

  String _getClusterIcon(String cluster) {
    final icons = {
      'Technology': '💻',
      'Healthcare': '🏥',
      'Business': '💼',
      'Arts': '🎨',
      'Engineering': '⚙️',
      'Science': '🔬',
      'Education': '📚',
      'STEM': '🧬',
    };
    return icons[cluster] ?? '💼';
  }
}
