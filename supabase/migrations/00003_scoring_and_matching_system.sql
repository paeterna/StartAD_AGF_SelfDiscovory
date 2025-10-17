-- =====================================================
-- Scoring, Aggregation & Career Matching System
-- Migration 00003
-- =====================================================

-- 1) Features table - defines the feature space for scoring
create table if not exists public.features (
  id serial primary key,
  key text unique not null,
  family text not null,  -- 'interests', 'cognition', 'traits'
  description text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_features_family on public.features(family);
create index if not exists idx_features_key on public.features(key);

-- 2) Seed features (~22 features across 3 families)
insert into public.features (key, family, description) values
  -- Interests (Holland RIASEC model)
  ('interest_creative', 'interests', 'Creative and artistic interests'),
  ('interest_social', 'interests', 'Social and helping interests'),
  ('interest_analytical', 'interests', 'Analytical and investigative interests'),
  ('interest_practical', 'interests', 'Practical and hands-on interests'),
  ('interest_enterprising', 'interests', 'Enterprising and leadership interests'),
  ('interest_conventional', 'interests', 'Conventional and organizational interests'),

  -- Cognition (cognitive abilities)
  ('cognition_verbal', 'cognition', 'Verbal reasoning and language'),
  ('cognition_quantitative', 'cognition', 'Quantitative and mathematical reasoning'),
  ('cognition_spatial', 'cognition', 'Spatial reasoning and visualization'),
  ('cognition_memory', 'cognition', 'Memory and recall'),
  ('cognition_attention', 'cognition', 'Attention and focus'),
  ('cognition_problem_solving', 'cognition', 'Problem solving and logic'),

  -- Traits (personality and work styles)
  ('trait_grit', 'traits', 'Perseverance and persistence'),
  ('trait_curiosity', 'traits', 'Curiosity and learning orientation'),
  ('trait_collaboration', 'traits', 'Collaboration and teamwork'),
  ('trait_conscientiousness', 'traits', 'Conscientiousness and organization'),
  ('trait_openness', 'traits', 'Openness to experience'),
  ('trait_adaptability', 'traits', 'Adaptability and flexibility'),
  ('trait_communication', 'traits', 'Communication skills'),
  ('trait_leadership', 'traits', 'Leadership and influence'),
  ('trait_creativity', 'traits', 'Creative thinking'),
  ('trait_emotional_intelligence', 'traits', 'Emotional intelligence')
on conflict (key) do nothing;

-- 3) Extend assessments table (reuse existing, add confidence)
-- The existing assessments table will be used, we'll add a confidence column
alter table public.assessments
  add column if not exists confidence float8 default 0.0 check (confidence between 0.0 and 1.0);

-- Note: activity_type_t enum already exists from 00001_init_schema.sql with values ('quiz','game')
-- No modification needed - the enum is already correct

-- 4) Assessment items table - individual responses/telemetry
create table if not exists public.assessment_items (
  id uuid primary key default gen_random_uuid(),
  assessment_id bigint not null references public.assessments(id) on delete cascade,
  item_id text not null,           -- identifies the quiz question or game segment
  response jsonb,                   -- raw response data
  score_raw float8,                 -- raw score before normalization
  score_norm float8,                -- normalized score [0..100]
  duration_ms int,                  -- time taken
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_assessment_items_assessment on public.assessment_items(assessment_id);
create index if not exists idx_assessment_items_item_id on public.assessment_items(item_id);

-- 5) User feature scores - aggregated EMA scores per user per feature
create table if not exists public.user_feature_scores (
  user_id uuid not null references auth.users(id) on delete cascade,
  feature_key text not null references public.features(key) on delete cascade,
  score_mean float8 not null default 50.0 check (score_mean between 0 and 100),
  score_std float8 default 0.0,    -- optional: track standard deviation
  n int not null default 0 check (n >= 0),  -- number of observations
  last_updated timestamptz not null default now(),
  primary key (user_id, feature_key)
);

create index if not exists idx_user_feature_scores_user on public.user_feature_scores(user_id);
create index if not exists idx_user_feature_scores_feature on public.user_feature_scores(feature_key);

-- 6) Update careers table with vector column
-- Add vector column to existing careers table
alter table public.careers
  add column if not exists vector float8[] check (array_length(vector, 1) = 22),  -- must match feature count
  add column if not exists description text,
  add column if not exists source text default 'manual';

-- Update existing careers to have empty vectors (will be populated later)
update public.careers
set vector = array_fill(0.5::float8, array[22])
where vector is null;

-- Make vector NOT NULL after backfill (only if not already set)
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_name = 'careers'
    and column_name = 'vector'
    and is_nullable = 'YES'
  ) then
    alter table public.careers alter column vector set not null;
  end if;
end $$;

create index if not exists idx_careers_vector on public.careers using gin(vector);
create index if not exists idx_careers_title on public.careers(title);

