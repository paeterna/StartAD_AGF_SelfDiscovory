import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
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

/// Locale provider - manages app language (en/ar)
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._localPrefs) : super(const Locale('en')) {
    _loadLocale();
  }

  final LocalPrefs _localPrefs;

  Future<void> _loadLocale() async {
    final savedLocale = _localPrefs.getLocale();
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(String languageCode) async {
    await _localPrefs.setLocale(languageCode);
    state = Locale(languageCode);
    debugPrint('🔵 [LOCALE] Locale changed to: $languageCode');
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'en' ? 'ar' : 'en';
    setLocale(newLocale);
  }

  /// Sync locale from user profile (when user logs in or updates profile)
  void syncFromUser(String? userLocale) {
    if (userLocale != null && userLocale != state.languageCode) {
      state = Locale(userLocale);
      _localPrefs.setLocale(userLocale);
      debugPrint('🔵 [LOCALE] Synced locale from user profile: $userLocale');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final localPrefs = ref.watch(localPrefsProvider);
  return LocaleNotifier(localPrefs);
});
