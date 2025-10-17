import '../entities/ai_insight.dart';

/// Repository interface for AI career insights
abstract class AIInsightRepository {
  /// Generate a new AI career insight for the user
  /// Returns the generated insight or throws an exception
  Future<AIInsight> generateInsight(String userId);

  /// Get the latest AI insight for a user
  /// Returns null if no insights exist
  Future<AIInsight?> getLatestInsight(String userId);

  /// Get all AI insights for a user, ordered by creation date (newest first)
  Future<List<AIInsight>> getAllInsights(String userId);

  /// Check if user has sufficient data to generate an AI insight
  /// Returns a map with 'can_generate' boolean and 'reason' string
  Future<Map<String, dynamic>> canGenerateInsight(String userId);

  /// Delete an AI insight
  Future<void> deleteInsight(String insightId);
}