-- 7) User career matches - computed similarity scores
create table if not exists public.user_career_matches (
  user_id uuid not null references auth.users(id) on delete cascade,
  career_id uuid not null references public.careers(id) on delete cascade,
  similarity float8 not null check (similarity between 0 and 1),
  confidence float8 not null default 0.0 check (confidence between 0 and 1),
  top_features jsonb default '[]'::jsonb,  -- top 3 contributing features
  last_updated timestamptz not null default now(),
  primary key (user_id, career_id)
);

create index if not exists idx_user_career_matches_user on public.user_career_matches(user_id);
create index if not exists idx_user_career_matches_similarity on public.user_career_matches(user_id, similarity desc);

-- 8) Quiz items configuration - mapping quiz items to features
create table if not exists public.quiz_items (
  item_id text primary key,
  feature_key text not null references public.features(key) on delete cascade,
  direction float8 not null default 1.0 check (direction in (-1.0, 1.0)),  -- 1 = positive, -1 = negative
  weight float8 not null default 1.0 check (weight > 0),
  question_text text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_quiz_items_feature on public.quiz_items(feature_key);

-- 9) Feature cohort statistics - for z-score normalization
create table if not exists public.feature_cohort_stats (
  feature_key text primary key references public.features(key) on delete cascade,
  mean float8 not null default 50.0,
  std_dev float8 not null default 10.0,
  min_val float8 not null default 0.0,
  max_val float8 not null default 100.0,
  n_samples int not null default 0,
  last_updated timestamptz not null default now()
);

-- Initialize with reasonable defaults
insert into public.feature_cohort_stats (feature_key, mean, std_dev, min_val, max_val)
select key, 50.0, 10.0, 0.0, 100.0
from public.features
on conflict (feature_key) do nothing;

-- 10) EMA aggregation function
create or replace function public.upsert_feature_ema(
  p_user_id uuid,
  p_key text,
  p_value float8,
  p_weight float8,
  p_n int
)
returns void
language plpgsql
security definer
as $$
declare
  v_alpha float8;
  v_old_mean float8;
  v_old_n int;
  v_new_mean float8;
  v_new_n int;
begin
  -- Clamp alpha between 0.15 and 0.7
  v_alpha := greatest(0.15, least(0.7, p_weight));

  -- Try to get existing values
  select score_mean, n into v_old_mean, v_old_n
  from public.user_feature_scores
  where user_id = p_user_id and feature_key = p_key;

  if found then
    -- Update with EMA
    v_new_mean := v_alpha * p_value + (1 - v_alpha) * v_old_mean;
    v_new_n := v_old_n + p_n;

    update public.user_feature_scores
    set score_mean = v_new_mean,
        n = v_new_n,
        last_updated = now()
    where user_id = p_user_id and feature_key = p_key;
  else
    -- Insert new row
    insert into public.user_feature_scores (user_id, feature_key, score_mean, n)
    values (p_user_id, p_key, p_value, p_n);
  end if;
end;
$$;

-- 11) Helper function to compute profile completeness
create or replace function public.get_profile_completeness(p_user_id uuid)
returns float8
language plpgsql
security definer
as $$
declare
  v_total_features int;
  v_avg_confidence float8;
begin
  -- Count total features
  select count(*) into v_total_features from public.features;

  -- Compute average confidence across all features
  -- confidence_i = min(1.0, n_i / 12)
  select avg(least(1.0, coalesce(n, 0)::float8 / 12.0))
  into v_avg_confidence
  from public.features f
  left join public.user_feature_scores ufs
    on ufs.feature_key = f.key and ufs.user_id = p_user_id;

  return coalesce(v_avg_confidence, 0.0) * 100.0;  -- return as percentage
end;
$$;

-- 12) Helper function to get user feature vector (ordered)
create or replace function public.get_user_feature_vector(p_user_id uuid)
returns float8[]
language plpgsql
security definer
as $$
declare
  v_vector float8[];
begin
  -- Build ordered vector from features table (ordered by id)
  -- Scale from [0..100] to [0..1]
  select array_agg(coalesce(ufs.score_mean, 50.0) / 100.0 order by f.id)
  into v_vector
  from public.features f
  left join public.user_feature_scores ufs
    on ufs.feature_key = f.key and ufs.user_id = p_user_id;

  return v_vector;
end;
$$;

-- 13) RLS Policies

-- assessment_items
alter table public.assessment_items enable row level security;

drop policy if exists "assessment_items_select_own" on public.assessment_items;
create policy "assessment_items_select_own" on public.assessment_items
  for select using (
    exists (
      select 1 from public.assessments a
      where a.id = assessment_items.assessment_id
      and a.user_id = auth.uid()
    )
  );

