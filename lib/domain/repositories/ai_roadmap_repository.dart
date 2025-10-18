import '../entities/ai_career_roadmap.dart';

/// Repository for AI-generated career roadmaps
abstract class AIRoadmapRepository {
  /// Generate a new AI roadmap for a career
  ///
  /// Returns the roadmap ID on success.
  /// Throws exceptions:
  /// - RoadmapLimitExceededException: User has 3 roadmaps already
  /// - RoadmapAlreadyExistsException: Roadmap for this career exists
  /// - AIGenerationFailedException: AI generation failed
  Future<String> generateRoadmap({
    required String careerId,
    String? locale,
  });

  /// Get detailed roadmap by ID
  Future<AICareerRoadmap?> getRoadmapById(String roadmapId);

  /// Get roadmap for a specific career (if exists)
  Future<AICareerRoadmap?> getRoadmapForCareer({
    required String userId,
    required String careerId,
  });

  /// Check if user has a roadmap for a career
  Future<bool> hasRoadmapForCareer({
    required String userId,
    required String careerId,
  });

  /// Get all user's roadmap summaries
  ///
  /// Returns a list of roadmap summaries (without full step details)
  /// sorted by generation date (newest first)
  Stream<List<AICareerRoadmapSummary>> watchUserRoadmaps(String userId);

  /// Get count of user's roadmaps
  Future<int> getUserRoadmapCount(String userId);

  /// Delete a roadmap
  ///
  /// This will cascade delete all phases and steps
  Future<void> deleteRoadmap(String roadmapId);

  /// Delete roadmap by career ID
  Future<void> deleteRoadmapForCareer({
    required String userId,
    required String careerId,
  });
}

/// Exception thrown when user tries to generate more than 3 roadmaps
class RoadmapLimitExceededException implements Exception {
  RoadmapLimitExceededException(this.currentCount);

  final int currentCount;

  @override
  String toString() =>
      'RoadmapLimitExceededException: User already has $currentCount roadmaps (max 3)';
}

/// Exception thrown when user tries to generate a duplicate roadmap
class RoadmapAlreadyExistsException implements Exception {
  RoadmapAlreadyExistsException(this.careerId);

  final String careerId;

  @override
  String toString() =>
      'RoadmapAlreadyExistsException: Roadmap for career $careerId already exists';
}

/// Exception thrown when AI generation fails
class AIGenerationFailedException implements Exception {
  AIGenerationFailedException(this.message);

  final String message;

  @override
  String toString() => 'AIGenerationFailedException: $message';
}
