import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/school.dart';

/// Repository for school data access
class SchoolRepository {
  final SupabaseClient _supabase;

  const SchoolRepository(this._supabase);

  /// Get all active schools for selection dropdown
  Future<List<School>> getActiveSchools() async {
    final response = await _supabase
        .from('schools')
        .select()
        .eq('active', true)
        .order('name');

    return (response as List<dynamic>)
        .map((json) => School.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search schools by name or code
  Future<List<School>> searchSchools(String query) async {
    final response = await _supabase
        .from('schools')
        .select()
        .eq('active', true)
        .or('name.ilike.%$query%,code.ilike.%$query%')
        .order('name')
        .limit(20);

    return (response as List<dynamic>)
        .map((json) => School.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get school by ID
  Future<School?> getSchoolById(String schoolId) async {
    final response = await _supabase
        .from('schools')
        .select()
        .eq('id', schoolId)
        .maybeSingle();

    if (response == null) return null;

    return School.fromJson(response);
  }

  /// Get school for current admin user
  Future<School?> getMySchool() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    // Get school_id from school_admins mapping
    final adminMapping = await _supabase
        .from('school_admins')
        .select('school_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (adminMapping == null) return null;

    final schoolId = adminMapping['school_id'] as String;
    return getSchoolById(schoolId);
  }

  /// Get school KPIs for dashboard
  Future<SchoolKpis> getSchoolKpis(String schoolId) async {
    final response = await _supabase.rpc<List<dynamic>>(
      'get_school_kpis',
      params: {'p_school_id': schoolId},
    );

    if (response.isEmpty) {
      return const SchoolKpis(
        totalStudents: 0,
        avgProfileCompletion: 0.0,
        avgMatchConfidence: 0.0,
      );
    }

    return SchoolKpis.fromJson(response.first as Map<String, dynamic>);
  }

  /// Get top students for school
  Future<List<TopStudent>> getTopStudents(
    String schoolId, {
    int limit = 5,
  }) async {
    final response = await _supabase.rpc<List<dynamic>>(
      'get_school_top_students',
      params: {
        'p_school_id': schoolId,
        'p_limit': limit,
      },
    );

    return response
        .map((json) => TopStudent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get career distribution for school
  Future<List<CareerDistribution>> getCareerDistribution(
    String schoolId,
  ) async {
    final response = await _supabase.rpc<List<dynamic>>(
      'get_school_career_distribution',
      params: {'p_school_id': schoolId},
    );

    return response
        .map(
          (json) => CareerDistribution.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get students list for school with search and pagination
  Future<List<SchoolStudent>> getSchoolStudents({
    required String schoolId,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _supabase.rpc<List<dynamic>>(
      'get_school_students',
      params: {
        'p_school_id': schoolId,
        'p_search': search,
        'p_limit': limit,
        'p_offset': offset,
      },
    );

    return response
        .map((json) => SchoolStudent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get individual student details by user ID
  Future<TopStudent?> getStudentDetail(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('''
          id,
          display_name,
          email,
          profile_completion,
          last_activity,
          (
            SELECT COALESCE(AVG(CAST(mean AS NUMERIC)), 0)
            FROM user_feature_scores
            WHERE user_id = profiles.id
          ) as overall_strength
        ''')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return TopStudent(
      userId: response['id'] as String,
      displayName: response['display_name'] as String?,
      email: response['email'] as String?,
      profileCompletion: ((response['profile_completion'] ?? 0) as num).toDouble(),
      overallStrength: ((response['overall_strength'] ?? 0) as num).toDouble(),
      lastActivity: response['last_activity'] != null
          ? DateTime.parse(response['last_activity'] as String)
          : null,
    );
  }

  /// Get school feature averages for radar chart
  Future<List<SchoolFeatureAverage>> getSchoolFeatureAverages(
    String schoolId,
  ) async {
    final response = await _supabase
        .from('v_school_feature_means')
        .select()
        .eq('school_id', schoolId)
        .order('feature_id');

    return (response as List<dynamic>)
        .map(
          (json) => SchoolFeatureAverage.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Check if current user is a school admin
  Future<bool> isSchoolAdmin() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final metadata = _supabase.auth.currentUser?.userMetadata;
    final role = metadata?['role'] as String?;

    return role == 'school_admin';
  }

  /// Update student's school assignment
  Future<void> assignStudentToSchool({
    required String userId,
    required String? schoolId,
  }) async {
    await _supabase
        .from('profiles')
        .update({'school_id': schoolId})
        .eq('id', userId);
  }
}
