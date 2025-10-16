import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features_registry.dart';
import 'scoring_pipeline.dart';

// =====================================================
// Batch Submission Helper
// =====================================================

/// Exception thrown when batch submission fails
class BatchSubmissionException implements Exception {
  final String message;
  final Object? originalError;

  BatchSubmissionException(this.message, [this.originalError]);

  @override
  String toString() => 'BatchSubmissionException: $message';
}

/// Helper for submitting feature scores to the Edge Function
class BatchSubmissionHelper {
  final SupabaseClient _supabase;

  BatchSubmissionHelper(this._supabase);

  /// Submit a batch of feature scores to update_profile_and_match Edge Function
  ///
  /// [userId] - The user ID
  /// [scoringOutput] - Output from ScoringPipeline
  /// [instrumentName] - Name of the instrument (e.g., "Mini RIASEC")
  /// [activityKind] - Type of activity: "quiz" or "game"
  ///
  /// Returns true if successful, throws BatchSubmissionException on error
  Future<bool> submitBatch({
    required String userId,
    required ScoringOutput scoringOutput,
    required String instrumentName,
    required String activityKind,
  }) async {
    // Validate all keys are canonical before submitting
    try {
      assertCanonicalKeys(scoringOutput.means0to100.keys);
    } catch (e) {
      throw BatchSubmissionException(
        'Non-canonical feature keys detected in scoring output',
        e,
      );
    }

    // Build batch_features payload
    final batchFeatures = scoringOutput.toBatchFeatures();

    if (batchFeatures.isEmpty) {
      throw BatchSubmissionException(
        'Cannot submit empty batch_features. '
        'Ensure scoring pipeline produced valid feature scores.',
      );
    }

    // Build payload for Edge Function
    final payload = {
      'user_id': userId,
      'batch_features': batchFeatures,
      'instrument': instrumentName,
      'activity_kind': activityKind,
      'delta_progress_hint': scoringOutput.deltaProgress,
    };

    debugPrint('📤 Submitting batch to Edge Function:');
    debugPrint('   User: $userId');
    debugPrint('   Instrument: $instrumentName');
    debugPrint('   Kind: $activityKind');
    debugPrint('   Features: ${batchFeatures.length}');
    for (final f in batchFeatures) {
      debugPrint(
        '     - ${f['key']}: ${(f['mean'] as double).toStringAsFixed(1)} '
        '(n=${f['n']}, q=${(f['quality'] as double).toStringAsFixed(2)})',
      );
    }

    try {
      final response = await _supabase.functions.invoke(
        'update_profile_and_match',
        body: payload,
      );

      if (response.status == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          debugPrint('✅ Batch submission succeeded');
          return true;
        } else {
          final error = data is Map ? data['error'] : 'Unknown error';
          throw BatchSubmissionException(
            'Edge Function returned success=false: $error',
          );
        }
      } else {
        throw BatchSubmissionException(
          'Edge Function returned status ${response.status}',
        );
      }
    } on FunctionException catch (e) {
      debugPrint('❌ Edge Function error: ${e.status} - ${e.details}');
      throw BatchSubmissionException(
        'Edge Function failed with status ${e.status}',
        e,
      );
    } on PostgrestException catch (e) {
      debugPrint('❌ Postgrest error: ${e.code} - ${e.message}');
      throw BatchSubmissionException(
        'Database error: ${e.message}',
        e,
      );
    } catch (e) {
      debugPrint('❌ Unexpected error during batch submission: $e');
      throw BatchSubmissionException(
        'Unexpected error during submission',
        e,
      );
    }
  }

  /// Submit batch with retry logic
  ///
  /// Attempts submission once, and retries once if it fails.
  /// Returns true if successful (on first or second attempt).
  /// Returns false if both attempts fail (does not throw).
  Future<bool> submitBatchWithRetry({
    required String userId,
    required ScoringOutput scoringOutput,
    required String instrumentName,
    required String activityKind,
  }) async {
    try {
      // First attempt
      return await submitBatch(
        userId: userId,
        scoringOutput: scoringOutput,
        instrumentName: instrumentName,
        activityKind: activityKind,
      );
    } on BatchSubmissionException catch (e) {
      debugPrint('⚠️ First submission attempt failed: ${e.message}');
      debugPrint('🔄 Retrying batch submission...');

      try {
        // Second attempt
        await Future<void>.delayed(const Duration(seconds: 1));
        return await submitBatch(
          userId: userId,
          scoringOutput: scoringOutput,
          instrumentName: instrumentName,
          activityKind: activityKind,
        );
      } on BatchSubmissionException catch (e2) {
        debugPrint('❌ Second submission attempt also failed: ${e2.message}');
        return false; // Both attempts failed, return false instead of throwing
      }
    }
  }
}

