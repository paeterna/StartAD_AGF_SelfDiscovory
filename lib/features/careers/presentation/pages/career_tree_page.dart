import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/career_tree_controller.dart';
import '../widgets/career_tree_legend.dart';
import '../widgets/career_tree_filter_bar.dart';
import '../widgets/career_tree_node.dart';
import '../../../../presentation/widgets/gradient_background.dart';

/// Main page for the career tree visualization
class CareerTreePage extends ConsumerStatefulWidget {
  const CareerTreePage({super.key});

  @override
  ConsumerState<CareerTreePage> createState() => _CareerTreePageState();
}

class _CareerTreePageState extends ConsumerState<CareerTreePage> {
  @override
  void initState() {
    super.initState();
    // Load tree data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(careerTreeControllerProvider.notifier).loadTree();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(careerTreeControllerProvider);
    final controller = ref.read(careerTreeControllerProvider.notifier);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Career Explorer'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Expand/collapse all
            IconButton(
              icon: const Icon(Icons.unfold_more),
              tooltip: 'Expand All',
              onPressed: controller.expandAll,
            ),
            IconButton(
              icon: const Icon(Icons.unfold_less),
              tooltip: 'Collapse All',
              onPressed: controller.collapseAll,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? _ErrorView(error: state.error!, onRetry: controller.loadTree)
                : _TreeView(state: state, controller: controller),
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load careers',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main tree view
class _TreeView extends StatelessWidget {
  const _TreeView({
    required this.state,
    required this.controller,
  });

  final CareerTreeState state;
  final CareerTreeController controller;

  @override
  Widget build(BuildContext context) {
    final filteredCategories = state.filteredCategories;

    return Column(
      children: [
        // Filter bar
        CareerTreeFilterBar(
          filter: state.filter,
          sort: state.sort,
          onSearchChanged: controller.updateSearch,
          onMinScoreChanged: controller.updateMinScore,
          onShowOnlyGreenToggled: controller.toggleShowOnlyGreen,
          onIncludeUnknownToggled: controller.toggleIncludeUnknown,
          onSortChanged: controller.updateSort,
          onReset: controller.resetFilters,
        ),

        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CareerTreeLegend(compact: true),
        ),

        // Tree content
        Expanded(
          child: filteredCategories.isEmpty
              ? CareerTreeEmptyState(
                  message: state.filter.isDefault
                      ? 'No careers found'
                      : 'No careers match your filters',
                  onReset: controller.resetFilters,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final careers = state.getCareersForCategory(category.id);
                    final isExpanded = state.expandedCategories.contains(category.id);
                    final aggregateScore = state.getCategoryAggregateScore(category.id);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category node
                        CategoryTreeNode(
                          category: category,
                          careerCount: careers.length,
                          aggregateScore: aggregateScore,
                          isExpanded: isExpanded,
                          onToggle: () => controller.toggleCategory(category.id),
                        ),

                        // Career nodes (when expanded)
                        if (isExpanded) ...[
                          if (careers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 40,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Text(
                                'No careers match the current filters',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            )
                          else
                            ...careers.map((career) {
                              return CareerTreeNode(
                                career: career,
                                onTap: () => _navigateToCareer(context, career.id),
                              );
                            }),
                        ],
                      ],
                    );
                  },
                ),
        ),

        // Stats footer
        _StatsFooter(state: state),
      ],
    );
  }

  void _navigateToCareer(BuildContext context, String careerId) {
    // Navigate to career detail page
    // Adjust the route based on your app's routing setup
    context.push('/careers/$careerId');
  }
}

/// Stats footer showing summary information
class _StatsFooter extends StatelessWidget {
  const _StatsFooter({required this.state});

  final CareerTreeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCareers = state.tree.totalCareers;
    final visibleCategories = state.filteredCategories.length;
    final totalCategories = state.tree.categories.length;

    // Count visible careers
    int visibleCareers = 0;
    for (final category in state.filteredCategories) {
      visibleCareers += state.getCareersForCategory(category.id).length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.category,
            label: 'Categories',
            value: '$visibleCategories / $totalCategories',
          ),
          _StatItem(
            icon: Icons.work,
            label: 'Careers',
            value: '$visibleCareers / $totalCareers',
          ),
          if (state.tree.averageMatchScore != null)
            _StatItem(
              icon: Icons.analytics,
              label: 'Avg Match',
              value: '${(state.tree.averageMatchScore! * 100).round()}%',
            ),
        ],
      ),
    );
  }
}

/// Individual stat item
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
