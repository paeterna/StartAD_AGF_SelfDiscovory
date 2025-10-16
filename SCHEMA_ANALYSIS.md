# Schema Analysis: Data Contract Compliance Report

**Status:** ⚠️ **Partial Compliance - Critical Issues Found**

**Generated:** 2025-01-13

---

## Executive Summary

The current database schema (`00001_init_schema.sql`, `00003_scoring_and_matching_system.sql`) **partially implements** the data contract with some **critical mismatches** that need attention:

### Critical Issues 🔴
1. **`assessments` table missing `confidence` column** (required by contract)
2. **Missing `activity_type_t` enum update** in migration 00003 (conflicts with existing enum)
3. **`user_career_matches` stores matches but no matching job/service implemented**
4. **Flutter app doesn't use `activity_runs` or `discovery_progress` properly**

### Warnings ⚠️
1. **Trigger `fn_update_progress_after_run` only fires on INSERT** (contract implies UPDATE on completion should also work)
2. **No `v_latest_traits` view usage** in Flutter app
3. **Duplicate scoring systems** (old rule-based + new feature-based not integrated)

### Compliant ✅
1. Core tables (profiles, consents, careers, roadmaps) match spec
2. RLS policies correctly implemented
3. Feature-based system (migration 00003) follows spec
4. Enum types match contract

---

## Detailed Analysis

### 1. Core User Lifecycle Tables

#### ✅ `public.profiles`
**Status:** COMPLIANT

**Schema:**
```sql
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  locale locale_t not null default 'en',
  theme theme_t not null default 'system',
  onboarding_complete boolean not null default false,
  created_at timestamptz not null default now()
);
```

**Contract Match:** ✅ All required columns present
**RLS:** ✅ Correct (select/insert/update own)
**Trigger:** ✅ `fn_create_profile_for_user` auto-creates on signup

**Flutter Usage:** ✅ Used in `AuthRepositoryImpl` and settings

---

#### ✅ `public.consents`
**Status:** COMPLIANT

**Schema:**
```sql
create table public.consents (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  version text not null,
  status consent_status_t not null,
  accepted_at timestamptz not null default now(),
  constraint uq_consents_user_version unique (user_id, version)
);
```

**Contract Match:** ✅ Perfect
**RLS:** ✅ Correct (select/insert own)

**Flutter Usage:** ⚠️ **NOT CURRENTLY USED** - consent flow not implemented in app

---

#### ⚠️ `public.discovery_progress`
**Status:** COMPLIANT BUT UNDERUTILIZED

**Schema:**
```sql
create table public.discovery_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  percent int not null default 0 check (percent between 0 and 100),
  streak_days int not null default 0 check (streak_days >= 0),
  last_activity_date date,
  updated_at timestamptz not null default now()
);
```

**Contract Match:** ✅ Perfect
**RLS:** ✅ Correct
**Trigger:** ✅ `fn_update_progress_after_run` maintains this table

**Issue:** Flutter app **doesn't use `activity_runs`**, so this table is never populated!

**Current App Flow:**
```
Quiz Complete → QuizScorer → Edge Function → user_feature_scores
                 ❌ MISSING: → activity_runs insert → trigger updates discovery_progress
```

**Data Contract Flow:**
```
Quiz Complete → Insert activity_runs → Trigger → discovery_progress
              → Call upsert_feature_ema for each feature
              → Background job → user_career_matches
```

---

### 2. Activities & Runs

#### ✅ `public.activities`
**Status:** COMPLIANT

**Schema:** ✅ Matches contract
**RLS:** ✅ Read-only to authenticated users
**Seed Data:** ✅ Sample activities present

**Flutter Usage:** ⚠️ **NOT CURRENTLY USED** - app has hardcoded quiz/game data

---

#### 🔴 `public.activity_runs`
**Status:** CRITICAL - NOT USED BY APP

**Schema:**
```sql
create table public.activity_runs (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_id uuid not null references public.activities(id) on delete cascade,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  score int,
  trait_scores jsonb not null default '{}'::jsonb,
  delta_progress int not null default 0 check (delta_progress between 0 and 20)
);
```

**Contract Match:** ✅ Perfect

**CRITICAL ISSUE:** Flutter app **never inserts into this table**!

**Current App:**
- Quizzes complete → directly call Edge Function
- No activity_runs record created
- Trigger `fn_update_progress_after_run` never fires
- `discovery_progress` never updated