// =====================================================
// Activity Run Repository Helper
// =====================================================

/// Helper for writing to activity_runs table
class ActivityRunHelper {
  final SupabaseClient _supabase;

  ActivityRunHelper(this._supabase);

  /// Write an activity run to the database
  Future<int> writeActivityRun({
    required String userId,
    required int activityId,
    required int composite,
    required Map<String, double> traitScores,
    required int deltaProgress,
  }) async {
    // Validate all trait score keys are canonical
    try {
      assertCanonicalKeys(traitScores.keys);
    } catch (e) {
      throw ArgumentError(
        'Non-canonical feature keys in traitScores: ${traitScores.keys.join(", ")}',
      );
    }

    final now = DateTime.now().toIso8601String();

    final data = {
      'user_id': userId,
      'activity_id': activityId,
      'started_at': now,
      'completed_at': now,
      'score': composite,
      'trait_scores': traitScores,
      'delta_progress': deltaProgress,
    };

    debugPrint('📝 Writing activity_run:');
    debugPrint('   Activity ID: $activityId');
    debugPrint('   Score: $composite');
    debugPrint('   Trait scores: ${traitScores.length} features');
    debugPrint('   Delta progress: $deltaProgress');

    try {
      final response = await _supabase
          .from('activity_runs')
          .insert(data)
          .select('id')
          .single();

      final runId = response['id'] as int;
      debugPrint('✅ Activity run created: $runId');
      return runId;
    } on PostgrestException catch (e) {
      debugPrint('❌ Failed to write activity_run: ${e.message}');
      rethrow;
    }
  }

  /// Resolve activity ID by title
  Future<int?> resolveActivityIdByTitle(String title) async {
    try {
      final response = await _supabase
          .from('activities')
          .select('id')
          .eq('title', title)
          .maybeSingle();

      return response?['id'] as int?;
    } on PostgrestException catch (e) {
      debugPrint('❌ Failed to resolve activity ID for "$title": ${e.message}');
      return null;
    }
  }
}

// =====================================================
// Assessment Repository Helper
// =====================================================

/// Helper for writing to assessments and assessment_items tables
class AssessmentHelper {
  final SupabaseClient _supabase;

  AssessmentHelper(this._supabase);

  /// Write an assessment record
  Future<int> writeAssessment({
    required String userId,
    required int activityRunId,
    required String activityType,
    required int score,
    required double confidence,
  }) async {
    final data = {
      'user_id': userId,
      'activity_run_id': activityRunId,
      'activity_type': activityType,
      'score': score,
      'confidence': confidence,
      'trait_scores':
          <String, dynamic>{}, // Empty, scores stored in user_feature_scores
    };

    try {
      final response = await _supabase
          .from('assessments')
          .insert(data)
          .select('id')
          .single();

      final assessmentId = response['id'] as int;
      debugPrint('✅ Assessment created: $assessmentId');
      return assessmentId;
    } on PostgrestException catch (e) {
      debugPrint('❌ Failed to write assessment: ${e.message}');
      rethrow;
    }
  }

  /// Write assessment items (telemetry)
  Future<void> writeAssessmentItems({
    required int assessmentId,
    required List<Map<String, dynamic>> items,
  }) async {
    if (items.isEmpty) return;

    try {
      await _supabase
          .from('assessment_items')
          .insert(
            items
                .map((item) => {...item, 'assessment_id': assessmentId})
                .toList(),
          );

      debugPrint('✅ Written ${items.length} assessment items');
    } on PostgrestException catch (e) {
      debugPrint('❌ Failed to write assessment items: ${e.message}');
      // Don't rethrow - assessment items are optional telemetry
    }
  }
}
