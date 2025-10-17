import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/ai_career_recommendations_card.dart';

class CareersPage extends ConsumerWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.careersTitle),
          actions: [
            // Tree view button
            IconButton(
              icon: const Icon(Icons.account_tree),
              tooltip: 'Career Tree View',
              onPressed: () => context.push(AppRoutes.careerTree),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // AI Recommendations
              const AICareerRecommendationsCard(),

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.careersSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
