import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/radar_data.dart';
import 'traits_repository.dart';

/// Provider for TraitsRepository
final Provider<TraitsRepository> traitsRepositoryProvider =
    Provider<TraitsRepository>((ref) {
      return TraitsRepository(Supabase.instance.client);
    });

/// Provider for radar chart data
final AutoDisposeFutureProvider<List<RadarDataPoint>> radarDataProvider =
    FutureProvider.autoDispose<List<RadarDataPoint>>((ref) async {
      final repository = ref.watch(traitsRepositoryProvider);
      return repository.getMyRadarData();
    });

/// Provider for radar data grouped by family
final AutoDisposeFutureProvider<RadarDataByFamily> radarDataByFamilyProvider =
    FutureProvider.autoDispose<RadarDataByFamily>((ref) async {
      final repository = ref.watch(traitsRepositoryProvider);
      return repository.getMyRadarDataByFamily();
    });

/// Provider to check if user has feature scores
final AutoDisposeFutureProvider<bool> hasFeatureScoresProvider =
    FutureProvider.autoDispose<bool>((ref) async {
      final repository = ref.watch(traitsRepositoryProvider);
      return repository.hasFeatureScores();
    });
