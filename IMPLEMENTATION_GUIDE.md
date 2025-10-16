# Implementation Guide: Data Contract Compliance

**Status:** ✅ **All Critical Fixes Applied**

This guide explains how to use the new services to implement quiz/game flows according to the data contract.

---

## What Was Fixed

### 1. ✅ Migration 00003 - Removed Redundant Enum Drop/Recreate
**Before:**
```sql
drop type if exists activity_type_t cascade;
create type activity_type_t as enum ('quiz','game');
```

**After:**
```sql
-- Note: activity_type_t enum already exists from 00001_init_schema.sql
-- No modification needed - the enum is already correct
```

### 2. ✅ Trigger Now Fires on INSERT OR UPDATE
**Before:**
```sql
create trigger trg_update_progress_after_run
after insert on public.activity_runs
for each row execute function public.fn_update_progress_after_run();
```

**After:**
```sql
create trigger trg_update_progress_after_run
after insert or update on public.activity_runs
for each row
when (new.completed_at is not null and (old is null or old.completed_at is null))
execute function public.fn_update_progress_after_run();
```

Now the trigger fires when:
- A new activity_run is inserted with `completed_at` set
- An existing activity_run is updated to set `completed_at`

### 3. ✅ New Service Layer Created

#### Services Created:
1. **[ActivityService](lib/application/activity/activity_service.dart)** - Manages activity_runs and discovery_progress
2. **[AssessmentService](lib/application/assessment/assessment_service.dart)** - Manages assessments and assessment_items
3. **[CompleteAssessmentOrchestrator](lib/application/assessment/complete_assessment_orchestrator.dart)** - Orchestrates the complete flow

#### Providers:
- [activity_providers.dart](lib/application/activity/activity_providers.dart)

### 4. ✅ Dashboard Updated
- Shows **Discovery Progress** (percent, from activity_runs)
- Shows **Streak Days** (from discovery_progress)
- Shows **Profile Completeness** (from user_feature_scores)

---

## How to Use: Complete Data Contract Flow

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  COMPLETE ASSESSMENT FLOW                │
└─────────────────────────────────────────────────────────┘

1. START ACTIVITY
   ↓
   ActivityService.startActivityRun(activityId)
   → Inserts into activity_runs
   → Returns runId

2. USER COMPLETES QUIZ/GAME
   ↓
   Compute scores locally (QuizScorer / GameScorer)
   → FeatureScores (for EMA)
   → TraitScores (for audit)
   → DeltaProgress (0-20)

3. COMPLETE ACTIVITY (Orchestrated)
   ↓
   CompleteAssessmentOrchestrator.completeAssessment(
     activityRunId: runId,
     traitScores: {...},
     featureScores: [...],
     deltaProgress: 10,
     confidence: 0.75
   )

   ↓ Step 3a: Complete activity_run
   ActivityService.completeActivityRun()
   → UPDATE activity_runs SET completed_at, score, trait_scores, delta_progress
   → TRIGGER fires → Updates discovery_progress (percent, streak)

   ↓ Step 3b: Create assessment (audit)
   AssessmentService.createAssessment()
   → INSERT INTO assessments (trait_scores, delta_progress, confidence)
   → Optional: INSERT INTO assessment_items (fine-grained audit)

   ↓ Step 3c: Update feature scores
   ScoringService.updateProfileAndMatch()
   → Edge Function → upsert_feature_ema() for each feature
   → Edge Function → Compute cosine similarity
   → Edge Function → Update user_career_matches

4. DONE
   ✅ discovery_progress updated (dashboard shows percent & streak)
   ✅ assessments created (audit trail)
   ✅ user_feature_scores updated (EMA)
   ✅ user_career_matches computed (careers page)
```

---

## Example: Integrating a Quiz

### Step 1: Get Activity ID

**Option A: Fetch from Database (Recommended)**
```dart
final activityService = ref.read(activityServiceProvider);
final activities = await activityService.getActivities(kind: 'quiz');
final personalityQuizId = activities
    .firstWhere((a) => a.title == 'Personality Assessment')
    .id;
