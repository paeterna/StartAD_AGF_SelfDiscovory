-- =====================================================
-- Migration 00012: Real Cohort Averages
-- Calculate actual average scores from all users instead of static values
-- =====================================================

-- 1) Create function to update cohort statistics from actual user data
create or replace function public.update_cohort_stats()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Update feature_cohort_stats with real averages from all users
  update public.feature_cohort_stats fcs
  set
    mean = coalesce(stats.avg_score, 50.0),
    std_dev = coalesce(stats.std_dev, 10.0),
    min_val = coalesce(stats.min_score, 0.0),
    max_val = coalesce(stats.max_score, 100.0),
    n_samples = coalesce(stats.user_count, 0),
    last_updated = now()
  from (
    select
      feature_key,
      avg(score_mean) as avg_score,
      stddev_pop(score_mean) as std_dev,
      min(score_mean) as min_score,
      max(score_mean) as max_score,
      count(distinct user_id) as user_count
    from public.user_feature_scores
    where score_mean is not null
      and n >= 1  -- Only include scores with at least 1 observation
    group by feature_key
  ) stats
  where fcs.feature_key = stats.feature_key;
end;
$$;

comment on function public.update_cohort_stats() is
  'Updates feature_cohort_stats table with real averages from all users';

grant execute on function public.update_cohort_stats() to authenticated;

-- 2) Create trigger to automatically update cohort stats when user scores change
-- This ensures the cohort averages stay up-to-date

create or replace function public.trigger_update_cohort_stats()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Only update cohort stats if the score changed significantly (>1 point)
  -- or if this is a new feature score
  if TG_OP = 'INSERT' or
     (TG_OP = 'UPDATE' and abs(NEW.score_mean - OLD.score_mean) > 1.0) then

    -- Update stats for the specific feature that changed
    update public.feature_cohort_stats
    set
      mean = (
        select coalesce(avg(score_mean), 50.0)
        from public.user_feature_scores
        where feature_key = NEW.feature_key
          and score_mean is not null
          and n >= 1
      ),
      std_dev = (
        select coalesce(stddev_pop(score_mean), 10.0)
        from public.user_feature_scores
        where feature_key = NEW.feature_key
          and score_mean is not null
          and n >= 1
      ),
      min_val = (
        select coalesce(min(score_mean), 0.0)
        from public.user_feature_scores
        where feature_key = NEW.feature_key
          and score_mean is not null
          and n >= 1
      ),
      max_val = (
        select coalesce(max(score_mean), 100.0)
        from public.user_feature_scores
        where feature_key = NEW.feature_key
          and score_mean is not null
          and n >= 1
      ),
      n_samples = (
        select count(distinct user_id)
        from public.user_feature_scores
        where feature_key = NEW.feature_key
          and score_mean is not null
          and n >= 1
      ),
      last_updated = now()
    where feature_key = NEW.feature_key;
  end if;

  return NEW;
end;
$$;

comment on function public.trigger_update_cohort_stats() is
  'Trigger function to update cohort stats when user scores change';

-- 3) Create trigger on user_feature_scores table
drop trigger if exists trg_update_cohort_stats on public.user_feature_scores;

create trigger trg_update_cohort_stats
  after insert or update on public.user_feature_scores
  for each row
  execute function public.trigger_update_cohort_stats();

comment on trigger trg_update_cohort_stats on public.user_feature_scores is
  'Automatically updates cohort statistics when user feature scores change';

-- 4) Initial update: Calculate real cohort statistics from existing data
select public.update_cohort_stats();

-- 5) Create a scheduled job helper (for manual or cron execution)
-- Note: Supabase doesn't have built-in cron, but this can be called manually
-- or via an edge function on a schedule

comment on function public.update_cohort_stats() is
  'Updates feature_cohort_stats with real user averages.
   Call manually: SELECT update_cohort_stats();
   Or schedule via Edge Function cron job.
   Trigger automatically updates on each user score change.';

-- 6) Add index to improve performance of cohort calculations
create index if not exists idx_user_feature_scores_feature_score
  on public.user_feature_scores(feature_key, score_mean)
  where n >= 1;

comment on index idx_user_feature_scores_feature_score is
  'Optimizes cohort statistics calculations by feature';
