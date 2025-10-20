import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/ai_career_roadmap.dart';
import '../../domain/repositories/ai_roadmap_repository.dart';

class AIRoadmapRepositoryImpl implements AIRoadmapRepository {
  AIRoadmapRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<String> generateRoadmap({
    required String careerId,
    String? locale,
  }) async {
    try {
      // Call the edge function to generate roadmap
      final response = await _supabase.functions.invoke(
        'ai-generate-career-roadmap',
        method: HttpMethod.post,
        body: {
          'career_id': careerId,
          if (locale != null) 'locale': locale,
        },
      );

      if (response.status != 200) {
        final data = response.data as Map<String, dynamic>?;
        final error = data?['error'] as String? ?? 'Unknown error';

        // Handle specific error codes
        if (error == 'roadmap_limit_reached') {
          final count = data?['current_count'] as int? ?? 3;
          throw RoadmapLimitExceededException(count);
        } else if (error == 'roadmap_already_exists') {
          throw RoadmapAlreadyExistsException(careerId);
        } else if (error == 'missing_auth' || error == 'invalid_token') {
          throw Exception('Authentication failed');
        } else {
          throw AIGenerationFailedException(error);
        }
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw AIGenerationFailedException(
          data['error'] as String? ?? 'Failed to generate roadmap',
        );
      }

      final roadmapId = data['roadmap_id'] as String;
      return roadmapId;
    } on Exception catch (e) {
      if (e is RoadmapLimitExceededException ||
          e is RoadmapAlreadyExistsException ||
          e is AIGenerationFailedException) {
        rethrow;
      }
      throw Exception('Error generating roadmap: $e');
    }
  }

  @override
  Future<AICareerRoadmap?> getRoadmapById(String roadmapId) async {
    try {
      // Fetch roadmap with phases and steps using the helper function
      final response = await _supabase
          .rpc<Map<String, dynamic>>(
            'get_user_career_roadmap_by_id',
            params: {'p_roadmap_id': roadmapId},
          )
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapToEntity(response);
    } on Exception catch (e) {
      throw Exception('Error fetching roadmap: $e');
    }
  }

  @override
  Future<AICareerRoadmap?> getRoadmapForCareer({
    required String userId,
    required String careerId,
  }) async {
    try {
      // First get the roadmap ID
      final roadmapResponse = await _supabase
          .from('user_career_roadmaps')
          .select('id')
          .eq('user_id', userId)
          .eq('career_id', careerId)
          .maybeSingle();

      if (roadmapResponse == null) {
        return null;
      }

      final roadmapId = roadmapResponse['id'] as String;
      return getRoadmapById(roadmapId);
    } on Exception catch (e) {
      throw Exception('Error fetching roadmap for career: $e');
    }
  }

  @override
  Future<bool> hasRoadmapForCareer({
    required String userId,
    required String careerId,
  }) async {
    try {
      final response = await _supabase
          .from('user_career_roadmaps')
          .select('id')
          .eq('user_id', userId)
          .eq('career_id', careerId)
          .maybeSingle();

      return response != null;
    } on Exception catch (e) {
      throw Exception('Error checking roadmap existence: $e');
    }
  }

  @override
  Stream<List<AICareerRoadmapSummary>> watchUserRoadmaps(String userId) {
    return _supabase
        .from('user_career_roadmaps')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('generated_at', ascending: false)
        .map((data) {
          return data
              .map((json) => AICareerRoadmapSummary.fromJson(json))
              .toList();
        });
  }

  @override
  Future<int> getUserRoadmapCount(String userId) async {
    try {
      final response = await _supabase
          .from('user_career_roadmaps')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } on Exception catch (e) {
      throw Exception('Error counting roadmaps: $e');
    }
  }

  @override
  Future<void> deleteRoadmap(String roadmapId) async {
    try {
      await _supabase.from('user_career_roadmaps').delete().eq('id', roadmapId);
    } on Exception catch (e) {
      throw Exception('Error deleting roadmap: $e');
    }
  }

  @override
  Future<void> deleteRoadmapForCareer({
    required String userId,
    required String careerId,
  }) async {
    try {
      await _supabase
          .from('user_career_roadmaps')
          .delete()
          .eq('user_id', userId)
          .eq('career_id', careerId);
    } on Exception catch (e) {
      throw Exception('Error deleting roadmap for career: $e');
    }
  }

  /// Map database JSON to AICareerRoadmap entity
  AICareerRoadmap _mapToEntity(Map<String, dynamic> json) {
    final phases =
        (json['phases'] as List<dynamic>?)
            ?.map((p) => RoadmapPhase.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return AICareerRoadmap(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      careerId: json['career_id'] as String,
      careerTitle: json['career_title'] as String,
      description: json['description'] as String,
      estimatedDuration: json['estimated_duration'] as String,
      salaryRange: json['salary_range'] as String,
      icon: json['icon'] as String? ?? '💼',
      phases: phases,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
