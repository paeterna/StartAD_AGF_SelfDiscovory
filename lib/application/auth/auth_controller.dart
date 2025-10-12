import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../domain/entities/user.dart';

/// Auth state
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final User? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth controller
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    _init();
  }

  final Ref _ref;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isLoading: false);
    }
  }

  /// Refresh user state (called after OAuth callback)
  Future<void> refreshUser() async {
    debugPrint('🔵 [AUTH_CONTROLLER] refreshUser called');
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      debugPrint('✅ [AUTH_CONTROLLER] User refreshed: ${user?.id}');
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      debugPrint('🔴 [AUTH_CONTROLLER] refreshUser error: $e');
      state = AuthState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint('🔵 [AUTH_CONTROLLER] signIn called for: $email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      debugPrint('🔵 [AUTH_CONTROLLER] Calling repository signIn...');
      final user = await authRepo.signIn(email: email, password: password);
      debugPrint('✅ [AUTH_CONTROLLER] Repository signIn successful. User ID: ${user.id}');
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      debugPrint('🔴 [AUTH_CONTROLLER] signIn error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    debugPrint('🔵 [AUTH_CONTROLLER] signUp called for: $email (Display: $displayName)');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      debugPrint('🔵 [AUTH_CONTROLLER] Calling repository signUp...');
      final user = await authRepo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      debugPrint('✅ [AUTH_CONTROLLER] Repository signUp successful. User ID: ${user.id}');
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      debugPrint('🔴 [AUTH_CONTROLLER] signUp error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    debugPrint('🔵 [AUTH_CONTROLLER] signInWithGoogle called');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      debugPrint('🔵 [AUTH_CONTROLLER] Calling repository signInWithGoogle...');
      await authRepo.signInWithGoogle();
      debugPrint('✅ [AUTH_CONTROLLER] Repository signInWithGoogle initiated');
      debugPrint('🔵 [AUTH_CONTROLLER] OAuth flow started - user will be redirected');
      // The actual user session will be handled by Supabase auth state changes
      // So we just clear loading state here
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('🔴 [AUTH_CONTROLLER] signInWithGoogle error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.signOut();
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword({required String email}) async {
    debugPrint('🔵 [AUTH_CONTROLLER] resetPassword called for: $email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      debugPrint('🔵 [AUTH_CONTROLLER] Calling repository resetPassword...');
      await authRepo.resetPassword(email: email);
      debugPrint('✅ [AUTH_CONTROLLER] Repository resetPassword successful. Email sent to: $email');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('🔴 [AUTH_CONTROLLER] resetPassword error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? locale,
    ThemeModePreference? theme,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final user = await authRepo.updateProfile(
        userId: state.user!.id,
        displayName: displayName,
        locale: locale,
        theme: theme,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> completeOnboarding() async {
    if (state.user == null) return;

    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final analytics = _ref.read(analyticsServiceProvider);

      final user = await authRepo.completeOnboarding(userId: state.user!.id);
      state = state.copyWith(user: user);

      await analytics.logOnboardingComplete(userId: user.id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Auth controller provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
