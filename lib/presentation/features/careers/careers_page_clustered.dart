import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/career_cluster.dart' show CareerClusterGroup;
import '../../../domain/entities/career.dart' hide CareerCluster;
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../application/roadmaps/roadmap_providers.dart';
import '../../../application/scoring/scoring_providers.dart';
import '../../../common/theme/teen_palette_extension.dart';

/// Cluster-first careers page
///
/// Displays top 4 career clusters, each showing top 3 matching careers.
/// Users can expand clusters to see all careers or generate roadmaps.
class CareersPageClustered extends ConsumerWidget {
  const CareersPageClustered({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clustersAsync = ref.watch(careerClusterGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.careersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'My Roadmaps',
            onPressed: () => context.push(AppRoutes.roadmap),
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

          // Cluster list - Using real data from database
          Expanded(
            child: clustersAsync.when(
              data: (clusters) => _ClusterList(clusters: clusters),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _ErrorView(error: error.toString()),
            ),
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
            id: '00000000-0000-0000-0000-000000000001',
            title: 'Software Developer',
            description: 'Build apps and software solutions',
            tags: [],
            matchScore: 95,
            cluster: 'Technology',
          ),
          const Career(
            id: '00000000-0000-0000-0000-000000000002',
            title: 'Data Scientist',
            description: 'Analyze data and build AI models',
            tags: [],
            matchScore: 88,
            cluster: 'Technology',
          ),
          const Career(
            id: '00000000-0000-0000-0000-000000000003',
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
            id: '00000000-0000-0000-0000-000000000004',
            title: 'Doctor',
            description: 'Diagnose and treat patients',
            tags: [],
            matchScore: 78,
            cluster: 'Healthcare',
          ),
          const Career(
            id: '00000000-0000-0000-0000-000000000005',
            title: 'Pharmacist',
            description: 'Dispense medications and advise patients',
            tags: [],
            matchScore: 75,
            cluster: 'Healthcare',
          ),
          const Career(
            id: '00000000-0000-0000-0000-000000000006',
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
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

/// Expandable cluster card with animations
class _ClusterCard extends ConsumerStatefulWidget {
  const _ClusterCard({required this.cluster});

  final CareerClusterGroup cluster;

  @override
  ConsumerState<_ClusterCard> createState() => _ClusterCardState();
}

class _ClusterCardState extends ConsumerState<_ClusterCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  LinearGradient _getClusterGradient(BuildContext context) {
    final teenTheme = Theme.of(context).extension<TeenPalette>();
    if (teenTheme == null) {
      return LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primaryContainer,
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        ],
      );
    }

    // Create unique gradient per cluster based on theme colors
    final clusterIndex = widget.cluster.id.hashCode % 3;
    switch (clusterIndex) {
      case 0:
        return LinearGradient(
          colors: [
            teenTheme.primary.withValues(alpha: 0.3),
            teenTheme.secondary.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 1:
        return LinearGradient(
          colors: [
            teenTheme.secondary.withValues(alpha: 0.3),
            teenTheme.tertiary.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [
            teenTheme.tertiary.withValues(alpha: 0.3),
            teenTheme.primary.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teenTheme = theme.extension<TeenPalette>();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: teenTheme?.elevation ?? 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(teenTheme?.buttonRadius ?? 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cluster header
                GestureDetector(
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) {
                    _scaleController.reverse();
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  onTapCancel: () => _scaleController.reverse(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: _getClusterGradient(context),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(teenTheme?.buttonRadius ?? 16),
                      ),
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
                              color: _getMatchColor(
                                widget.cluster.maxMatchScore,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Best Match: ${widget.cluster.maxMatchScore}%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: _getMatchColor(
                                  widget.cluster.maxMatchScore,
                                ),
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

                // Careers list with animated expand/collapse
                AnimatedSize(
                  duration: Duration(
                    milliseconds: (300 * (teenTheme?.motionScale ?? 1.0)).round(),
                  ),
                  curve: Curves.easeInOut,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...widget.cluster.topCareers.map((career) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _CareerItem(
                              career: career,
                              onGenerateRoadmap: () =>
                                  _handleGenerateRoadmap(context, career),
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
                ),
                ],
              ),
            ),

        );
      },
    );
  }

  Color _getMatchColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.grey;
  }

  Future<void> _handleGenerateRoadmap(
    BuildContext context,
    Career career,
  ) async {
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

    // Call the service which handles everything: checks, limits, generation, navigation
    await roadmapService.generateRoadmapWithFlow(
      context: context,
      userId: userId,
      careerId: career.id,
      careerTitle: career.title,
      matchScore: career.matchScore,
      locale: 'en', // TODO: Get from user preferences
    );
  }
}

/// Individual career item within a cluster - with animations
class _CareerItem extends StatefulWidget {
  const _CareerItem({
    required this.career,
    required this.onGenerateRoadmap,
  });

  final Career career;
  final VoidCallback onGenerateRoadmap;

  @override
  State<_CareerItem> createState() => _CareerItemState();
}

class _CareerItemState extends State<_CareerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.career.matchScore / 100.0,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Color _getMatchColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchColor = _getMatchColor(widget.career.matchScore);

    return AnimatedScale(
      scale: _isHovered ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Match score circle with Hero transition
                  Hero(
                    tag: 'career-score-${widget.career.id}',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: matchColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.career.matchScore}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: matchColor,
                            fontWeight: FontWeight.bold,
                          ),
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
                        Hero(
                          tag: 'career-title-${widget.career.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              widget.career.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.career.description,
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
                    onPressed: widget.onGenerateRoadmap,
                    icon: const Icon(Icons.auto_awesome),
                    tooltip: 'Generate AI Roadmap',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // Animated progress bar
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(matchColor),
                      minHeight: 6,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error view widget
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Careers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
