import '../entities/career.dart';
import '../entities/career_cluster.dart';

/// Career repository interface
/// Extension point: Replace rule-based matching with AI/ML in Phase-2
abstract class CareerRepository {
  /// Get all careers
  Future<List<Career>> getCareers();

  /// Get careers filtered by cluster
  Future<List<Career>> getCareersByCluster({required String cluster});

  /// Get careers matching user's trait scores
  /// Uses rule-based matching in Phase-1, can be replaced with ML model
  Future<List<Career>> getMatchedCareers({
    required Map<String, int> traitScores,
    int minMatchScore = 0,
  });

  /// Get top career clusters with top 3 careers each (cluster-first view)
  ///
  /// Returns the top 4 clusters ranked by the highest match score in each cluster.
  /// Each cluster contains its top 3 careers sorted by match score.
  /// Used for the new cluster-first careers page design.
  Stream<List<CareerClusterGroup>> watchTopClustersWithCareers({
    required String userId,
    int clusterLimit = 4,
    int careersPerCluster = 3,
  });

  /// Get a specific career by ID
  Future<Career?> getCareer({required String careerId});

  /// Search careers by keyword
  Future<List<Career>> searchCareers({required String query});

  /// Get user's saved/favorited careers
  Future<List<Career>> getSavedCareers({required String userId});

  /// Save/favorite a career
  Future<void> saveCareer({required String userId, required String careerId});

  /// Remove career from saved list
  Future<void> unsaveCareer({required String userId, required String careerId});
}
