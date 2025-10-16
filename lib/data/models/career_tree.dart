import 'package:flutter/foundation.dart';

/// Node representing a career category (cluster) in the tree
@immutable
class CategoryNode {
  const CategoryNode({
    required this.id,
    required this.name,
    required this.careerIds,
    this.parentId,
    this.description,
  });

  /// Unique identifier for this category (typically the cluster name)
  final String id;

  /// Display name of the category
  final String name;

  /// List of career IDs belonging to this category
  final List<String> careerIds;

  /// Parent category ID (for nested categories, currently null)
  final String? parentId;

  /// Optional description of the category
  final String? description;

  /// Get count of careers in this category
  int get careerCount => careerIds.length;

  CategoryNode copyWith({
    String? id,
    String? name,
    List<String>? careerIds,
    String? parentId,
    String? description,
  }) {
    return CategoryNode(
      id: id ?? this.id,
      name: name ?? this.name,
      careerIds: careerIds ?? this.careerIds,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryNode(id: $id, name: $name, careers: ${careerIds.length})';
}

/// Node representing an individual career in the tree
@immutable
class CareerNode {
  const CareerNode({
    required this.id,
    required this.title,
    required this.categoryId,
    this.matchScore,
    this.description,
    this.tags,
    this.topFeatures,
  });

  /// Unique career identifier
  final String id;

  /// Career title/name
  final String title;

  /// Category this career belongs to
  final String categoryId;

  /// Match score (0.0 to 1.0), null if unknown/not calculated
  final double? matchScore;

  /// Career description
  final String? description;

  /// Associated tags
  final List<String>? tags;

  /// Top contributing features (for "why this match?")
  final List<String>? topFeatures;

  /// Get match score as percentage (0-100)
  int? get matchPercent => matchScore != null ? (matchScore! * 100).round() : null;

  /// Check if match score exists
  bool get hasMatchScore => matchScore != null;

  CareerNode copyWith({
    String? id,
    String? title,
    String? categoryId,
    double? matchScore,
    String? description,
    List<String>? tags,
    List<String>? topFeatures,
  }) {
    return CareerNode(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      matchScore: matchScore ?? this.matchScore,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      topFeatures: topFeatures ?? this.topFeatures,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CareerNode(id: $id, title: $title, match: $matchPercent%)';
}

/// Complete career tree structure
@immutable
class CareerTree {
  const CareerTree({
    required this.categories,
    required this.careers,
  });

  /// All categories in the tree
  final List<CategoryNode> categories;

  /// All careers in the tree
  final List<CareerNode> careers;

  /// Get careers for a specific category
  List<CareerNode> getCareersForCategory(String categoryId) {
    return careers.where((c) => c.categoryId == categoryId).toList();
  }

  /// Get category by ID
  CategoryNode? getCategory(String categoryId) {
    return categories.cast<CategoryNode?>().firstWhere(
      (c) => c?.id == categoryId,
      orElse: () => null,
    );
  }

  /// Get total career count
  int get totalCareers => careers.length;

  /// Get careers with match scores
  List<CareerNode> get careersWithScores =>
      careers.where((c) => c.hasMatchScore).toList();

  /// Get average match score across all careers
  double? get averageMatchScore {
    final withScores = careersWithScores;
    if (withScores.isEmpty) return null;

    final sum = withScores.fold<double>(
      0.0,
      (sum, career) => sum + (career.matchScore ?? 0.0),
    );
    return sum / withScores.length;
  }

  CareerTree copyWith({
    List<CategoryNode>? categories,
    List<CareerNode>? careers,
  }) {
    return CareerTree(
      categories: categories ?? this.categories,
      careers: careers ?? this.careers,
    );
  }

  @override
  String toString() => 'CareerTree(categories: ${categories.length}, careers: ${careers.length})';
}

/// Filter options for the career tree
@immutable
class CareerTreeFilter {
  const CareerTreeFilter({
    this.searchQuery = '',
    this.minMatchScore = 0.0,
    this.showOnlyGreen = false,
    this.includeUnknown = true,
    this.selectedCategories = const [],
  });

  /// Search query for filtering by name
  final String searchQuery;

  /// Minimum match score threshold (0.0 to 1.0)
  final double minMatchScore;

  /// Show only high-match careers (>= 0.8)
  final bool showOnlyGreen;

  /// Include careers with unknown match scores
  final bool includeUnknown;

  /// Filter by specific categories (empty = all)
  final List<String> selectedCategories;

  /// Check if this filter is the default (no filtering applied)
  bool get isDefault =>
      searchQuery.isEmpty &&
      minMatchScore == 0.0 &&
      !showOnlyGreen &&
      includeUnknown &&
      selectedCategories.isEmpty;

  CareerTreeFilter copyWith({
    String? searchQuery,
    double? minMatchScore,
    bool? showOnlyGreen,
    bool? includeUnknown,
    List<String>? selectedCategories,
  }) {
    return CareerTreeFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      minMatchScore: minMatchScore ?? this.minMatchScore,
      showOnlyGreen: showOnlyGreen ?? this.showOnlyGreen,
      includeUnknown: includeUnknown ?? this.includeUnknown,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  /// Reset filter to default
  CareerTreeFilter reset() => const CareerTreeFilter();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerTreeFilter &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          minMatchScore == other.minMatchScore &&
          showOnlyGreen == other.showOnlyGreen &&
          includeUnknown == other.includeUnknown &&
          listEquals(selectedCategories, other.selectedCategories);

  @override
  int get hashCode => Object.hash(
        searchQuery,
        minMatchScore,
        showOnlyGreen,
        includeUnknown,
        selectedCategories,
      );
}

/// Sort options for careers
enum CareerTreeSort {
  matchScoreDesc('Match Score (High to Low)'),
  matchScoreAsc('Match Score (Low to High)'),
  alphabetical('Alphabetical'),
  categoryThenMatch('Category, then Match');

  const CareerTreeSort(this.label);

  final String label;
}
