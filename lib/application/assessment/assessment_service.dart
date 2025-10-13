import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing assessments and assessment items
/// Provides audit trail for quiz/game completions
class AssessmentService {
  AssessmentService(this._supabase);

  final SupabaseClient _supabase;

  /// Create an assessment record
  /// Returns the assessment ID
  Future<int> createAssessment({
    required Map<String, dynamic> traitScores,
    required int deltaProgress,
    required double confidence, // 0.0-1.0
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Validate inputs
    if (deltaProgress < 0 || deltaProgress > 20) {
      throw ArgumentError('delta_progress must be between 0 and 20');
    }

    if (confidence < 0.0 || confidence > 1.0) {
      throw ArgumentError('confidence must be between 0.0 and 1.0');
    }

    final response = await _supabase
        .from('assessments')
        .insert({
          'user_id': userId,
          'trait_scores': traitScores,
          'delta_progress': deltaProgress,
          'confidence': confidence,
        })
        .select('id')
        .single();

    return response['id'] as int;
  }

  /// Insert assessment items (batch)
  /// For fine-grained audit trail
  Future<void> createAssessmentItems({
    required int assessmentId,
    required List<AssessmentItemInput> items,
  }) async {
    if (items.isEmpty) {
      return;
    }

    final itemsData = items.map((item) => item.toJson(assessmentId)).toList();

    await _supabase.from('assessment_items').insert(itemsData);
  }

  /// Get user's assessment history
  Future<List<Assessment>> getAssessments({int? limit}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return [];
    }

    var query = _supabase
        .from('assessments')
        .select('id, taken_at, trait_scores, delta_progress, confidence')
        .eq('user_id', userId)
        .order('taken_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;

    return (response as List<dynamic>)
        .map((e) => Assessment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get latest assessment for a user
  Future<Assessment?> getLatestAssessment() async {
    final assessments = await getAssessments(limit: 1);
    return assessments.isEmpty ? null : assessments.first;
  }

  /// Get assessment items for a specific assessment
  Future<List<AssessmentItem>> getAssessmentItems(int assessmentId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return [];
    }

    // Verify assessment belongs to user
    final assessment = await _supabase
        .from('assessments')
        .select('id')
        .eq('id', assessmentId)
        .eq('user_id', userId)
        .maybeSingle();

    if (assessment == null) {
      throw Exception('Assessment not found or access denied');
    }

    final response = await _supabase
        .from('assessment_items')
        .select(
            'id, item_id, response, score_raw, score_norm, duration_ms, metadata, created_at',)
        .eq('assessment_id', assessmentId)
        .order('created_at');

    return (response as List<dynamic>)
        .map((e) => AssessmentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Assessment model
class Assessment {
  const Assessment({
    required this.id,
    required this.takenAt,
    required this.traitScores,
    required this.deltaProgress,
    required this.confidence,
  });

  final int id;
  final DateTime takenAt;
  final Map<String, dynamic> traitScores;
  final int deltaProgress;
  final double confidence;

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] as int,
      takenAt: DateTime.parse(json['taken_at'] as String),
      traitScores: json['trait_scores'] as Map<String, dynamic>? ?? {},
      deltaProgress: json['delta_progress'] as int,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

/// Assessment item model
class AssessmentItem {
  const AssessmentItem({
    required this.id,
    required this.itemId,
    this.response,
    this.scoreRaw,
    this.scoreNorm,
    this.durationMs,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final Map<String, dynamic>? response;
  final double? scoreRaw;
  final double? scoreNorm;
  final int? durationMs;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  factory AssessmentItem.fromJson(Map<String, dynamic> json) {
    return AssessmentItem(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      response: json['response'] as Map<String, dynamic>?,
      scoreRaw: (json['score_raw'] as num?)?.toDouble(),
      scoreNorm: (json['score_norm'] as num?)?.toDouble(),
      durationMs: json['duration_ms'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Input model for creating assessment items
class AssessmentItemInput {
  const AssessmentItemInput({
    required this.itemId,
    this.response,
    this.scoreRaw,
    this.scoreNorm,
    this.durationMs,
    this.metadata,
  });

  final String itemId;
  final Map<String, dynamic>? response;
  final double? scoreRaw;
  final double? scoreNorm;
  final int? durationMs;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson(int assessmentId) {
    return {
      'assessment_id': assessmentId,
      'item_id': itemId,
      if (response != null) 'response': response,
      if (scoreRaw != null) 'score_raw': scoreRaw,
      if (scoreNorm != null) 'score_norm': scoreNorm,
      if (durationMs != null) 'duration_ms': durationMs,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
