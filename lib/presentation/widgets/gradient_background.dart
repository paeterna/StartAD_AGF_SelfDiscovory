import 'package:flutter/material.dart';
import 'package:startad_agf_selfdiscovery/core/theme/app_colors.dart';

/// Reusable gradient background widget with optional animation
/// Provides futuristic, AI-era inspired backgrounds that adapt to theme
class GradientBackground extends StatefulWidget {
  const GradientBackground({
    required this.child,
    this.gradient,
    this.animated = false,
    this.animationDuration = const Duration(seconds: 8),
    super.key,
  });

  final Widget child;
  final Gradient? gradient;
  final bool animated;
  final Duration animationDuration;

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _animationController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
      _animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ));
      _animationController!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default gradient based on theme (warm orange → beige → sky blue)
    final defaultGradient = isDark
        ? AppColors.darkBackgroundGradient
        : AppColors.primaryGradient;

    final selectedGradient = widget.gradient ?? defaultGradient;

    if (widget.animated && _animation != null && selectedGradient is LinearGradient) {
      return AnimatedBuilder(
        animation: _animation!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: selectedGradient.colors,
                begin: Alignment.lerp(
                  selectedGradient.begin as Alignment,
                  selectedGradient.end as Alignment,
                  _animation!.value,
                )!,
                end: Alignment.lerp(
                  selectedGradient.end as Alignment,
                  selectedGradient.begin as Alignment,
                  _animation!.value,
                )!,
                stops: selectedGradient.stops,
              ),
            ),
            child: widget.child,
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(gradient: selectedGradient),
      child: widget.child,
    );
  }
}

/// Hero gradient background for special sections
class HeroGradientBackground extends StatelessWidget {
  const HeroGradientBackground({
    required this.child,
    this.opacity = 1.0,
    super.key,
  });

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroGradient = isDark
        ? AppColors.darkBackgroundGradient
        : AppColors.accentGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: heroGradient.colors
              .map((Color color) => color.withValues(alpha: opacity))
              .toList(),
          begin: heroGradient.begin,
          end: heroGradient.end,
          stops: heroGradient.stops,
        ),
      ),
      child: child,
    );
  }
}

/// Animated shimmer gradient background
class ShimmerGradientBackground extends StatefulWidget {
  const ShimmerGradientBackground({
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.animationDuration = const Duration(milliseconds: 1500),
    super.key,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration animationDuration;

  @override
  State<ShimmerGradientBackground> createState() => _ShimmerGradientBackgroundState();
}

class _ShimmerGradientBackgroundState extends State<ShimmerGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(1.0 + _animation.value, 0.0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
