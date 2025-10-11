import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/analytics/analytics_service.dart';
import '../../data/repositories_impl/assessment_repository_impl.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/career_repository_impl.dart';
import '../../data/repositories_impl/progress_repository_impl.dart';
import '../../data/repositories_impl/roadmap_repository_impl.dart';
import '../../data/sources/local_prefs.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/career_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/roadmap_repository.dart';

/// Shared Preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized first');
});

/// Local preferences provider
final localPrefsProvider = Provider<LocalPrefs>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalPrefs(prefs);
});

/// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return MockAnalyticsService();
});

/// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localPrefs = ref.watch(localPrefsProvider);
  return AuthRepositoryImpl(localPrefs);
});

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepositoryImpl();
});

final careerRepositoryProvider = Provider<CareerRepository>((ref) {
  return CareerRepositoryImpl();
});

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  return RoadmapRepositoryImpl();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl();
});
