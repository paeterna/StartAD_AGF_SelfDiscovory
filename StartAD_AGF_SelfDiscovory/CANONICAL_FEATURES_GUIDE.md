# Canonical Features System - Implementation Guide

## Overview

This system implements a **Single Canonical Feature Space (22D)** for all assessments (quizzes and games) in the application. All feature scores are normalized to a 0-100 scale and stored using only the 22 predefined canonical feature keys.

## The 22 Canonical Features

### Interests (6 features)
Based on Holland's RIASEC model, mapped to canonical names:

| Canonical Key | RIASEC Equivalent | Description |
|--------------|-------------------|-------------|
| `interest_creative` | Artistic | Creative and artistic interests |
| `interest_social` | Social | Social and helping interests |
| `interest_analytical` | Investigative | Analytical and investigative interests |
| `interest_practical` | Realistic | Practical and hands-on interests |
| `interest_enterprising` | Enterprising | Enterprising and leadership interests |
| `interest_conventional` | Conventional | Conventional and organizational interests |

### Cognition (6 features)
Cognitive abilities:

| Canonical Key | Description |
|--------------|-------------|
| `cognition_verbal` | Verbal reasoning and language |
| `cognition_quantitative` | Quantitative and mathematical reasoning |
| `cognition_spatial` | Spatial reasoning and visualization |
| `cognition_memory` | Memory and recall |
| `cognition_attention` | Attention and focus |
| `cognition_problem_solving` | Problem solving and logic |

### Traits (10 features)
Personality and work styles:

| Canonical Key | Description |
|--------------|-------------|
| `trait_grit` | Perseverance and persistence |
| `trait_curiosity` | Curiosity and learning orientation |
| `trait_collaboration` | Collaboration and teamwork |
| `trait_conscientiousness` | Conscientiousness and organization |
| `trait_openness` | Openness to experience |
| `trait_adaptability` | Adaptability and flexibility |
| `trait_communication` | Communication skills |
| `trait_leadership` | Leadership and influence |
| `trait_creativity` | Creative thinking |
| `trait_emotional_intelligence` | Emotional intelligence |

## Architecture

### Core Components

```
lib/core/scoring/
├── features_registry.dart      # Canonical features definition
├── scoring_pipeline.dart       # Unified scoring pipeline
└── submit_batch.dart          # Edge Function submission helper
```

### Key Files

1. **`features_registry.dart`**
   - Defines the 22 canonical features with English and Arabic labels
   - Provides validation functions: `isCanonicalKey()`, `assertCanonicalKeys()`
   - Contains RIASEC → Canonical mapping: `riasecToCanonical()`
   - Feature contribution system for quiz/game items

2. **`scoring_pipeline.dart`**
   - Unified scoring pipeline for all assessments
   - Converts raw responses to normalized 0-100 scores
   - Computes quality metrics based on observation count
   - Calculates progress delta (0-20)

3. **`submit_batch.dart`**
   - Helpers for submitting to activity_runs table
   - Edge Function invocation with retry logic
   - Validates all keys are canonical before submission

## Data Flow

```
Quiz/Game → Item Outcomes → Scoring Pipeline → Canonical Scores
                                ↓
                    activity_runs (traitScores)
                                ↓
                    assessments (audit trail)
                                ↓
                    Edge Function (update_profile_and_match)
                                ↓
                    user_feature_scores (EMA aggregation)
                                ↓
                    user_career_matches (similarity)
                                ↓
                    Dashboard/Spider Graph
```

## Adding New Quiz Items

### Step 1: Create Quiz JSON

```json
{
  "instrument": "my_quiz",
  "items": [
    {
      "id": "q1",
      "text": "I enjoy solving complex problems",
      "feature_key": "analytical",  // Bare RIASEC key
      "direction": 1,
      "weight": 1.0
    }
  ]
}
```

### Step 2: Quiz Scoring Handles Mapping Automatically

The `QuizScoringHelper` automatically maps RIASEC keys to canonical:

```dart
// In quiz_scoring_helper.dart
final featureScores = QuizScoringHelper.computeFeatureScores(
  items: metadata.items,
  responses: responses,
  instrument: 'riasec_mini', // Triggers RIASEC mapping
);

// Output: analytical → interest_analytical (canonical)
```

### Step 3: No Code Changes Needed!

The system automatically:
1. Maps `analytical` → `interest_analytical`
2. Validates the canonical key
3. Computes normalized 0-100 scores
4. Submits to Edge Function with canonical keys

