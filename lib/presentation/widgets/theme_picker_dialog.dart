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

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose Your Vibe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a theme that matches your style',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),

            // Theme grid
            Expanded(
              child: currentThemeKeyAsync.when(
                data: (currentThemeKey) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: TeenThemes.allThemes.length,
                  itemBuilder: (context, index) {
                    final theme = TeenThemes.allThemes[index];
                    final isSelected = theme.themeKey == currentThemeKey;

                    return _ThemeCard(
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () async {
                        await themeController.changeTheme(theme.themeKey);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading themes')),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.buttonRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: theme.bgGradient,
          borderRadius: BorderRadius.circular(theme.buttonRadius),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.5),
                    blurRadius: theme.cardGlow * 2,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: theme.cardGlow,
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Theme name and emoji
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.emojiPack.first,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),

            // Color preview circles
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _ColorCircle(color: theme.primary, size: 20),
                  const SizedBox(width: 4),
                  _ColorCircle(color: theme.secondary, size: 20),
                  const SizedBox(width: 4),
                  _ColorCircle(color: theme.tertiary, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small color preview circle
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
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