**Required Integration:**
```dart
// MISSING in current app
Future<void> completeQuiz({
  required String activityId,
  required int score,
  required Map<String, dynamic> traitScores,
  required int deltaProgress,
}) async {
  // 1. Insert activity run
  final run = await supabase
    .from('activity_runs')
    .insert({
      'user_id': userId,
      'activity_id': activityId,
      'completed_at': DateTime.now().toIso8601String(),
      'score': score,
      'trait_scores': traitScores,
      'delta_progress': deltaProgress,  // 0-20
    })
    .select()
    .single();

  // 2. Trigger fires automatically → updates discovery_progress

  // 3. THEN call feature scoring
  await scoringService.updateProfileAndMatch(...);
}
```

---

### 3. Assessments & Items

#### 🔴 `public.assessments`
**Status:** CRITICAL - MISSING REQUIRED COLUMN

**Current Schema (00001):**
```sql
create table public.assessments (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  taken_at timestamptz not null default now(),
  trait_scores jsonb not null default '{}'::jsonb,
  delta_progress int not null default 0 check (delta_progress between 0 and 20)
);
```

**Migration 00003 adds:**
```sql
alter table public.assessments
  add column if not exists confidence float8 default 0.0 check (confidence between 0.0 and 1.0);
```

**Contract Requirement:**
```sql
-- From data contract
insert into public.assessments (user_id, trait_scores, delta_progress, confidence)
values (auth.uid(), $1::jsonb, $2, $3)  -- confidence is REQUIRED in contract
```

**Status:** ✅ FIXED in migration 00003
**Flutter Usage:** ⚠️ App doesn't insert assessments (should for audit trail)

---

#### ✅ `public.assessment_items`
**Status:** COMPLIANT (added in migration 00003)

**Schema:**
```sql
create table public.assessment_items (
  id uuid primary key default gen_random_uuid(),
  assessment_id bigint not null references public.assessments(id) on delete cascade,
  item_id text not null,
  response jsonb,
  score_raw float8,
  score_norm float8,
  duration_ms int,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);
```

**Contract Match:** ✅ Perfect
**RLS:** ✅ Correct (select/insert only if assessment belongs to user)

**Flutter Usage:** ⚠️ **NOT CURRENTLY USED** - no item-level audit trail

---

### 4. Feature Framework (22-dimensional)

#### ✅ `public.features`
**Status:** COMPLIANT

**Schema (migration 00003):**
```sql
create table public.features (
  id serial primary key,
  key text unique not null,
  family text not null,  -- 'interests', 'cognition', 'traits'
  description text not null,
  created_at timestamptz not null default now()
);
```

**Contract Match:** ✅ Perfect
**Seed Data:** ✅ 22 features seeded
**RLS:** ✅ Read-only to authenticated

---

#### ✅ `public.user_feature_scores`
**Status:** COMPLIANT

**Schema:**
```sql
create table public.user_feature_scores (
  user_id uuid not null references auth.users(id) on delete cascade,
  feature_key text not null references public.features(key) on delete cascade,
  score_mean float8 not null default 50.0 check (score_mean between 0 and 100),
  score_std float8 default 0.0,
  n int not null default 0 check (n >= 0),
  last_updated timestamptz not null default now(),
  primary key (user_id, feature_key)
);
```

**Contract Match:** ✅ Perfect
**Function:** ✅ `upsert_feature_ema()` implemented
**Flutter Usage:** ✅ Used correctly via Edge Function

---

#### ✅ `public.feature_cohort_stats`
**Status:** COMPLIANT

**Schema:** ✅ Matches contract
**Seed Data:** ✅ Initialized with defaults

**Admin Usage:** ⚠️ No periodic recompute job scheduled (contract says "periodic recompute")

---

#### ✅ `public.quiz_items`
**Status:** COMPLIANT

**Schema:** ✅ Matches contract
**Seed Data:** ✅ Sample items present

**Flutter Usage:** ⚠️ App has hardcoded quiz items, doesn't fetch from DB

---

### 5. Careers & Matching

#### ⚠️ `public.careers`
**Status:** PARTIALLY COMPLIANT

**Current Schema (00001):**
```sql
create table public.careers (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  cluster text,
  tags text[] not null default '{}',
  active boolean not null default true,
  created_at timestamptz not null default now()
);
```

