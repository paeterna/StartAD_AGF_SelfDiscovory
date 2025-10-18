import 'dart:developer' as developer;

/// Analytics service interface
/// Extension point: Wire to GA4/Amplitude/Mixpanel in Phase-2
abstract class AnalyticsService {
  /// Track a screen view
  Future<void> logScreenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  });

  /// Track a user action/event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  });

  /// Track onboarding completion
  Future<void> logOnboardingComplete({required String userId});

  /// Track quiz/game completion
  Future<void> logAssessmentComplete({
    required String userId,
    required String assessmentId,
    required String assessmentType,
  });

  /// Track career selection
  Future<void> logCareerSelected({
    required String userId,
    required String careerId,
    required int matchScore,
  });

  /// Track roadmap step completion
  Future<void> logRoadmapStepComplete({
    required String userId,
    required String stepId,
  });

  // AI Roadmap Events

  /// Track when user views a career cluster
  Future<void> logCareerClusterViewed({
    required String userId,
    required String clusterId,
    required String clusterName,
  });

  /// Track when user expands a career cluster
  Future<void> logClusterExpanded({
    required String userId,
    required String clusterId,
    required String clusterName,
  });

  /// Track when user clicks generate roadmap button
  Future<void> logCareerGenerateClicked({
    required String userId,
    required String careerId,
    required String careerTitle,
    required int matchScore,
  });

  /// Track when roadmap generation succeeds
  Future<void> logRoadmapGenerated({
    required String userId,
    required String roadmapId,
    required String careerId,
    required String careerTitle,
  });

  /// Track when roadmap generation fails
  Future<void> logRoadmapGenerationFailed({
    required String userId,
    required String careerId,
    required String careerTitle,
    required String errorCode,
  });

  /// Track when user deletes a roadmap
  Future<void> logRoadmapDeleted({
    required String userId,
    required String roadmapId,
    required String careerTitle,
    required String reason, // 'limit_reached', 'user_initiated'
  });

  /// Track when user navigates to roadmap detail view
  Future<void> logRoadmapViewNavigated({
    required String userId,
    required String roadmapId,
    required String careerTitle,
  });
}

/// Mock implementation for Phase-1
class MockAnalyticsService implements AnalyticsService {
  @override
  Future<void> logScreenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) async {
    developer.log(
      '[Analytics] Screen: $screenName ${parameters ?? ""}',
      name: 'AnalyticsService',
    );
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    developer.log(
      '[Analytics] Event: $name ${parameters ?? ""}',
      name: 'AnalyticsService',
    );
  }

  @override
  Future<void> setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    developer.log(
      '[Analytics] User Properties: $userId ${properties ?? ""}',
      name: 'AnalyticsService',
    );
  }

  @override
  Future<void> logOnboardingComplete({required String userId}) async {
    await logEvent(
      name: 'onboarding_complete',
      parameters: {'user_id': userId},
    );
  }

  @override
  Future<void> logAssessmentComplete({
    required String userId,
    required String assessmentId,
    required String assessmentType,
  }) async {
    await logEvent(
      name: 'assessment_complete',
      parameters: {
        'user_id': userId,
        'assessment_id': assessmentId,
        'assessment_type': assessmentType,
      },
    );
  }

  @override
  Future<void> logCareerSelected({
    required String userId,
    required String careerId,
    required int matchScore,
  }) async {
    await logEvent(
      name: 'career_selected',
      parameters: {
        'user_id': userId,
        'career_id': careerId,
        'match_score': matchScore,
      },
    );
  }

  @override
  Future<void> logRoadmapStepComplete({
    required String userId,
    required String stepId,
  }) async {
    await logEvent(
      name: 'roadmap_step_complete',
      parameters: {'user_id': userId, 'step_id': stepId},
    );
  }

  @override
  Future<void> logCareerClusterViewed({
    required String userId,
    required String clusterId,
    required String clusterName,
  }) async {
    await logEvent(
      name: 'career_cluster_viewed',
      parameters: {
        'user_id': userId,
        'cluster_id': clusterId,
        'cluster_name': clusterName,
      },
    );
  }

  @override
  Future<void> logClusterExpanded({
    required String userId,
    required String clusterId,
    required String clusterName,
  }) async {
    await logEvent(
      name: 'cluster_expanded',
      parameters: {
        'user_id': userId,
        'cluster_id': clusterId,
        'cluster_name': clusterName,
      },
    );
  }

  @override
  Future<void> logCareerGenerateClicked({
    required String userId,
    required String careerId,
    required String careerTitle,
    required int matchScore,
  }) async {
    await logEvent(
      name: 'career_generate_clicked',
      parameters: {
        'user_id': userId,
        'career_id': careerId,
        'career_title': careerTitle,
        'match_score': matchScore,
      },
    );
  }

  @override
  Future<void> logRoadmapGenerated({
    required String userId,
    required String roadmapId,
    required String careerId,
    required String careerTitle,
  }) async {
    await logEvent(
      name: 'roadmap_generated',
      parameters: {
        'user_id': userId,
        'roadmap_id': roadmapId,
        'career_id': careerId,
        'career_title': careerTitle,
      },
    );
  }

  @override
  Future<void> logRoadmapGenerationFailed({
    required String userId,
    required String careerId,
    required String careerTitle,
    required String errorCode,
  }) async {
    await logEvent(
      name: 'roadmap_generation_failed',
      parameters: {
        'user_id': userId,
        'career_id': careerId,
        'career_title': careerTitle,
        'error_code': errorCode,
      },
    );
  }

  @override
  Future<void> logRoadmapDeleted({
    required String userId,
    required String roadmapId,
    required String careerTitle,
    required String reason,
  }) async {
    await logEvent(
      name: 'roadmap_deleted',
      parameters: {
        'user_id': userId,
        'roadmap_id': roadmapId,
        'career_title': careerTitle,
        'reason': reason,
      },
    );
  }

  @override
  Future<void> logRoadmapViewNavigated({
    required String userId,
    required String roadmapId,
    required String careerTitle,
  }) async {
    await logEvent(
      name: 'roadmap_view_navigated',
      parameters: {
        'user_id': userId,
        'roadmap_id': roadmapId,
        'career_title': careerTitle,
      },
    );
  }
}
