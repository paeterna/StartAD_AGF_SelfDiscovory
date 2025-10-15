import 'package:flutter/material.dart';
import 'package:startad_agf_selfdiscovery/core/theme/app_colors.dart';
import 'package:startad_agf_selfdiscovery/core/theme/app_theme.dart';
import 'package:startad_agf_selfdiscovery/generated/l10n/app_localizations.dart';
import 'package:startad_agf_selfdiscovery/presentation/widgets/enhanced_glassy_card.dart';
import 'package:startad_agf_selfdiscovery/presentation/widgets/gradient_background.dart';

/// Welcome screen for onboarding - Friendly introduction for teens
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.onGetStarted, super.key});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      animated: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Animated emoji/icon
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceXLarge),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPurple.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.explore,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceXLarge),

              // Welcome title
              Text(
                l10n.welcomeTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceMedium),

              // Subtitle
              Text(
                l10n.welcomeSubtitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceLarge),

              // Info points as simple text
              _buildInfoPoint(context, l10n.welcomeQuickDescription),
              const SizedBox(height: AppTheme.spaceMedium),
              _buildInfoPoint(context, l10n.welcomeDiscoverDescription),
              const SizedBox(height: AppTheme.spaceMedium),
              _buildInfoPoint(context, l10n.welcomePlanDescription),

              const Spacer(),

              // Get Started Button
              GradientGlassyCard(
                onTap: onGetStarted,
                child: Center(
                  child: Text(
                    l10n.welcomeGetStartedButton,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppTheme.spaceSmall),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