```

**Option B: Seed Database and Use Known ID**
```sql
-- In migration or seed script
INSERT INTO activities (id, title, kind, estimated_minutes)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Personality Assessment', 'quiz', 5);
```

```dart
const personalityQuizId = '11111111-1111-1111-1111-111111111111';
```

### Step 2: Start Activity Run (When Quiz Begins)

```dart
final activityService = ref.read(activityServiceProvider);

// Start the run
final runId = await activityService.startActivityRun(
  activityId: personalityQuizId,
);

// Store runId for later completion
```

### Step 3: User Completes Quiz

```dart
// Collect responses
final responses = [
  QuizResponse(itemId: 'pa_001', likertValue: 5),
  QuizResponse(itemId: 'pa_002', likertValue: 4),
  // ... more responses
];

// Compute scores
final quizItems = [
  QuizItem(itemId: 'pa_001', featureKey: 'trait_creativity', direction: 1.0),
  QuizItem(itemId: 'pa_002', featureKey: 'trait_collaboration', direction: 1.0),
  // ... more items
];

final featureScores = QuizScorer.computeBatchScores(
  responses: responses,
  items: quizItems,
  defaultQuality: 0.75,
);

// Compute trait scores for audit (aggregate by feature family)
final traitScores = <String, double>{};
for (final score in featureScores) {
  traitScores[score.key] = score.mean;
}
```

### Step 4: Complete the Assessment

```dart
final orchestrator = CompleteAssessmentOrchestrator(
  activityService: ref.read(activityServiceProvider),
  assessmentService: AssessmentService(Supabase.instance.client),
  scoringService: ref.read(scoringServiceProvider),
);

final result = await orchestrator.completeAssessment(
  activityRunId: runId,
  activityId: personalityQuizId,
  score: responses.length, // Optional: total items completed
  traitScores: traitScores,
  featureScores: featureScores,
  deltaProgress: 10, // 0-20 based on quiz length/importance
  confidence: 0.75, // Based on quality of responses
);

if (result.success) {
  // Show success message
  print('Assessment complete!');
  print('Matches computed: ${result.matchesComputed}');
  print('Confidence: ${result.confidence}');

  // Navigate to results or careers page
  context.push(AppRoutes.careers);
} else {
  // Handle error
  print('Error: ${result.error}');
}
```

### Step 5: Optionally Add Item-Level Audit Trail

```dart
// For detailed audit, create assessment items
final assessmentItems = responses.map((response) {
  final item = quizItems.firstWhere((i) => i.itemId == response.itemId);
  final scoreNorm = QuizScorer.scoreItem(
    likertValue: response.likertValue,
    direction: item.direction,
    weight: item.weight,
  );

  return AssessmentItemInput(
    itemId: response.itemId,
    response: {'likert': response.likertValue},
    scoreRaw: (response.likertValue - 3) / 2.0, // -1 to 1
    scoreNorm: scoreNorm, // 0 to 100
    durationMs: response.durationMs,
  );
}).toList();

// Pass to orchestrator
final result = await orchestrator.completeAssessment(
  // ... other params
  assessmentItems: assessmentItems, // Add this
);
```

---

## Example: Integrating a Game

### Game with Telemetry

```dart
// Step 1: Start activity run
final runId = await activityService.startActivityRun(
  activityId: problemSolvingGameId,
);

// Step 2: User plays game, collect telemetry
final telemetry = GameTelemetry(
  correct: 18,
  total: 20,
  reactionTimes: [1200, 1150, 1300, 1180, 1250],
  targetTime: 1500,
);

// Step 3: Compute scores
final featureScores = GameScorer.computeBatchScores(
  telemetry: telemetry,
  mappings: GameScorer.problemSolvingMappings,
  qualityMultiplier: 1.0,
);

final traitScores = {
  'problem_solving': GameScorer.scaleToHundred(
    GameScorer.computeProblemSolving(telemetry),
  ),
  'attention': GameScorer.scaleToHundred(
    GameScorer.computeAttention(telemetry),
  ),
};

