import '../../domain/entities/roadmap.dart';
import '../../domain/repositories/roadmap_repository.dart';
import '../sources/mock_data.dart';

/// Mock implementation of RoadmapRepository
/// Extension point: Replace with database + AI-generated roadmaps in Phase-2
class RoadmapRepositoryImpl implements RoadmapRepository {
  RoadmapRepositoryImpl();

  // In-memory storage: key format "userId_careerId"
  final Map<String, Roadmap> _roadmaps = {};

  @override
  Future<Roadmap?> getRoadmap({
    required String userId,
    required String careerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final key = '${userId}_$careerId';
    return _roadmaps[key];
  }

  @override
  Future<List<Roadmap>> getUserRoadmaps({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return _roadmaps.values
        .where((roadmap) => roadmap.userId == userId)
        .toList();
  }

  @override
  Future<Roadmap> createRoadmap({
    required String userId,
    required String careerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Get template steps for this career
    final templateSteps = await getRoadmapTemplate(careerId: careerId);

    // Create user-specific copies of the steps
    final userSteps = templateSteps
        .map((step) => step.copyWith(completed: false))
        .toList();

    final roadmap = Roadmap(
      userId: userId,
      careerId: careerId,
      steps: userSteps,
      createdAt: DateTime.now(),
    );

    final key = '${userId}_$careerId';
    _roadmaps[key] = roadmap;

    return roadmap;
  }

  @override
  Future<RoadmapStep> updateStepCompletion({
    required String stepId,
    required bool completed,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    // Find the roadmap containing this step
    for (final entry in _roadmaps.entries) {
      final roadmap = entry.value;
      final stepIndex = roadmap.steps.indexWhere((s) => s.id == stepId);

      if (stepIndex != -1) {
        final updatedStep = roadmap.steps[stepIndex].copyWith(
          completed: completed,
        );

        // Update the roadmap with the modified step
        final updatedSteps = List<RoadmapStep>.from(roadmap.steps);
        updatedSteps[stepIndex] = updatedStep;

        _roadmaps[entry.key] = roadmap.copyWith(steps: updatedSteps);

        return updatedStep;
      }
    }

    throw Exception('Step not found');
  }

  @override
  Future<void> deleteRoadmap({
    required String userId,
    required String careerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final key = '${userId}_$careerId';
    _roadmaps.remove(key);
  }

  @override
  Future<List<RoadmapStep>> getRoadmapTemplate({
    required String careerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Return template from mock data, or generate a generic one
    if (MockData.roadmapTemplates.containsKey(careerId)) {
      return MockData.roadmapTemplates[careerId]!;
    }

    // Generic fallback template
    return [
      RoadmapStep(
        id: 'generic_1',
        careerId: careerId,
        title: 'Research the Career',
        description:
            'Learn about the career requirements, skills, and opportunities.',
        order: 1,
        category: RoadmapStepCategory.activity,
      ),
      RoadmapStep(
        id: 'generic_2',
        careerId: careerId,
        title: 'Develop Core Skills',
        description:
            'Take courses and practice skills relevant to this career.',
        order: 2,
        category: RoadmapStepCategory.skill,
      ),
      RoadmapStep(
        id: 'generic_3',
        careerId: careerId,
        title: 'Build a Portfolio',
        description: 'Create projects that showcase your abilities.',
        order: 3,
        category: RoadmapStepCategory.project,
      ),
      RoadmapStep(
        id: 'generic_4',
        careerId: careerId,
        title: 'Gain Experience',
        description:
            'Seek internships, volunteer work, or part-time positions.',
        order: 4,
        category: RoadmapStepCategory.experience,
      ),
      RoadmapStep(
        id: 'generic_5',
        careerId: careerId,
        title: 'Network with Professionals',
        description:
            'Connect with people in the field and learn from their experiences.',
        order: 5,
        category: RoadmapStepCategory.activity,
      ),
    ];
  }
}