## Adding New Game

### Step 1: Define Item Contributions

```dart
// In your game controller
Map<String, List<FeatureContribution>> buildContributions() {
  return {
    'memory_game_session': [
      FeatureContribution(
        key: 'cognition_memory',  // Canonical key
        weight: 1.0,
      ),
      FeatureContribution(
        key: 'cognition_attention',  // Canonical key
        weight: 0.8,
      ),
    ],
  };
}
```

### Step 2: Create Item Outcomes

```dart
// Convert game performance to ItemOutcomes
final outcomes = [
  ItemOutcome(
    itemId: 'memory_game_session',
    value: accuracyToNormalized(correctMatches, totalAttempts),
    durationMs: gameTime,
  ),
];
```

### Step 3: Use Scoring Pipeline

```dart
import 'package:startad_agf_selfdiscovery/core/scoring/scoring_pipeline.dart';

final scoringOutput = ScoringPipeline.computeScores(
  items: outcomes,
  itemContributions: buildContributions(),
  instrumentName: 'Memory Match',
  kind: 'game',
  baselineNPerKey: 1, // Games typically have 1-2 observations per feature
);

// scoringOutput.means0to100 contains canonical scores
// scoringOutput.toBatchFeatures() ready for Edge Function
```

## Validation Guards

The system enforces canonical keys at multiple points:

### 1. At Scoring Time

```dart
// Automatic validation in scoring pipeline
// Throws StateError if non-canonical key detected
final scoringOutput = ScoringPipeline.computeScores(
  items: outcomes,
  itemContributions: contributions, // Validated here
  instrumentName: 'My Quiz',
  kind: 'quiz',
);
```

### 2. At Orchestration Time

```dart
// In complete_assessment_orchestrator.dart
await orchestrator.completeAssessment(
  // ... other params
  traitScores: traitScores,      // Validated here
  featureScores: featureScores,  // Validated here
);
```

### 3. At Submission Time

```dart
// In submit_batch.dart
await batchSubmissionHelper.submitBatch(
  // ... params
  scoringOutput: output, // Keys validated before Edge Function call
);
```

## Error Handling

### Non-Canonical Key Error

```
StateError: Non-canonical feature key encountered: "riasec_realistic".
Only the 22 canonical features are allowed.
See lib/core/scoring/features_registry.dart
```

**Solution**: Use the RIASEC mapping or ensure your quiz uses canonical keys.

### Foreign Key Constraint Violation

This was the original issue - fixed by using canonical keys throughout.

```
Error: insert or update on table "user_feature_scores"
violates foreign key constraint "user_feature_scores_feature_key_fkey"
```

**Solution**: Ensure all assessments use canonical keys from `features_registry.dart`.

## Testing

### Unit Test Example

```dart
import 'package:test/test.dart';
import 'package:startad_agf_selfdiscovery/core/scoring/features_registry.dart';

void main() {
  group('Canonical Features', () {
    test('validates canonical keys', () {
      expect(isCanonicalKey('interest_creative'), isTrue);
      expect(isCanonicalKey('riasec_realistic'), isFalse);
    });

    test('maps RIASEC to canonical', () {
      expect(riasecToCanonical('realistic'), equals('interest_practical'));
      expect(riasecToCanonical('investigative'), equals('interest_analytical'));
    });

    test('rejects non-canonical keys', () {
      expect(
        () => assertCanonicalKeys(['bad_key']),
        throwsStateError,
      );
    });
  });
}
```

### Integration Test

1. Submit a quiz with RIASEC keys
2. Verify `activity_runs.trait_scores` contains canonical keys only
3. Verify Edge Function receives canonical batch_features
4. Verify `user_feature_scores` table has canonical keys
5. Verify spider graph displays data correctly

## Spider Graph (Radar Chart)

The radar chart automatically fetches data using canonical features:

```dart
// In traits_repository.dart
final radarData = await repository.getMyRadarDataByFamily();

// radarData.interests → interest_* features (6)
// radarData.cognition → cognition_* features (6)
// radarData.traits → trait_* features (10)
```

The `v_user_radar` view or `get_my_radar_data()` RPC must return features in order by `features.id`.

## Database Schema

### Features Table (Seeded in Migration 00003)

