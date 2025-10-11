import '../entities/user.dart';

/// Auth repository interface
/// Extension point: Replace mock implementation with Firebase Auth/Supabase in Phase-2
abstract class AuthRepository {
  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Sign in with email and password
  Future<User> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle();

  /// Sign out current user
  Future<void> signOut();

  /// Reset password for given email
  Future<void> resetPassword({required String email});

  /// Update user profile
  Future<User> updateProfile({
    required String userId,
    String? displayName,
    String? locale,
    ThemeModePreference? theme,
  });

  /// Mark onboarding as complete
  Future<User> completeOnboarding({required String userId});

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
