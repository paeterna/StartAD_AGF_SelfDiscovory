import '../entities/career.dart';

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

  /// Get a specific career by ID
  Future<Career?> getCareer({required String careerId});

  /// Search careers by keyword
  Future<List<Career>> searchCareers({required String query});

  /// Get user's saved/favorited careers
  Future<List<Career>> getSavedCareers({required String userId});

  /// Save/favorite a career
  Future<void> saveCareer({
    required String userId,
    required String careerId,
  });

  /// Remove career from saved list
  Future<void> unsaveCareer({
    required String userId,
    required String careerId,
  });
}
