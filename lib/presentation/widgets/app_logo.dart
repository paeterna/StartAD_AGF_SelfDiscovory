import 'package:flutter/material.dart';

/// Reusable logo widget for the SelfMap application
/// Displays the logo with configurable size
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_selfmap.png',
      height: height,
      width: width,
      fit: fit,
    );
  }
}

/// Small logo for navigation bars and headers
class AppLogoSmall extends StatelessWidget {
  const AppLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(
      height: 56,
    );
  }
}

/// Medium logo for login screens
class AppLogoMedium extends StatelessWidget {
  const AppLogoMedium({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(
      height: 160,
    );
  }
}

/// Large logo for splash screens or onboarding
class AppLogoLarge extends StatelessWidget {
  const AppLogoLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(
      height: 220,
    );
  }
}
