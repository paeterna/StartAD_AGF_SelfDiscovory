import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';

class RoadmapPage extends StatelessWidget {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.roadmapTitle),
        ),
        body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.roadmapSoftwareEngineerTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.roadmapSubtitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),

          // Progress summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.roadmapProgressLabel,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        l10n.roadmapProgressValue(2, 5),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(value: 0.4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Steps
          _RoadmapStep(
            title: l10n.roadmapStepProgrammingTitle,
            description: l10n.roadmapStepProgrammingDescription,
            completed: true,
            category: l10n.roadmapCategorySubject,
          ),
          _RoadmapStep(
            title: l10n.roadmapStepProjectsTitle,
            description: l10n.roadmapStepProjectsDescription,
            completed: true,
            category: l10n.roadmapCategoryProject,
          ),
          _RoadmapStep(
            title: l10n.roadmapStepAlgorithmsTitle,
            description: l10n.roadmapStepAlgorithmsDescription,
            completed: false,
            category: l10n.roadmapCategorySkill,
          ),
          _RoadmapStep(
            title: l10n.roadmapStepOpenSourceTitle,
            description: l10n.roadmapStepOpenSourceDescription,
            completed: false,
            category: l10n.roadmapCategoryExperience,
          ),
          _RoadmapStep(
            title: l10n.roadmapStepInternshipTitle,
            description: l10n.roadmapStepInternshipDescription,
            completed: false,
            category: l10n.roadmapCategoryExperience,
          ),
        ],
        ),
      ),
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  const _RoadmapStep({
    required this.title,
    required this.description,
    required this.completed,
    required this.category,
  });

  final String title;
  final String description;
  final bool completed;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: completed,
                onChanged: (value) {},
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
