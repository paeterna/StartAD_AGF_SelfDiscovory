import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/radar_data.dart';

/// Repository for fetching user trait and feature data for visualization
class TraitsRepository {
  final SupabaseClient _supabase;

  const TraitsRepository(this._supabase);

  /// Fetch radar chart data for the current user
  /// Returns user scores vs cohort averages for all 22 features
  Future<List<RadarDataPoint>> getMyRadarData() async {
    final result = await _supabase.rpc<List<dynamic>>('get_my_radar_data');

    return result
        .map((item) => RadarDataPoint.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetch radar data grouped by family (RIASEC, Cognition, Traits)
  Future<RadarDataByFamily> getMyRadarDataByFamily() async {
    final allPoints = await getMyRadarData();
    return RadarDataByFamily.fromList(allPoints);
  }

  /// Fetch radar data from view (alternative method if RPC is not preferred)
  Future<List<RadarDataPoint>> getMyRadarDataFromView() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final result = await _supabase
        .from('v_user_radar')
        .select()
        .eq('user_id', userId)
        .order('feature_index');

    return (result as List<dynamic>)
        .map((item) => RadarDataPoint.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Check if user has any feature scores
  Future<bool> hasFeatureScores() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    final result = await _supabase
        .from('user_feature_scores')
        .select('id')
        .eq('user_id', userId)
        .limit(1);

    return result.isNotEmpty;
  }
}
