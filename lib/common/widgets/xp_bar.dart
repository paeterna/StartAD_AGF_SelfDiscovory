import 'package:flutter/material.dart';
import '../theme/teen_palette_extension.dart';

/// Animated XP progress bar showing current XP and progress to next level
class XpBar extends StatefulWidget {
  final int currentXp;
  final int xpForNextLevel;
  final int level;
  final bool showLabel;
  final double height;
  final bool animate;

  const XpBar({
    super.key,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.level,
    this.showLabel = true,
    this.height = 24,
    this.animate = true,
  });

  @override
  State<XpBar> createState() => _XpBarState();
}

class _XpBarState extends State<XpBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _updateProgress();
  }

  @override
  void didUpdateWidget(XpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentXp != widget.currentXp ||
        oldWidget.xpForNextLevel != widget.xpForNextLevel) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final newProgress = widget.xpForNextLevel > 0
        ? (widget.currentXp / widget.xpForNextLevel).clamp(0.0, 1.0)
        : 0.0;

    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _previousProgress = newProgress;

    if (widget.animate) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 1.0;
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${widget.level}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: teenTheme.primary,
                ),
              ),
              Text(
                '${widget.currentXp} / ${widget.xpForNextLevel} XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: teenTheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: teenTheme.background.withOpacity(0.3),
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(
                  color: teenTheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Animated progress fill
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            teenTheme.primary,
                            teenTheme.secondary,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: teenTheme.primary.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Shine effect
                  if (_progressAnimation.value > 0.05)
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                  // Percentage text (optional, centered)
                  if (widget.height >= 24)
                    Center(
                      child: Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _progressAnimation.value > 0.5
                              ? Colors.white
                              : teenTheme.tertiary,
                          shadows: _progressAnimation.value > 0.5
                              ? [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Compact version of XP bar for headers/cards
class CompactXpBar extends StatelessWidget {
  final int currentXp;
  final int xpForNextLevel;
  final double height;

  const CompactXpBar({
    super.key,
    required this.currentXp,
    required this.xpForNextLevel,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpForNextLevel > 0
        ? (currentXp / xpForNextLevel).clamp(0.0, 1.0)
        : 0.0;

    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: teenTheme.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [teenTheme.primary, teenTheme.secondary],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
