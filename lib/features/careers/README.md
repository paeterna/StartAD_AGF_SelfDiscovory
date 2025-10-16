# Career Tree Feature

A comprehensive career exploration feature that visualizes career matches in a hierarchical tree structure, allowing users to discover and filter careers based on their assessment results.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Components](#components)
- [Usage Examples](#usage-examples)
- [Testing](#testing)
- [Color Mapping System](#color-mapping-system)

## Overview

The Career Tree feature provides an interactive, hierarchical view of all available careers, organized by category (cluster). Each career displays a match score based on the user's assessment results, with intuitive color coding to help users quickly identify their best matches.

### Key Features

- **Hierarchical Organization**: Careers grouped by clusters (STEM, Creative, Business, Healthcare, etc.)
- **Match Score Visualization**: Color-coded match scores from 0-100%
- **Advanced Filtering**: Filter by score thresholds, search terms, and categories
- **Multiple Sort Options**: Sort by match score, alphabetically, or by category
- **Real-time Updates**: Automatically refreshes when new assessment data is available
- **Responsive Design**: Works on mobile, tablet, and desktop

## Architecture

### Directory Structure

```
lib/features/careers/
├── presentation/
│   ├── pages/
│   │   └── career_tree_page.dart          # Main page widget
│   ├── controllers/
│   │   └── career_tree_controller.dart    # State management
│   └── widgets/
│       ├── career_tree_node.dart          # Career and category nodes
│       ├── career_tree_legend.dart        # Color legend
│       └── career_tree_filter_bar.dart    # Filter controls
├── data/
│   └── models/
│       └── career_tree.dart               # Data models
└── README.md                              # This file
```

### Data Flow

```
User Assessment → ScoringService → CareerMatch (DB)
                                    ↓
                    CareerTreeController ← scoringServiceProvider
                                    ↓
                             CareerTreeState
                                    ↓
                            CareerTreePage (UI)
```

## Components

### 1. CareerTreeController

State management controller that handles:
- Loading career data from the scoring service
- Filtering and sorting careers
- Managing UI state (expanded categories, filters, etc.)

**Key Methods:**
- `loadTree()` - Fetches careers and match scores
- `toggleCategory(String id)` - Expands/collapses categories
- `updateSearch(String query)` - Filters by search query
- `updateMinScore(double score)` - Sets minimum match threshold
- `updateSort(CareerTreeSort sort)` - Changes sort order

### 2. CareerTreePage

Main page component that displays the tree view.

**Features:**
- Loading states and error handling
- Filter bar for search and filtering
- Color legend
- Expandable category nodes
- Statistics footer

### 3. Data Models

#### CareerTree
```dart
class CareerTree {
  final List<CategoryNode> categories;
  final List<CareerNode> careers;
}
```

#### CareerNode
```dart
class CareerNode {
  final String id;
  final String title;
  final String categoryId;
  final double? matchScore;  // 0.0 to 1.0
  final String? description;
  final List<String>? tags;
  final List<String>? topFeatures;
}
```

#### CategoryNode
```dart
class CategoryNode {
  final String id;
  final String name;
  final List<String> careerIds;
  final String? description;
}
```

## Usage Examples

### Example 1: Navigating to Career Tree

From anywhere in the app:

```dart
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

// Navigate to career tree
context.push(AppRoutes.careerTree);
```

From CareersPage, there's a built-in button:

```dart
// Already implemented in CareersPage
IconButton(
  icon: const Icon(Icons.account_tree),
  tooltip: 'Career Tree View',
  onPressed: () => context.push(AppRoutes.careerTree),
)
```

### Example 2: Using the Controller Directly

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/career_tree_controller.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careerTreeControllerProvider);
    final controller = ref.read(careerTreeControllerProvider.notifier);

    // Load tree on first build
    useEffect(() {
      controller.loadTree();
      return null;
    }, []);

    // Filter by high matches only
    ElevatedButton(
      onPressed: () => controller.updateMinScore(0.8),
      child: Text('Show Top Matches'),
    );

    // Search for specific careers
    TextField(
      onChanged: (query) => controller.updateSearch(query),
      decoration: InputDecoration(hintText: 'Search careers...'),
    );

    return ListView(
      children: state.filteredCategories.map((category) {
        final careers = state.getCareersForCategory(category.id);
        return ExpansionTile(
          title: Text(category.name),
          children: careers.map((career) =>
            ListTile(
              title: Text(career.title),
              trailing: Text('${career.matchPercent}%'),
            )
          ).toList(),
        );
      }).toList(),
    );
  }
}
```

### Example 3: Custom Color Mapping

The `MatchScoreColors` utility provides consistent color coding:

```dart
import '../../../core/utils/match_score_colors.dart';

// Get color for a match score
final color = MatchScoreColors.getColor(0.85);  // Returns green

// Get background color with opacity
final bgColor = MatchScoreColors.getBackgroundColor(0.85, opacity: 0.2);

// Get label text
final label = MatchScoreColors.getLabel(0.85);  // Returns "High Match"

// Get icon
final icon = MatchScoreColors.getIcon(0.85);  // Returns Icons.check_circle

// Get aggregate color for a category
final scores = [0.9, 0.8, 0.75];
final categoryColor = MatchScoreColors.getAggregateColor(scores);
```

### Example 4: Filtering Options

```dart
// Show only high matches (>= 80%)
controller.toggleShowOnlyGreen();

// Set custom minimum threshold
controller.updateMinScore(0.5);  // Show only 50%+ matches

// Toggle unknown scores
controller.toggleIncludeUnknown();  // Include/exclude careers with no score

// Filter by specific categories
controller.updateSelectedCategories(['STEM', 'Creative']);

// Reset all filters
controller.resetFilters();
```

### Example 5: Sort Options

```dart
import '../../../data/models/career_tree.dart';

// Sort by match score (highest first)
controller.updateSort(CareerTreeSort.matchScoreDesc);

// Sort alphabetically
controller.updateSort(CareerTreeSort.alphabetical);

// Sort by category, then match score
controller.updateSort(CareerTreeSort.categoryThenMatch);

// Sort by match score (lowest first)
controller.updateSort(CareerTreeSort.matchScoreAsc);
```

### Example 6: Accessing Career Details

```dart
final state = ref.watch(careerTreeControllerProvider);

// Get all careers
final allCareers = state.tree.careers;

// Get careers for specific category
final stemCareers = state.getCareersForCategory('STEM');

// Get filtered careers based on current filters
final filteredCategories = state.filteredCategories;
for (final category in filteredCategories) {
  final careers = state.getCareersForCategory(category.id);
  print('${category.name}: ${careers.length} careers');
}

// Get aggregate score for a category
final avgScore = state.getCategoryAggregateScore('STEM');
print('STEM average match: ${(avgScore ?? 0) * 100}%');

// Check if filters are active
if (!state.filter.isDefault) {
  print('Filters are active');
}
```

## Testing

### Running Tests

```bash
# Run all career tree tests
flutter test test/features/careers/

# Run color mapping tests only
flutter test test/core/utils/match_score_colors_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage

- ✅ Color mapping utility (100% coverage)
- ✅ Data models (CareerTree, CareerNode, CategoryNode)
- ✅ Filter and sort logic
- 🔄 Controller state management (in progress)
- 🔄 Widget tests (in progress)

### Example Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:startad_agf_selfdiscovery/core/utils/match_score_colors.dart';

void main() {
  test('getColor returns green for high match', () {
    final color = MatchScoreColors.getColor(0.9);
    expect(color, equals(Colors.green.shade600));
  });

  test('getLabel returns correct label', () {
    expect(MatchScoreColors.getLabel(0.9), equals('High Match'));
    expect(MatchScoreColors.getLabel(0.65), equals('Good Match'));
  });
}
```

## Color Mapping System

The color mapping system provides visual feedback for match scores:

### Score Ranges

| Score Range | Color | Label | Icon |
|------------|-------|-------|------|
| 80-100% | 🟢 Green | High Match | ✓ check_circle |
| 50-80% | 🟡 Yellow-Orange | Good Match | 👍 thumb_up |
| 20-50% | 🟠 Orange-Red | Fair Match | ⊖ remove_circle_outline |
| 0-20% | 🔴 Red | Low Match | ✗ cancel_outlined |
| Unknown | ⚪ Grey | Unknown Match | ? help_outline |

### Color Thresholds

```dart
static const double highThreshold = 0.8;        // >= 80%
static const double mediumHighThreshold = 0.5;  // >= 50%
static const double mediumLowThreshold = 0.2;   // >= 20%
```

### Gradient Interpolation

For smooth transitions, colors are interpolated between thresholds:
- 50-80%: Linear gradient from orange to yellow
- 20-50%: Linear gradient from red to orange

### Usage in Widgets

```dart
// In a career card
Container(
  decoration: BoxDecoration(
    color: MatchScoreColors.getBackgroundColor(career.matchScore),
    border: Border.all(
      color: MatchScoreColors.getColor(career.matchScore),
      width: 2,
    ),
  ),
  child: Row(
    children: [
      Icon(
        MatchScoreColors.getIcon(career.matchScore),
        color: MatchScoreColors.getColor(career.matchScore),
      ),
      Text(career.title),
      Text(
        MatchScoreColors.getLabel(career.matchScore),
        style: TextStyle(
          color: MatchScoreColors.getColor(career.matchScore),
        ),
      ),
    ],
  ),
)
```

## Integration with Scoring System

The Career Tree integrates with the scoring service to provide real-time match data:

### Data Flow

1. **User completes assessment** → Updates `user_feature_scores` table
2. **Scoring service** → Computes cosine similarity → Stores in `user_career_matches`
3. **CareerTreeController** → Fetches matches via `scoringServiceProvider`
4. **UI updates** → Displays updated match scores with color coding

### Provider Integration

```dart
// Defined in career_tree_controller.dart
final careerTreeControllerProvider =
    StateNotifierProvider<CareerTreeController, CareerTreeState>((ref) {
  final scoringService = ref.watch(scoringServiceProvider);
  return CareerTreeController(scoringService: scoringService);
});
```

### Refresh Strategy

The controller automatically refreshes data when:
- User navigates to the page
- User pulls to refresh (future enhancement)
- Assessment completion triggers invalidation (future enhancement)

## Best Practices

### Performance

1. **Lazy Loading**: Categories are collapsed by default
2. **Efficient Filtering**: Filters are applied in-memory after initial load
3. **Memoization**: State is cached and only recomputed when needed

### UX Guidelines

1. **Empty States**: Show helpful messages when no careers match filters
2. **Loading States**: Display progress indicator during data fetch
3. **Error Handling**: Provide retry option with clear error messages
4. **Accessibility**: All colors meet WCAG contrast requirements

### State Management

1. **Provider Pattern**: Use Riverpod for reactive state updates
2. **Immutable State**: All state objects are immutable
3. **Single Source of Truth**: Controller manages all tree state

## Future Enhancements

- [ ] Career detail pages
- [ ] Save favorite careers
- [ ] Export career list
- [ ] Share career matches
- [ ] Career comparison tool
- [ ] Personalized recommendations
- [ ] Historical match tracking
- [ ] Career roadmap integration

## Troubleshooting

### Common Issues

**Issue**: No careers showing
**Solution**: Ensure user has completed at least one assessment

**Issue**: All scores show as "Unknown"
**Solution**: Run the scoring service to compute matches

**Issue**: Colors not displaying correctly
**Solution**: Check that match scores are in range 0.0-1.0

**Issue**: Navigation not working
**Solution**: Verify route is registered in app_router.dart

## Contributing

When adding new features to the Career Tree:

1. Update the controller if adding new state
2. Add tests for new functionality
3. Update this README with usage examples
4. Follow the existing code style and patterns
5. Ensure all tests pass before committing

## Related Files

- [app_router.dart](../../core/router/app_router.dart#L220-L227) - Routing configuration
- [careers_page.dart](../../presentation/features/careers/careers_page.dart) - Main careers list page
- [scoring_service.dart](../../application/scoring/scoring_service.dart) - Career matching logic
- [match_score_colors.dart](../../core/utils/match_score_colors.dart) - Color mapping utility

## License

This feature is part of the StartAD AGF Self-Discovery application.
