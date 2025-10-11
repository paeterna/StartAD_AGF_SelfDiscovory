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
    _supabase.auth.onAuthStateChange.listen((data) {
      final supabaseUser = data.session?.user;
      if (supabaseUser != null) {
        _currentUser = _toDomainUser(supabaseUser);
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
      displayName: metadata['display_name'] as String? ??
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

  @override
  Future<User?> getCurrentUser() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser == null) {
        await _localPrefs.clearUserId();
        return null;
      }

      _currentUser = _toDomainUser(supabaseUser);
      await _localPrefs.setUserId(_currentUser!.id);

      return _currentUser;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      _currentUser = _toDomainUser(response.user!);
      await _localPrefs.setUserId(_currentUser!.id);
      _authStateController.add(_currentUser);

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
      debugPrint('🔵 [AUTH_REPO] Session: ${response.session?.accessToken != null ? "present" : "null"}');

      if (response.user == null) {
        debugPrint('🔴 [AUTH_REPO] No user in response - sign up may require email confirmation');
        throw Exception('Sign up failed - please check your email for confirmation link');
      }

      debugPrint('✅ [AUTH_REPO] User created successfully: ${response.user!.email}');

      _currentUser = _toDomainUser(response.user!);
      await _localPrefs.setUserId(_currentUser!.id);
      _authStateController.add(_currentUser);

      return _currentUser!;
    } on AuthException catch (e) {
      debugPrint('🔴 [AUTH_REPO] AuthException: ${e.message} (status: ${e.statusCode})');
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
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );

      // For web, this will redirect and the session will be picked up on return
      // For mobile, check if we got a user
      if (!kIsWeb && _supabase.auth.currentUser != null) {
        _currentUser = _toDomainUser(_supabase.auth.currentUser!);
        await _localPrefs.setUserId(_currentUser!.id);
        _authStateController.add(_currentUser);
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
      final currentMetadata = _supabase.auth.currentUser?.userMetadata ?? {};

      final updates = <String, dynamic>{
        ...currentMetadata,
        if (displayName != null) 'display_name': displayName,
        if (locale != null) 'locale': locale,
        if (theme != null) 'theme': theme.toJson(),
      };

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );

      if (response.user == null) {
        throw Exception('Failed to update profile');
      }

      _currentUser = _toDomainUser(response.user!);
      _authStateController.add(_currentUser);

      return _currentUser!;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<User> completeOnboarding({required String userId}) async {
    try {
      final currentMetadata = _supabase.auth.currentUser?.userMetadata ?? {};

      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            ...currentMetadata,
            'onboarding_complete': true,
          },
        ),
      );

      if (response.user == null) {
        throw Exception('Failed to complete onboarding');
      }

      _currentUser = _toDomainUser(response.user!);
      _authStateController.add(_currentUser);

      return _currentUser!;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Onboarding completion failed: ${e.toString()}');
    }
  }

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
