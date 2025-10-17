-- =====================================================
-- Test Script: Cohort Averages Implementation
-- Run this after applying migration 00012
-- =====================================================

-- Test 1: Check if functions exist
SELECT
  'update_cohort_stats' as function_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM pg_proc
    WHERE proname = 'update_cohort_stats'
  ) THEN '✓ EXISTS' ELSE '✗ MISSING' END as status;

SELECT
  'trigger_update_cohort_stats' as function_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM pg_proc
    WHERE proname = 'trigger_update_cohort_stats'
  ) THEN '✓ EXISTS' ELSE '✗ MISSING' END as status;

-- Test 2: Check if trigger is active
SELECT
  'trg_update_cohort_stats' as trigger_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_update_cohort_stats'
  ) THEN '✓ ACTIVE' ELSE '✗ INACTIVE' END as status;

-- Test 3: Check current cohort statistics
\echo '\n--- Current Cohort Statistics ---'
SELECT
  feature_key,
  ROUND(mean::numeric, 1) as avg_score,
  ROUND(std_dev::numeric, 1) as std_dev,
  n_samples,
  last_updated
FROM feature_cohort_stats
ORDER BY n_samples DESC, feature_key
LIMIT 10;

-- Test 4: Compare stored vs calculated averages
\echo '\n--- Validation: Stored vs Calculated Averages ---'
SELECT
  fcs.feature_key,
  ROUND(fcs.mean::numeric, 2) as stored_avg,
  ROUND(COALESCE((
    SELECT AVG(score_mean)
    FROM user_feature_scores
    WHERE feature_key = fcs.feature_key AND n >= 1
  ), 50.0)::numeric, 2) as calculated_avg,
  CASE
    WHEN ABS(fcs.mean - COALESCE((
      SELECT AVG(score_mean)
      FROM user_feature_scores
      WHERE feature_key = fcs.feature_key AND n >= 1
    ), 50.0)) < 0.01 THEN '✓ MATCH'
    ELSE '✗ MISMATCH'
  END as status
FROM feature_cohort_stats fcs
ORDER BY fcs.feature_key
LIMIT 10;

-- Test 5: Check user participation by feature
\echo '\n--- User Participation by Feature ---'
SELECT
  f.family,
  f.key as feature_key,
  COUNT(DISTINCT ufs.user_id) as users_with_scores,
  ROUND(AVG(ufs.score_mean)::numeric, 1) as avg_user_score
FROM features f
LEFT JOIN user_feature_scores ufs ON ufs.feature_key = f.key AND ufs.n >= 1
GROUP BY f.family, f.key
ORDER BY f.family, users_with_scores DESC;

-- Test 6: Test trigger (optional - only if you have write access)
-- Uncomment the following to test the trigger:

/*
\echo '\n--- Testing Trigger ---'

-- Save current stats
CREATE TEMP TABLE temp_before_stats AS
SELECT feature_key, mean, n_samples
FROM feature_cohort_stats
WHERE feature_key = 'trait_creativity';

-- Insert a test score (or update if exists)
INSERT INTO user_feature_scores (user_id, feature_key, score_mean, n)
VALUES (
  auth.uid(),
  'trait_creativity',
  75.0,
  3
)
ON CONFLICT (user_id, feature_key) DO UPDATE
SET score_mean = 75.0, n = 3;

-- Wait a moment for trigger to fire
SELECT pg_sleep(1);

-- Compare before and after
SELECT
  'BEFORE' as when,
  mean,
  n_samples
FROM temp_before_stats
UNION ALL
SELECT
  'AFTER' as when,
  mean,
  n_samples
FROM feature_cohort_stats
WHERE feature_key = 'trait_creativity';

-- Cleanup
DROP TABLE temp_before_stats;
*/

-- Test 7: Manual recalculation test
\echo '\n--- Testing Manual Recalculation ---'
SELECT update_cohort_stats();
SELECT 'Manual recalculation completed' as status;

-- Test 8: Check index exists
\echo '\n--- Performance Index Check ---'
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'user_feature_scores'
  AND indexname LIKE '%feature_score%';

-- Test 9: Sample radar data for a user
\echo '\n--- Sample Radar Data (Your Profile) ---'
SELECT
  feature_key,
  ROUND(user_score_0_100::numeric, 1) as your_score,
  ROUND(cohort_mean_0_100::numeric, 1) as cohort_avg,
  ROUND((user_score_0_100 - cohort_mean_0_100)::numeric, 1) as difference
FROM get_my_radar_data()
WHERE cohort_mean_0_100 != 50.0  -- Show only features with real averages
ORDER BY feature_key
LIMIT 10;

-- Summary
\echo '\n--- Summary ---'
SELECT
  COUNT(*) FILTER (WHERE n_samples > 0) as features_with_data,
  COUNT(*) FILTER (WHERE n_samples = 0) as features_without_data,
  COUNT(*) FILTER (WHERE mean != 50.0) as features_with_real_avg,
  ROUND(AVG(mean)::numeric, 1) as overall_avg_score,
  MAX(last_updated) as last_update_time
FROM feature_cohort_stats;

\echo '\n✓ Test script completed!'
\echo 'If you see real averages (not 50.0) and n_samples > 0, the implementation is working! 🎉'
