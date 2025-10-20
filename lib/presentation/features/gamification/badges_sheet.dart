import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/gamification/gamification_providers.dart';
import '../../../application/gamification/remote_config_service.dart';
import '../../../domain/entities/gamification.dart' as gam;

/// Bottom sheet displaying user's badge collection
/// Shows earned badges and locked badges with progress indicators
class BadgesSheet extends ConsumerWidget {
  const BadgesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BadgesSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);
    final catalogAsync = ref.watch(badgeCatalogProvider);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge Collection',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      badgesAsync.when(
                        data: (badges) => Text(
                          '${badges.length} earned',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Badge grid
          Expanded(
            child: catalogAsync.when(
              data: (catalog) {
                return badgesAsync.when(
                  data: (earnedBadges) {
                    // Get earned badge keys for quick lookup
                    final earnedKeys = earnedBadges.map((b) => b.badgeKey).toSet();

                    // Sort: earned first, then by tier
                    final sortedCatalog = catalog.entries.toList()
                      ..sort((a, b) {
                        final aEarned = earnedKeys.contains(a.key);
                        final bEarned = earnedKeys.contains(b.key);
                        if (aEarned != bEarned) return aEarned ? -1 : 1;
                        return _tierValue(a.value.tier).compareTo(_tierValue(b.value.tier));
                      });

                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: sortedCatalog.length,
                      itemBuilder: (context, index) {
                        final entry = sortedCatalog[index];
                        final badgeKey = entry.key;
                        final badgeDef = entry.value;
                        final isEarned = earnedKeys.contains(badgeKey);
                        final badge = earnedBadges.firstWhere(
                          (b) => b.badgeKey == badgeKey,
                          orElse: () => gam.Badge(
                            id: 0,
                            userId: '',
                            badgeKey: badgeKey,
                            earnedAt: DateTime.now(),
                          ),
                        );

                        return _BadgeCard(
                          badgeDefinition: badgeDef,
                          badge: isEarned ? badge : null,
                          isEarned: isEarned,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Error loading badges: $error'),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error loading catalog: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _tierValue(String tier) {
    switch (tier) {
      case 'platinum': return 0;
      case 'gold': return 1;
      case 'silver': return 2;
      case 'bronze': return 3;
      default: return 4;
    }
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badgeDefinition,
    required this.badge,
    required this.isEarned,
  });

  final gam.BadgeDefinition badgeDefinition;
  final gam.Badge? badge;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierColor = _getTierColor(badgeDefinition.tier, theme);

    return GestureDetector(
      onTap: () => _showBadgeDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEarned
                ? tierColor.withOpacity(0.5)
                : theme.colorScheme.outline.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: tierColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with lock overlay
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  badgeDefinition.iconPath,
                  style: TextStyle(
                    fontSize: 48,
                    color: isEarned ? null : Colors.grey.withOpacity(0.3),
                  ),
                ),
                if (!isEarned)
                  Icon(
                    Icons.lock,
                    size: 28,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Badge name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                badgeDefinition.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isEarned ? tierColor.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isEarned ? tierColor : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                badgeDefinition.tier.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isEarned ? tierColor : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier, ThemeData theme) {
    switch (tier) {
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return theme.colorScheme.primary;
    }
  }

  void _showBadgeDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _BadgeDetailDialog(
        badgeDefinition: badgeDefinition,
        badge: badge,
        isEarned: isEarned,
      ),
    );
  }
}

class _BadgeDetailDialog extends StatelessWidget {
  const _BadgeDetailDialog({
    required this.badgeDefinition,
    required this.badge,
    required this.isEarned,
  });

  final gam.BadgeDefinition badgeDefinition;
  final gam.Badge? badge;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierColor = _getTierColor(badgeDefinition.tier, theme);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEarned
                    ? tierColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                border: Border.all(
                  color: isEarned ? tierColor : Colors.grey,
                  width: 3,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      badgeDefinition.iconPath,
                      style: TextStyle(
                        fontSize: 56,
                        color: isEarned ? null : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    if (!isEarned)
                      Icon(
                        Icons.lock,
                        size: 40,
                        color: Colors.grey,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Badge name
            Text(
              badgeDefinition.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Tier
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tierColor, width: 1),
              ),
              child: Text(
                badgeDefinition.tier.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tierColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              badgeDefinition.description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Condition
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      badgeDefinition.condition,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Earned date if earned
            if (isEarned && badge != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: tierColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Earned ${_formatDate(badge!.earnedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tierColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier, ThemeData theme) {
    switch (tier) {
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

/// Provider for badge catalog from remote config
final badgeCatalogProvider = FutureProvider<Map<String, gam.BadgeDefinition>>((ref) async {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final catalogJson = await remoteConfig.getBadgeCatalog();

  if (catalogJson == null) return {};

  return catalogJson.map(
    (key, value) => MapEntry(
      key,
      gam.BadgeDefinition.fromJson(value as Map<String, dynamic>),
    ),
  );
});
