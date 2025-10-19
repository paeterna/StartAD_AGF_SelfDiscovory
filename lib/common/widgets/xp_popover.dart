import 'package:flutter/material.dart';
import '../theme/teen_palette_extension.dart';

/// Floating "+XP" notification that appears and floats up
class XpPopover extends StatefulWidget {
  final int xpAmount;
  final String? reason;
  final Duration duration;
  final VoidCallback? onComplete;

  const XpPopover({
    super.key,
    required this.xpAmount,
    this.reason,
    this.duration = const Duration(milliseconds: 2000),
    this.onComplete,
  });

  @override
  State<XpPopover> createState() => _XpPopoverState();
}

class _XpPopoverState extends State<XpPopover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Slide up animation
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Fade in then out
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    // Scale pop animation
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  teenTheme.primary,
                  teenTheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: teenTheme.primary.withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '⭐',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${widget.xpAmount} XP',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.reason != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${widget.reason}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show XP popover as an overlay
void showXpPopover(
  BuildContext context, {
  required int xpAmount,
  String? reason,
  Alignment alignment = Alignment.topCenter,
  Duration? duration,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: alignment == Alignment.topCenter ? 100 : null,
      bottom: alignment == Alignment.bottomCenter ? 100 : null,
      left: 0,
      right: 0,
      child: Align(
        alignment: alignment,
        child: XpPopover(
          xpAmount: xpAmount,
          reason: reason,
          duration: duration ?? const Duration(milliseconds: 2000),
          onComplete: () {
            entry.remove();
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
}

/// XP gained card for displaying XP rewards in result sheets
class XpGainedCard extends StatelessWidget {
  final int xpAmount;
  final String reason;
  final int? newLevel;
  final bool showLevelUp;

  const XpGainedCard({
    super.key,
    required this.xpAmount,
    required this.reason,
    this.newLevel,
    this.showLevelUp = false,
  });

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            teenTheme.primary.withOpacity(0.2),
            teenTheme.secondary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: teenTheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '⭐',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Text(
                '+$xpAmount XP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: teenTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: TextStyle(
              fontSize: 16,
              color: teenTheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (showLevelUp && newLevel != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    teenTheme.secondary,
                    teenTheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level $newLevel Unlocked!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact XP indicator for inline use
class CompactXpIndicator extends StatelessWidget {
  final int xpAmount;
  final bool showPlus;

  const CompactXpIndicator({
    super.key,
    required this.xpAmount,
    this.showPlus = true,
  });

  @override
  Widget build(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: teenTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: teenTheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⭐',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            '${showPlus ? '+' : ''}$xpAmount',
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
