import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startad_agf_selfdiscovery/application/roadmap/roadmap_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the roadmap service
final roadmapServiceProvider = Provider<RoadmapService>((ref) {
  return RoadmapService(Supabase.instance.client);
});

/// Provider for user's roadmaps
final myRoadmapsProvider =
    FutureProvider.autoDispose<List<Roadmap>>((ref) async {
  final roadmapService = ref.watch(roadmapServiceProvider);
  return roadmapService.getMyRoadmaps();
});

/// Provider for a specific roadmap with steps
final roadmapWithStepsProvider =
    FutureProvider.autoDispose.family<RoadmapWithSteps?, String>(
  (ref, roadmapId) async {
    final roadmapService = ref.watch(roadmapServiceProvider);
    return roadmapService.getRoadmapWithSteps(roadmapId);
  },
);
