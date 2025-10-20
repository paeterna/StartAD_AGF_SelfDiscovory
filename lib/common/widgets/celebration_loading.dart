import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Teen-friendly loading animation with pulsing emojis and messages
/// Shows during game result processing to prevent "stuck" feeling
class CelebrationLoading extends StatefulWidget {
  const CelebrationLoading({
    this.message = 'Processing your results...',
    this.emoji = '🎮',
    super.key,
  });

  final String message;
  final String emoji;

  @override
  State<CelebrationLoading> createState() => _CelebrationLoadingState();
}

class _CelebrationLoadingState extends State<CelebrationLoading>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _messageController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _messageAnimation;

  final List<String> _messages = [
    'Calculating your score...',
    'Analyzing your performance...',
    'Checking for achievements...',
    'Almost there...',
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Pulse animation for emoji
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Message fade animation
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _messageController, curve: Curves.easeIn),
    );

    _messageController.forward();

    // Cycle through messages
    _startMessageCycle();
  }

  void _startMessageCycle() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
      });

      _messageController.reset();
      _messageController.forward();

      _startMessageCycle();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surface.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spinning dots around emoji
            Stack(
              alignment: Alignment.center,
              children: [
                // Rotating dots
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          children: List.generate(8, (index) {
                            final angle = (index * math.pi * 2) / 8;
                            final x = 50 + 45 * math.cos(angle);
                            final y = 50 + 45 * math.sin(angle);

                            return Positioned(
                              left: x,
                              top: y,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.3 + (index / 8) * 0.7,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),

                // Pulsing emoji
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Animated message
            AnimatedBuilder(
              animation: _messageController,
              builder: (context, child) {
                return Opacity(
                  opacity: _messageAnimation.value,
                  child: Text(
                    _messages[_currentMessageIndex],
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Progress bar
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Hang tight!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay widget that shows CelebrationLoading
class CelebrationLoadingOverlay extends StatelessWidget {
  const CelebrationLoadingOverlay({
    this.message = 'Processing...',
    this.emoji = '🎮',
    super.key,
  });

  final String message;
  final String emoji;

  /// Show the loading overlay
  static OverlayEntry show(
    BuildContext context, {
    String message = 'Processing...',
    String emoji = '🎮',
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => CelebrationLoadingOverlay(
        message: message,
        emoji: emoji,
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CelebrationLoading(
        message: message,
        emoji: emoji,
      ),
    );
  }
}
