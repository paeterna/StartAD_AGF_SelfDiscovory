# Real Cohort Averages Implementation

## Problem
The radar chart was showing static average scores (always 50.0) instead of actual averages calculated from all users in the database.

## Solution
Created a system that automatically calculates and updates cohort averages based on real user data.

---

## Changes Made

### 1. Database Migration: `00012_real_cohort_averages.sql`

Created a new migration that implements:

#### A. `update_cohort_stats()` Function
Calculates real statistics from all users:
- **Mean**: Average score across all users for each feature
- **Standard Deviation**: Population standard deviation
- **Min/Max**: Minimum and maximum scores observed
- **N Samples**: Number of users contributing to each feature

```sql
SELECT update_cohort_stats();
```

#### B. Automatic Trigger
Automatically updates cohort statistics when user scores change:
- Triggers on INSERT or UPDATE of `user_feature_scores`
- Only updates if score changes by more than 1 point (prevents excessive updates)
- Updates only the specific feature that changed (efficient)

#### C. Performance Optimization
Added index for faster cohort calculations:
```sql
idx_user_feature_scores_feature_score on (feature_key, score_mean)
```

---

## How It Works

### Before (Static)
```
feature_cohort_stats.mean = 50.0 (hardcoded for all features)
```

### After (Dynamic)
```sql
-- Real calculation from all users
SELECT avg(score_mean)
FROM user_feature_scores
WHERE feature_key = 'trait_creativity'
  AND n >= 1;
```

### Data Flow
```
1. User completes assessment
   ↓
2. Scores saved to user_feature_scores
   ↓
3. Trigger fires: trigger_update_cohort_stats()
   ↓
4. feature_cohort_stats updated with new average
   ↓
5. Radar chart shows updated cohort average
```

---

## Applying the Migration

### Option 1: Supabase Dashboard (SQL Editor)
1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Copy and paste the contents of `supabase/migrations/00012_real_cohort_averages.sql`
4. Click **Run**
5. Verify success (should see "Success" message)

### Option 2: Supabase CLI (if available)
```bash
# From project root
supabase db push

# Or migrate specific file
supabase db execute --file supabase/migrations/00012_real_cohort_averages.sql
```

### Option 3: Manual SQL Execution
Connect to your PostgreSQL database and run:
```bash
psql <your-connection-string> < supabase/migrations/00012_real_cohort_averages.sql
```

---

## Testing the Implementation

### 1. Check Current Cohort Stats (Before)
```sql
SELECT feature_key, mean, n_samples, last_updated
FROM feature_cohort_stats
ORDER BY feature_key;
```

You should see all means = 50.0 and n_samples = 0.

### 2. Apply Migration
Run the migration using one of the methods above.

### 3. Check Cohort Stats (After)
```sql
SELECT feature_key, mean, std_dev, n_samples, last_updated
FROM feature_cohort_stats
ORDER BY feature_key;
```

Now you should see:
- Real averages based on actual user data
- Non-zero n_samples (if users exist)
- Recent last_updated timestamps

### 4. Test Automatic Updates
Insert a test score:
```sql
-- Insert a new score for a test user
INSERT INTO user_feature_scores (user_id, feature_key, score_mean, n)
VALUES (
  auth.uid(), -- current user
  'trait_creativity',
  85.0,
  5
)
ON CONFLICT (user_id, feature_key) DO UPDATE
SET score_mean = 85.0, n = 5;

-- Check if cohort stats updated automatically
SELECT feature_key, mean, n_samples, last_updated
FROM feature_cohort_stats
WHERE feature_key = 'trait_creativity';
```

The trigger should have automatically updated the cohort average!

### 5. Test Radar Chart in App
1. Run the Flutter app
2. Navigate to any page with a radar chart
3. The "Average" line should now reflect real user averages (not always 50.0)

---

## Performance Considerations

### Trigger Optimization
The trigger only updates when:
- New feature score is inserted (INSERT)
- Existing score changes by more than 1 point (UPDATE)

This prevents excessive database updates for minor score adjustments.

### Query Optimization
The added index speeds up cohort calculations:
```sql
idx_user_feature_scores_feature_score on (feature_key, score_mean)
```

### Scalability
For very large user bases (100k+ users), consider:
1. **Debounced updates**: Update cohort stats every N minutes instead of on every change
2. **Materialized views**: Create a materialized view that refreshes periodically
3. **Background job**: Calculate cohort stats via a scheduled Edge Function

---

## Manual Recalculation

If you ever need to manually recalculate all cohort statistics:

