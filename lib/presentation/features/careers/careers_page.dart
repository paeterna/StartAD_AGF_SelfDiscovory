import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../application/scoring/scoring_providers.dart';
import '../../../application/roadmaps/roadmap_providers.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/gradient_background.dart';

class CareersPage extends ConsumerWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final careerMatchesAsync = ref.watch(careerMatchesProvider);

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
        body: Column(
          children: [
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

            // Career list
            Expanded(
              child: careerMatchesAsync.when(
                data: (matches) {
                  if (matches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No career matches yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete quizzes and games to discover careers',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(careerMatchesProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: matches.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return _CareerCard(
                          careerId: match.match.careerId,
                          title: match.title,
                          description: match.description ?? '',
                          matchScore: match.similarityPercent.round(),
                          cluster: match.cluster ?? 'General',
                          topFeatures: match.topFeatures.take(3).toList(),
                          tags: match.tags,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading careers: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(careerMatchesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerCard extends ConsumerStatefulWidget {
  const _CareerCard({
    required this.careerId,
    required this.title,
    required this.description,
    required this.matchScore,
    required this.cluster,
    this.topFeatures = const [],
    this.tags = const [],
  });

  final String careerId;
  final String title;
  final String description;
  final int matchScore;
  final String cluster;
  final List<dynamic> topFeatures;
  final List<String> tags;

  @override
  ConsumerState<_CareerCard> createState() => _CareerCardState();
}

class _CareerCardState extends ConsumerState<_CareerCard> {
  bool _isGenerating = false;

  Future<void> _handleGenerateRoadmap(BuildContext context) async {
    final roadmapService = ref.read(roadmapServiceProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to generate roadmaps')),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      await roadmapService.generateRoadmapWithFlow(
        context: context,
        userId: userId,
        careerId: widget.careerId,
        careerTitle: widget.title,
        matchScore: widget.matchScore,
        locale: 'en',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // Check if roadmap exists for this career
    final hasRoadmapAsync = userId != null
        ? ref.watch(hasRoadmapForCareerProvider(widget.careerId))
        : const AsyncValue.data(false);

    final matchLevel = widget.matchScore >= 70
        ? l10n.careersHighMatch
        : widget.matchScore >= 40
        ? l10n.careersMediumMatch
        : l10n.careersLowMatch;

    final matchColor = widget.matchScore >= 70
        ? Colors.green
        : widget.matchScore >= 40
        ? Colors.orange
        : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: matchColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.matchScore}%',
                    style: TextStyle(
                      color: matchColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.description, style: Theme.of(context).textTheme.bodyMedium),
            if (widget.topFeatures.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Why this match?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.topFeatures.map((dynamic feature) {
                  final featureKey = feature is Map
                      ? feature['feature_key'] as String?
                      : '';
                  final displayName =
                      featureKey
                          ?.replaceAll('_', ' ')
                          .split(' ')
                          .map(
                            (w) => w.isNotEmpty
                                ? w[0].toUpperCase() + w.substring(1)
                                : '',
                          )
                          .join(' ') ??
                      '';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.cluster,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: matchColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    matchLevel,
                    style: TextStyle(
                      fontSize: 12,
                      color: matchColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                hasRoadmapAsync.when(
                  data: (hasRoadmap) {
                    if (_isGenerating) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    return hasRoadmap
                        ? TextButton.icon(
                            onPressed: () async {
                              if (userId == null) return;
                              final roadmap = await ref.read(
                                roadmapForCareerProvider(widget.careerId).future,
                              );
                              if (roadmap != null && context.mounted) {
                                await context.push('${AppRoutes.roadmapDetail}/${roadmap.id}');
                              }
                            },
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('View Roadmap'),
                          )
                        : TextButton.icon(
                            onPressed: () => _handleGenerateRoadmap(context),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('Generate AI Roadmap'),
                          );
                  },
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (error, _) => TextButton.icon(
                    onPressed: () => _handleGenerateRoadmap(context),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Generate AI Roadmap'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
