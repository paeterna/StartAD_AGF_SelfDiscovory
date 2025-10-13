import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../activity/activity_service.dart';
import '../scoring/scoring_service.dart';
import 'assessment_service.dart';
import 'complete_assessment_orchestrator.dart';

/// Provider for AssessmentService
final Provider<AssessmentService> assessmentServiceProvider =
    Provider<AssessmentService>((ref) {
  return AssessmentService(Supabase.instance.client);
});

/// Provider for CompleteAssessmentOrchestrator
final Provider<CompleteAssessmentOrchestrator>
    completeAssessmentOrchestratorProvider =
    Provider<CompleteAssessmentOrchestrator>((ref) {
  return CompleteAssessmentOrchestrator(
    activityService: ActivityService(Supabase.instance.client),
    assessmentService: AssessmentService(Supabase.instance.client),
    scoringService: ScoringService(Supabase.instance.client),
  );
});
