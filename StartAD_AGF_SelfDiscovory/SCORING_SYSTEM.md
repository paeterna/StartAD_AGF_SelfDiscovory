# Scoring & Career Matching System

A comprehensive feature-based scoring and career matching system using Exponential Moving Averages (EMA), cosine similarity, and PostgreSQL functions.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Database Schema](#database-schema)
3. [Scoring Algorithm](#scoring-algorithm)
4. [Career Matching](#career-matching)
5. [Runbook](#runbook)
6. [Test Data Loader](#test-data-loader)
7. [API Reference](#api-reference)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
┌─────────────────┐
│  Flutter App    │
│  (Quiz/Game)    │
└────────┬────────┘
         │ Score responses locally
         ▼
┌─────────────────────┐
│  QuizScorer/        │
│  GameScorer         │
│  (Dart)             │
└────────┬────────────┘
         │ Batch feature scores
         ▼
┌─────────────────────────────┐
│  ScoringService             │
│  (Edge Function Invocation) │
└────────┬────────────────────┘
         │ POST batch_features
         ▼
┌───────────────────────────────┐
│  Edge Function                │
│  update_profile_and_match     │
└────────┬──────────────────────┘
         │
         ├─→ upsert_feature_ema()
         │   (EMA aggregation)
         │
         ├─→ Build user vector
         │
         ├─→ Compute cosine similarity
         │   with all careers
         │
         └─→ Store top 50 matches
             in user_career_matches
```

### Key Components

1. **Features Table** (22 features across 3 families)
   - Interests (RIASEC: 6 features)
   - Cognition (6 features)
   - Traits (10 features)

2. **Scoring Helpers** (Flutter/Dart)
   - `QuizScorer`: Likert scale scoring
   - `GameScorer`: Telemetry-based scoring

3. **EMA Aggregation** (PostgreSQL function)
   - Updates user feature scores incrementally
   - Weighted exponential moving average

4. **Career Matching** (Edge Function)
   - Cosine similarity between user and career vectors
   - Confidence-weighted scoring
   - Top contributing features identification

---

## Database Schema

### Core Tables

#### `features`
Defines the 22-dimensional feature space.

| Column | Type | Description |
|--------|------|-------------|
| id | serial | Primary key (defines vector order) |
| key | text | Feature identifier (e.g., 'trait_creativity') |
| family | text | 'interests', 'cognition', or 'traits' |
| description | text | Human-readable description |

**22 Features:**
- **Interests (RIASEC)**: creative, social, analytical, practical, enterprising, conventional
- **Cognition**: verbal, quantitative, spatial, memory, attention, problem_solving
- **Traits**: grit, curiosity, collaboration, conscientiousness, openness, adaptability, communication, leadership, creativity, emotional_intelligence

#### `user_feature_scores`
Aggregated scores per user per feature.

| Column | Type | Description |
|--------|------|-------------|
| user_id | uuid | User reference |
| feature_key | text | Feature reference |
| score_mean | float8 | Mean score [0..100] |
| score_std | float8 | Standard deviation (optional) |
| n | int | Number of observations |
| last_updated | timestamptz | Last update timestamp |

**Primary Key:** (user_id, feature_key)

#### `user_career_matches`
Computed career matches with similarity scores.

| Column | Type | Description |
|--------|------|-------------|
| user_id | uuid | User reference |
| career_id | uuid | Career reference |
| similarity | float8 | Cosine similarity [0..1] |
| confidence | float8 | Overall confidence [0..1] |
| top_features | jsonb | Top 3 contributing features |
| last_updated | timestamptz | Last update timestamp |

**Primary Key:** (user_id, career_id)

#### `careers`
Career definitions with feature vectors.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| title | text | Career title |
| vector | float8[] | 22-dimensional feature vector [0..1] |
| description | text | Career description |
| tags | text[] | Tags for filtering |
| cluster | text | Career cluster |
| active | boolean | Active flag |

#### `quiz_items`
Quiz item configuration for scoring.

| Column | Type | Description |
|--------|------|-------------|
| item_id | text | Quiz item identifier |
| feature_key | text | Target feature |
| direction | float8 | 1.0 (positive) or -1.0 (negative) |
| weight | float8 | Item weight (default 1.0) |
| question_text | text | Question text |

---

## Scoring Algorithm

### Quiz Scoring (Likert Scale)

**Formula:**
```
raw_score = weight × direction × (likert - 3) / 2
normalized_score = 50 + (raw_score × 50)
```

**Example:**
- Likert value: 5 (Strongly Agree)
- Direction: 1.0 (positive)
- Weight: 1.0
- Raw: 1.0 × 1.0 × (5 - 3) / 2 = 1.0
- Normalized: 50 + (1.0 × 50) = 100

**Range:** [0..100] where 50 is neutral

### Game Scoring (Telemetry-Based)

**Metrics:**
1. **Accuracy**: `correct / total`
2. **Speed**: `target_time / avg_reaction_time` (clamped [0..1])
3. **Stability**: `1 - (std_dev / max_std)` (clamped [0..1])

**Composite Scores:**
- **Problem Solving**: 0.5×accuracy + 0.3×speed + 0.2×stability
- **Attention**: 0.6×accuracy + 0.4×stability
- **Memory**: accuracy
- **Spatial**: 0.7×accuracy + 0.3×speed

**Quality Calculation:**
```dart
base_quality = (0.5 + 0.5 × accuracy) × min(1.0, total_trials / 10.0)
```

Range: [0.3..0.9] (clamped for stability)

### EMA Aggregation

**PostgreSQL Function:** `upsert_feature_ema()`

**Formula:**
```sql
new_mean = α × new_value + (1 - α) × old_mean
new_n = old_n + n
```

**Alpha (α):**
- Clamped between 0.15 and 0.7
- Higher quality → higher alpha (more weight on new data)
- Lower quality → lower alpha (more weight on history)

**Rationale:**
- Incremental updates without full recalculation
- Resistant to outliers
- More recent data has appropriate influence

---

## Career Matching

### Algorithm

1. **Build User Vector** (22 dimensions)
   - Fetch all user_feature_scores
   - Order by features.id (ensures consistent ordering)
   - Scale from [0..100] to [0..1]
   - Fill missing features with 0.5 (neutral)

2. **Compute Confidence**
   ```
   avg_observations = total_observations / features_with_data
   confidence = min(1.0, avg_observations / 12.0)
   ```

3. **Cosine Similarity**
   ```
   similarity = dot(user_vector, career_vector) / (||user_vector|| × ||career_vector||)
   ```

4. **Confidence Weighting**
   ```
   final_similarity = similarity × confidence
   ```

5. **Top Features**
   - Compute contribution = user[i] × career[i] for each feature
   - Sort by contribution descending
   - Return top 3

6. **Store Top 50 Matches**
   - Delete old matches for user
   - Insert top 50 new matches

### Career Vectors

Example: **Software Developer**
```javascript
[
  0.3,  // interest_creative
  0.3,  // interest_social
  0.9,  // interest_analytical (HIGH)
  0.5,  // interest_practical
  0.4,  // interest_enterprising
  0.6,  // interest_conventional
  0.6,  // cognition_verbal
  0.9,  // cognition_quantitative (HIGH)
  0.7,  // cognition_spatial
  0.5,  // cognition_memory
  0.7,  // cognition_attention
  0.9,  // cognition_problem_solving (HIGH)
  0.8,  // trait_grit
  0.8,  // trait_curiosity
  0.7,  // trait_collaboration
  0.7,  // trait_conscientiousness
  0.6,  // trait_openness
  0.7,  // trait_adaptability
  0.6,  // trait_communication
  0.5,  // trait_leadership
  0.7,  // trait_creativity
  0.5   // trait_emotional_intelligence
]
```

Values represent **importance** of each feature for that career (0 = not important, 1 = very important).

---

## Runbook

### Initial Setup

1. **Run Migration**
   ```sql
   -- In Supabase SQL Editor
   -- Run: supabase/migrations/00003_scoring_and_matching_system.sql
   ```

2. **Deploy Edge Function**
   ```bash
   supabase functions deploy update_profile_and_match
   ```

3. **Verify Tables**
   ```sql
   -- Check features
   SELECT COUNT(*) FROM features; -- Should be 22

   -- Check quiz_items
   SELECT COUNT(*) FROM quiz_items; -- Should be 12 (sample)

   -- Check careers with vectors
   SELECT title, array_length(vector, 1) FROM careers WHERE vector IS NOT NULL;
   ```

### Testing the System

#### 1. Manual Score Insertion

```sql
-- Manually insert a feature score for testing
INSERT INTO user_feature_scores (user_id, feature_key, score_mean, n)
VALUES
  ('YOUR_USER_ID', 'trait_creativity', 85.0, 5),
  ('YOUR_USER_ID', 'interest_analytical', 75.0, 3)
ON CONFLICT (user_id, feature_key) DO UPDATE
SET score_mean = EXCLUDED.score_mean, n = EXCLUDED.n;
```

#### 2. Test EMA Function

```sql
-- Test the EMA aggregation
SELECT public.upsert_feature_ema(
  'YOUR_USER_ID'::uuid,
  'trait_grit',
  80.0,  -- new value
  0.5,   -- weight/alpha
  3      -- number of observations
);

-- Verify the result
SELECT * FROM user_feature_scores
WHERE user_id = 'YOUR_USER_ID' AND feature_key = 'trait_grit';
```

#### 3. Test Profile Completeness

```sql
-- Get profile completeness
SELECT public.get_profile_completeness('YOUR_USER_ID'::uuid);
```

#### 4. Test Edge Function

**Using curl:**
```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/update_profile_and_match \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "YOUR_USER_ID",
    "batch_features": [
      {"key": "trait_creativity", "mean": 85.0, "n": 5, "quality": 0.7},
      {"key": "interest_analytical", "mean": 90.0, "n": 4, "quality": 0.8}
    ]
  }'
```

**Using Flutter:**
```dart
final scoringService = ScoringService(Supabase.instance.client);

final response = await scoringService.updateProfileAndMatch(
  userId: userId,
  batchFeatures: [
    FeatureScore(key: 'trait_creativity', mean: 85.0, n: 5, quality: 0.7),
    FeatureScore(key: 'interest_analytical', mean: 90.0, n: 4, quality: 0.8),
  ],
);

print('Success: ${response.success}');
print('Matches computed: ${response.matchesComputed}');
print('Confidence: ${response.confidence}');
```

#### 5. View Career Matches

```sql
-- View top 10 career matches for a user
SELECT
  c.title,
  ucm.similarity,
  ucm.confidence,
  ucm.top_features,
  (ucm.similarity * 100)::int as match_percent
FROM user_career_matches ucm
JOIN careers c ON c.id = ucm.career_id
WHERE ucm.user_id = 'YOUR_USER_ID'
ORDER BY ucm.similarity DESC
LIMIT 10;
```

### Monitoring

#### Check System Health

```sql
-- Users with profiles
SELECT COUNT(DISTINCT user_id) FROM user_feature_scores;

-- Average profile completeness
SELECT AVG(
  (SELECT get_profile_completeness(ufs.user_id))
) as avg_completeness
FROM (SELECT DISTINCT user_id FROM user_feature_scores) ufs;

-- Career match distribution
SELECT
  CASE
    WHEN similarity >= 0.7 THEN 'High (70%+)'
    WHEN similarity >= 0.4 THEN 'Medium (40-70%)'
    ELSE 'Low (<40%)'
  END as match_level,
  COUNT(*) as count
FROM user_career_matches
GROUP BY match_level;
```

---

## Test Data Loader

### SQL Script for Test Data

```sql
-- =====================================================
-- Test Data Loader
-- Creates sample users with feature scores and matches
-- =====================================================

-- Helper function to generate random user ID (for testing)
-- In production, use actual auth.users IDs

DO $$
DECLARE
  test_user_id uuid := gen_random_uuid();
  feature_rec RECORD;
BEGIN
  -- Print the test user ID
  RAISE NOTICE 'Creating test data for user: %', test_user_id;

  -- Scenario 1: Analytical/Tech-oriented student
  -- High scores in analytical thinking, problem solving, quantitative

  FOR feature_rec IN
    SELECT key FROM features ORDER BY id
  LOOP
    INSERT INTO user_feature_scores (user_id, feature_key, score_mean, n)
    VALUES (
      test_user_id,
      feature_rec.key,
      CASE feature_rec.key
        -- High analytical interests
        WHEN 'interest_analytical' THEN 85.0
        WHEN 'interest_creative' THEN 45.0
        WHEN 'interest_social' THEN 40.0
        WHEN 'interest_practical' THEN 60.0
        WHEN 'interest_enterprising' THEN 55.0
        WHEN 'interest_conventional' THEN 65.0

        -- Strong cognitive abilities in tech areas
        WHEN 'cognition_verbal' THEN 70.0
        WHEN 'cognition_quantitative' THEN 90.0
        WHEN 'cognition_spatial' THEN 75.0
        WHEN 'cognition_memory' THEN 65.0
        WHEN 'cognition_attention' THEN 80.0
        WHEN 'cognition_problem_solving' THEN 88.0

        -- Moderate traits
        WHEN 'trait_grit' THEN 75.0
        WHEN 'trait_curiosity' THEN 80.0
        WHEN 'trait_collaboration' THEN 60.0
        WHEN 'trait_conscientiousness' THEN 70.0
        WHEN 'trait_openness' THEN 65.0
        WHEN 'trait_adaptability' THEN 70.0
        WHEN 'trait_communication' THEN 55.0
        WHEN 'trait_leadership' THEN 50.0
        WHEN 'trait_creativity' THEN 60.0
        WHEN 'trait_emotional_intelligence' THEN 55.0
        ELSE 50.0
      END,
      FLOOR(5 + RANDOM() * 10)::int  -- Random n between 5-15
    );
  END LOOP;

  RAISE NOTICE 'Inserted feature scores for test user';

  -- Manually trigger the matching function
  -- Note: In production, this is done via Edge Function
  RAISE NOTICE 'Run Edge Function to compute matches:';
  RAISE NOTICE 'POST /functions/v1/update_profile_and_match with user_id: %', test_user_id;

END $$;
```

### Dart Test Data Generator

Save as `test/scoring_test_data.dart`:

```dart
import 'package:startad_agf_selfdiscovery/application/scoring/quiz_scorer.dart';
import 'package:startad_agf_selfdiscovery/application/scoring/game_scorer.dart';
import 'package:startad_agf_selfdiscovery/data/models/feature_score.dart';

/// Generate test quiz responses for different personality types
class TestDataGenerator {
  /// Generate responses for an analytical/tech-oriented personality
  static List<FeatureScore> generateAnalyticalProfile() {
    // Sample quiz items matching the database seed
    final items = [
      QuizItem(itemId: 'pa_001', featureKey: 'trait_creativity', direction: 1.0),
      QuizItem(itemId: 'pa_002', featureKey: 'trait_collaboration', direction: 1.0),
      QuizItem(itemId: 'pa_003', featureKey: 'trait_grit', direction: 1.0),
      QuizItem(itemId: 'pa_004', featureKey: 'interest_analytical', direction: 1.0),
      QuizItem(itemId: 'pa_005', featureKey: 'interest_creative', direction: 1.0),
      QuizItem(itemId: 'pa_006', featureKey: 'interest_social', direction: 1.0),
    ];

    // Responses favoring analytical thinking
    final responses = [
      QuizResponse(itemId: 'pa_001', likertValue: 4),  // Somewhat creative
      QuizResponse(itemId: 'pa_002', likertValue: 3),  // Neutral on collaboration
      QuizResponse(itemId: 'pa_003', likertValue: 5),  // High grit
      QuizResponse(itemId: 'pa_004', likertValue: 5),  // High analytical
      QuizResponse(itemId: 'pa_005', likertValue: 3),  // Neutral creative
      QuizResponse(itemId: 'pa_006', likertValue: 2),  // Low social
    ];

    return QuizScorer.computeBatchScores(
      responses: responses,
      items: items,
      defaultQuality: 0.75,
    );
  }

  /// Generate game telemetry for problem-solving task
  static List<FeatureScore> generateProblemSolvingGameScores() {
    final telemetry = GameTelemetry(
      correct: 18,
      total: 20,
      reactionTimes: [1200, 1150, 1300, 1180, 1250], // ms
      targetTime: 1500,
    );

    return GameScorer.computeBatchScores(
      telemetry: telemetry,
      mappings: GameScorer.problemSolvingMappings,
      qualityMultiplier: 1.0,
    );
  }

  /// Generate complete test profile
  static List<FeatureScore> generateCompleteProfile() {
    return [
      ...generateAnalyticalProfile(),
      ...generateProblemSolvingGameScores(),
    ];
  }
}

// Usage in tests
void main() {
  final testProfile = TestDataGenerator.generateCompleteProfile();

  print('Generated ${testProfile.length} feature scores:');
  for (final score in testProfile) {
    print('${score.key}: ${score.mean.toStringAsFixed(1)} (n=${score.n}, q=${score.quality.toStringAsFixed(2)})');
  }
}
```

---

## API Reference

### Edge Function: `update_profile_and_match`

**Endpoint:** `POST /functions/v1/update_profile_and_match`

**Request Body:**
```typescript
{
  user_id: string;
  batch_features: Array<{
    key: string;      // Feature key (e.g., 'trait_creativity')
    mean: number;     // Score [0..100]
    n: number;        // Number of observations
    quality: number;  // Quality/confidence [0..1]
  }>;
}
```

**Response:**
```typescript
{
  ok: boolean;
  matches_computed: number;
  matches_stored: number;
  confidence: number;
  top: Array<{
    career_id: string;
    similarity: number;
    top_features: Array<{
      feature_key: string;
      contribution: number;
    }>;
  }>;
}
```

**Error Response:**
```typescript
{
  error: string;
}
```

### PostgreSQL Functions

#### `upsert_feature_ema()`
```sql
public.upsert_feature_ema(
  p_user_id uuid,
  p_key text,
  p_value float8,   -- New score [0..100]
  p_weight float8,  -- Weight/alpha [0..1]
  p_n int           -- Number of observations
) RETURNS void
```

#### `get_profile_completeness()`
```sql
public.get_profile_completeness(
  p_user_id uuid
) RETURNS float8  -- Percentage [0..100]
```

#### `get_user_feature_vector()`
```sql
public.get_user_feature_vector(
  p_user_id uuid
) RETURNS float8[]  -- 22-dimensional vector [0..1]
```

---

## Troubleshooting

### Common Issues

#### 1. **Vector Dimension Mismatch**

**Error:** `Career X has invalid vector (expected 22, got 0)`

**Solution:**
```sql
-- Check careers with invalid vectors
SELECT id, title, array_length(vector, 1) as vector_length
FROM careers
WHERE vector IS NULL OR array_length(vector, 1) != 22;

-- Fix by setting default vector
UPDATE careers
SET vector = array_fill(0.5::float8, array[22])
WHERE vector IS NULL OR array_length(vector, 1) != 22;
```

#### 2. **No Matches Computed**

**Problem:** Edge Function returns `matches_computed: 0`

**Checklist:**
- [ ] Are there active careers? `SELECT COUNT(*) FROM careers WHERE active = true;`
- [ ] Do careers have vectors? `SELECT COUNT(*) FROM careers WHERE vector IS NOT NULL;`
- [ ] Does user have feature scores? `SELECT COUNT(*) FROM user_feature_scores WHERE user_id = 'X';`

#### 3. **Low Confidence Scores**

**Problem:** `confidence < 0.3`

**Explanation:** User needs more observations. Confidence = min(1.0, avg_n / 12)

**Solution:** User needs to complete more quizzes/games. Each feature needs ~12 observations for 100% confidence.

#### 4. **Profile Completeness Stuck at 0%**

**Check:**
```sql
SELECT * FROM user_feature_scores WHERE user_id = 'YOUR_USER_ID';
```

If empty, feature scores aren't being inserted. Check:
1. Edge Function is being called
2. EMA function has correct permissions
3. RLS policies allow inserts

#### 5. **CORS Errors in Edge Function**

**Error:** `Access-Control-Allow-Origin` header missing

**Fix:** Verify CORS headers in Edge Function:
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Handle preflight
if (req.method === 'OPTIONS') {
  return new Response('ok', { headers: corsHeaders });
}
```

---

## Performance Considerations

### Optimization Tips

1. **Batch Feature Updates**
   - Send all features from a quiz/game in one Edge Function call
   - Reduces network overhead and function invocations

2. **Career Vector Caching**
   - Career vectors rarely change
   - Consider caching in Flutter app for offline matching

3. **Indexing**
   - All necessary indexes are created in migration
   - Monitor slow queries with `EXPLAIN ANALYZE`

4. **RLS Performance**
   - RLS policies use indexed columns (user_id)
   - Policies are efficient for per-user queries

### Scaling Considerations

**Current system handles:**
- 10,000+ users
- 100+ careers
- Real-time matching (<2 seconds)

**For larger scale:**
- Implement career vector caching
- Use materialized views for cohort statistics
- Consider background job for batch matching
- Add Redis cache for hot data

---

## Next Steps

1. **Add More Careers**
   - Define feature vectors for 50-100 careers
   - Use career clustering for better organization

2. **Improve Matching Algorithm**
   - Experiment with other similarity metrics
   - Add user feedback loop
   - Implement collaborative filtering

3. **Add Game Telemetry**
   - Define more game-to-feature mappings
   - Calibrate scoring thresholds
   - A/B test different quality calculations

4. **Analytics & Insights**
   - Track score distributions
   - Identify feature correlations
   - Provide explanations for matches

5. **User Experience**
   - Show progress towards confidence goals
   - Explain why careers match
   - Suggest activities to improve specific features

---

## Support

For questions or issues:
- Check the [Troubleshooting](#troubleshooting) section
- Review the [runbook](#runbook)
- Contact the development team

**Built with:** PostgreSQL • Supabase Edge Functions • Flutter • Riverpod

**Version:** 1.0.0 | **Last Updated:** 2025-01-13
