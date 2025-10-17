import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing parental/guardian consent or privacy acknowledgements
/// Purpose: manage consent records per user and version
/// Owner key: user_id. Unique per (user_id, version)
/// Write path: when user accepts latest consent in onboarding; support revoke
/// Read path: check if user has accepted latest version
class ConsentService {
  ConsentService(this._supabase);

  final SupabaseClient _supabase;

  /// Record or update consent
  /// Status: 'accepted' | 'declined' | 'revoked'
  Future<void> upsert({
    required String version,
    required String status, // 'accepted' | 'declined' | 'revoked'
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Validate status
    if (!['accepted', 'declined', 'revoked'].contains(status)) {
      throw ArgumentError(
        'Invalid status. Must be accepted, declined, or revoked',
      );
    }

    await _supabase.from('consents').upsert({
      'user_id': userId,
      'version': version,
      'status': status,
    });
  }

  /// Get latest consent record for current user
  Future<Consent?> latest() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('consents')
        .select('id, version, status, accepted_at')
        .eq('user_id', userId)
        .order('accepted_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response != null ? Consent.fromJson(response) : null;
  }

  /// Check if user has accepted a specific version
  Future<bool> hasAccepted(String version) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('consents')
        .select('status')
        .eq('user_id', userId)
        .eq('version', version)
        .maybeSingle();

    return response != null && response['status'] == 'accepted';
  }

  /// Get all consent records for current user
  Future<List<Consent>> getAll() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('consents')
        .select('id, version, status, accepted_at')
        .eq('user_id', userId)
        .order('accepted_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Consent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Accept consent (helper)
  Future<void> accept(String version) async {
    await upsert(version: version, status: 'accepted');
  }

  /// Decline consent (helper)
  Future<void> decline(String version) async {
    await upsert(version: version, status: 'declined');
  }

  /// Revoke consent (helper)
  Future<void> revoke(String version) async {
    await upsert(version: version, status: 'revoked');
  }
}

/// Consent record model
class Consent {
  const Consent({
    required this.id,
    required this.version,
    required this.status,
    required this.acceptedAt,
  });

  final int id;
  final String version;
  final String status; // 'accepted' | 'declined' | 'revoked'
  final DateTime acceptedAt;

  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isRevoked => status == 'revoked';

  factory Consent.fromJson(Map<String, dynamic> json) {
    return Consent(
      id: json['id'] as int,
      version: json['version'] as String,
      status: json['status'] as String,
      acceptedAt: DateTime.parse(json['accepted_at'] as String),
    );
  }
}
