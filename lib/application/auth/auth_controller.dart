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

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final user = await authRepo.signIn(email: email, password: password);
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final user = await authRepo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
      // The actual user session will be handled by Supabase auth state changes
      // So we just clear loading state here
      state = state.copyWith(isLoading: false);
    } catch (e) {
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.resetPassword(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
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
