import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startad_agf_selfdiscovery/data/models/feature_score.dart';

/// Response from update_profile_and_match Edge Function
class ProfileUpdateResponse {
  const ProfileUpdateResponse({
    required this.success,
    required this.matchesComputed,
    required this.matchesStored,
    required this.confidence,
    required this.topMatches,
    this.error,
  });

  final bool success;
  final int matchesComputed;
  final int matchesStored;
  final double confidence;
  final List<TopCareerMatch> topMatches;
  final String? error;

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: json['ok'] as bool? ?? false,
      matchesComputed: json['matches_computed'] as int? ?? 0,
      matchesStored: json['matches_stored'] as int? ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      topMatches:
          (json['top'] as List<dynamic>?)
              ?.map((e) => TopCareerMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      error: json['error'] as String?,
    );
  }
}

/// Top career match from Edge Function
class TopCareerMatch {
  const TopCareerMatch({
    required this.careerId,
    required this.similarity,
    required this.topFeatures,
  });

  final String careerId;
  final double similarity;
  final List<FeatureContribution> topFeatures;

  factory TopCareerMatch.fromJson(Map<String, dynamic> json) {
    return TopCareerMatch(
      careerId: json['career_id'] as String,
      similarity: (json['similarity'] as num).toDouble(),
      topFeatures:
          (json['top_features'] as List<dynamic>?)
              ?.map(
                (e) => FeatureContribution.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Feature contribution to a career match
class FeatureContribution {
  const FeatureContribution({
    required this.featureKey,
    required this.contribution,
  });

  final String featureKey;
  final double contribution;

  factory FeatureContribution.fromJson(Map<String, dynamic> json) {
    return FeatureContribution(
      featureKey: json['feature_key'] as String,
      contribution: (json['contribution'] as num).toDouble(),
    );
  }
}

/// Service for updating user profiles and computing career matches
class ScoringService {
  ScoringService(this._supabase);

  final SupabaseClient _supabase;

  /// Update user feature scores and compute career matches
  ///
  /// This calls the Edge Function which:
  /// 1. Updates user_feature_scores via EMA
  /// 2. Computes cosine similarity to all careers
  /// 3. Stores top matches in user_career_matches
  ///
  /// Returns response with top matches and confidence
  Future<ProfileUpdateResponse> updateProfileAndMatch({
    required String userId,
    required List<FeatureScore> batchFeatures,
  }) async {
    try {
      final batch = FeatureScoreBatch(userId: userId, features: batchFeatures);

      final response = await _supabase.functions.invoke(
        'update_profile_and_match',
        body: batch.toJson(),
      );

      if (response.data == null) {
        throw Exception('Empty response from Edge Function');
      }

      // Check for errors in response
      final data = response.data as Map<String, dynamic>;
      if (data['error'] != null) {
        return ProfileUpdateResponse(
          success: false,
          matchesComputed: 0,
          matchesStored: 0,
          confidence: 0.0,
          topMatches: [],
          error: data['error'] as String,
        );
      }

      return ProfileUpdateResponse.fromJson(data);
    } catch (e) {
      return ProfileUpdateResponse(
        success: false,
        matchesComputed: 0,
        matchesStored: 0,
        confidence: 0.0,
        topMatches: [],
        error: e.toString(),
      );
    }
  }

  /// Get current user's feature scores
  Future<List<UserFeatureScore>> getUserFeatureScores(String userId) async {
    final response = await _supabase
        .from('user_feature_scores')
        .select('feature_key, score_mean, n, last_updated')
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map((e) => UserFeatureScore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get profile completeness percentage
  /// Uses the Postgres function get_profile_completeness
  Future<double> getProfileCompleteness(String userId) async {
    final response = await _supabase.rpc<double>(
      'get_profile_completeness',
      params: {'p_user_id': userId},
    );

    return response;
  }

  /// Get user's career matches (already computed)
  Future<List<CareerMatch>> getCareerMatches({
    required String userId,
    int limit = 20,
  }) async {
    final response = await _supabase
        .from('user_career_matches')
        .select('career_id, similarity, confidence, top_features')
        .eq('user_id', userId)
        .order('similarity', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((e) => CareerMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get career details for a list of career IDs
  Future<List<Career>> getCareers(List<String> careerIds) async {
    if (careerIds.isEmpty) return [];

    final response = await _supabase
        .from('careers')
        .select('id, title, description, tags, cluster')
        .inFilter('id', careerIds);

    return (response as List<dynamic>)
        .map((e) => Career.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get all active careers
  Future<List<Career>> getAllActiveCareers() async {
    final response = await _supabase
        .from('careers')
        .select('id, title, description, tags, cluster')
        .eq('active', true)
        .order('title');

    return (response as List<dynamic>)
        .map((e) => Career.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// User feature score from database
class UserFeatureScore {
  const UserFeatureScore({
    required this.featureKey,
    required this.scoreMean,
    required this.n,
    required this.lastUpdated,
  });

  final String featureKey;
  final double scoreMean;
  final int n;
  final DateTime lastUpdated;

  factory UserFeatureScore.fromJson(Map<String, dynamic> json) {
    return UserFeatureScore(
      featureKey: json['feature_key'] as String,
      scoreMean: (json['score_mean'] as num).toDouble(),
      n: json['n'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }
}

/// Career match from database
class CareerMatch {
  const CareerMatch({
    required this.careerId,
    required this.similarity,
    required this.confidence,
    required this.topFeatures,
  });

  final String careerId;
  final double similarity;
  final double confidence;
  final List<FeatureContribution> topFeatures;

  factory CareerMatch.fromJson(Map<String, dynamic> json) {
    return CareerMatch(
      careerId: json['career_id'] as String,
      similarity: (json['similarity'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      topFeatures:
          (json['top_features'] as List<dynamic>?)
              ?.map(
                (e) => FeatureContribution.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Career details
class Career {
  const Career({
    required this.id,
    required this.title,
    this.description,
    this.tags,
    this.cluster,
  });

  final String id;
  final String title;
  final String? description;
  final List<String>? tags;
  final String? cluster;

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      cluster: json['cluster'] as String?,
    );
  }
}
