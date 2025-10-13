import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startad_agf_selfdiscovery/application/activity/activity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the activity service
final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService(Supabase.instance.client);
});

/// Provider for discovery progress
final discoveryProgressProvider =
    FutureProvider.autoDispose<DiscoveryProgress?>((ref) async {
  final activityService = ref.watch(activityServiceProvider);
  return activityService.getDiscoveryProgress();
});

/// Provider for activity run history
final activityRunsProvider =
    FutureProvider.autoDispose<List<ActivityRun>>((ref) async {
  final activityService = ref.watch(activityServiceProvider);
  return activityService.getActivityRuns(limit: 20);
});

/// Provider for available activities
final availableActivitiesProvider =
    FutureProvider.autoDispose.family<List<Activity>, String?>((ref, kind) async {
  final activityService = ref.watch(activityServiceProvider);
  return activityService.getActivities(kind: kind);
});
