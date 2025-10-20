import 'package:flutter/material.dart';
import '../theme/teen_palette_extension.dart';

/// Streak counter chip with fire emoji and animations
class StreakChip extends StatefulWidget {
  final int streakDays;
  final bool showLabel;
  final VoidCallback? onTap;
  final bool animate;

  const StreakChip({
    super.key,
    required this.streakDays,
    this.showLabel = true,
    this.onTap,
    this.animate = true,
  });

  @override
  State<StreakChip> createState() => _StreakChipState();
}

class _StreakChipState extends State<StreakChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _flameAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    if (widget.animate && widget.streakDays > 0) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(StreakChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakDays != widget.streakDays) {
      if (widget.animate && widget.streakDays > 0) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getFireEmoji() {
    if (widget.streakDays == 0) return '💨'; // No streak
    if (widget.streakDays >= 30) return '🔥🔥🔥'; // Fire streak!
    if (widget.streakDays >= 14) return '🔥🔥'; // Hot streak
    if (widget.streakDays >= 7) return '🔥'; // Week streak
    return '✨'; // Starting streak
  }

  Color _getStreakColor(TeenPalette teenTheme) {
    if (widget.streakDays >= 30) return const Color(0xFFFF6B00); // Orange
    if (widget.streakDays >= 14) return teenTheme.primary;
    if (widget.streakDays >= 7) return teenTheme.secondary;
    return teenTheme.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;
    final streakColor = _getStreakColor(teenTheme);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              streakColor.withValues(alpha: 0.2),
              streakColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: streakColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: widget.streakDays > 0
              ? [
                  BoxShadow(
                    color: streakColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated fire emoji
            AnimatedBuilder(
              animation: _flameAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.animate && widget.streakDays > 0
                      ? _flameAnimation.value
                      : 1.0,
                  child: Text(
                    _getFireEmoji(),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            // Streak count
            Text(
              '${widget.streakDays}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: streakColor,
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(width: 4),
              Text(
                widget.streakDays == 1 ? 'day' : 'days',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: streakColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact streak display for headers
class CompactStreakChip extends StatelessWidget {
  final int streakDays;

  const CompactStreakChip({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: teenTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: teenTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: streakDays >= 7 ? Colors.orange : teenTheme.tertiary,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakDays',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: teenTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak milestone celebration widget
class StreakMilestone extends StatelessWidget {
  final int streakDays;
  final String message;

  const StreakMilestone({
    super.key,
    required this.streakDays,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            teenTheme.primary.withValues(alpha: 0.2),
            teenTheme.secondary.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: teenTheme.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥🎉',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            '$streakDays Day Streak!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: teenTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: teenTheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
