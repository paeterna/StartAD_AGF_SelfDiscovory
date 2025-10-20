import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/teen_palette_extension.dart';

/// Confetti particle for celebrations
class ConfettiParticle {
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;
  double opacity;

  ConfettiParticle({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    this.opacity = 1.0,
  });

  void update(double dt) {
    position = Offset(
      position.dx + velocity.dx * dt,
      position.dy + velocity.dy * dt,
    );
    velocity = Offset(
      velocity.dx,
      velocity.dy + 500 * dt, // Gravity
    );
    rotation += rotationSpeed * dt;
    opacity = (opacity - 0.5 * dt).clamp(0.0, 1.0);
  }
}

/// Confetti overlay widget for celebrations
class ConfettiOverlay extends StatefulWidget {
  final bool show;
  final Duration duration;
  final VoidCallback? onComplete;
  final int particleCount;

  const ConfettiOverlay({
    super.key,
    required this.show,
    this.duration = const Duration(seconds: 3),
    this.onComplete,
    this.particleCount = 100,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.show && _particles.isEmpty) {
      _initParticles();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _initParticles();
      _controller.forward(from: 0);
    }
  }

  void _initParticles() {
    _particles.clear();
    final teenTheme = Theme.of(context).extension<TeenPalette>()!;
    final colors = [
      teenTheme.primary,
      teenTheme.secondary,
      teenTheme.tertiary,
      Colors.yellow,
      Colors.pink,
      Colors.cyan,
    ];

    for (int i = 0; i < widget.particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi - pi; // -π to π
      final speed = 200 + _random.nextDouble() * 300;
      final velocity = Offset(
        cos(angle) * speed,
        sin(angle) * speed - 300, // Shoot upward
      );

      _particles.add(
        ConfettiParticle(
          position: Offset(
            _random.nextDouble() * 400,
            500, // Start from bottom
          ),
          velocity: velocity,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: _random.nextDouble() * 10 - 5,
          color: colors[_random.nextInt(colors.length)],
          size: 6 + _random.nextDouble() * 8,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show && _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Update particles
          if (_controller.isAnimating) {
            const dt = 1 / 60; // Assume 60fps
            for (final particle in _particles) {
              particle.update(dt);
            }
          }

          return CustomPaint(
            painter: _ConfettiPainter(_particles),
            child: Container(),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      // Draw confetti as small rectangles
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 1.5,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Show confetti overlay as a dialog/overlay
void showConfetti(BuildContext context, {Duration? duration}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: ConfettiOverlay(
        show: true,
        duration: duration ?? const Duration(seconds: 3),
        onComplete: () {
          entry.remove();
        },
      ),
    ),
  );

  overlay.insert(entry);
}

/// Confetti celebration widget with message
class ConfettiCelebration extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String emoji;
  final VoidCallback? onDismiss;

  const ConfettiCelebration({
    super.key,
    required this.title,
    this.subtitle,
    this.emoji = '🎉',
    this.onDismiss,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

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

    return Stack(
      children: [
        // Confetti background
        ConfettiOverlay(
          show: true,
          duration: const Duration(seconds: 3),
        ),
        // Centered message
        Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        teenTheme.primary.withValues(alpha: 0.95),
                        teenTheme.secondary.withValues(alpha: 0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: teenTheme.primary.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismiss?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: teenTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Awesome!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Show confetti celebration dialog
void showConfettiCelebration(
  BuildContext context, {
  required String title,
  String? subtitle,
  String emoji = '🎉',
  VoidCallback? onDismiss,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => ConfettiCelebration(
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      onDismiss: onDismiss,
    ),
  );
}
