import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startad_agf_selfdiscovery/application/progress/progress_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the progress service
final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService(Supabase.instance.client);
});

/// Provider for discovery progress
/// Note: This is the canonical provider - use this instead of the one in activity_providers
final myProgressProvider =
    FutureProvider.autoDispose<DiscoveryProgress?>((ref) async {
  final progressService = ref.watch(progressServiceProvider);
  return progressService.getMyProgress();
});

/// Provider for profile completeness percentage
final myProfileCompletenessProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final progressService = ref.watch(progressServiceProvider);
  return progressService.getProfileCompleteness();
});