```sql
-- Recalculate all cohort averages
SELECT update_cohort_stats();
```

This is useful if:
- You bulk import user data
- You suspect stats are out of sync
- You want to force a fresh calculation

---

## Verification Queries

### Check Feature Coverage
```sql
-- How many users have scores for each feature?
SELECT
  f.key as feature_key,
  COUNT(DISTINCT ufs.user_id) as user_count,
  ROUND(AVG(ufs.score_mean)::numeric, 1) as avg_score,
  ROUND(fcs.mean::numeric, 1) as cohort_mean
FROM features f
LEFT JOIN user_feature_scores ufs ON ufs.feature_key = f.key AND ufs.n >= 1
LEFT JOIN feature_cohort_stats fcs ON fcs.feature_key = f.key
GROUP BY f.key, fcs.mean
ORDER BY user_count DESC;
```

### Check Cohort Stats Update History
```sql
-- See when cohort stats were last updated
SELECT
  feature_key,
  mean,
  n_samples,
  last_updated,
  EXTRACT(EPOCH FROM (NOW() - last_updated))/60 as minutes_ago
FROM feature_cohort_stats
ORDER BY last_updated DESC;
```

### Validate Calculations
```sql
-- Verify cohort stats match manual calculations
SELECT
  fcs.feature_key,
  fcs.mean as stored_mean,
  (
    SELECT AVG(score_mean)
    FROM user_feature_scores
    WHERE feature_key = fcs.feature_key AND n >= 1
  ) as calculated_mean,
  fcs.n_samples as stored_count,
  (
    SELECT COUNT(DISTINCT user_id)
    FROM user_feature_scores
    WHERE feature_key = fcs.feature_key AND n >= 1
  ) as calculated_count
FROM feature_cohort_stats fcs
ORDER BY fcs.feature_key;
```

If `stored_mean` ≠ `calculated_mean`, run `SELECT update_cohort_stats();`

---

## Rollback (if needed)

If you need to revert to static averages:

```sql
-- Disable the trigger
DROP TRIGGER IF EXISTS trg_update_cohort_stats ON user_feature_scores;

-- Reset to static values
UPDATE feature_cohort_stats
SET mean = 50.0, std_dev = 10.0, n_samples = 0;
```

---

## No Code Changes Required!

The best part: **No Flutter code changes needed**!

The existing code in [`radar_traits_card.dart`](lib/presentation/widgets/radar_traits_card.dart) already fetches data from `v_user_radar` view, which in turn reads from `feature_cohort_stats`.

The view query (from migration 00004):
```sql
SELECT
  ...
  coalesce(fcs.mean, 50.0) as cohort_mean_0_100
FROM features f
LEFT JOIN feature_cohort_stats fcs ON fcs.feature_key = f.key
```

Once the migration runs, the cohort means will automatically be real averages! ✨

---

## Expected Results

### Before Migration
- All radar charts show average at 50.0 for every feature
- Average line forms a perfect circle/polygon at the center

### After Migration
- Radar charts show real averages based on actual user data
- Average line varies by feature (e.g., creativity might be 62.5, leadership 45.3)
- More meaningful comparison between user scores and population

---

## Monitoring

### Daily Health Check
```sql
-- Check that cohort stats are updating
SELECT
  COUNT(*) as features_with_data,
  MIN(last_updated) as oldest_update,
  MAX(last_updated) as newest_update
FROM feature_cohort_stats
WHERE n_samples > 0;
```

### Alert if stats are stale (>7 days)
```sql
SELECT feature_key, last_updated
FROM feature_cohort_stats
WHERE last_updated < NOW() - INTERVAL '7 days'
  AND n_samples > 0;
```

---

## Summary

### What Changed
1. ✅ Created `update_cohort_stats()` function to calculate real averages
2. ✅ Added automatic trigger to update on user score changes
3. ✅ Added performance index for faster calculations
4. ✅ Initial recalculation from existing data

### What Stayed the Same
- Flutter code (no changes needed!)
- View definition
- RPC function
- User interface

### Result
🎉 Radar charts now display **real cohort averages** instead of static 50.0 values!

---

## Support

If you encounter issues:
1. Check the verification queries above
2. Run manual recalculation: `SELECT update_cohort_stats();`
3. Check PostgreSQL logs for trigger errors
4. Verify RLS policies allow reading `feature_cohort_stats`

**Built with:** PostgreSQL triggers • Automatic updates • Zero app changes
**Version:** 1.0.0 | **Last Updated:** 2025-10-16
