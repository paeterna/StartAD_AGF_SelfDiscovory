import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/theme/theme_providers.dart';
import '../../../common/theme/teen_palette_extension.dart';
import '../../../core/router/app_router.dart';

/// Post-signup theme selection page
/// Shown after user completes signup to choose their theme
class ThemeSelectionPage extends ConsumerStatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  ConsumerState<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends ConsumerState<ThemeSelectionPage> {
  String? _selectedThemeKey;

  @override
  Widget build(BuildContext context) {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final currentThemeKeyAsync = ref.watch(currentThemeKeyProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 24),
              Text(
                'Choose Your Vibe 🎨',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a theme that matches your style. You can always change it later!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 32),

              // Theme grid
              Expanded(
                child: currentThemeKeyAsync.when(
                  data: (currentThemeKey) {
                    final selectedKey = _selectedThemeKey ?? currentThemeKey;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: TeenThemes.allThemes.length,
                      itemBuilder: (context, index) {
                        final theme = TeenThemes.allThemes[index];
                        final isSelected = theme.key == selectedKey;

                        return _ThemeCard(
                          theme: theme,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedThemeKey = theme.key;
                            });
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedThemeKey != null
                      ? () async {
                          // Save theme selection
                          await themeController.changeTheme(_selectedThemeKey!);

                          // Navigate to dashboard or next onboarding step
                          if (context.mounted) {
                            context.go(AppRoutes.dashboard);
                          }
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme card for selection
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.buttonRadius),
      child: AnimatedContainer(
        duration: Duration(milliseconds: (theme.motionScale * 300).round()),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: theme.bgGradient,
          borderRadius: BorderRadius.circular(theme.buttonRadius),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.6),
                    blurRadius: theme.elevation * 3,
                    spreadRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: theme.elevation,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    theme.emojiPack.first,
                    style: const TextStyle(fontSize: 40),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: theme.primary,
                        size: 20,
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Theme name
              Text(
                _getDisplayName(theme.key),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Color preview
              Row(
                children: [
                  _ColorCircle(color: theme.primary, size: 24),
                  const SizedBox(width: 6),
                  _ColorCircle(color: theme.secondary, size: 24),
                  const SizedBox(width: 6),
                  _ColorCircle(color: theme.tertiary, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Color preview circle
class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    );
  }
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
