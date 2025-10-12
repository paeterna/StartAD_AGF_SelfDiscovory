import '../../domain/entities/assessment.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../sources/mock_data.dart';

/// Mock implementation of AssessmentRepository
/// Extension point: Replace with ML-based scoring in Phase-2
class AssessmentRepositoryImpl implements AssessmentRepository {
  AssessmentRepositoryImpl();

  // In-memory storage
  final Map<String, Assessment> _assessments = {};
  final Map<String, List<String>> _userAssessments = {}; // userId -> assessmentIds

  @override
  Future<List<Assessment>> getUserAssessments({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final assessmentIds = _userAssessments[userId] ?? [];
    return assessmentIds
        .map((id) => _assessments[id])
        .whereType<Assessment>()
        .toList();
  }

  @override
  Future<Assessment?> getAssessment({required String assessmentId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _assessments[assessmentId];
  }

  @override
  Future<Assessment> saveAssessment({
    required String userId,
    required Map<String, int> traitScores,
    required AssessmentType type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Calculate progress boost based on assessment type
    int deltaProgress = 0;
    switch (type) {
      case AssessmentType.onboarding:
        deltaProgress = 10;
        break;
      case AssessmentType.quiz:
        deltaProgress = 5;
        break;
      case AssessmentType.game:
        deltaProgress = 8;
        break;
    }

    final assessmentId = 'assessment_${DateTime.now().millisecondsSinceEpoch}';
    final assessment = Assessment(
      id: assessmentId,
      userId: userId,
      takenAt: DateTime.now(),
      traitScores: traitScores,
      deltaProgress: deltaProgress,
      type: type,
      completed: true,
    );

    _assessments[assessmentId] = assessment;
    _userAssessments.putIfAbsent(userId, () => []);
    _userAssessments[userId]!.add(assessmentId);

    return assessment;
  }

  @override
  Future<Assessment> updateAssessment({
    required String assessmentId,
    Map<String, int>? traitScores,
    bool? completed,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final existing = _assessments[assessmentId];
    if (existing == null) {
      throw Exception('Assessment not found');
    }

    final updated = existing.copyWith(
      traitScores: traitScores ?? existing.traitScores,
      completed: completed ?? existing.completed,
    );

    _assessments[assessmentId] = updated;
    return updated;
  }

  @override
  Future<Map<String, int>> getUserTraitScores({required String userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final assessments = await getUserAssessments(userId: userId);
    final completedAssessments =
        assessments.where((a) => a.completed).toList();

    if (completedAssessments.isEmpty) {
      return {};
    }

    // Aggregate scores: average across all completed assessments
    final Map<String, List<int>> traitScoresList = {};

    for (final assessment in completedAssessments) {
      for (final entry in assessment.traitScores.entries) {
        traitScoresList.putIfAbsent(entry.key, () => []);
        traitScoresList[entry.key]!.add(entry.value);
      }
    }

    // Calculate averages
    final Map<String, int> aggregatedScores = {};
    for (final entry in traitScoresList.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      aggregatedScores[entry.key] = avg.round();
    }

    return aggregatedScores;
  }

  @override
  Future<List<AssessmentTemplate>> getAvailableAssessments({
    AssessmentType? type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (type == null) {
      return MockData.assessmentTemplates;
    }

    return MockData.assessmentTemplates
        .where((template) => template.type == type)
        .toList();
  }
}
