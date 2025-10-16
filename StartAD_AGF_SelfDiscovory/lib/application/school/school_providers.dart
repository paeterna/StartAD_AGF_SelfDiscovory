import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/school.dart';
import '../../data/repositories/school_repository.dart';

// =====================================================
// Repository Provider
// =====================================================

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  final supabase = Supabase.instance.client;
  return SchoolRepository(supabase);
});

// =====================================================
// School Data Providers
// =====================================================

/// Get all active schools for selection
final activeSchoolsProvider = FutureProvider<List<School>>((ref) async {
  final repository = ref.watch(schoolRepositoryProvider);
  return repository.getActiveSchools();
});

/// Search schools by query
final FutureProviderFamily<List<School>, String> searchSchoolsProvider =
    FutureProvider.family<List<School>, String>((ref, query) async {
      if (query.isEmpty) {
        return ref.watch(activeSchoolsProvider).value ?? [];
      }
      final repository = ref.watch(schoolRepositoryProvider);
      return repository.searchSchools(query);
    });

/// Get current admin's school
final mySchoolProvider = FutureProvider<School?>((ref) async {
  final repository = ref.watch(schoolRepositoryProvider);
  return repository.getMySchool();
});

/// Check if current user is school admin
final isSchoolAdminProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(schoolRepositoryProvider);
  return repository.isSchoolAdmin();
});

// =====================================================
// School Dashboard Providers
// =====================================================

/// Get school KPIs
final FutureProviderFamily<SchoolKpis, String> schoolKpisProvider =
    FutureProvider.family<SchoolKpis, String>((ref, schoolId) async {
      final repository = ref.watch(schoolRepositoryProvider);
      return repository.getSchoolKpis(schoolId);
    });

/// Get top students for school
final FutureProviderFamily<List<TopStudent>, String> schoolTopStudentsProvider =
    FutureProvider.family<List<TopStudent>, String>((ref, schoolId) async {
      final repository = ref.watch(schoolRepositoryProvider);
      return repository.getTopStudents(schoolId);
    });

/// Get individual student detail by user ID
final FutureProviderFamily<TopStudent?, String> studentDetailProvider =
    FutureProvider.family<TopStudent?, String>((ref, userId) async {
      final repository = ref.watch(schoolRepositoryProvider);
      return repository.getStudentDetail(userId);
    });

/// Get career distribution for school
final FutureProviderFamily<List<CareerDistribution>, String>
schoolCareerDistributionProvider =
    FutureProvider.family<List<CareerDistribution>, String>((
      ref,
      schoolId,
    ) async {
      final repository = ref.watch(schoolRepositoryProvider);
      return repository.getCareerDistribution(schoolId);
    });

/// Get school feature averages for radar
final FutureProviderFamily<List<SchoolFeatureAverage>, String>
schoolFeatureAveragesProvider =
    FutureProvider.family<List<SchoolFeatureAverage>, String>((
      ref,
      schoolId,
    ) async {
      final repository = ref.watch(schoolRepositoryProvider);
      return repository.getSchoolFeatureAverages(schoolId);
    });

// =====================================================
// School Students List Provider
// =====================================================

/// Parameters for students list
class SchoolStudentsParams {
  final String schoolId;
  final String? search;
  final int limit;
  final int offset;

  const SchoolStudentsParams({
    required this.schoolId,
    this.search,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolStudentsParams &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId &&
          search == other.search &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode =>
      schoolId.hashCode ^ search.hashCode ^ limit.hashCode ^ offset.hashCode;
}

/// Get students list with search and pagination
final FutureProviderFamily<List<SchoolStudent>, SchoolStudentsParams>
schoolStudentsProvider =
    FutureProvider.family<List<SchoolStudent>, SchoolStudentsParams>((
      ref,
      params,
    ) async {
      final repository = ref.watch(schoolRepositoryProvider);
      return repository.getSchoolStudents(
        schoolId: params.schoolId,
        search: params.search,
        limit: params.limit,
        offset: params.offset,
      );
    });

// =====================================================
// School Assignment Controller
// =====================================================

/// Controller for assigning students to schools
final Provider<SchoolAssignmentController> schoolAssignmentControllerProvider =
    Provider((ref) {
      final repository = ref.watch(schoolRepositoryProvider);
      return SchoolAssignmentController(repository);
    });

class SchoolAssignmentController {
  final SchoolRepository _repository;

  SchoolAssignmentController(this._repository);

  Future<void> assignStudentToSchool({
    required String userId,
    required String? schoolId,
  }) async {
    await _repository.assignStudentToSchool(
      userId: userId,
      schoolId: schoolId,
    );
  }
}
