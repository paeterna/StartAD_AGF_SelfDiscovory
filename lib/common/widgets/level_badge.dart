import 'package:flutter/material.dart';
import '../theme/teen_palette_extension.dart';

/// Animated level badge that pulses and glows
class LevelBadge extends StatefulWidget {
  final int level;
  final double size;
  final bool animate;
  final VoidCallback? onTap;

  const LevelBadge({
    super.key,
    required this.level,
    this.size = 60,
    this.animate = true,
    this.onTap,
  });

  @override
  State<LevelBadge> createState() => _LevelBadgeState();
}

class _LevelBadgeState extends State<LevelBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_controller);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_controller);

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LevelBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      // Level up animation
      _controller.forward(from: 0).then((_) {
        if (widget.animate && mounted) {
          _controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.animate ? _scaleAnimation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    teenTheme.secondary,
                    teenTheme.primary,
                  ],
                  stops: const [0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: teenTheme.primary.withOpacity(
                      widget.animate ? _glowAnimation.value * 0.6 : 0.4,
                    ),
                    blurRadius: widget.animate
                        ? _glowAnimation.value * 20
                        : 10,
                    spreadRadius: widget.animate ? _glowAnimation.value * 4 : 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Outer ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  // Center content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.level.toString(),
                          style: TextStyle(
                            fontSize: widget.size * 0.4,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        if (widget.size >= 50)
                          Text(
                            'LVL',
                            style: TextStyle(
                              fontSize: widget.size * 0.15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Compact level badge for inline use
class CompactLevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const CompactLevelBadge({
    super.key,
    required this.level,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [teenTheme.primary, teenTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          level.toString(),
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Level badge with text label
class LevelBadgeWithLabel extends StatelessWidget {
  final int level;
  final String? label;
  final double size;

  const LevelBadgeWithLabel({
    super.key,
    required this.level,
    this.label,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LevelBadge(
          level: level,
          size: size,
          animate: false,
        ),
        const SizedBox(height: 8),
        Text(
          label ?? 'Level $level',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: teenTheme.tertiary,
          ),
        ),
      ],
    );
  }
}
