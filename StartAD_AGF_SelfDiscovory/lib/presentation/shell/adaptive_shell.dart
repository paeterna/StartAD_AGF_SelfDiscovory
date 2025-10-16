import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:startad_agf_selfdiscovery/core/responsive/responsive.dart';
import 'package:startad_agf_selfdiscovery/generated/l10n/app_localizations.dart';

// =====================================================
// Adaptive Shell - Responsive Navigation
// =====================================================
//
// This widget provides adaptive navigation based on screen size:
// - Mobile (xs/sm): Bottom navigation bar
// - Tablet (md): Compact navigation rail
// - Desktop (lg/xl): Expanded navigation rail with optional side panels

/// Navigation destination
class NavDestination {
  const NavDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
  });

  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations) labelKey;

  String label(BuildContext context) => labelKey(AppLocalizations.of(context)!);
}

/// Available navigation destinations
class NavDestinations {
  static final List<NavDestination> items = [
    NavDestination(
      route: '/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      labelKey: (l10n) => 'Dashboard',
    ),
    NavDestination(
      route: '/discover',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      labelKey: (l10n) => 'Discover',
    ),
    NavDestination(
      route: '/careers',
      icon: Icons.work_outline,
      selectedIcon: Icons.work,
      labelKey: (l10n) => 'Careers',
    ),
    NavDestination(
      route: '/roadmap',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      labelKey: (l10n) => 'Roadmap',
    ),
    NavDestination(
      route: '/ai-insights',
      icon: Icons.psychology_outlined,
      selectedIcon: Icons.psychology,
      labelKey: (l10n) => 'AI Insights',
    ),
    NavDestination(
      route: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: (l10n) => 'Settings',
    ),
  ];

  static int indexOfRoute(String location) {
    // Handle subroutes (e.g., /careers/123 -> /careers)
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) {
        return i;
      }
    }
    return 0; // Default to first item
  }
}

/// Adaptive shell that wraps page content with appropriate navigation
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Mobile: Bottom navigation bar
    if (context.isMobile) {
      return Scaffold(
        body: child,
        bottomNavigationBar: const _BottomNav(),
      );
    }

    // Tablet: Compact navigation rail
    if (context.isTablet) {
      return Scaffold(
        body: Row(
          children: [
            const _Rail(compact: true),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Desktop: Expanded navigation rail + optional side panels
    return Scaffold(
      body: Row(
        children: [
          const _Rail(compact: false),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
          // Optional insights panel for xl screens
          if (context.isXl) ...[
            const VerticalDivider(width: 1, thickness: 1),
            const _InsightsPanel(),
          ],
        ],
      ),
    );
  }
}

// =====================================================
// Bottom Navigation Bar (Mobile)
// =====================================================

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = NavDestinations.indexOfRoute(location);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final destination = NavDestinations.items[index];
        context.go(destination.route);
      },
      destinations: NavDestinations.items.map((dest) {
        return NavigationDestination(
          icon: Icon(dest.icon),
          selectedIcon: Icon(dest.selectedIcon),
          label: dest.label(context),
        );
      }).toList(),
    );
  }
}

// =====================================================
// Navigation Rail (Tablet & Desktop)
// =====================================================

class _Rail extends StatelessWidget {
  const _Rail({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = NavDestinations.indexOfRoute(location);
    final theme = Theme.of(context);

    return NavigationRail(
      extended: !compact,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final destination = NavDestinations.items[index];
        context.go(destination.route);
      },
      labelType: compact
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.none,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.secondaryContainer,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Icon(
          Icons.school,
          size: compact ? 32 : 40,
          color: theme.colorScheme.primary,
        ),
      ),
      trailing: compact
          ? null
          : Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      // Show help dialog
                      showDialog<void>(
                        context: context,
                        builder: (context) => const _HelpDialog(),
                      );
                    },
                    tooltip: 'Help',
                  ),
                ),
              ),
            ),
      destinations: NavDestinations.items.map((dest) {
        return NavigationRailDestination(
          icon: Icon(dest.icon),
          selectedIcon: Icon(dest.selectedIcon),
          label: Text(dest.label(context)),
        );
      }).toList(),
    );
  }
}

// =====================================================
// Insights Panel (XL screens)
// =====================================================

class _InsightsPanel extends StatelessWidget {
  const _InsightsPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 320,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _InsightCard(
                  icon: Icons.trending_up,
                  title: 'Progress Streak',
                  subtitle: 'Keep going! You\'re on a roll.',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                _InsightCard(
                  icon: Icons.star_outline,
                  title: 'Top Match',
                  subtitle: 'Software Developer (95% match)',
                  color: Colors.amber,
                ),
                const SizedBox(height: 12),
                _InsightCard(
                  icon: Icons.quiz_outlined,
                  title: 'Next Assessment',
                  subtitle: 'Complete personality quiz',
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 12),
                _InsightCard(
                  icon: Icons.emoji_events_outlined,
                  title: 'Achievement',
                  subtitle: 'Completed 5 assessments',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Help Dialog
// =====================================================

class _HelpDialog extends StatelessWidget {
  const _HelpDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.help_outline),
      title: const Text('Need Help?'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome to your career discovery journey!'),
          SizedBox(height: 16),
          Text('• Complete assessments to build your profile'),
          Text('• Explore careers that match your interests'),
          Text('• Follow your personalized roadmap'),
          SizedBox(height: 16),
          Text(
            'Tip: The more assessments you complete, the better your career matches will be.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}
