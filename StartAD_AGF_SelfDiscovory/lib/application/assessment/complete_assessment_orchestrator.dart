import 'package:startad_agf_selfdiscovery/application/activity/activity_service.dart';
import 'package:startad_agf_selfdiscovery/application/assessment/assessment_service.dart';
import 'package:startad_agf_selfdiscovery/application/scoring/scoring_service.dart';
import 'package:startad_agf_selfdiscovery/core/scoring/features_registry.dart';
import 'package:startad_agf_selfdiscovery/data/models/feature_score.dart';

/// Orchestrates the complete assessment flow according to the data contract:
/// 1. Complete activity_run → Trigger updates discovery_progress
/// 2. Create assessment (audit trail)
/// 3. Insert assessment_items (optional, for fine-grained audit)
/// 4. Call upsert_feature_ema via Edge Function
/// 5. Edge Function computes career matches
class CompleteAssessmentOrchestrator {
  CompleteAssessmentOrchestrator({
    required this.activityService,
    required this.assessmentService,
    required this.scoringService,
  });

  final ActivityService activityService;
  final AssessmentService assessmentService;
  final ScoringService scoringService;

  /// Complete a quiz or game assessment with full data contract compliance
  ///
  /// [activityRunId] - The activity_run.id from startActivityRun()
  /// [activityId] - The activities.id
  /// [score] - Optional raw score (0-100 or game-specific)
  /// [traitScores] - Computed trait scores as JSONB (e.g., {"creativity": 85, "grit": 75})
  /// [featureScores] - List of feature scores to update via EMA
  /// [deltaProgress] - Progress delta 0-20 for discovery_progress
  /// [confidence] - Assessment confidence 0.0-1.0
  /// [assessmentItems] - Optional fine-grained items for audit trail
  Future<CompleteAssessmentResult> completeAssessment({
    required int activityRunId,
    required String activityId,
    int? score,
    required Map<String, dynamic> traitScores,
    required List<FeatureScore> featureScores,
    required int deltaProgress,
    required double confidence,
    List<AssessmentItemInput>? assessmentItems,
  }) async {
    try {
      // Validate all keys are canonical before proceeding
      if (traitScores.isNotEmpty) {
        assertCanonicalKeys(traitScores.keys);
      }
      if (featureScores.isNotEmpty) {
        assertCanonicalKeys(featureScores.map((f) => f.key));
      }

      // Step 1: Complete activity_run
      // This triggers fn_update_progress_after_run → updates discovery_progress
      await activityService.completeActivityRun(
        runId: activityRunId,
        score: score,
        traitScores: traitScores,
        deltaProgress: deltaProgress,
      );

      // Step 2: Create assessment record (audit trail)
      final assessmentId = await assessmentService.createAssessment(
        traitScores: traitScores,
        deltaProgress: deltaProgress,
        confidence: confidence,
      );

      // Step 3: Insert assessment items (optional, for detailed audit)
      if (assessmentItems != null && assessmentItems.isNotEmpty) {
        await assessmentService.createAssessmentItems(
          assessmentId: assessmentId,
          items: assessmentItems,
        );
      }

      // Step 4: Update feature scores via Edge Function (non-blocking)
      // This calls upsert_feature_ema for each feature
      // Then computes cosine similarity and updates user_career_matches
      final userId = activityService.getCurrentUserId();
      int matchesComputed = 0;
      double profileConfidence = confidence;

      if (userId != null && featureScores.isNotEmpty) {
        try {
          // Log what we're sending for debugging
          print(
            '🔵 Calling Edge Function with ${featureScores.length} features for user $userId',
          );
          for (final f in featureScores) {
            print(
              '  - ${f.key}: ${f.mean.toStringAsFixed(1)} (n=${f.n}, q=${f.quality.toStringAsFixed(2)})',
            );
          }

          final profileResponse = await scoringService.updateProfileAndMatch(
            userId: userId,
            batchFeatures: featureScores,
          );

          if (profileResponse.success) {
            matchesComputed = profileResponse.matchesComputed;
            profileConfidence = profileResponse.confidence;
            print(
              '✅ Edge Function succeeded: $matchesComputed matches computed',
            );
          } else {
            // Log but don't fail - assessment is already saved
            print('⚠️ Edge Function failed: ${profileResponse.error}');
          }
        } on Exception catch (e) {
          // Log but don't fail - assessment is already saved
          print('⚠️ Edge Function exception: $e');
        }
      } else {
        print(
          '⚠️ Skipping Edge Function: userId=$userId, features=${featureScores.length}',
        );
      }

      return CompleteAssessmentResult(
        success: true,
        assessmentId: assessmentId,
        matchesComputed: matchesComputed,
        confidence: profileConfidence,
      );
    } on Object catch (e) {
      return CompleteAssessmentResult(success: false, error: e.toString());
    }
  }

  /// Simplified flow for quick assessments (no items audit)
  Future<CompleteAssessmentResult> completeQuickAssessment({
    required int activityRunId,
    required String activityId,
    int? score,
    required Map<String, dynamic> traitScores,
    required List<FeatureScore> featureScores,
    required int deltaProgress,
    required double confidence,
  }) async {
    return completeAssessment(
      activityRunId: activityRunId,
      activityId: activityId,
      score: score,
      traitScores: traitScores,
      featureScores: featureScores,
      deltaProgress: deltaProgress,
      confidence: confidence,
      assessmentItems: null, // No detailed audit
    );
  }
}

/// Result of completing an assessment
class CompleteAssessmentResult {
  const CompleteAssessmentResult({
    required this.success,
    this.assessmentId,
    this.matchesComputed,
    this.confidence,
    this.error,
  });

  final bool success;
  final int? assessmentId;
  final int? matchesComputed;
  final double? confidence;
  final String? error;
}
