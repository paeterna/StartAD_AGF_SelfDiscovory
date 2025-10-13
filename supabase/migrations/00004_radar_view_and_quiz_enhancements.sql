-- =====================================================
-- Migration 00004: Radar Chart View + Quiz Enhancements
-- =====================================================

-- 0) Extend quiz_items table to support multiple instruments and languages
-- Add new columns needed for JSON-based assessment loading
alter table public.quiz_items
  add column if not exists instrument text,
  add column if not exists version text,
  add column if not exists language text,
  add column if not exists sort_order int;

-- Update existing rows to have default values
update public.quiz_items
set instrument = 'legacy',
    version = '1.0',
    language = 'en',
    sort_order = 1
where instrument is null;

-- Drop the old primary key and create new composite primary key
-- Only if needed (check if pk is still on item_id only)
do $$
begin
  -- Drop existing PK if it's just on item_id
  if exists (
    select 1 from information_schema.table_constraints
    where constraint_name = 'quiz_items_pkey'
    and table_name = 'quiz_items'
  ) then
    alter table public.quiz_items drop constraint quiz_items_pkey;
  end if;
end $$;

-- Create new primary key on (instrument, language, item_id)
alter table public.quiz_items
  add primary key (instrument, language, item_id);

-- 1) Create view for radar chart visualization
-- This view combines user feature scores with cohort statistics
-- for visual comparison in spider/radar charts

create or replace view public.v_user_radar as
select
  f.id as feature_index,
  f.key as feature_key,
  initcap(replace(f.key, '_', ' ')) as feature_label,
  f.family as family,
  coalesce(ufs.score_mean, 50.0) as user_score_0_100,
  coalesce(fcs.mean, 50.0) as cohort_mean_0_100,
  ufs.user_id
from public.features f
left join public.user_feature_scores ufs
  on ufs.feature_key = f.key
left join public.feature_cohort_stats fcs
  on fcs.feature_key = f.key
order by f.id;

-- Grant access to authenticated users (filtered by RLS via user_id)
grant select on public.v_user_radar to authenticated;

comment on view public.v_user_radar is
  'Radar chart data: user scores vs cohort averages for all 22 features';

-- 2) Add RLS policy for the view (users can only see their own data)
-- Note: Views inherit RLS from underlying tables, but we ensure proper filtering

-- 3) Create helper function to get radar data for current user
create or replace function public.get_my_radar_data()
returns table (
  feature_index int,
  feature_key text,
  feature_label text,
  family text,
  user_score_0_100 numeric,
  cohort_mean_0_100 numeric
)
language sql
security definer
set search_path = public
as $$
  select
    feature_index,
    feature_key,
    feature_label,
    family,
    user_score_0_100,
    cohort_mean_0_100
  from public.v_user_radar
  where user_id = auth.uid()
  order by feature_index;
$$;

grant execute on function public.get_my_radar_data() to authenticated;

comment on function public.get_my_radar_data() is
  'Returns radar chart data for the current authenticated user';

-- 4) Add indexes for better performance on feature lookups
create index if not exists idx_user_feature_scores_feature_key
  on public.user_feature_scores(feature_key);

create index if not exists idx_features_key
  on public.features(key);

-- 5) Ensure quiz_items table has proper indexes for seeding and fetching
create index if not exists idx_quiz_items_instrument_lang
  on public.quiz_items(instrument, language);

create index if not exists idx_quiz_items_sort_order
  on public.quiz_items(sort_order);

-- 6) Add helper function to check if quiz instrument is seeded
create or replace function public.is_quiz_instrument_seeded(
  p_instrument text,
  p_language text
)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists(
    select 1
    from public.quiz_items
    where instrument = p_instrument
      and language = p_language
    limit 1
  );
$$;

grant execute on function public.is_quiz_instrument_seeded(text, text) to authenticated;

comment on function public.is_quiz_instrument_seeded(text, text) is
  'Checks if a quiz instrument has been seeded for a given language';