drop policy if exists "assessment_items_insert_own" on public.assessment_items;
create policy "assessment_items_insert_own" on public.assessment_items
  for insert with check (
    exists (
      select 1 from public.assessments a
      where a.id = assessment_items.assessment_id
      and a.user_id = auth.uid()
    )
  );

-- user_feature_scores
alter table public.user_feature_scores enable row level security;

drop policy if exists "user_feature_scores_select_own" on public.user_feature_scores;
create policy "user_feature_scores_select_own" on public.user_feature_scores
  for select using (auth.uid() = user_id);

drop policy if exists "user_feature_scores_insert_own" on public.user_feature_scores;
create policy "user_feature_scores_insert_own" on public.user_feature_scores
  for insert with check (auth.uid() = user_id);

drop policy if exists "user_feature_scores_update_own" on public.user_feature_scores;
create policy "user_feature_scores_update_own" on public.user_feature_scores
  for update using (auth.uid() = user_id);

-- user_career_matches
alter table public.user_career_matches enable row level security;

drop policy if exists "user_career_matches_select_own" on public.user_career_matches;
create policy "user_career_matches_select_own" on public.user_career_matches
  for select using (auth.uid() = user_id);

drop policy if exists "user_career_matches_insert_own" on public.user_career_matches;
create policy "user_career_matches_insert_own" on public.user_career_matches
  for insert with check (auth.uid() = user_id);

drop policy if exists "user_career_matches_update_own" on public.user_career_matches;
create policy "user_career_matches_update_own" on public.user_career_matches
  for update using (auth.uid() = user_id);

-- quiz_items (read-only for all authenticated users)
alter table public.quiz_items enable row level security;

drop policy if exists "quiz_items_read_all" on public.quiz_items;
create policy "quiz_items_read_all" on public.quiz_items
  for select using (auth.uid() is not null);

-- features (read-only for all authenticated users)
alter table public.features enable row level security;

drop policy if exists "features_read_all" on public.features;
create policy "features_read_all" on public.features
  for select using (auth.uid() is not null);

-- feature_cohort_stats (read-only for all authenticated users)
alter table public.feature_cohort_stats enable row level security;

drop policy if exists "feature_cohort_stats_read_all" on public.feature_cohort_stats;
create policy "feature_cohort_stats_read_all" on public.feature_cohort_stats
  for select using (auth.uid() is not null);

-- 14) Seed sample quiz items (example personality assessment)
insert into public.quiz_items (item_id, feature_key, direction, weight, question_text) values
  ('pa_001', 'trait_creativity', 1.0, 1.0, 'I enjoy coming up with new and original ideas'),
  ('pa_002', 'trait_collaboration', 1.0, 1.0, 'I work well in team environments'),
  ('pa_003', 'trait_grit', 1.0, 1.0, 'I persist through difficult challenges'),
  ('pa_004', 'interest_analytical', 1.0, 1.0, 'I enjoy solving complex problems'),
  ('pa_005', 'interest_creative', 1.0, 1.0, 'I am drawn to artistic and creative activities'),
  ('pa_006', 'interest_social', 1.0, 1.0, 'I enjoy helping and supporting others'),
  ('pa_007', 'trait_conscientiousness', 1.0, 1.0, 'I am organized and detail-oriented'),
  ('pa_008', 'trait_openness', 1.0, 1.0, 'I am open to new experiences and ideas'),
  ('pa_009', 'interest_practical', 1.0, 1.0, 'I prefer hands-on, practical work'),
  ('pa_010', 'interest_enterprising', 1.0, 1.0, 'I enjoy taking initiative and leading projects'),
  ('pa_011', 'trait_adaptability', 1.0, 1.0, 'I adapt easily to changing situations'),
  ('pa_012', 'trait_communication', 1.0, 1.0, 'I communicate clearly and effectively')
on conflict (item_id) do nothing;

-- 15) Seed sample careers with feature vectors
-- Vector order matches features.id order (22 dimensions)
-- Values are in [0..1] scale representing importance of each feature for that career

-- Software Developer
update public.careers
set vector = array[
  0.3,  -- interest_creative
  0.3,  -- interest_social
  0.9,  -- interest_analytical (HIGH)
  0.5,  -- interest_practical
  0.4,  -- interest_enterprising
  0.6,  -- interest_conventional
  0.6,  -- cognition_verbal
  0.9,  -- cognition_quantitative (HIGH)
  0.7,  -- cognition_spatial
  0.5,  -- cognition_memory
  0.7,  -- cognition_attention
  0.9,  -- cognition_problem_solving (HIGH)
  0.8,  -- trait_grit
  0.8,  -- trait_curiosity
  0.7,  -- trait_collaboration
  0.7,  -- trait_conscientiousness
  0.6,  -- trait_openness
  0.7,  -- trait_adaptability
  0.6,  -- trait_communication
  0.5,  -- trait_leadership
  0.7,  -- trait_creativity
  0.5   -- trait_emotional_intelligence
]::float8[],
description = 'Design, develop, and maintain software applications and systems'
where title = 'Software Developer';