**Migration 00003 adds:**
```sql
alter table public.careers
  add column if not exists vector float8[] check (array_length(vector, 1) = 22),
  add column if not exists description text,
  add column if not exists source text default 'manual';
```

**Contract Requirement:**
```sql
-- Each has a fixed 22-dim vector (0..1) aligned to features order
select id, title, cluster, tags, vector, description
from public.careers
where active = true;
```

**Status:** ✅ COMPLIANT after migration 00003
**Seed Data:** ✅ 5 careers with vectors

**Issue:** Contract says vectors are in `[0..1]` scale, migration uses same scale ✅

---

#### ⚠️ `public.user_career_matches`
**Status:** COMPLIANT BUT NO MATCHING JOB

**Schema (migration 00003):**
```sql
create table public.user_career_matches (
  user_id uuid not null references auth.users(id) on delete cascade,
  career_id uuid not null references public.careers(id) on delete cascade,
  similarity float8 not null check (similarity between 0 and 1),
  confidence float8 not null default 0.0 check (confidence between 0 and 1),
  top_features jsonb default '[]'::jsonb,
  last_updated timestamptz not null default now(),
  primary key (user_id, career_id)
);
```

**Contract Match:** ✅ Perfect

**CRITICAL GAP:** Contract says:
> "A matching job computes similarity (e.g., cosine on [0..1] vectors) and upserts here."

**Current Implementation:**
- ✅ Edge Function computes matches
- ✅ Upserts to this table
- ✅ Cosine similarity implemented

**But:** Edge Function is **manually called** by app after scoring, not a background job.

**Contract implies:**
```sql
-- Service role background job (every 5 min? on user activity?)
-- Recomputes ALL user matches
```

**Current:**
```dart
// User-triggered in Flutter
await scoringService.updateProfileAndMatch(...)  // Updates THIS user only
```

**Recommendation:** Current approach is fine for MVP. For scale, move to background job.

---

### 6. Roadmaps

#### ✅ `public.roadmaps` & `public.roadmap_steps`
**Status:** COMPLIANT

**Schema:** ✅ Matches contract perfectly
**RLS:** ✅ Correct (nested policy for steps)

**Flutter Usage:** ⚠️ **NOT CURRENTLY USED** - roadmap feature not implemented

---

### 7. Functions & Triggers

#### ✅ `fn_create_profile_for_user()`
**Status:** COMPLIANT (improved in 00002)

**Contract:** ✅ Auto-creates profile on signup
**Implementation:** ✅ Uses `security definer` safely
**Trigger:** ✅ Fires on `auth.users` insert

---

#### ⚠️ `fn_update_progress_after_run()`
**Status:** TRIGGER LOGIC INCOMPLETE

**Contract Says:**
> "Never update directly for activity gains—use public.activity_runs (trigger will maintain this table)."

**Current Trigger:**
```sql
create trigger trg_update_progress_after_run
after insert on public.activity_runs  -- ⚠️ ONLY ON INSERT
for each row execute function public.fn_update_progress_after_run();
```

**Issue:** Trigger only fires on INSERT, but contract shows UPDATE pattern:
```sql
-- Complete run
update public.activity_runs
set completed_at = now(),
    score = $1,
    trait_scores = $2::jsonb,
    delta_progress = $3  -- Contract says trigger updates discovery_progress
where id = $4 and user_id = auth.uid();
```

**Current trigger fires on INSERT only**, so delta_progress must be set at INSERT time.

**Fix:** Trigger should ALSO fire on UPDATE:
```sql
create trigger trg_update_progress_after_run
after insert or update on public.activity_runs
for each row
when (new.completed_at is not null and (old.completed_at is null or old is null))
execute function public.fn_update_progress_after_run();
```

---

#### ✅ `upsert_feature_ema()`
**Status:** COMPLIANT

**Contract:** ✅ Matches spec exactly
**Implementation:** ✅ EMA logic correct, alpha clamped [0.15, 0.7]

---

#### ✅ `get_profile_completeness()`
**Status:** COMPLIANT

**Contract:** ✅ Returns float8 [0..100]
**Implementation:** ✅ Uses confidence formula from contract
**Flutter Usage:** ✅ Used in dashboard

---

#### ✅ `get_user_feature_vector()`
**Status:** COMPLIANT

**Contract:** ✅ Returns float8[22] scaled [0..1]
**Implementation:** ✅ Ordered by features.id, defaults to 0.5

