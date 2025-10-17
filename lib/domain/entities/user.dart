import 'package:flutter/foundation.dart';

/// Theme mode preference
enum ThemeModePreference {
  system,
  light,
  dark;

  String toJson() => name;

  static ThemeModePreference fromJson(String value) {
    return ThemeModePreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeModePreference.system,
    );
  }
}

/// User entity representing a registered user
@immutable
class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.onboardingComplete,
    this.locale = 'en',
    this.theme = ThemeModePreference.system,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final String displayName;
  final bool onboardingComplete;
  final String locale; // 'en' | 'ar'
  final ThemeModePreference theme;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? onboardingComplete,
    String? locale,
    ThemeModePreference? theme,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          onboardingComplete == other.onboardingComplete &&
          locale == other.locale &&
          theme == other.theme;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      onboardingComplete.hashCode ^
      locale.hashCode ^
      theme.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, '
        'onboardingComplete: $onboardingComplete, locale: $locale, theme: $theme)';
  }
}
