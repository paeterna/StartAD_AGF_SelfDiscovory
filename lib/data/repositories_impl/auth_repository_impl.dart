import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/local_prefs.dart';

/// Mock implementation of AuthRepository
/// Extension point: Replace with Firebase Auth/Supabase in Phase-2
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._localPrefs);

  final LocalPrefs _localPrefs;
  final _authStateController = StreamController<User?>.broadcast();

  // Mock in-memory user database
  final Map<String, _MockUser> _users = {};
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    final userId = _localPrefs.getUserId();
    if (userId == null) return null;

    if (_currentUser == null && _users.containsKey(userId)) {
      final mockUser = _users[userId]!;
      _currentUser = User(
        id: userId,
        email: mockUser.email,
        displayName: mockUser.displayName,
        onboardingComplete: mockUser.onboardingComplete,
        locale: mockUser.locale,
        theme: mockUser.theme,
        createdAt: mockUser.createdAt,
        lastLoginAt: DateTime.now(),
      );
    }

    return _currentUser;
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Find user by email
    final entry = _users.entries.firstWhere(
      (e) => e.value.email == email,
      orElse: () => throw Exception('Invalid credentials'),
    );

    final mockUser = entry.value;

    // Check password
    if (mockUser.password != password) {
      throw Exception('Invalid credentials');
    }

    // Update last login
    mockUser.lastLoginAt = DateTime.now();

    _currentUser = User(
      id: entry.key,
      email: mockUser.email,
      displayName: mockUser.displayName,
      onboardingComplete: mockUser.onboardingComplete,
      locale: mockUser.locale,
      theme: mockUser.theme,
      createdAt: mockUser.createdAt,
      lastLoginAt: mockUser.lastLoginAt,
    );

    await _localPrefs.setUserId(entry.key);
    _authStateController.add(_currentUser);

    return _currentUser!;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    // Check if email already exists
    if (_users.values.any((u) => u.email == email)) {
      throw Exception('Email already in use');
    }

    // Check password strength
    if (password.length < 8) {
      throw Exception('Password too weak');
    }

    // Create new user
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    _users[userId] = _MockUser(
      email: email,
      password: password,
      displayName: displayName,
      onboardingComplete: false,
      locale: 'en',
      theme: ThemeModePreference.system,
      createdAt: now,
      lastLoginAt: now,
    );

    _currentUser = User(
      id: userId,
      email: email,
      displayName: displayName,
      onboardingComplete: false,
      locale: 'en',
      theme: ThemeModePreference.system,
      createdAt: now,
      lastLoginAt: now,
    );

    await _localPrefs.setUserId(userId);
    _authStateController.add(_currentUser);

    return _currentUser!;
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? null // Will use the URL configured in Supabase dashboard
            : null, // For mobile, Supabase handles this automatically
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      return true;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _localPrefs.clearUserId();
    _authStateController.add(null);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Check if user exists
    final userExists = _users.values.any((u) => u.email == email);
    if (!userExists) {
      throw Exception('User not found');
    }

    // In a real implementation, this would send an email
    // For now, just return success
  }

  @override
  Future<User> updateProfile({
    required String userId,
    String? displayName,
    String? locale,
    ThemeModePreference? theme,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!_users.containsKey(userId)) {
      throw Exception('User not found');
    }

    final mockUser = _users[userId]!;

    if (displayName != null) {
      mockUser.displayName = displayName;
    }
    if (locale != null) {
      mockUser.locale = locale;
      await _localPrefs.setLocale(locale);
    }
    if (theme != null) {
      mockUser.theme = theme;
      await _localPrefs.setTheme(theme.toJson());
    }

    _currentUser = _currentUser?.copyWith(
      displayName: mockUser.displayName,
      locale: mockUser.locale,
      theme: mockUser.theme,
    );

    _authStateController.add(_currentUser);

    return _currentUser!;
  }

  @override
  Future<User> completeOnboarding({required String userId}) async {
    if (!_users.containsKey(userId)) {
      throw Exception('User not found');
    }

    final mockUser = _users[userId]!;
    mockUser.onboardingComplete = true;

    _currentUser = _currentUser?.copyWith(onboardingComplete: true);
    await _localPrefs.setOnboardingComplete(true);

    _authStateController.add(_currentUser);

    return _currentUser!;
  }

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}

/// Mock user data class
class _MockUser {
  _MockUser({
    required this.email,
    required this.password,
    required this.displayName,
    required this.onboardingComplete,
    required this.locale,
    required this.theme,
    required this.createdAt,
    required this.lastLoginAt,
  });

  final String email;
  final String password;
  String displayName;
  bool onboardingComplete;
  String locale;
  ThemeModePreference theme;
  final DateTime createdAt;
  DateTime? lastLoginAt;
}
