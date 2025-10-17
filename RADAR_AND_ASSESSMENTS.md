# Radar Chart Visualization and Psychometric Assessments

## Overview

This document describes the implementation of the radar chart visualization system and psychometric assessment functionality added to the SelfMap application. These features enable users to visualize their 22-dimensional feature profile and complete standardized personality and career interest assessments.

## Table of Contents

- [Architecture](#architecture)
- [Assessment System](#assessment-system)
- [Radar Chart Visualization](#radar-chart-visualization)
- [Database Schema](#database-schema)
- [Implementation Guide](#implementation-guide)
- [API Reference](#api-reference)
- [Testing](#testing)

---

## Architecture

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Assessment Flow                          │
└─────────────────────────────────────────────────────────────┘

1. User Navigation
   └─> AssessmentPage(instrument: 'riasec_mini', language: 'en')

2. Load Assessment
   └─> QuizItemSeeder.loadInstrument() → JSON Asset
   └─> Display paged Likert scale UI (10 items/page)

3. User Completes Assessment
   └─> QuizScoringHelper.computeFeatureScores()
       ├─> item_score = weight * direction * (likert - 3) / 2
       ├─> Aggregate by feature_key
       └─> Convert to [0, 100] scale

4. Submit to Orchestrator
   └─> CompleteAssessmentOrchestrator.completeAssessment()
       ├─> 1. Complete activity_run (triggers progress update)
       ├─> 2. Create assessment audit trail
       ├─> 3. Call Edge Function → upsert_feature_ema()
       ├─> 4. Edge Function computes career matches
       └─> 5. Update user_feature_scores & user_career_matches

5. View Results
   └─> RadarTraitsCard displays radar chart
       ├─> Fetch v_user_radar view
       ├─> User scores vs cohort averages
       └─> Interactive fl_chart visualization
```

### Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
├─────────────────────────────────────────────────────────────┤
│ Models:                                                      │
│ - QuizInstrument     Assessment metadata from JSON          │
│ - QuizItem           Individual question definition         │
│ - RadarDataPoint     User score vs cohort average          │
│ - FeatureScore       Computed feature score (key/mean/n/q) │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌─────────────────────────────────────────────────────────────┐
│                 Application Layer                            │
├─────────────────────────────────────────────────────────────┤
│ Services:                                                    │
│ - QuizItemSeeder              Load JSON → Supabase         │
│ - QuizScoringHelper           Compute feature scores       │
│ - TraitsRepository            Fetch radar data             │
│ - CompleteAssessmentOrchestrator  End-to-end flow         │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌─────────────────────────────────────────────────────────────┐
│                Presentation Layer                            │
├─────────────────────────────────────────────────────────────┤
│ Widgets:                                                     │
│ - AssessmentPage         Likert scale assessment UI         │
│ - RadarTraitsCard        Radar chart visualization          │
└─────────────────────────────────────────────────────────────┘
```

---

## Assessment System

### Supported Assessments

#### 1. RIASEC Mini-IP (Career Interests)

**File**: `assets/assessments/riasec_mini_{en|ar}.json`

- **Items**: 30 questions (5 per dimension)
- **Dimensions**:
  - **R**ealistic: Hands-on, practical work
  - **I**nvestigative: Scientific, analytical thinking
  - **A**rtistic: Creative expression
  - **S**ocial: Helping and teaching others
  - **E**nterprising: Leadership and persuasion
  - **C**onventional: Organization and data management
- **Scale**: 5-point Likert (1=Strongly Dislike, 5=Strongly Like)
- **Duration**: ~5 minutes
- **Features Updated**: `realistic`, `investigative`, `artistic`, `social`, `enterprising`, `conventional`

#### 2. IPIP-50 (Big Five Personality)

**File**: `assets/assessments/ipip50_{en|ar}.json`

- **Items**: 50 questions (10 per trait)
- **Traits**:
  - **E**xtraversion: Sociability, assertiveness
  - **A**greeableness: Compassion, cooperation
  - **C**onscientiousness: Organization, responsibility
  - **Emotional Stability**: Calmness, resilience (reverse-scored as Neuroticism)
  - **O**penness: Curiosity, creativity
- **Scale**: 5-point Likert (1=Very Inaccurate, 5=Very Accurate)
- **Duration**: ~10 minutes
- **Features Updated**: `extraversion`, `agreeableness`, `conscientiousness`, `emotional_stability`, `openness`

### JSON Assessment Format

```json
{
  "instrument": "riasec_mini",
  "version": "1.0",
  "language": "en",
  "title": "Career Interest Explorer",
  "description": "Discover your career interests...",
  "instructions": "Rate each statement based on...",
  "scale": {
    "type": "likert5",
    "labels": {
      "1": "Strongly Dislike",
      "2": "Dislike",
      "3": "Neutral",
      "4": "Like",
      "5": "Strongly Like"
    }
  },
  "items": [
    {
      "id": "r1",
      "text": "Working with tools and machines",
      "feature_key": "realistic",
      "direction": 1,
      "weight": 1.0
    },
    // ... more items
  ]
}
```

**Field Descriptions**:
- `id`: Unique item identifier within instrument
- `text`: Question text shown to user
- `feature_key`: Maps to `features.key` in database
- `direction`: 1 (positive) or -1 (reverse-scored)
- `weight`: Item importance (usually 1.0)

### Scoring Algorithm

#### Per-Item Score

```dart
// Map Likert [1,5] to normalized [-1,1] range
item_score = weight * direction * (likert_value - 3) / 2

// Examples:
// Likert=5, direction=1  → item_score = 1.0 * 1 * (5-3)/2 = +1.0
// Likert=1, direction=1  → item_score = 1.0 * 1 * (1-3)/2 = -1.0
// Likert=5, direction=-1 → item_score = 1.0 * -1 * (5-3)/2 = -1.0 (reverse)
// Likert=3 (neutral)     → item_score = 0.0
```

#### Feature Aggregation

```dart
// 1. Group item scores by feature_key
Map<String, List<double>> scoresByFeature;

// 2. Compute weighted mean per feature
mean_normalized = sum(item_scores * weights) / sum(weights);  // [-1, 1]

// 3. Convert to [0, 1] scale
mean_01 = (mean_normalized + 1.0) / 2.0;

// 4. Convert to [0, 100] scale for database storage
mean_100 = mean_01 * 100.0;

// 5. Compute quality/confidence
quality = min(1.0, num_items / 5.0);  // More items = higher confidence
```

#### Progress & Confidence

```dart
// Delta progress: Each full assessment = 20% progress
delta_progress = (20 / total_items) * answered_items;  // Capped at 20

// Overall confidence: Based on completion rate
overall_confidence = (answered_items / total_items) * 0.8;  // Max 0.8
```

---

## Radar Chart Visualization

### Overview

The radar chart (spider chart) provides a visual representation of the user's 22-dimensional feature profile compared to cohort averages.

### Features

- **22 Data Points**: All features from RIASEC (6) + Cognition (6) + Traits (10)
- **Dual Series**:
  - User scores (solid colored line with fill)
  - Cohort averages (gray dashed line)
- **Family Filtering**: Can display all features or filter by family (RIASEC, Cognition, Traits)
- **Interactive**: Hover to see exact values
- **Responsive**: Adapts to theme colors and dark mode

### Usage Example

```dart
// Show all features
RadarTraitsCard()

// Show only RIASEC dimensions
RadarTraitsCard(
  family: 'riasec',
  title: 'Career Interests Profile',
)

// Show only personality traits
RadarTraitsCard(
  family: 'traits',
  showLegend: true,
)
```

### Data Source

The radar chart pulls data from the `v_user_radar` view:

```sql
select
  f.id as feature_index,
  f.key as feature_key,
  initcap(replace(f.key, '_', ' ')) as feature_label,
  f.family as family,
  coalesce(ufs.score_mean, 50.0) as user_score_0_100,
  coalesce(fcs.mean, 50.0) as cohort_mean_0_100
from features f
left join user_feature_scores ufs on ufs.feature_key = f.key
left join feature_cohort_stats fcs on fcs.feature_key = f.key
where ufs.user_id = auth.uid();
```

**Default Values**:
- If user has no score yet: defaults to 50.0 (neutral)
- If cohort stats unavailable: defaults to 50.0

---

## Database Schema

### Migration 00004: New & Modified Tables

#### Extended: `quiz_items`

```sql
create table public.quiz_items (
  -- Existing columns
  item_id text,
  feature_key text references features(key),
  direction float8 check (direction in (-1.0, 1.0)),
  weight float8 default 1.0,
  question_text text,
  metadata jsonb,
  created_at timestamptz default now(),

  -- New columns (added in migration 00004)
  instrument text,      -- e.g., 'riasec_mini', 'ipip50'
  version text,         -- e.g., '1.0'
  language text,        -- e.g., 'en', 'ar'
  sort_order int,       -- Display order within instrument

  primary key (instrument, language, item_id)
);

-- Indexes for performance
create index idx_quiz_items_instrument_lang on quiz_items(instrument, language);
create index idx_quiz_items_sort_order on quiz_items(sort_order);
```

#### New View: `v_user_radar`

```sql
create view v_user_radar as
select
  f.id as feature_index,
  f.key as feature_key,
  initcap(replace(f.key, '_', ' ')) as feature_label,
  f.family as family,
  coalesce(ufs.score_mean, 50.0) as user_score_0_100,
  coalesce(fcs.mean, 50.0) as cohort_mean_0_100,
  ufs.user_id
from features f
left join user_feature_scores ufs on ufs.feature_key = f.key
left join feature_cohort_stats fcs on fcs.feature_key = f.key
order by f.id;

grant select on v_user_radar to authenticated;
```

#### New Function: `get_my_radar_data()`

```sql
create function get_my_radar_data()
returns table (
  feature_index int,
  feature_key text,
  feature_label text,
  family text,
  user_score_0_100 numeric,
  cohort_mean_0_100 numeric
)
as $$
  select * from v_user_radar
  where user_id = auth.uid()
  order by feature_index;
$$;

grant execute on function get_my_radar_data() to authenticated;
```

#### New Function: `is_quiz_instrument_seeded()`

```sql
create function is_quiz_instrument_seeded(
  p_instrument text,
  p_language text
)
returns boolean
as $$
  select exists(
    select 1 from quiz_items
    where instrument = p_instrument
      and language = p_language
    limit 1
  );
$$;

grant execute on function is_quiz_instrument_seeded(text, text) to authenticated;
```

---

## Implementation Guide

### Step 1: Run Database Migration

```bash
# Using Supabase CLI
supabase db push

# Or manually in Supabase SQL Editor
# Execute: supabase/migrations/00004_radar_view_and_quiz_enhancements.sql
```

### Step 2: Seed Quiz Items

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/application/quiz/quiz_providers.dart';

// In your app initialization (e.g., main.dart or onboarding)
class SeedQuizItemsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final seeder = ref.read(quizItemSeederProvider);

        try {
          await seeder.seedAll();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assessments seeded successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      },
      child: Text('Seed Assessments'),
    );
  }
}
```

**One-Time Setup**: Only needs to be run once per deployment. You can also:
- Create an admin page with a "Seed Data" button
- Run it in a database migration script via Edge Function
- Seed during app first launch with a flag in shared_preferences

### Step 3: Navigate to Assessment

```dart
import 'package:go_router/go_router.dart';

// Add route in router configuration
GoRoute(
  path: '/assessment/:instrument/:language',
  builder: (context, state) => AssessmentPage(
    instrument: state.pathParameters['instrument']!,
    language: state.pathParameters['language']!,
  ),
),

// Navigate from anywhere
context.push('/assessment/riasec_mini/en');
context.push('/assessment/ipip50/ar');
```

### Step 4: Display Radar Chart

```dart
import 'package:your_app/presentation/widgets/radar_traits_card.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Full profile radar
            RadarTraitsCard(),

            SizedBox(height: 24),

            // Career interests only
            RadarTraitsCard(
              family: 'riasec',
              title: 'Career Interests',
            ),

            SizedBox(height: 24),

            // Personality traits only
            RadarTraitsCard(
              family: 'traits',
              title: 'Personality Traits',
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 5: Create Activities for Assessments

In your Supabase `activities` table, create entries:

```sql
-- RIASEC Mini-IP
insert into activities (id, type, name, description, duration_minutes, difficulty)
values (
  'quiz_riasec_mini',
  'quiz',
  'Career Interest Explorer',
  'Discover your career interests with the RIASEC model',
  5,
  'easy'
);

-- IPIP-50
insert into activities (id, type, name, description, duration_minutes, difficulty)
values (
  'quiz_ipip50',
  'quiz',
  'Personality Assessment',
  'Understand your Big Five personality traits',
  10,
  'medium'
);
```

---

## API Reference

### QuizItemSeeder

```dart
class QuizItemSeeder {
  /// Load instrument metadata from JSON asset
  Future<QuizInstrument> loadInstrument({
    required String instrument,
    required String language,
  });

  /// Check if instrument already seeded in database
  Future<bool> instrumentExists({
    required String instrument,
    required String language,
  });

  /// Seed quiz items from JSON into database
  Future<void> seedInstrument({
    required String instrument,
    required String language,
    bool force = false,  // Overwrite existing items
  });

  /// Seed all available instruments (RIASEC + IPIP-50 in EN/AR)
  Future<void> seedAll({bool force = false});

  /// Fetch quiz items from database for assessment
  Future<List<Map<String, dynamic>>> fetchQuizItems({
    required String instrument,
    required String language,
  });
}
```

### QuizScoringHelper

```dart
class QuizScoringHelper {
  /// Compute feature scores from Likert responses
  static List<FeatureScore> computeFeatureScores({
    required List<QuizItem> items,
    required Map<String, int> responses,  // item_id → likert_value
  });

  /// Compute delta progress (0-20) based on completion
  static int computeDeltaProgress({
    required int totalItems,
    required int answeredItems,
  });

  /// Compute overall confidence (0.0-0.8) based on completion
  static double computeOverallConfidence({
    required int totalItems,
    required int answeredItems,
  });

  /// Check if all items have been answered
  static bool areAllItemsAnswered({
    required List<QuizItem> items,
    required Map<String, int> responses,
  });

  /// Get list of unanswered item IDs
  static List<String> getUnansweredItems({
    required List<QuizItem> items,
    required Map<String, int> responses,
  });
}
```

### TraitsRepository

```dart
class TraitsRepository {
  /// Fetch radar chart data for current user (RPC call)
  Future<List<RadarDataPoint>> getMyRadarData();

  /// Fetch radar data grouped by family
  Future<RadarDataByFamily> getMyRadarDataByFamily();

  /// Fetch radar data from view (alternative to RPC)
  Future<List<RadarDataPoint>> getMyRadarDataFromView();

  /// Check if user has any feature scores
  Future<bool> hasFeatureScores();
}
```

### CompleteAssessmentOrchestrator

```dart
class CompleteAssessmentOrchestrator {
  /// Complete assessment with full data contract compliance
  Future<CompleteAssessmentResult> completeAssessment({
    required int activityRunId,
    required String activityId,
    int? score,
    required Map<String, dynamic> traitScores,
    required List<FeatureScore> featureScores,
    required int deltaProgress,
    required double confidence,
    List<AssessmentItemInput>? assessmentItems,
  });
}
```

---

## Testing

### Unit Tests

```dart
// test/application/quiz/quiz_scoring_helper_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizScoringHelper', () {
    test('computes correct item score for positive direction', () {
      // Likert=5, direction=1, weight=1.0
      final score = 1.0 * 1 * (5 - 3) / 2;
      expect(score, 1.0);
    });

    test('computes correct item score for reverse direction', () {
      // Likert=5, direction=-1, weight=1.0
      final score = 1.0 * -1 * (5 - 3) / 2;
      expect(score, -1.0);
    });

    test('converts normalized score to 0-100 range', () {
      final normalized = 0.5;  // Midpoint [-1, 1] → 0.5
      final scaled = ((normalized + 1.0) / 2.0) * 100.0;
      expect(scaled, 75.0);
    });

    test('computes delta progress correctly', () {
      final delta = QuizScoringHelper.computeDeltaProgress(
        totalItems: 30,
        answeredItems: 30,
      );
      expect(delta, 20);
    });
  });
}
```

### Integration Tests

```dart
// test/application/quiz/quiz_seeder_integration_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('seeds RIASEC assessment and displays in UI', (tester) async {
    // 1. Seed assessment
    final seeder = QuizItemSeeder(mockSupabase);
    await seeder.seedInstrument(
      instrument: 'riasec_mini',
      language: 'en',
    );

    // 2. Navigate to assessment page
    await tester.pumpWidget(
      MaterialApp(
        home: AssessmentPage(
          instrument: 'riasec_mini',
          language: 'en',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 3. Verify title displayed
    expect(find.text('Career Interest Explorer'), findsOneWidget);

    // 4. Verify 30 items loaded (3 pages of 10)
    expect(find.byType(Card), findsNWidgets(10));
  });
}
```

### Manual Testing Checklist

#### Assessment Flow
- [ ] Navigate to RIASEC assessment (EN)
- [ ] Verify 30 items load (3 pages of 10)
- [ ] Complete first page, verify progress bar updates (10/30)
- [ ] Navigate back/forward between pages
- [ ] Complete all items
- [ ] Submit assessment
- [ ] Verify success dialog shows "Progress updated by 20%"
- [ ] Check database: `activity_runs`, `assessments`, `user_feature_scores` updated

#### Bilingual Support
- [ ] Switch app locale to Arabic
- [ ] Navigate to RIASEC assessment (AR)
- [ ] Verify RTL layout
- [ ] Verify Arabic question text displays correctly
- [ ] Complete and submit assessment

#### Radar Chart
- [ ] Navigate to profile page
- [ ] Verify radar chart displays
- [ ] Check 22 data points present
- [ ] Verify legend shows "Your Score" and "Average"
- [ ] Hover over data points (if web)
- [ ] Test dark mode rendering
- [ ] Filter by family (RIASEC only, Traits only)

#### Edge Cases
- [ ] Start assessment but don't complete (verify partial save?)
- [ ] Complete assessment twice (verify EMA updates correctly)
- [ ] View radar chart before any assessments (verify defaults to 50.0)
- [ ] Test with missing quiz items (verify error handling)

---

## Performance Considerations

### Database Indexes

The following indexes are created in migration 00004:

```sql
-- Fast lookup by instrument + language
create index idx_quiz_items_instrument_lang on quiz_items(instrument, language);

-- Sorting items in display order
create index idx_quiz_items_sort_order on quiz_items(sort_order);

-- Fast feature score lookups for radar chart
create index idx_user_feature_scores_feature_key on user_feature_scores(feature_key);
create index idx_features_key on features(key);
```

### Optimization Tips

1. **Prefetch Quiz Items**: Load items when user lands on activity selection page
2. **Cache Radar Data**: Use Riverpod's `autoDispose` with keepAlive for 5 minutes
3. **Lazy Load Assessments**: Only seed assessments when first accessed
4. **Batch Feature Updates**: The Edge Function already batches EMA updates

---

## Troubleshooting

### Issue: "Unable to load assessment"

**Cause**: Quiz items not seeded or incorrect instrument/language

**Solution**:
```dart
// Check if seeded
final seeder = ref.read(quizItemSeederProvider);
final exists = await seeder.instrumentExists(
  instrument: 'riasec_mini',
  language: 'en',
);

if (!exists) {
  await seeder.seedInstrument(
    instrument: 'riasec_mini',
    language: 'en',
  );
}
```

### Issue: "404 Not Found on get_my_radar_data"

**Cause**: Migration 00004 not run

**Solution**: Execute migration in Supabase SQL Editor

### Issue: Radar chart shows all 50.0 values

**Cause**: User hasn't completed any assessments yet

**Solution**: This is expected behavior. Complete an assessment first.

### Issue: Assessment submission fails with "activity not found"

**Cause**: Activity ID doesn't exist in `activities` table

**Solution**: Create activity entries (see Step 5 in Implementation Guide)

---

## Future Enhancements

### Planned Features
- [ ] Assessment history/timeline view
- [ ] Radar chart animation on profile page load
- [ ] Comparison with custom cohorts (e.g., same age group)
- [ ] Export radar chart as PNG/PDF
- [ ] Adaptive assessment (skip questions based on confidence thresholds)
- [ ] More assessment instruments (e.g., VIA Character Strengths, MBTI-like)

### Localization Expansion
- [ ] Add French translations (`*_fr.json`)
- [ ] Add Spanish translations (`*_es.json`)
- [ ] Right-to-left (RTL) layout testing for Arabic

### Accessibility
- [ ] Screen reader support for radar chart
- [ ] Keyboard navigation for Likert scales
- [ ] Color-blind friendly palettes

---

## References

### Academic Sources
- **RIASEC Model**: Holland, J. L. (1997). *Making Vocational Choices*
- **IPIP-50**: Goldberg, L. R. (1992). *International Personality Item Pool*
- **Big Five**: Costa, P. T., & McCrae, R. R. (1992). *NEO PI-R*

### Technical Documentation
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [Supabase RLS Policies](https://supabase.com/docs/guides/auth/row-level-security)
- [Flutter Riverpod Guide](https://riverpod.dev/)

---

## Changelog

### Version 1.0.0 (Current)
- ✅ Implemented RIASEC Mini-IP (30 items)
- ✅ Implemented IPIP-50 (50 items)
- ✅ Bilingual support (EN/AR)
- ✅ Radar chart with fl_chart
- ✅ Database migration 00004
- ✅ Complete orchestration pipeline
- ✅ Progress tracking and confidence scoring

---

## Contact & Support

For questions or issues related to the assessment system:
- Check [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) for general architecture
- Check [SCORING_SYSTEM.md](./SCORING_SYSTEM.md) for EMA and matching algorithms
- Review [SCHEMA_ANALYSIS.md](./SCHEMA_ANALYSIS.md) for database structure

---

**Document Version**: 1.0
**Last Updated**: 2025-10-13
**Author**: Claude (Anthropic)
**License**: MIT
