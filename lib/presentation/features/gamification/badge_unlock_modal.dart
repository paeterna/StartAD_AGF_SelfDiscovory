import 'package:flutter/material.dart';
import '../../../domain/entities/gamification.dart' as gam;
import '../../../common/widgets/confetti_overlay.dart';

/// Modal dialog showing badge unlock with celebration animation
/// Uses confetti overlay and animated badge reveal
class BadgeUnlockModal extends StatefulWidget {
  const BadgeUnlockModal({
    required this.badgeDefinition,
    super.key,
  });

  final gam.BadgeDefinition badgeDefinition;

  /// Show the badge unlock modal with confetti
  static Future<void> show(
    BuildContext context, {
    required gam.BadgeDefinition badgeDefinition,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BadgeUnlockModal(badgeDefinition: badgeDefinition),
    );
  }

  @override
  State<BadgeUnlockModal> createState() => _BadgeUnlockModalState();
}

class _BadgeUnlockModalState extends State<BadgeUnlockModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Badge scales up with bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    // Slight rotation for dynamic effect
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Pulsing glow effect
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.7), weight: 50),
    ]).animate(_controller);

    // Start animation
    _controller.forward();

    // Show confetti after badge appears
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _showConfetti = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierColor = _getTierColor(widget.badgeDefinition.tier, theme);

    return Stack(
      children: [
        // Confetti overlay
        if (_showConfetti)
          ConfettiOverlay(
            show: true,
            particleCount: 80,
          ),

        // Modal dialog
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: tierColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Badge Unlocked" header
                Text(
                  'Badge Unlocked!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tierColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Animated badge icon
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                tierColor.withValues(alpha: 0.3),
                                tierColor.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: tierColor.withValues(alpha: _glowAnimation.value * 0.6),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 10 * _glowAnimation.value,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface,
                              border: Border.all(
                                color: tierColor,
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.badgeDefinition.iconPath,
                                style: const TextStyle(fontSize: 64),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Badge name
                Text(
                  widget.badgeDefinition.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Tier badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tierColor, width: 2),
                  ),
                  child: Text(
                    widget.badgeDefinition.tier.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tierColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  widget.badgeDefinition.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Close button
                FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Awesome!'),
                ),
              ],
            ),
          ),
        ),
      ],
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
}
