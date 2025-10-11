import '../entities/assessment.dart';

/// Assessment repository interface
/// Extension point: Replace mock with ML-based scoring in Phase-2
abstract class AssessmentRepository {
  /// Get all assessments for a user
  Future<List<Assessment>> getUserAssessments({required String userId});

  /// Get a specific assessment by ID
  Future<Assessment?> getAssessment({required String assessmentId});

  /// Save a new assessment
  Future<Assessment> saveAssessment({
    required String userId,
    required Map<String, int> traitScores,
    required AssessmentType type,
  });

  /// Update assessment completion status
  Future<Assessment> updateAssessment({
    required String assessmentId,
    Map<String, int>? traitScores,
    bool? completed,
  });

  /// Get user's aggregated trait scores from all completed assessments
  Future<Map<String, int>> getUserTraitScores({required String userId});

  /// Get available quizzes/games
  Future<List<AssessmentTemplate>> getAvailableAssessments({
    AssessmentType? type,
  });
}

/// Template for assessments (quizzes/games)
class AssessmentTemplate {
  const AssessmentTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.questions,
    required this.estimatedMinutes,
    this.iconPath,
  });

  final String id;
  final String title;
  final String description;
  final AssessmentType type;
  final List<AssessmentQuestion> questions;
  final int estimatedMinutes;
  final String? iconPath;
}

/// Question within an assessment
class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.trait,
  });

  final String id;
  final String text;
  final List<AssessmentOption> options;

  /// Which trait this question measures (e.g., 'curiosity', 'creativity')
  final String? trait;
}

/// Answer option for a question
class AssessmentOption {
  const AssessmentOption({
    required this.id,
    required this.text,
    required this.score,
  });

  final String id;
  final String text;

  /// Score value (0-10) for this option
  final int score;
}
