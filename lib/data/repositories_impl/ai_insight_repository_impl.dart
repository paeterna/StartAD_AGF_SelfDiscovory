import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/entities/career_roadmap.dart';
import '../../domain/repositories/ai_insight_repository.dart';

class AIInsightRepositoryImpl implements AIInsightRepository {
  AIInsightRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<AIInsight> generateInsight(String userId) async {
    try {
      // Call the edge function to generate insight
      final response = await _supabase.functions.invoke(
        'generate_ai_career_insight',
        method: HttpMethod.post,
      );

      if (response.status != 200) {
        throw Exception(
          'Failed to generate insight: ${response.data['error'] ?? 'Unknown error'}',
        );
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception(
          data['error'] ?? 'Failed to generate insight',
        );
      }

      // Fetch the created insight from database
      final insightId = data['insight_id'] as String;
      final insight = await _getInsightById(insightId);
      
      if (insight == null) {
        throw Exception('Failed to retrieve generated insight');
      }

      return insight;
    } catch (e) {
      throw Exception('Error generating AI insight: $e');
    }
  }

  @override
  Future<AIInsight?> getLatestInsight(String userId) async {
    try {
      final response = await _supabase
          .from('ai_career_insights')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapToEntity(response);
    } catch (e) {
      throw Exception('Error fetching latest insight: $e');
    }
  }

  @override
  Future<List<AIInsight>> getAllInsights(String userId) async {
    try {
      final response = await _supabase
          .from('ai_career_insights')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapToEntity(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching insights: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> canGenerateInsight(String userId) async {
    try {
      final response = await _supabase.rpc<Map<String, dynamic>>(
        'can_generate_ai_insight',
        params: {'p_user_id': userId},
      ).single();

      return response;
    } catch (e) {
      throw Exception('Error checking insight eligibility: $e');
    }
  }

  @override
  Future<void> deleteInsight(String insightId) async {
    try {
      await _supabase
          .from('ai_career_insights')
          .delete()
          .eq('id', insightId);
    } catch (e) {
      throw Exception('Error deleting insight: $e');
    }
  }

  Future<AIInsight?> _getInsightById(String insightId) async {
    try {
      final response = await _supabase
          .from('ai_career_insights')
          .select()
          .eq('id', insightId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapToEntity(response);
    } catch (e) {
      return null;
    }
  }

  AIInsight _mapToEntity(Map<String, dynamic> json) {
    return AIInsight(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      personalitySummary: json['personality_summary'] as String,
      skillsDetected: List<String>.from(json['skills_detected'] as List),
      interestScores: Map<String, double>.from(
        (json['interest_scores'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      careerRecommendations: (json['career_recommendations'] as List)
          .map((e) => CareerRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      careerReasoning: Map<String, String>.from(json['career_reasoning'] as Map),
      careerRoadmaps: json['career_roadmaps'] != null
          ? (json['career_roadmaps'] as Map).map(
              (key, value) => MapEntry(
                key as String,
                CareerRoadmap.fromJson(key as String, value as Map<String, dynamic>),
              ),
            )
          : {}, // Return empty map if null
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      dataPointsUsed: json['data_points_used'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

