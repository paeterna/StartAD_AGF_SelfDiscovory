import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/career_cluster.dart' show CareerClusterGroup;
import '../../../domain/entities/career.dart' hide CareerCluster;
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';

/// Cluster-first careers page
///
/// Displays top 4 career clusters, each showing top 3 matching careers.
/// Users can expand clusters to see all careers or generate roadmaps.
class CareersPageClustered extends ConsumerWidget {
  const CareersPageClustered({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Replace with actual provider that calls watchTopClustersWithCareers
    // final clustersAsync = ref.watch(careerClustersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.careersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree),
            tooltip: 'Career Tree View',
            onPressed: () => context.push(AppRoutes.careerTree),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'My Roadmaps',
            onPressed: () {
              // TODO: Navigate to roadmaps list
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Top Career Matches',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore careers by field and generate personalized roadmaps',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Cluster list
          Expanded(
            child: _buildMockClusters(context),
            // TODO: Replace with actual stream
            // child: clustersAsync.when(
            //   data: (clusters) => _ClusterList(clusters: clusters),
            //   loading: () => const Center(child: CircularProgressIndicator()),
            //   error: (error, stack) => _ErrorView(error: error),
            // ),
          ),
        ],
      ),
    );
  }

  // Mock data for demonstration
  Widget _buildMockClusters(BuildContext context) {
    final mockClusters = [
      CareerClusterGroup(
        id: 'technology',
        name: 'Technology',
        description: 'Software, AI, Data, and Digital Innovation',
        icon: '💻',
        topCareers: [
          const Career(
            id: '1',
            title: 'Software Developer',
            description: 'Build apps and software solutions',
            tags: [],
            matchScore: 95,
            cluster: 'Technology',
          ),
          const Career(
            id: '2',
            title: 'Data Scientist',
            description: 'Analyze data and build AI models',
            tags: [],
            matchScore: 88,
            cluster: 'Technology',
          ),
          const Career(
            id: '3',
            title: 'UX Designer',
            description: 'Design user-friendly digital experiences',
            tags: [],
            matchScore: 82,
            cluster: 'Technology',
          ),
        ],
        maxMatchScore: 95,
      ),
      CareerClusterGroup(
        id: 'healthcare',
        name: 'Healthcare',
        description: 'Medical, Nursing, and Health Services',
        icon: '🏥',
        topCareers: [
          const Career(
            id: '4',
            title: 'Doctor',
            description: 'Diagnose and treat patients',
            tags: [],
            matchScore: 78,
            cluster: 'Healthcare',
          ),
          const Career(
            id: '5',
            title: 'Pharmacist',
            description: 'Dispense medications and advise patients',
            tags: [],
            matchScore: 75,
            cluster: 'Healthcare',
          ),
          const Career(
            id: '6',
            title: 'Physical Therapist',
            description: 'Help patients recover mobility',
            tags: [],
            matchScore: 72,
            cluster: 'Healthcare',
          ),
        ],
        maxMatchScore: 78,
      ),
    ];

    return _ClusterList(clusters: mockClusters);
  }
}

/// List of career clusters
class _ClusterList extends StatelessWidget {
  const _ClusterList({required this.clusters});

  final List<CareerClusterGroup> clusters;

  @override
  Widget build(BuildContext context) {
    if (clusters.isEmpty) {
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: clusters.length,
      separatorBuilder: (context, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _ClusterCard(cluster: clusters[index]);
      },
    );
  }
}

/// Expandable cluster card
class _ClusterCard extends StatefulWidget {
  const _ClusterCard({required this.cluster});

  final CareerClusterGroup cluster;

  @override
  State<_ClusterCard> createState() => _ClusterCardState();
}

class _ClusterCardState extends State<_ClusterCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cluster header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.cluster.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cluster.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.cluster.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 16,
                              color: _getMatchColor(widget.cluster.maxMatchScore),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Best Match: ${widget.cluster.maxMatchScore}%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: _getMatchColor(widget.cluster.maxMatchScore),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          // Careers list (always show top 3, expand for all)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.cluster.topCareers.map((career) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CareerItem(
                      career: career,
                      onGenerateRoadmap: () => _handleGenerateRoadmap(context, career),
                    ),
                  );
                }),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to full cluster view
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('View all ${widget.cluster.name} careers'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.grey;
  }

  void _handleGenerateRoadmap(BuildContext context, Career career) {
    // TODO: Check if roadmap exists, handle limit, call generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generate roadmap for ${career.title}'),
        action: SnackBarAction(
          label: 'Generate',
          onPressed: () {
            // TODO: Implement roadmap generation
          },
        ),
      ),
    );
  }
}

/// Individual career item within a cluster
class _CareerItem extends StatelessWidget {
  const _CareerItem({
    required this.career,
    required this.onGenerateRoadmap,
  });

  final Career career;
  final VoidCallback onGenerateRoadmap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchColor = _getMatchColor(career.matchScore);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Match score
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: matchColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${career.matchScore}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: matchColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Career info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  career.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  career.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action button
          IconButton(
            onPressed: onGenerateRoadmap,
            icon: const Icon(Icons.map),
            tooltip: 'Generate Roadmap',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.grey;
  }
}