---

### 8. Views

#### ⚠️ `v_latest_traits`
**Status:** COMPLIANT BUT NOT USED

**Schema:**
```sql
create view public.v_latest_traits as
select a.user_id,
       (select trait_scores from public.assessments a2
        where a2.user_id = a.user_id
        order by a2.taken_at desc limit 1) as trait_scores
from public.assessments a
group by a.user_id;
```

**Contract:** ✅ Matches spec
**Flutter Usage:** ❌ **NOT USED** - app doesn't query this view

**Recommendation:** Use this in dashboard to show latest trait scores without scanning all assessments.

---

## RLS Policy Compliance

### ✅ All Policies Correct

| Table | Contract Requirement | Implementation | Status |
|-------|---------------------|----------------|--------|
| `profiles` | User can SELECT/INSERT/UPDATE own | ✅ Correct | ✅ |
| `consents` | User can read/insert own | ✅ Correct | ✅ |
| `discovery_progress` | User can read/insert/update own | ✅ Correct | ✅ |
| `activities` | World-readable to authenticated | ✅ `for select using (true)` | ✅ |
| `activity_runs` | User can read/insert/update own | ✅ Correct | ✅ |
| `assessments` | User can read/insert own | ✅ Correct | ✅ |
| `assessment_items` | Select/insert only if assessment belongs to user | ✅ Correct | ✅ |
| `features` | Read-only to authenticated | ✅ Correct | ✅ |
| `user_feature_scores` | User can read/insert/update own | ✅ Correct | ✅ |
| `user_career_matches` | User can read/insert/update own | ✅ Correct | ✅ |
| `careers` | Read-only to authenticated | ✅ Correct | ✅ |
| `roadmaps` | User can read/insert own | ✅ Correct | ✅ |
| `roadmap_steps` | Nested policy via roadmap owner | ✅ Correct | ✅ |

---

## Enum Type Issues

### 🔴 CRITICAL: `activity_type_t` Conflict

**Migration 00001:**
```sql
create type activity_type_t as enum ('quiz','game');
```

**Migration 00003 (line 55-56):**
```sql
drop type if exists activity_type_t cascade;
create type activity_type_t as enum ('quiz','game');
```

**Issue:** Migration 00003 drops and recreates the SAME enum!

**Why?** Comment says:
```sql
-- Update type constraint to include both quiz and game
```

But the enum already has both values. This is **unnecessary and dangerous**:
- `DROP TYPE CASCADE` will drop ALL columns using this type
- Then recreates with same values
- Works but is a no-op

**Recommendation:** Remove these lines from migration 00003:
```sql
-- REMOVE THESE LINES (55-56)
-- drop type if exists activity_type_t cascade;
-- create type activity_type_t as enum ('quiz','game');
```

---

## Flutter App Integration Issues

### 1. ❌ **Not Using `activity_runs` Table**

**Current Flow:**
```
User completes quiz
  ↓
QuizScorer.computeBatchScores()
  ↓
ScoringService.updateProfileAndMatch()  [calls Edge Function]
  ↓
Edge Function → upsert_feature_ema() → user_career_matches
```

**Missing:**
```dart
// Should insert activity_run FIRST
await supabase.from('activity_runs').insert({
  'user_id': userId,
  'activity_id': quizId,
  'completed_at': now,
  'trait_scores': traitScores,
  'delta_progress': 10,  // 0-20
});
// Trigger fires → discovery_progress updated
```

**Impact:**
- ❌ `discovery_progress` never updated (percent, streak)
- ❌ Can't track which activities user completed
- ❌ Can't compute "activities completed" metrics

---

### 2. ❌ **Not Using `assessments` Table**

**Contract says:**
> "Create on assessment submit; push trait_scores, delta_progress, and confidence"

**Current:** App never inserts into `assessments`

**Impact:**
- ❌ No audit trail of assessment history
- ❌ Can't show "score improvement over time"
- ❌ `v_latest_traits` view is empty

**Recommendation:** After quiz completion:
```dart
// Insert assessment for audit
await supabase.from('assessments').insert({
  'user_id': userId,
  'trait_scores': traitScores,
  'delta_progress': 10,
  'confidence': 0.75,
});
```

---

### 3. ⚠️ **Hardcoded Quiz/Game Data**

**Issue:** App has hardcoded quiz questions and game logic

**Contract expects:** Fetch from `activities` and `quiz_items` tables

