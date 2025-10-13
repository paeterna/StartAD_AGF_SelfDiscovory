import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user career roadmaps and steps
/// Purpose: user-selected career plan + checklist of steps
/// Owner key: roadmaps.user_id; steps guarded by subquery policy
/// Write path: when user saves a matched career, create a roadmap; steps can be checked off
class RoadmapService {
  RoadmapService(this._supabase);

  final SupabaseClient _supabase;

  /// Create a new roadmap for a career
  Future<String> create(String careerId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('roadmaps')
        .insert({
          'user_id': userId,
          'career_id': careerId,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  /// Get all roadmaps for current user
  Future<List<Roadmap>> getMyRoadmaps() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('roadmaps')
        .select('id, career_id, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Roadmap.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific roadmap with its steps
  Future<RoadmapWithSteps?> getRoadmapWithSteps(String roadmapId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    // Get roadmap
    final roadmapResponse = await _supabase
        .from('roadmaps')
        .select('id, career_id, created_at')
        .eq('id', roadmapId)
        .eq('user_id', userId)
        .maybeSingle();

    if (roadmapResponse == null) return null;

    final roadmap = Roadmap.fromJson(roadmapResponse);

    // Get steps
    final stepsResponse = await _supabase
        .from('roadmap_steps')
        .select('id, sort_order, title, description, completed, completed_at')
        .eq('roadmap_id', roadmapId)
        .order('sort_order');

    final steps = (stepsResponse as List<dynamic>)
        .map((e) => RoadmapStep.fromJson(e as Map<String, dynamic>))
        .toList();

    return RoadmapWithSteps(roadmap: roadmap, steps: steps);
  }

  /// Add a step to a roadmap
  Future<String> addStep({
    required String roadmapId,
    required String title,
    String? description,
    int? sortOrder,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Verify roadmap belongs to user
    final roadmap = await _supabase
        .from('roadmaps')
        .select('id')
        .eq('id', roadmapId)
        .eq('user_id', userId)
        .maybeSingle();

    if (roadmap == null) {
      throw Exception('Roadmap not found or access denied');
    }

    // If no sort_order provided, get max + 1
    int order = sortOrder ?? 1;
    if (sortOrder == null) {
      final maxOrderResponse = await _supabase
          .from('roadmap_steps')
          .select('sort_order')
          .eq('roadmap_id', roadmapId)
          .order('sort_order', ascending: false)
          .limit(1)
          .maybeSingle();

      if (maxOrderResponse != null) {
        order = (maxOrderResponse['sort_order'] as int) + 1;
      }
    }

    final response = await _supabase
        .from('roadmap_steps')
        .insert({
          'roadmap_id': roadmapId,
          'title': title,
          'description': description,
          'sort_order': order,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  /// Toggle a step's completion status
  Future<void> toggleStep(String stepId, bool completed) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase.from('roadmap_steps').update({
      'completed': completed,
      'completed_at': completed ? DateTime.now().toIso8601String() : null,
    }).eq('id', stepId);
    // RLS policy ensures user owns the parent roadmap
  }

  /// Delete a roadmap (cascades to steps)
  Future<void> delete(String roadmapId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase
        .from('roadmaps')
        .delete()
        .eq('id', roadmapId)
        .eq('user_id', userId);
  }

  /// Delete a step
  Future<void> deleteStep(String stepId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase.from('roadmap_steps').delete().eq('id', stepId);
    // RLS policy ensures user owns the parent roadmap
  }
}

/// Roadmap model
class Roadmap {
  const Roadmap({
    required this.id,
    required this.careerId,
    required this.createdAt,
  });

  final String id;
  final String careerId;
  final DateTime createdAt;

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      id: json['id'] as String,
      careerId: json['career_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Roadmap step model
class RoadmapStep {
  const RoadmapStep({
    required this.id,
    required this.sortOrder,
    required this.title,
    this.description,
    required this.completed,
    this.completedAt,
  });

  final String id;
  final int sortOrder;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? completedAt;

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      id: json['id'] as String,
      sortOrder: json['sort_order'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}

/// Combined roadmap with steps
class RoadmapWithSteps {
  const RoadmapWithSteps({
    required this.roadmap,
    required this.steps,
  });

  final Roadmap roadmap;
  final List<RoadmapStep> steps;

  int get totalSteps => steps.length;
  int get completedSteps => steps.where((s) => s.completed).length;
  double get completionPercent =>
      totalSteps == 0 ? 0 : (completedSteps / totalSteps * 100);
}
