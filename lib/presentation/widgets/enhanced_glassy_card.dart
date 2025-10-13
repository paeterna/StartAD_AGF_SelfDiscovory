import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:startad_agf_selfdiscovery/core/theme/app_colors.dart';
import 'package:startad_agf_selfdiscovery/core/theme/app_theme.dart';

/// Enhanced glassy card widget with blur effect and modern aesthetics
/// Perfect for futuristic, AI-era glassmorphism design
class GlassyCard extends StatefulWidget {
  const GlassyCard({
    super.key,
    required this.child,
    this.blur = AppTheme.glassBlur,
    this.gradient,
    this.borderGradient,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation = 0,
    this.shadowColor,
    this.borderRadius,
    this.enableHoverEffect = false,
  });

  final Widget child;
  final Gradient? gradient;
  final Gradient? borderGradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double blur;
  final double elevation;
  final Color? shadowColor;
  final BorderRadius? borderRadius;
  final bool enableHoverEffect;

  @override
  State<GlassyCard> createState() => _GlassyCardState();
}

class _GlassyCardState extends State<GlassyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation,
          end: widget.elevation + 4,
        ).animate(
          CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          child: Transform.scale(
            scale: widget.enableHoverEffect ? _scaleAnimation.value : 1.0,
            child: Material(
              elevation: widget.enableHoverEffect
                  ? _elevationAnimation.value
                  : widget.elevation,
              shadowColor:
                  widget.shadowColor ??
                  (isDark
                      ? AppColors.warmAmber.withValues(alpha: 0.3)
                      : AppColors.warmOrange.withValues(alpha: 0.2)),
              borderRadius: borderRadius,
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blur,
                    sigmaY: widget.blur,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:
                          widget.gradient ??
                          LinearGradient(
                            colors: [
                              isDark
                                  ? Colors.white.withValues(
                                      alpha: AppTheme.glassOpacity,
                                    )
                                  : Colors.white.withValues(
                                      alpha: AppTheme.glassOpacity + 0.1,
                                    ),
                              isDark
                                  ? Colors.white.withValues(
                                      alpha: AppTheme.glassOpacity * 0.5,
                                    )
                                  : Colors.white.withValues(
                                      alpha: AppTheme.glassOpacity,
                                    ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: AppTheme.glassBorderOpacity,
                        ),
                        width: 1.0,
                      ),
                    ),
                    child: widget.onTap != null
                        ? InkWell(
                            onTap: widget.onTap,
                            onHover: widget.enableHoverEffect
                                ? (hovering) {
                                    if (hovering) {
                                      _hoverController.forward();
                                    } else {
                                      _hoverController.reverse();
                                    }
                                  }
                                : null,
                            borderRadius: borderRadius,
                            child: Container(
                              padding:
                                  widget.padding ??
                                  const EdgeInsets.all(AppTheme.spaceLarge),
                              child: widget.child,
                            ),
                          )
                        : Container(
                            padding:
                                widget.padding ??
                                const EdgeInsets.all(AppTheme.spaceLarge),
                            child: widget.child,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gradient-enhanced glassy card for special sections
class GradientGlassyCard extends StatelessWidget {
  const GradientGlassyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.enableHoverEffect = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassyCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      enableHoverEffect: enableHoverEffect,
      gradient: isDark
          ? AppColors.darkBackgroundGradient
          : AppColors.primaryGradient,
      child: child,
    );
  }
}