**Current:**
```dart
// Hardcoded in app
final questions = [
  PersonalityQuestion(id: 'pa_001', text: 'I enjoy...'),
  ...
];
```

**Should be:**
```dart
// Fetch from DB
final quizItems = await supabase
  .from('quiz_items')
  .select('item_id, feature_key, direction, weight, question_text')
  .eq('item_id', 'pa_%');  // Personality assessment items
```

**Benefit:** Can update quiz without app release

---

### 4. ⚠️ **No Consent Flow**

**Issue:** `consents` table exists but app doesn't use it

**Contract requires:** Record consent on every consent surface

**Recommendation:** Add consent screen for minors/privacy:
```dart
await supabase.from('consents').insert({
  'user_id': userId,
  'version': 'v1.0',
  'status': 'accepted',
});
```

---

## Operational Guardrails Compliance

### ✅ Constraints
- [x] `delta_progress` between 0 and 20
- [x] `percent` between 0 and 100
- [x] Enums with explicit casts
- [x] Check constraints on scores

### ⚠️ Triggers
- [x] `activity_runs` owns streak logic
- [x] Don't bypass triggers
- [ ] **MISSING:** App doesn't use `activity_runs` at all!

### ✅ Admin Writes
- [x] Service role for catalog writes
- [x] RLS enforced on user tables

---

## Recommendations

### Priority 1 (Critical)

1. **Remove redundant enum drop/create in migration 00003**
   ```sql
   -- DELETE lines 55-56
   ```

2. **Integrate `activity_runs` into app flow**
   ```dart
   // After quiz/game completion
   await supabase.from('activity_runs').insert({...});
   // THEN call scoring service
   ```

3. **Update trigger to fire on INSERT OR UPDATE**
   ```sql
   create trigger trg_update_progress_after_run
   after insert or update on public.activity_runs
   ...
   ```

### Priority 2 (Important)

4. **Add `assessments` insertion** for audit trail
5. **Implement consent flow** using `consents` table
6. **Fetch quiz items from database** instead of hardcoding

### Priority 3 (Nice to Have)

7. **Use `v_latest_traits` view** in dashboard
8. **Add background job** for career matching (for scale)
9. **Implement roadmap feature** (tables exist, UI missing)

---

## Data Contract Checklist

### Tables
- [x] profiles
- [x] consents (not used in app)
- [x] discovery_progress (not populated - missing activity_runs)
- [x] activities (not used in app)
- [ ] **activity_runs** - ❌ NOT USED BY APP
- [x] assessments (with confidence column added)
- [x] assessment_items (not used in app)
- [x] features
- [x] user_feature_scores
- [x] feature_cohort_stats
- [x] quiz_items (not fetched from DB)
- [x] careers (with vectors)
- [x] user_career_matches
- [x] roadmaps (not used in app)
- [x] roadmap_steps (not used in app)

### Functions
- [x] fn_create_profile_for_user
- [ ] **fn_update_progress_after_run** - ⚠️ Only fires on INSERT
- [x] upsert_feature_ema
- [x] get_profile_completeness
- [x] get_user_feature_vector

### Views
- [x] v_latest_traits (not used in app)

### RLS Policies
- [x] All policies correct ✅

### Enums
- [x] locale_t
- [x] theme_t
- [x] activity_type_t (⚠️ unnecessary drop/recreate in migration 00003)
- [x] consent_status_t

---

## Conclusion

**Overall Grade:** B- (Partially Compliant)

**Strengths:**
- ✅ Core schema matches contract well
- ✅ Feature-based scoring system properly implemented
- ✅ RLS policies all correct
- ✅ Functions match spec

**Critical Gaps:**
- ❌ Flutter app doesn't use `activity_runs` (breaks discovery progress tracking)
- ❌ No audit trail (`assessments`/`assessment_items` not used)
- ❌ Hardcoded quiz data instead of DB-driven
- ⚠️ Trigger only fires on INSERT (should also fire on UPDATE)

**Action Required:**
1. Integrate `activity_runs` into quiz/game completion flow
2. Fix trigger to fire on UPDATE
3. Remove redundant enum drop/create
4. Consider using `assessments` for audit trail

**Timeline:**
- Critical fixes: 1-2 days
- Full compliance: 1 week

---

**Generated by:** Schema Analysis Tool
**Version:** 1.0.0
**Date:** 2025-01-13
