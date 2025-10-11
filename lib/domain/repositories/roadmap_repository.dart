import '../entities/roadmap.dart';

/// Roadmap repository interface
/// Extension point: Replace mock with database + AI-generated roadmaps in Phase-2
abstract class RoadmapRepository {
  /// Get roadmap for a specific career
  Future<Roadmap?> getRoadmap({
    required String userId,
    required String careerId,
  });

  /// Get all roadmaps for a user
  Future<List<Roadmap>> getUserRoadmaps({required String userId});

  /// Create a new roadmap for a career
  Future<Roadmap> createRoadmap({
    required String userId,
    required String careerId,
  });

  /// Update a roadmap step completion status
  Future<RoadmapStep> updateStepCompletion({
    required String stepId,
    required bool completed,
  });

  /// Delete a roadmap
  Future<void> deleteRoadmap({
    required String userId,
    required String careerId,
  });

  /// Get roadmap template for a career (used to generate user roadmaps)
  Future<List<RoadmapStep>> getRoadmapTemplate({required String careerId});
}
