import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/local_prefs.dart';

/// Supabase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._localPrefs) {
    // Listen to Supabase auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final supabaseUser = data.session?.user;
      if (supabaseUser != null) {
        _currentUser = await _loadUserProfile(supabaseUser);
        _authStateController.add(_currentUser);
      } else {
        _currentUser = null;
        _authStateController.add(null);
      }
    });
  }

  final LocalPrefs _localPrefs;
  final _authStateController = StreamController<User?>.broadcast();

  // Get Supabase client instance
  SupabaseClient get _supabase => Supabase.instance.client;

  User? _currentUser;

  /// Convert Supabase User to domain User entity
  User _toDomainUser(supabase.User supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName:
          metadata['display_name'] as String? ??
          supabaseUser.email?.split('@').first ??
          'User',
      onboardingComplete: metadata['onboarding_complete'] as bool? ?? false,
      locale: metadata['locale'] as String? ?? 'en',
      theme: ThemeModePreference.fromJson(
        metadata['theme'] as String? ?? 'system',
      ),
      createdAt: DateTime.parse(supabaseUser.createdAt),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Load user profile from profiles table and sync with user_metadata
  Future<User?> _loadUserProfile(supabase.User supabaseUser) async {
    try {
      // First, try to get profile from profiles table
      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();

      if (profileResponse != null) {
        // Profile exists in database, use it as source of truth
        return User(
          id: supabaseUser.id,
          email: supabaseUser.email ?? '',
          displayName: profileResponse['display_name'] as String? ?? 'User',
          onboardingComplete:
              profileResponse['onboarding_complete'] as bool? ?? false,
          locale: profileResponse['locale'] as String? ?? 'en',
          theme: ThemeModePreference.fromJson(
            profileResponse['theme'] as String? ?? 'system',
          ),
          createdAt: DateTime.parse(profileResponse['created_at'] as String),
          lastLoginAt: DateTime.now(),
        );
      } else {
        // Profile doesn't exist, create it from user_metadata
        debugPrint(
          '🔵 [AUTH_REPO] Profile not found, creating from metadata...',
        );
        final metadata = supabaseUser.userMetadata ?? {};

        final newProfile = {
          'id': supabaseUser.id,
          'display_name':
              metadata['display_name'] as String? ??
              supabaseUser.email?.split('@').first ??
              'User',
          'locale': metadata['locale'] as String? ?? 'en',
          'theme': metadata['theme'] as String? ?? 'system',
          'onboarding_complete':
              metadata['onboarding_complete'] as bool? ?? false,
        };

        await _supabase.from('profiles').insert(newProfile);

        return User(
          id: supabaseUser.id,
          email: supabaseUser.email ?? '',
          displayName: newProfile['display_name']! as String,
          onboardingComplete: newProfile['onboarding_complete']! as bool,
          locale: newProfile['locale']! as String,
          theme: ThemeModePreference.fromJson(newProfile['theme']! as String),
          createdAt: DateTime.parse(supabaseUser.createdAt),
          lastLoginAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('🔴 [AUTH_REPO] Error loading profile: $e');
      // Fallback to user_metadata
      return _toDomainUser(supabaseUser);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser == null) {
        await _localPrefs.clearUserId();
        return null;
      }

      _currentUser = await _loadUserProfile(supabaseUser);
      if (_currentUser != null) {
        await _localPrefs.setUserId(_currentUser!.id);
      }

      return _currentUser;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      _currentUser = await _loadUserProfile(response.user!);
      if (_currentUser != null) {
        await _localPrefs.setUserId(_currentUser!.id);
        _authStateController.add(_currentUser);
      }

      return _currentUser!;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      debugPrint('🔵 [AUTH_REPO] Calling Supabase signUp for: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'onboarding_complete': false,
          'locale': 'en',
          'theme': 'system',
        },
      );

      debugPrint('🔵 [AUTH_REPO] Supabase response received');
      debugPrint('🔵 [AUTH_REPO] User: ${response.user?.id}');
      debugPrint(
        '🔵 [AUTH_REPO] Session: ${response.session?.accessToken != null ? "present" : "null"}',
      );

      if (response.user == null) {
        debugPrint(
          '🔴 [AUTH_REPO] No user in response - sign up may require email confirmation',
        );
        throw Exception(
          'Sign up failed - please check your email for confirmation link',
        );
      }

      debugPrint(
        '✅ [AUTH_REPO] User created successfully: ${response.user!.email}',
      );

      // Create profile in profiles table
      try {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'display_name': displayName,
          'locale': 'en',
          'theme': 'system',
          'onboarding_complete': false,
        });
        debugPrint('✅ [AUTH_REPO] Profile created in profiles table');
      } catch (e) {
        debugPrint(
          '⚠️ [AUTH_REPO] Profile creation failed (may already exist): $e',
        );
      }

      _currentUser = await _loadUserProfile(response.user!);
      if (_currentUser != null) {
        await _localPrefs.setUserId(_currentUser!.id);
        _authStateController.add(_currentUser);
      }

      return _currentUser!;
    } on AuthException catch (e) {
      debugPrint(
        '🔴 [AUTH_REPO] AuthException: ${e.message} (status: ${e.statusCode})',
      );

      // Provide user-friendly error messages
      if (e.message.contains('email_address_invalid')) {
        throw Exception(
          'This email is already registered. Please sign in instead or use a different email.',
        );
      } else if (e.message.contains('User already registered')) {
        throw Exception(
          'This email is already registered. Please sign in instead.',
        );
      }

      throw Exception(e.message);
    } catch (e) {
      debugPrint('🔴 [AUTH_REPO] Unknown error: $e');
      debugPrint('🔴 [AUTH_REPO] Error type: ${e.runtimeType}');
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? '${Uri.base.origin}/auth/callback' : null,
        queryParams: {'access_type': 'offline', 'prompt': 'consent'},
      );

      // For web, this will redirect and the session will be picked up on return
      // For mobile, check if we got a user
      if (!kIsWeb && _supabase.auth.currentUser != null) {
        _currentUser = await _loadUserProfile(_supabase.auth.currentUser!);
        if (_currentUser != null) {
          await _localPrefs.setUserId(_currentUser!.id);
          _authStateController.add(_currentUser);
        }
        return true;
      }

      return true;
    } on AuthException catch (e) {
      debugPrint('Google sign-in error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      throw Exception('Google sign-in failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      await _localPrefs.clearUserId();
      _authStateController.add(null);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? '${Uri.base.origin}/reset-password' : null,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<User> updateProfile({
    required String userId,
    String? displayName,
    String? locale,
    ThemeModePreference? theme,
  }) async {
    try {
      // Update profiles table (source of truth)
      final profileUpdates = <String, dynamic>{};
      if (displayName != null) profileUpdates['display_name'] = displayName;
      if (locale != null) profileUpdates['locale'] = locale;
      if (theme != null) profileUpdates['theme'] = theme.toJson();

      if (profileUpdates.isNotEmpty) {
        await _supabase
            .from('profiles')
            .update(profileUpdates)
            .eq('id', userId);

        debugPrint(
          '✅ [AUTH_REPO] Profile updated in profiles table: $profileUpdates',
        );
      }

      // Also update user_metadata for quick access
      final currentMetadata = _supabase.auth.currentUser?.userMetadata ?? {};
      final metadataUpdates = <String, dynamic>{
        ...currentMetadata,
        if (displayName != null) 'display_name': displayName,
        if (locale != null) 'locale': locale,
        if (theme != null) 'theme': theme.toJson(),
      };

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: metadataUpdates),
      );

      if (response.user == null) {
        throw Exception('Failed to update profile');
      }

      // Reload profile from database to ensure consistency
      _currentUser = await _loadUserProfile(response.user!);
      if (_currentUser != null) {
        _authStateController.add(_currentUser);
      }

      return _currentUser!;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<User> completeOnboarding({
    required String userId,
    Map<String, String>? onboardingAnswers,
  }) async {
    try {
      debugPrint(
        '🎯 [AUTH_REPO] Starting onboarding completion for user: $userId',
      );

      // If we have onboarding answers, process them and save to assessments table
      if (onboardingAnswers != null && onboardingAnswers.isNotEmpty) {
        debugPrint(
          '📝 [AUTH_REPO] Processing ${onboardingAnswers.length} onboarding answers',
        );

        // Convert answers to trait scores based on a simple scoring system
        final traitScores = _calculateTraitScores(onboardingAnswers);

        debugPrint('🧮 [AUTH_REPO] Calculated trait scores: $traitScores');

        // Save assessment results to the assessments table
        await _supabase.from('assessments').insert({
          'user_id': userId,
          'trait_scores': traitScores,
          'delta_progress':
              15, // Award 15 progress points for completing onboarding
          'taken_at': DateTime.now().toIso8601String(),
        });

        debugPrint('✅ [AUTH_REPO] Saved assessment results to database');
      }

      // Update profiles table to mark onboarding as complete
      await _supabase
          .from('profiles')
          .update({'onboarding_complete': true})
          .eq('id', userId);

      // Also update user_metadata for quick access
      final currentMetadata = _supabase.auth.currentUser?.userMetadata ?? {};
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: {...currentMetadata, 'onboarding_complete': true}),
      );

      if (response.user == null) {
        throw Exception('Failed to complete onboarding');
      }

      debugPrint('✅ [AUTH_REPO] Onboarding completed successfully');

      // Reload profile from database to ensure consistency
      _currentUser = await _loadUserProfile(response.user!);
      if (_currentUser != null) {
        _authStateController.add(_currentUser);
      }

      return _currentUser!;
    } on AuthException catch (e) {
      debugPrint(
        '🔴 [AUTH_REPO] AuthException during onboarding completion: ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint('🔴 [AUTH_REPO] Error during onboarding completion: $e');
      throw Exception('Onboarding completion failed: ${e.toString()}');
    }
  }

  /// Calculate trait scores based on onboarding answers
  /// This is a simple scoring system that maps answers to personality traits
  Map<String, int> _calculateTraitScores(Map<String, String> answers) {
    // Initialize trait scores
    final scores = <String, int>{
      'analytical': 0,
      'creative': 0,
      'collaborative': 0,
      'persistent': 0,
      'curious': 0,
    };

    // Process each answer and add to appropriate traits
    // Question 1: Problem-solving approach
    final q1Answer = answers['question_1'];
    if (q1Answer != null) {
      if (q1Answer.contains('logically') || q1Answer.contains('منطقياً')) {
        scores['analytical'] = scores['analytical']! + 2;
        scores['persistent'] = scores['persistent']! + 1;
      } else if (q1Answer.contains('creatively') ||
          q1Answer.contains('إبداعية')) {
        scores['creative'] = scores['creative']! + 2;
        scores['curious'] = scores['curious']! + 1;
      } else if (q1Answer.contains('others') || q1Answer.contains('الآخرين')) {
        scores['collaborative'] = scores['collaborative']! + 2;
        scores['curious'] = scores['curious']! + 1;
      }
    }

    // Question 2: Energy source
    final q2Answer = answers['question_2'];
    if (q2Answer != null) {
      if (q2Answer.contains('independently') || q2Answer.contains('مستقل')) {
        scores['analytical'] = scores['analytical']! + 1;
        scores['persistent'] = scores['persistent']! + 2;
      } else if (q2Answer.contains('team') || q2Answer.contains('فريق')) {
        scores['collaborative'] = scores['collaborative']! + 2;
        scores['creative'] = scores['creative']! + 1;
      } else if (q2Answer.contains('leading') || q2Answer.contains('أقود')) {
        scores['collaborative'] = scores['collaborative']! + 1;
        scores['persistent'] = scores['persistent']! + 2;
      }
    }

    // Question 3: Project approach
    final q3Answer = answers['question_3'];
    if (q3Answer != null) {
      if (q3Answer.contains('established') || q3Answer.contains('المجربة')) {
        scores['analytical'] = scores['analytical']! + 2;
        scores['persistent'] = scores['persistent']! + 1;
      } else if (q3Answer.contains('new') || q3Answer.contains('جديدة')) {
        scores['creative'] = scores['creative']! + 2;
        scores['curious'] = scores['curious']! + 2;
      } else if (q3Answer.contains('combine') || q3Answer.contains('أدمج')) {
        scores['analytical'] = scores['analytical']! + 1;
        scores['creative'] = scores['creative']! + 1;
        scores['collaborative'] = scores['collaborative']! + 1;
      }
    }

    // Question 4: Learning interests
    final q4Answer = answers['question_4'];
    if (q4Answer != null) {
      if (q4Answer.contains('new skills') ||
          q4Answer.contains('مهارات جديدة')) {
        scores['curious'] = scores['curious']! + 2;
        scores['creative'] = scores['creative']! + 1;
      } else if (q4Answer.contains('mastering') || q4Answer.contains('إتقان')) {
        scores['persistent'] = scores['persistent']! + 2;
        scores['analytical'] = scores['analytical']! + 1;
      } else if (q4Answer.contains('practically') ||
          q4Answer.contains('عملياً')) {
        scores['analytical'] = scores['analytical']! + 1;
        scores['collaborative'] = scores['collaborative']! + 1;
        scores['persistent'] = scores['persistent']! + 1;
      }
    }

    // Question 5: Task approach
    final q5Answer = answers['question_5'];
    if (q5Answer != null) {
      if (q5Answer.contains('big picture') || q5Answer.contains('الكبيرة')) {
        scores['creative'] = scores['creative']! + 2;
        scores['curious'] = scores['curious']! + 1;
      } else if (q5Answer.contains('details') ||
          q5Answer.contains('التفاصيل')) {
        scores['analytical'] = scores['analytical']! + 2;
        scores['persistent'] = scores['persistent']! + 1;
      } else if (q5Answer.contains('balance') || q5Answer.contains('أوازن')) {
        scores['collaborative'] = scores['collaborative']! + 2;
        scores['analytical'] = scores['analytical']! + 1;
      }
    }

    // Normalize scores to be between 1-5
    final normalizedScores = <String, int>{};
    for (final entry in scores.entries) {
      // Convert raw scores (0-8 range) to 1-5 scale
      final normalizedScore = ((entry.value / 8.0) * 4).round() + 1;
      normalizedScores[entry.key] = normalizedScore.clamp(1, 5);
    }

    return normalizedScores;
  }

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