```sql
-- Already seeded with 22 canonical features
SELECT key, family FROM features ORDER BY id;

-- Output:
-- interest_creative       | interests
-- interest_social         | interests
-- interest_analytical     | interests
-- interest_practical      | interests
-- interest_enterprising   | interests
-- interest_conventional   | interests
-- cognition_verbal        | cognition
-- cognition_quantitative  | cognition
-- cognition_spatial       | cognition
-- cognition_memory        | cognition
-- cognition_attention     | cognition
-- cognition_problem_solving | cognition
-- trait_grit              | traits
-- trait_curiosity         | traits
-- trait_collaboration     | traits
-- trait_conscientiousness | traits
-- trait_openness          | traits
-- trait_adaptability      | traits
-- trait_communication     | traits
-- trait_leadership        | traits
-- trait_creativity        | traits
-- trait_emotional_intelligence | traits
```

### User Feature Scores

```sql
-- Stores aggregated scores (EMA) per user per feature
SELECT user_id, feature_key, score_mean, n
FROM user_feature_scores
WHERE user_id = '...';

-- Example output:
-- user_id | feature_key          | score_mean | n
-- --------|---------------------|-----------|---
-- xxx     | interest_creative   | 75.5      | 15
-- xxx     | cognition_memory    | 82.0      | 8
```

## Edge Function Contract

### Request Payload

```json
{
  "user_id": "uuid",
  "batch_features": [
    {
      "key": "interest_creative",  // Must be canonical
      "mean": 75.5,
      "n": 5,
      "quality": 0.8
    }
  ],
  "instrument": "Mini RIASEC",
  "activity_kind": "quiz",
  "delta_progress_hint": 5
}
```

### Response

```json
{
  "success": true,
  "matches_computed": 5,
  "confidence": 0.65
}
```

## Localization

Feature labels are localized, but **keys remain constant**:

```dart
// English
final labelEn = kFeaturesByKey['interest_creative']!.labelEn;
// → "Creative & Artistic"

// Arabic
final labelAr = kFeaturesByKey['interest_creative']!.labelAr;
// → "إبداعي وفني"

// Key never changes
final key = 'interest_creative'; // Same in all languages
```

## Best Practices

### ✅ DO

- Use canonical keys from `features_registry.dart`
- Let `QuizScoringHelper` handle RIASEC mapping automatically
- Validate keys with `assertCanonicalKeys()` before submission
- Use `ScoringPipeline.computeScores()` for all assessments
- Order features by `features.id` in database queries

### ❌ DON'T

- Create new feature keys outside the 22 canonical ones
- Use RIASEC-prefixed keys (`riasec_realistic`) in storage
- Skip validation when building trait scores
- Assume alphabetical feature ordering
- Modify the 22 canonical features without updating the database schema

## Troubleshooting

### Quiz submission fails with foreign key error

**Check**: Are you using canonical keys?

```dart
// ❌ Wrong
final key = 'riasec_realistic';

// ✅ Correct
final key = riasecToCanonical('realistic'); // → 'interest_practical'
```

### Spider graph shows "No trait data yet"

**Check**:
1. Are feature scores being saved to `user_feature_scores`?
2. Is the Edge Function succeeding?
3. Is the `v_user_radar` view using correct feature keys?

```sql
-- Debug query
SELECT f.key, ufs.score_mean
FROM features f
LEFT JOIN user_feature_scores ufs ON ufs.feature_key = f.key AND ufs.user_id = '...'
ORDER BY f.id;
```

### Edge Function returns 500 error

**Check**: Edge Function logs for foreign key constraint violations.

This means non-canonical keys are being sent. Add logging:

```dart
print('🔵 Submitting features: ${scoringOutput.means0to100.keys}');
```

All keys must match the 22 canonical features exactly.

## Migration Notes

If you have existing data with non-canonical keys:

1. **Option A: Data Migration**
   ```sql
   -- Map old keys to canonical
   UPDATE user_feature_scores
   SET feature_key = 'interest_practical'
   WHERE feature_key = 'riasec_realistic';
   ```

2. **Option B: Fresh Start**
   - Clear `user_feature_scores` table
   - Users re-take assessments with canonical keys

## Summary

The canonical features system ensures:

- ✅ **Single source of truth**: 22 features, defined once
- ✅ **Type safety**: Validated at compile-time and runtime
- ✅ **Consistency**: Same keys across quizzes, games, database, UI
- ✅ **Localization-ready**: Keys constant, labels translated
- ✅ **Extensible**: Add new items via `itemContributions`, not new keys
- ✅ **No schema changes**: Works with existing database structure

All assessments feed into the same 22-dimensional feature space, enabling consistent career matching and profile visualization.
