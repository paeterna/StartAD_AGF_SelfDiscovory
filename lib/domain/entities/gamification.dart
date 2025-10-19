import 'package:flutter/foundation.dart';

/// Gamification profile containing XP, levels, streaks, and theme preferences
@immutable
class GamificationProfile {
  const GamificationProfile({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    this.themeKey = 'neon_arcade',
    this.avatarConfig = const {},
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final String themeKey;
  final Map<String, dynamic> avatarConfig;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Calculate XP needed for next level
  /// Formula: nextLevelXp = 100 * pow((level + 1) / 0.75, 1/0.75)
  int get xpForNextLevel {
    final nextLevel = level + 1;
    return (100 * pow(nextLevel / 0.75, 1 / 0.75)).round();
  }

  /// Calculate XP for current level
  int get xpForCurrentLevel {
    if (level == 0) return 0;
    return (100 * pow(level / 0.75, 1 / 0.75)).round();
  }

  /// Progress to next level (0.0 - 1.0)
  double get levelProgress {
    final currentLevelXp = xpForCurrentLevel;
    final nextLevelXp = xpForNextLevel;
    final xpInLevel = totalXp - currentLevelXp;
    final xpNeeded = nextLevelXp - currentLevelXp;
    return (xpInLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// XP remaining until next level
  int get xpUntilNextLevel => (xpForNextLevel - totalXp).clamp(0, double.infinity).toInt();

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    return GamificationProfile(
      userId: json['user_id'] as String,
      totalXp: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      themeKey: json['theme_key'] as String? ?? 'neon_arcade',
      avatarConfig: json['avatar_config'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_xp': totalXp,
      'level': level,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate?.toIso8601String(),
      'theme_key': themeKey,
      'avatar_config': avatarConfig,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  GamificationProfile copyWith({
    String? userId,
    int? totalXp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    String? themeKey,
    Map<String, dynamic>? avatarConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GamificationProfile(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      themeKey: themeKey ?? this.themeKey,
      avatarConfig: avatarConfig ?? this.avatarConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamificationProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          totalXp == other.totalXp &&
          level == other.level &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          themeKey == other.themeKey;

  @override
  int get hashCode =>
      userId.hashCode ^
      totalXp.hashCode ^
      level.hashCode ^
      currentStreak.hashCode ^
      longestStreak.hashCode ^
      themeKey.hashCode;
}

/// Badge earned by a user
@immutable
class Badge {
  const Badge({
    required this.id,
    required this.userId,
    required this.badgeKey,
    required this.earnedAt,
    this.metadata = const {},
  });

  final int id;
  final String userId;
  final String badgeKey;
  final DateTime earnedAt;
  final Map<String, dynamic> metadata;

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      badgeKey: json['badge_key'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_key': badgeKey,
      'earned_at': earnedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Badge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          badgeKey == other.badgeKey;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ badgeKey.hashCode;
}

/// Badge definition/catalog
@immutable
class BadgeDefinition {
  const BadgeDefinition({
    required this.key,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.condition,
    this.tier = 'bronze',
  });

  final String key;
  final String name;
  final String description;
  final String iconPath;
  final String condition; // Description of how to earn
  final String tier; // bronze, silver, gold, platinum

  factory BadgeDefinition.fromJson(Map<String, dynamic> json) {
    return BadgeDefinition(
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['icon_path'] as String,
      condition: json['condition'] as String,
      tier: json['tier'] as String? ?? 'bronze',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'icon_path': iconPath,
      'condition': condition,
      'tier': tier,
    };
  }
}

/// Telemetry event
@immutable
class TelemetryEvent {
  const TelemetryEvent({
    this.id,
    required this.userId,
    required this.eventKind,
    this.metadata = const {},
    this.createdAt,
  });

  final int? id;
  final String userId;
  final String eventKind;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  factory TelemetryEvent.fromJson(Map<String, dynamic> json) {
    return TelemetryEvent(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      eventKind: json['event_kind'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'event_kind': eventKind,
      'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

/// XP award reason and amount
@immutable
class XpAward {
  const XpAward({
    required this.reason,
    required this.amount,
    this.metadata = const {},
  });

  final String reason;
  final int amount;
  final Map<String, dynamic> metadata;
}

/// XP calculation constants from remote config
@immutable
class XpConstants {
  const XpConstants({
    required this.base,
    required this.k1,
    required this.k2,
    required this.k3,
  });

  final int base;
  final double k1;
  final double k2;
  final double k3;

  factory XpConstants.fromJson(Map<String, dynamic> json) {
    return XpConstants(
      base: json['base'] as int? ?? 10,
      k1: (json['k1'] as num?)?.toDouble() ?? 2.0,
      k2: (json['k2'] as num?)?.toDouble() ?? 1.5,
      k3: (json['k3'] as num?)?.toDouble() ?? 1.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'k1': k1,
      'k2': k2,
      'k3': k3,
    };
  }

  /// Calculate XP gain from game/quiz completion
  int calculateXpGain({
    required double deltaComposite,
    required double deltaAttention,
    required double deltaMemory,
  }) {
    final xp = base + (k1 * deltaComposite) + (k2 * deltaAttention) + (k3 * deltaMemory);
    return xp.round().clamp(0, 1000); // Cap at 1000 XP per activity
  }
}

// Helper function for pow
double pow(num x, num exponent) {
  return x < 0 ? 0 : x.toDouble().clamp(0, double.infinity);
}
