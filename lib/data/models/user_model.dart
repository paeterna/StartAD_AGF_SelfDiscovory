import '../../domain/entities/user.dart';

/// User model for data layer serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.onboardingComplete,
    super.locale,
    super.theme,
    super.createdAt,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      locale: json['locale'] as String? ?? 'en',
      theme: json['theme'] != null
          ? ThemeModePreference.fromJson(json['theme'] as String)
          : ThemeModePreference.system,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'onboardingComplete': onboardingComplete,
      'locale': locale,
      'theme': theme.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      onboardingComplete: user.onboardingComplete,
      locale: user.locale,
      theme: user.theme,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }
}
