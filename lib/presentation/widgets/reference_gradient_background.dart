import 'package:flutter/material.dart';
import 'package:startad_agf_selfdiscovery/core/theme/app_colors.dart';

/// Enhanced gradient background that matches the reference image exactly
/// Includes the diagonal blend plus soft radial blooms for photo-realistic effect
class ReferenceGradientBackground extends StatelessWidget {
  const ReferenceGradientBackground({
    super.key,
    required this.child,
    this.withBlooms = true,
  });

  final Widget child;
  final bool withBlooms;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? AppColors.referenceGradientDark
        : AppColors.referenceGradient;

    if (!withBlooms) {
      // Simple version without blooms
      return Container(
        decoration: BoxDecoration(gradient: base),
        child: child,
      );
    }

    // Full version with blooms for photo-like effect
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base diagonal blend
        DecoratedBox(decoration: BoxDecoration(gradient: base)),

        // Bottom-left magenta bloom
        IgnorePointer(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.magentaBloomBL,
            ),
          ),
        ),

        // Right-side orange bloom
        IgnorePointer(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.orangeBloomR,
            ),
          ),
        ),

        // Your UI content
        child,
      ],
    );
  }
}
