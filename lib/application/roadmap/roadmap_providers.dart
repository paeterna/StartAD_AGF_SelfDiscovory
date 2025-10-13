import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/providers/future_provider.dart';
import 'package:startad_agf_selfdiscovery/application/roadmap/roadmap_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the roadmap service
final roadmapServiceProvider = Provider<RoadmapService>((ref) {
  return RoadmapService(Supabase.instance.client);
});

/// Provider for user's roadmaps
final FutureProvider<List<Roadmap>> myRoadmapsProvider =
    FutureProvider.autoDispose<List<Roadmap>>((ref) async {
      final roadmapService = ref.watch(roadmapServiceProvider);
      return roadmapService.getMyRoadmaps();
    });

/// Provider for a specific roadmap with steps
final FutureProviderFamily<RoadmapWithSteps?, String> roadmapWithStepsProvider =
    FutureProvider.autoDispose.family<RoadmapWithSteps?, String>(
      (ref, roadmapId) async {
        final roadmapService = ref.watch(roadmapServiceProvider);
        return roadmapService.getRoadmapWithSteps(roadmapId);
      },
    );
