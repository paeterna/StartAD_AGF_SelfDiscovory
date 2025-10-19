import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/theme/theme_providers.dart';
import '../../common/theme/teen_palette_extension.dart';

/// Theme picker dialog for selecting teen themes
/// Shows all available themes with previews
class ThemePickerDialog extends ConsumerWidget {
  const ThemePickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeKeyAsync = ref.watch(currentThemeKeyProvider);
    final themeController = ref.watch(themeControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose Your Vibe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick a theme that matches your style',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Theme grid - much smaller boxes
            Expanded(
              child: currentThemeKeyAsync.when(
                data: (currentThemeKey) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: TeenThemes.allThemes.length,
                  itemBuilder: (context, index) {
                    final theme = TeenThemes.allThemes[index];
                    final isSelected = theme.key == currentThemeKey;

                    return _ThemeCard(
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () async {
                        await themeController.changeTheme(theme.key);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading themes')),
              ),
            ),

            const SizedBox(height: 16),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual theme card with preview
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final TeenPalette theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currentColorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    // Generate a preview ColorScheme for this theme
    final previewScheme = ColorScheme.fromSeed(
      seedColor: theme.seed,
      brightness: brightness,
      primary: theme.primary,
      secondary: theme.secondary,
      tertiary: theme.tertiary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            // Use the theme's actual surface color
            color: brightness == Brightness.dark
                ? theme.background
                : previewScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: currentColorScheme.primary, width: 2.5)
                : Border.all(
                    color: currentColorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section with icon and theme name
              Column(
                children: [
                  // Icon based on theme (using tertiary for preview)
                  Icon(
                    _getThemeIcon(theme.key),
                    size: 28,
                    color: theme.primary,
                  ),
                  const SizedBox(height: 6),
                  // Theme name
                  Text(
                    _getDisplayName(theme.key),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // Bottom section - 3 color buttons side by side
              Column(
                children: [
                  // Three color preview buttons in a row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.tertiary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Selected indicator at bottom
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: currentColorScheme.primary,
                  size: 14,
                )
              else
                const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show theme picker dialog
Future<void> showThemePickerDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const ThemePickerDialog(),
  );
}

/// Helper function to get display name from theme key
String _getDisplayName(String key) {
  switch (key) {
    case 'neon_arcade':
      return 'Neon Arcade';
    case 'galaxy_pulse':
      return 'Galaxy Pulse';
    case 'street_pop':
      return 'Street Pop';
    case 'ocean_wave':
      return 'Ocean Wave';
    case 'retro_pixel':
      return 'Retro Pixel';
    default:
      return 'Neon Arcade';
  }
}

/// Helper function to get icon for theme
IconData _getThemeIcon(String key) {
  switch (key) {
    case 'neon_arcade':
      return Icons.sports_esports; // Gaming controller
    case 'galaxy_pulse':
      return Icons.rocket_launch; // Rocket/space
    case 'street_pop':
      return Icons.skateboarding; // Skateboard
    case 'ocean_wave':
      return Icons.waves; // Ocean waves
    case 'retro_pixel':
      return Icons.videogame_asset; // Retro game controller
    default:
      return Icons.sports_esports;
  }
}
