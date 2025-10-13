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
}

/// Mock implementation for Phase-1
class MockAnalyticsService implements AnalyticsService {
  @override
  Future<void> logScreenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) async {
    // ignore: avoid_print
    print('[Analytics] Screen: $screenName ${parameters ?? ""}');
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    // ignore: avoid_print
    print('[Analytics] Event: $name ${parameters ?? ""}');
  }

  @override
  Future<void> setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    // ignore: avoid_print
    print('[Analytics] User Properties: $userId ${properties ?? ""}');
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
}