// Step 4: Complete assessment
final result = await orchestrator.completeAssessment(
  activityRunId: runId,
  activityId: problemSolvingGameId,
  score: telemetry.correct,
  traitScores: traitScores,
  featureScores: featureScores,
  deltaProgress: 15, // Games might give more progress
  confidence: 0.85, // Higher confidence from objective metrics
);
```

---

## Delta Progress Guidelines

**How much progress to award?**

`delta_progress` is a value between **0-20** that gets added to `discovery_progress.percent` (capped at 100).

### Recommended Values:

| Activity Type | Duration | Delta Progress | Reasoning |
|---------------|----------|----------------|-----------|
| Short quiz (5-7 questions) | 2-3 min | 5-8 | Quick completion |
| Medium quiz (10-15 questions) | 5-7 min | 10-12 | Standard assessment |
| Long quiz (20+ questions) | 10+ min | 15-18 | Comprehensive assessment |
| Short game (single level) | 3-5 min | 8-10 | Skill-based |
| Long game (multiple levels) | 10+ min | 15-20 | Extensive data |
| Onboarding quiz | 5 min | 20 | One-time, important |

### Formula:
```dart
int computeDeltaProgress(int questionCount, int durationMinutes) {
  // Base: 0.5 per question, capped at 15
  final baseFromQuestions = min(15, (questionCount * 0.5).round());

  // Bonus for time investment: 1 per 2 minutes, capped at 5
  final timeBonus = min(5, (durationMinutes / 2).round());

  // Total capped at 20
  return min(20, baseFromQuestions + timeBonus);
}

// Example:
// 12 questions, 6 minutes = 6 + 3 = 9 delta_progress
// 25 questions, 12 minutes = 15 + 5 = 20 delta_progress (max)
```

### Goal:
- **5-6 activities → 100% discovery progress**
- Encourages users to complete diverse activities
- Gives sense of achievement

---

## Confidence Guidelines

**What is confidence?**

Confidence (0.0-1.0) represents how reliable the assessment is. Used to weight career matches.

### Factors:

1. **Response Consistency**
   ```dart
   // If user answers similar questions differently, lower confidence
   final consistency = QuizScorer.computeQuality(scores);
   ```

2. **Sample Size**
   ```dart
   // More questions = higher confidence
   final sampleConfidence = min(1.0, questionCount / 12.0);
   ```

3. **Completion Rate**
   ```dart
   // Skipped questions lower confidence
   final completionRate = answeredCount / totalCount;
   ```

4. **Combined:**
   ```dart
   final confidence = (consistency * 0.4 +
                       sampleConfidence * 0.3 +
                       completionRate * 0.3).clamp(0.0, 1.0);
   ```

### Recommended Values:

- **0.5-0.6**: Quick quiz, few questions, might have inconsistencies
- **0.7-0.8**: Standard quiz, good coverage, consistent responses
- **0.85-0.95**: Comprehensive quiz, many questions, high consistency
- **0.95-1.0**: Very rare, near-perfect assessment

---

## Fetching Quiz Items from Database

**Currently:** Quiz questions are hardcoded in Flutter.

**Data Contract:** Fetch from `quiz_items` table.

### Migration Steps:

#### 1. Seed Quiz Items (Database)
```sql
-- Add more quiz items to database
INSERT INTO quiz_items (item_id, feature_key, direction, weight, question_text) VALUES
  ('pa_013', 'trait_curiosity', 1.0, 1.0, 'I actively seek out new learning opportunities'),
  ('pa_014', 'trait_openness', 1.0, 1.0, 'I am comfortable with ambiguity and change'),
  -- Add 20-30 more items for complete assessment
  ...
ON CONFLICT (item_id) DO NOTHING;
```

#### 2. Create Quiz Items Service

```dart
class QuizItemsService {
  QuizItemsService(this._supabase);

  final SupabaseClient _supabase;

  /// Fetch quiz items for a specific assessment
  Future<List<QuizItemConfig>> getQuizItems(String assessmentPrefix) async {
    final response = await _supabase
        .from('quiz_items')
        .select('item_id, feature_key, direction, weight, question_text, metadata')
        .like('item_id', '$assessmentPrefix%')
        .order('item_id');

    return (response as List<dynamic>)
        .map((e) => QuizItemConfig.fromJson(e))
        .toList();
  }
}

class QuizItemConfig {
  final String itemId;
  final String featureKey;
  final double direction;
  final double weight;
  final String questionText;
  final Map<String, dynamic> metadata;

