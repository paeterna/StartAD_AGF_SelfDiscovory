import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user profiles
/// Purpose: per-user preferences (display name, locale, theme, onboarding flag)
/// Owner key: id = auth.users.id
/// Write path: created automatically via trigger, updated from Settings
/// Read path: load at app bootstrap to pick locale and theme
class ProfilesService {
  ProfilesService(this._supabase);

  final SupabaseClient _supabase;

  /// Get current user's profile
  Future<UserProfile?> getMyProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('profiles')
        .select('id, display_name, locale, theme, onboarding_complete, created_at')
        .eq('id', userId)
        .maybeSingle();

    return response != null ? UserProfile.fromJson(response) : null;
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? locale, // 'en' | 'ar'
    String? theme, // 'system' | 'light' | 'dark'
    bool? onboardingComplete,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (locale != null) updates['locale'] = locale;
    if (theme != null) updates['theme'] = theme;
    if (onboardingComplete != null) {
      updates['onboarding_complete'] = onboardingComplete;
    }

    if (updates.isEmpty) return;

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await updateProfile(onboardingComplete: true);
  }
}

/// User profile model
class UserProfile {
  const UserProfile({
    required this.id,
    this.displayName,
    required this.locale,
    required this.theme,
    required this.onboardingComplete,
    required this.createdAt,
  });

  final String id;
  final String? displayName;
  final String locale; // 'en' | 'ar'
  final String theme; // 'system' | 'light' | 'dark'
  final bool onboardingComplete;
  final DateTime createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      locale: json['locale'] as String,
      theme: json['theme'] as String,
      onboardingComplete: json['onboarding_complete'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'locale': locale,
      'theme': theme,
      'onboarding_complete': onboardingComplete,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