-- Graphic Designer
update public.careers
set vector = array[
  0.95, -- interest_creative (VERY HIGH)
  0.5,  -- interest_social
  0.4,  -- interest_analytical
  0.6,  -- interest_practical
  0.5,  -- interest_enterprising
  0.4,  -- interest_conventional
  0.6,  -- cognition_verbal
  0.4,  -- cognition_quantitative
  0.9,  -- cognition_spatial (HIGH)
  0.5,  -- cognition_memory
  0.7,  -- cognition_attention
  0.6,  -- cognition_problem_solving
  0.7,  -- trait_grit
  0.8,  -- trait_curiosity
  0.6,  -- trait_collaboration
  0.6,  -- trait_conscientiousness
  0.9,  -- trait_openness (HIGH)
  0.7,  -- trait_adaptability
  0.7,  -- trait_communication
  0.5,  -- trait_leadership
  0.95, -- trait_creativity (VERY HIGH)
  0.6   -- trait_emotional_intelligence
]::float8[]
where title = 'Graphic Designer';

-- Data Analyst
update public.careers
set vector = array[
  0.3,  -- interest_creative
  0.3,  -- interest_social
  0.95, -- interest_analytical (VERY HIGH)
  0.4,  -- interest_practical
  0.5,  -- interest_enterprising
  0.7,  -- interest_conventional
  0.6,  -- cognition_verbal
  0.95, -- cognition_quantitative (VERY HIGH)
  0.5,  -- cognition_spatial
  0.6,  -- cognition_memory
  0.8,  -- cognition_attention
  0.9,  -- cognition_problem_solving (HIGH)
  0.7,  -- trait_grit
  0.8,  -- trait_curiosity
  0.6,  -- trait_collaboration
  0.8,  -- trait_conscientiousness
  0.6,  -- trait_openness
  0.6,  -- trait_adaptability
  0.7,  -- trait_communication
  0.5,  -- trait_leadership
  0.5,  -- trait_creativity
  0.5   -- trait_emotional_intelligence
]::float8[],
description = 'Analyze data to help organizations make informed decisions'
where title = 'Data Analyst';

-- Teacher
update public.careers
set vector = array[
  0.6,  -- interest_creative
  0.95, -- interest_social (VERY HIGH)
  0.5,  -- interest_analytical
  0.5,  -- interest_practical
  0.6,  -- interest_enterprising
  0.6,  -- interest_conventional
  0.8,  -- cognition_verbal
  0.5,  -- cognition_quantitative
  0.5,  -- cognition_spatial
  0.7,  -- cognition_memory
  0.7,  -- cognition_attention
  0.6,  -- cognition_problem_solving
  0.8,  -- trait_grit
  0.7,  -- trait_curiosity
  0.9,  -- trait_collaboration (HIGH)
  0.8,  -- trait_conscientiousness
  0.8,  -- trait_openness
  0.8,  -- trait_adaptability
  0.95, -- trait_communication (VERY HIGH)
  0.7,  -- trait_leadership
  0.7,  -- trait_creativity
  0.9   -- trait_emotional_intelligence (HIGH)
]::float8[],
description = 'Educate and inspire students in various subjects'
where title = 'Teacher';

-- Entrepreneur
update public.careers
set vector = array[
  0.8,  -- interest_creative
  0.7,  -- interest_social
  0.7,  -- interest_analytical
  0.6,  -- interest_practical
  0.95, -- interest_enterprising (VERY HIGH)
  0.5,  -- interest_conventional
  0.7,  -- cognition_verbal
  0.7,  -- cognition_quantitative
  0.6,  -- cognition_spatial
  0.6,  -- cognition_memory
  0.7,  -- cognition_attention
  0.8,  -- cognition_problem_solving
  0.95, -- trait_grit (VERY HIGH)
  0.8,  -- trait_curiosity
  0.7,  -- trait_collaboration
  0.7,  -- trait_conscientiousness
  0.8,  -- trait_openness
  0.9,  -- trait_adaptability (HIGH)
  0.9,  -- trait_communication (HIGH)
  0.95, -- trait_leadership (VERY HIGH)
  0.9,  -- trait_creativity (HIGH)
  0.8   -- trait_emotional_intelligence
]::float8[],
description = 'Start and manage your own business ventures'
where title = 'Entrepreneur';

-- 16) Grant execute permissions on functions
grant execute on function public.upsert_feature_ema(uuid, text, float8, float8, int) to authenticated;
grant execute on function public.get_profile_completeness(uuid) to authenticated;
grant execute on function public.get_user_feature_vector(uuid) to authenticated;

-- Migration complete
