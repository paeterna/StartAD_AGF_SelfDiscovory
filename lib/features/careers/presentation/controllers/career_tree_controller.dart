import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/scoring/scoring_service.dart';
import '../../../../application/scoring/scoring_providers.dart';
import '../../../../data/models/career_tree.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// State for the career tree view
class CareerTreeState {
  const CareerTreeState({
    required this.tree,
    required this.filter,
    required this.sort,
    required this.expandedCategories,
    this.isLoading = false,
    this.error,
  });

  final CareerTree tree;
  final CareerTreeFilter filter;
  final CareerTreeSort sort;
  final Set<String> expandedCategories;
  final bool isLoading;
  final String? error;

  CareerTreeState copyWith({
    CareerTree? tree,
    CareerTreeFilter? filter,
    CareerTreeSort? sort,
    Set<String>? expandedCategories,
    bool? isLoading,
    String? error,
  }) {
    return CareerTreeState(
      tree: tree ?? this.tree,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      expandedCategories: expandedCategories ?? this.expandedCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get filtered categories
  List<CategoryNode> get filteredCategories {
    var categories = tree.categories;

    // Filter by selected categories
    if (filter.selectedCategories.isNotEmpty) {
      categories = categories
          .where((c) => filter.selectedCategories.contains(c.id))
          .toList();
    }

    // Filter by search query
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      categories = categories.where((c) {
        // Check category name
        if (c.name.toLowerCase().contains(query)) return true;

        // Check if any career in this category matches
        final careers = tree.getCareersForCategory(c.id);
        return careers.any((career) =>
            career.title.toLowerCase().contains(query) ||
            (career.description?.toLowerCase().contains(query) ?? false));
      }).toList();
    }

    return categories;
  }

  /// Get filtered and sorted careers for a category
  List<CareerNode> getCareersForCategory(String categoryId) {
    var careers = tree.getCareersForCategory(categoryId);

    // Apply filters
    careers = careers.where((career) {
      // Search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        if (!career.title.toLowerCase().contains(query) &&
            !(career.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Score filters
      if (career.matchScore == null) {
        return filter.includeUnknown;
      }

      if (filter.showOnlyGreen && career.matchScore! < 0.8) {
        return false;
      }

      if (career.matchScore! < filter.minMatchScore) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    careers = _sortCareers(careers);

    return careers;
  }

  List<CareerNode> _sortCareers(List<CareerNode> careers) {
    switch (sort) {
      case CareerTreeSort.matchScoreDesc:
        careers.sort((a, b) {
          if (a.matchScore == null && b.matchScore == null) return 0;
          if (a.matchScore == null) return 1;
          if (b.matchScore == null) return -1;
          return b.matchScore!.compareTo(a.matchScore!);
        });
        break;

      case CareerTreeSort.matchScoreAsc:
        careers.sort((a, b) {
          if (a.matchScore == null && b.matchScore == null) return 0;
          if (a.matchScore == null) return 1;
          if (b.matchScore == null) return -1;
          return a.matchScore!.compareTo(b.matchScore!);
        });
        break;

      case CareerTreeSort.alphabetical:
        careers.sort((a, b) => a.title.compareTo(b.title));
        break;

      case CareerTreeSort.categoryThenMatch:
        careers.sort((a, b) {
          final categoryCompare = a.categoryId.compareTo(b.categoryId);
          if (categoryCompare != 0) return categoryCompare;

          if (a.matchScore == null && b.matchScore == null) return 0;
          if (a.matchScore == null) return 1;
          if (b.matchScore == null) return -1;
          return b.matchScore!.compareTo(a.matchScore!);
        });
        break;
    }

    return careers;
  }

  /// Get aggregate score for a category
  double? getCategoryAggregateScore(String categoryId) {
    final careers = tree.getCareersForCategory(categoryId);
    final scores = careers.map((c) => c.matchScore).whereType<double>().toList();

    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

/// Controller for career tree
class CareerTreeController extends StateNotifier<CareerTreeState> {
  CareerTreeController({
    required this.scoringService,
  }) : super(CareerTreeState(
          tree: const CareerTree(categories: [], careers: []),
          filter: const CareerTreeFilter(),
          sort: CareerTreeSort.matchScoreDesc,
          expandedCategories: {},
        ));

  final ScoringService scoringService;

  /// Load career tree data
  Future<void> loadTree() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }

      // Fetch all careers and matches
      final careers = await scoringService.getAllActiveCareers();
      final matches = await scoringService.getCareerMatches(
        userId: userId,
        limit: 1000, // Get all matches
      );

      // Create a map of career_id -> match score
      final matchesMap = {for (final m in matches) m.careerId: m};

      // Group careers by cluster to create categories
      final Map<String, List<Career>> careersByCluster = {};
      for (final career in careers) {
        final cluster = career.cluster ?? 'Other';
        careersByCluster.putIfAbsent(cluster, () => []).add(career);
      }

      // Create category nodes
      final categories = careersByCluster.entries.map((entry) {
        final cluster = entry.key;
        final clusterCareers = entry.value;

        return CategoryNode(
          id: cluster,
          name: _formatClusterName(cluster),
          careerIds: clusterCareers.map((c) => c.id).toList(),
          description: _getClusterDescription(cluster),
        );
      }).toList();

      // Create career nodes with match scores
      final careerNodes = careers.map((career) {
        final match = matchesMap[career.id];

        return CareerNode(
          id: career.id,
          title: career.title,
          categoryId: career.cluster ?? 'Other',
          matchScore: match?.similarity,
          description: career.description,
          tags: career.tags,
          topFeatures: match?.topFeatures.map((f) => f.featureKey).toList(),
        );
      }).toList();

      final tree = CareerTree(
        categories: categories,
        careers: careerNodes,
      );

      state = state.copyWith(
        tree: tree,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle category expansion
  void toggleCategory(String categoryId) {
    final expanded = Set<String>.from(state.expandedCategories);
    if (expanded.contains(categoryId)) {
      expanded.remove(categoryId);
    } else {
      expanded.add(categoryId);
    }
    state = state.copyWith(expandedCategories: expanded);
  }

  /// Expand all categories
  void expandAll() {
    state = state.copyWith(
      expandedCategories: state.tree.categories.map((c) => c.id).toSet(),
    );
  }

  /// Collapse all categories
  void collapseAll() {
    state = state.copyWith(expandedCategories: {});
  }

  /// Update search query
  void updateSearch(String query) {
    state = state.copyWith(
      filter: state.filter.copyWith(searchQuery: query),
    );

    // Auto-expand categories with matching results
    if (query.isNotEmpty) {
      final matchingCategories = state.filteredCategories.map((c) => c.id).toSet();
      state = state.copyWith(expandedCategories: matchingCategories);
    }
  }

  /// Update minimum match score filter
  void updateMinScore(double score) {
    state = state.copyWith(
      filter: state.filter.copyWith(minMatchScore: score),
    );
  }

  /// Toggle "show only green" filter
  void toggleShowOnlyGreen() {
    state = state.copyWith(
      filter: state.filter.copyWith(showOnlyGreen: !state.filter.showOnlyGreen),
    );
  }

  /// Toggle "include unknown" filter
  void toggleIncludeUnknown() {
    state = state.copyWith(
      filter: state.filter.copyWith(includeUnknown: !state.filter.includeUnknown),
    );
  }

  /// Update sort order
  void updateSort(CareerTreeSort sort) {
    state = state.copyWith(sort: sort);
  }

  /// Reset all filters
  void resetFilters() {
    state = state.copyWith(filter: const CareerTreeFilter());
  }

  /// Update selected categories filter
  void updateSelectedCategories(List<String> categories) {
    state = state.copyWith(
      filter: state.filter.copyWith(selectedCategories: categories),
    );
  }

  String _formatClusterName(String cluster) {
    // Convert snake_case or kebab-case to Title Case
    return cluster
        .split(RegExp(r'[_-]'))
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String? _getClusterDescription(String cluster) {
    // Add descriptions for known clusters
    final descriptions = {
      'STEM': 'Science, Technology, Engineering, and Mathematics careers',
      'Creative': 'Arts, Design, and Creative industries',
      'Business': 'Business, Finance, and Management careers',
      'Healthcare': 'Medical and Healthcare professions',
      'Education': 'Teaching and Educational careers',
      'Social': 'Social Services and Community work',
    };
    return descriptions[cluster];
  }
}

/// Provider for career tree controller
final careerTreeControllerProvider =
    StateNotifierProvider<CareerTreeController, CareerTreeState>((ref) {
  final scoringService = ref.watch(scoringServiceProvider);
  return CareerTreeController(scoringService: scoringService);
});