  // fromJson, etc.
}
```

#### 3. Update Quiz UI to Fetch from DB

```dart
class PersonalityQuizPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizItemsAsync = ref.watch(quizItemsProvider('pa_')); // personality assessment

    return quizItemsAsync.when(
      data: (items) => _buildQuiz(items),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => ErrorWidget(e),
    );
  }
}
```

**Benefits:**
- Update quiz questions without app release
- A/B test different question sets
- Localize questions in database
- Track which questions are most predictive

---

## Consent Flow (Optional - For Production)

The `consents` table exists but is currently unused.

### When to Implement:
- Before launching to minors
- For GDPR/privacy compliance
- For parental consent requirements

### Example Implementation:

```dart
class ConsentService {
  final SupabaseClient _supabase;

  Future<void> recordConsent({
    required String version,
    required String status, // 'accepted' | 'declined' | 'revoked'
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    await _supabase.from('consents').insert({
      'user_id': userId,
      'version': version,
      'status': status,
    });
  }

  Future<Consent?> getLatestConsent() async {
    final userId = _supabase.auth.currentUser?.id;

    final response = await _supabase
        .from('consents')
        .select()
        .eq('user_id', userId)
        .order('accepted_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response != null ? Consent.fromJson(response) : null;
  }
}

// Usage in onboarding
final consent = await consentService.getLatestConsent();
if (consent == null || consent.version != 'v2.0') {
  // Show consent screen
  await showConsentDialog();
}
```

---

## Testing the Complete Flow

### Unit Tests

```dart
// test/application/activity/activity_service_test.dart
void main() {
  group('ActivityService', () {
    test('startActivityRun inserts and returns ID', () async {
      // Mock Supabase client
      // Test startActivityRun
      // Assert runId returned
    });

    test('completeActivityRun updates and triggers progress', () async {
      // Mock Supabase client
      // Test completeActivityRun
      // Assert activity_runs updated
      // Note: Trigger logic is tested in DB tests
    });
  });
}
```

### Integration Tests

```sql
-- Test in Supabase SQL Editor

-- 1. Insert test user's activity_run
INSERT INTO activity_runs (user_id, activity_id, completed_at, delta_progress)
VALUES (auth.uid(), 'some-activity-id', now(), 10);

-- 2. Verify discovery_progress updated
SELECT * FROM discovery_progress WHERE user_id = auth.uid();
-- Should show percent increased by 10, streak updated

-- 3. Test EMA function
SELECT upsert_feature_ema(
  auth.uid(),
  'trait_creativity',
  85.0,
  0.7,
  5
);

-- 4. Verify user_feature_scores
SELECT * FROM user_feature_scores
WHERE user_id = auth.uid() AND feature_key = 'trait_creativity';

-- 5. Test Edge Function
-- Use curl or Postman to call update_profile_and_match

-- 6. Verify user_career_matches
SELECT c.title, ucm.similarity, ucm.confidence
FROM user_career_matches ucm
JOIN careers c ON c.id = ucm.career_id
WHERE ucm.user_id = auth.uid()
ORDER BY ucm.similarity DESC
LIMIT 5;
```

### End-to-End Test

```dart
// test/e2e/complete_assessment_flow_test.dart
void main() {
  testWidgets('Complete quiz flow updates all tables', (tester) async {
    // 1. Start activity_run
    final runId = await activityService.startActivityRun(...);

    // 2. Simulate quiz completion
    final responses = [...];
    final featureScores = QuizScorer.computeBatchScores(...);

    // 3. Complete assessment
    final result = await orchestrator.completeAssessment(...);

    // 4. Verify
    expect(result.success, isTrue);

    // 5. Check discovery_progress
    final progress = await activityService.getDiscoveryProgress();
    expect(progress?.percent, greaterThan(0));

    // 6. Check assessments
    final assessment = await assessmentService.getLatestAssessment();
    expect(assessment, isNotNull);

    // 7. Check career matches
    final matches = await scoringService.getCareerMatches(...);
    expect(matches, isNotEmpty);
  });
}
```

---

## Migration Checklist

### Before Production:

- [ ] Run updated migrations (00001_init_schema.sql with new trigger, 00003 with enum fix)
- [ ] Deploy Edge Function `update_profile_and_match`
- [ ] Seed activities table with quiz/game definitions
- [ ] Seed quiz_items with 20-30 questions minimum
- [ ] Test complete flow end-to-end
- [ ] Update UI to use new services
- [ ] Add error handling and loading states
- [ ] Test streak logic (complete activity on consecutive days)
- [ ] Test progress capping (should stop at 100%)
- [ ] Verify RLS policies (user can only see own data)
- [ ] Add analytics tracking for activity completions
- [ ] Document delta_progress values for content team
- [ ] Set up monitoring for Edge Function errors

### Gradual Rollout:

1. **Phase 1** (Current): Use orchestrator but keep existing UI
2. **Phase 2**: Show discovery progress on dashboard
3. **Phase 3**: Fetch quiz items from database
4. **Phase 4**: Implement consent flow
5. **Phase 5**: Add roadmap feature (tables already exist)

---

## Performance Considerations

### Edge Function Caching

Currently, Edge Function recomputes matches on every call. For high-traffic:

```typescript
// Add to Edge Function
// Check if user already has recent matches (within last hour)
const { data: existingMatches } = await supabase
  .from('user_career_matches')
  .select('last_updated')
  .eq('user_id', user_id)
  .limit(1)
  .single();

if (existingMatches) {
  const lastUpdated = new Date(existingMatches.last_updated);
  const hourAgo = new Date(Date.now() - 60 * 60 * 1000);

  if (lastUpdated > hourAgo) {
    // Skip recomputation, just update feature scores
    return { ok: true, skipped_matching: true };
  }
}
```

### Database Indexes

All necessary indexes are already created:
- ✅ `idx_activity_runs_user` on activity_runs(user_id)
- ✅ `idx_user_feature_scores_user` on user_feature_scores(user_id)
- ✅ `idx_user_career_matches_user` on user_career_matches(user_id)

Monitor slow queries with:
```sql
-- Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## Troubleshooting

### Issue: Discovery progress not updating

**Check:**
```sql
-- 1. Verify trigger exists
SELECT tgname, tgrelid::regclass, tgenabled
FROM pg_trigger
WHERE tgname = 'trg_update_progress_after_run';

-- 2. Verify activity_run was inserted/updated
SELECT * FROM activity_runs WHERE user_id = auth.uid() ORDER BY started_at DESC LIMIT 5;

-- 3. Check if completed_at is set
-- Trigger only fires when completed_at is NOT NULL
```

**Fix:** Ensure `completeActivityRun()` is called with `completed_at` set.

### Issue: Career matches empty

**Check:**
```sql
-- 1. Verify user has feature scores
SELECT COUNT(*) FROM user_feature_scores WHERE user_id = auth.uid();

-- 2. Verify careers have vectors
SELECT title, array_length(vector, 1) FROM careers WHERE active = true;

-- 3. Check Edge Function logs
-- In Supabase dashboard: Edge Functions → update_profile_and_match → Logs
```

**Fix:** Ensure `updateProfileAndMatch()` was called successfully.

### Issue: Assessments not being created

**Check:**
```sql
-- Verify user has permission to insert
SELECT * FROM assessments WHERE user_id = auth.uid();
```

**Fix:** Ensure RLS policies are correct (already set in migration).

---

## Summary

✅ **All critical fixes applied**
✅ **Service layer created**
✅ **Dashboard updated**
✅ **Complete flow documented**

**Next Steps:**
1. Update existing quiz/game pages to use new services
2. Test the complete flow
3. Consider implementing quiz items fetch from DB
4. Consider adding consent flow

**Key Files:**
- Services: `lib/application/activity/`, `lib/application/assessment/`
- Migrations: `supabase/migrations/00001_init_schema.sql`, `00003_scoring_and_matching_system.sql`
- Dashboard: `lib/presentation/features/dashboard/dashboard_page.dart`

For questions, see [SCHEMA_ANALYSIS.md](SCHEMA_ANALYSIS.md) or [SCORING_SYSTEM.md](SCORING_SYSTEM.md).

---

**Version:** 1.0.0
**Last Updated:** 2025-01-13
**Status:** Ready for Production Integration
