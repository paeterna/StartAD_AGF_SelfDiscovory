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
      labelKey: (l10n) => l10n.dashboardTitle,
    ),
    NavDestination(
      route: '/discover',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      labelKey: (l10n) => l10n.discoverTitle,
    ),
    NavDestination(
      route: '/careers',
      icon: Icons.work_outline,
      selectedIcon: Icons.work,
      labelKey: (l10n) => l10n.careersTitle,
    ),
    NavDestination(
      route: '/roadmap',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      labelKey: (l10n) => l10n.roadmapTitle,
    ),
    NavDestination(
      route: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: (l10n) => l10n.settingsTitle,
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

    // Desktop: Expanded navigation rail
    return Scaffold(
      body: Row(
        children: [
          const _Rail(compact: false),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
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
      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
      indicatorColor: Theme.of(context).colorScheme.tertiary.withAlpha(90),
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
// Help Dialog
// =====================================================

class _HelpDialog extends StatelessWidget {
  const _HelpDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      icon: const Icon(Icons.help_outline),
      title: Text(l10n.helpDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.helpDialogWelcome),
          const SizedBox(height: 16),
          Text(l10n.helpDialogTip1),
          Text(l10n.helpDialogTip2),
          Text(l10n.helpDialogTip3),
          const SizedBox(height: 16),
          Text(
            l10n.helpDialogAdvice,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.helpDialogButton),
        ),
      ],
    );
  }
}
