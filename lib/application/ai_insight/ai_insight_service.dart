import '../../domain/entities/ai_insight.dart';
import '../../domain/repositories/ai_insight_repository.dart';

/// Service for managing AI career insights
class AIInsightService {
  AIInsightService(this._repository);

  final AIInsightRepository _repository;

  /// Generate a new AI career insight for the current user
  /// Throws an exception if user doesn't have sufficient data
  Future<AIInsight> generateInsight(String userId) async {
    // Check if user has sufficient data
    final eligibility = await _repository.canGenerateInsight(userId);
    
    if (eligibility['can_generate'] != true) {
      throw InsufficientDataException(
        eligibility['reason'] as String? ?? 'Insufficient data for analysis',
        assessments: eligibility['assessments'] as int? ?? 0,
        activities: eligibility['activities'] as int? ?? 0,
        features: eligibility['features'] as int? ?? 0,
      );
    }

    return await _repository.generateInsight(userId);
  }

  /// Get the latest AI insight for a user
  Future<AIInsight?> getLatestInsight(String userId) async {
    return await _repository.getLatestInsight(userId);
  }

  /// Get all AI insights for a user
  Future<List<AIInsight>> getAllInsights(String userId) async {
    return await _repository.getAllInsights(userId);
  }

  /// Check if user can generate an AI insight
  Future<InsightEligibility> checkEligibility(String userId) async {
    final result = await _repository.canGenerateInsight(userId);
    
    return InsightEligibility(
      canGenerate: result['can_generate'] as bool,
      reason: result['reason'] as String,
      assessments: result['assessments'] as int? ?? 0,
      activities: result['activities'] as int? ?? 0,
      features: result['features'] as int? ?? 0,
    );
  }

  /// Delete an AI insight
  Future<void> deleteInsight(String insightId) async {
    await _repository.deleteInsight(insightId);
  }
}

/// Eligibility status for generating AI insights
class InsightEligibility {
  const InsightEligibility({
    required this.canGenerate,
    required this.reason,
    required this.assessments,
    required this.activities,
    required this.features,
  });

  final bool canGenerate;
  final String reason;
  final int assessments;
  final int activities;
  final int features;

  /// Get progress percentage (0-100) towards being eligible
  int get progressPercentage {
    // Requirements: 1+ assessments, 2+ activities, 10+ features
    final assessmentProgress = (assessments / 1 * 100).clamp(0, 100);
    final activityProgress = (activities / 2 * 100).clamp(0, 100);
    final featureProgress = (features / 10 * 100).clamp(0, 100);
    
    return ((assessmentProgress + activityProgress + featureProgress) / 3).round();
  }

  /// Get a user-friendly message about what's needed
  String get userMessage {
    if (canGenerate) {
      return 'You have enough data! Generate your personalized career insight now.';
    }

    final missing = <String>[];
    if (assessments < 1) {
      missing.add('Complete at least 1 personality quiz');
    }
    if (activities < 2) {
      missing.add('Complete at least ${2 - activities} more activities');
    }
    if (features < 10) {
      missing.add('Build your profile by completing more quizzes and games');
    }

    return 'To unlock AI insights: ${missing.join(', ')}';
  }
}

/// Exception thrown when user doesn't have sufficient data for AI analysis
class InsufficientDataException implements Exception {
  InsufficientDataException(
    this.message, {
    required this.assessments,
    required this.activities,
    required this.features,
  });

  final String message;
  final int assessments;
  final int activities;
  final int features;

  @override
  String toString() => 'InsufficientDataException: $message '
      '(assessments: $assessments, activities: $activities, features: $features)';
}

