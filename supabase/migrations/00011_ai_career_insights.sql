-- =====================================================
-- AI Career Insights System
-- Migration 00011
-- =====================================================

-- 1) AI Career Insights table - stores AI-generated career analysis
create table if not exists public.ai_career_insights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,

  -- Core insights
  personality_summary text not null,
  skills_detected text[] not null default '{}',
  interest_scores jsonb not null default '{}'::jsonb,

  -- Career recommendations
  career_recommendations jsonb not null default '[]'::jsonb,
  -- Format: [{"title": "Software Developer", "match_score": 85, "description": "..."}]

  career_reasoning jsonb not null default '{}'::jsonb,
  -- Format: {"Software Developer": "You show strong analytical skills..."}

  learning_path jsonb not null default '[]'::jsonb,
  -- Format: [{"title": "Try Scratch", "description": "...", "type": "course"}]

  -- Metadata
  confidence_score float8 default 0.0 check (confidence_score between 0 and 1),
  data_points_used int default 0,  -- number of assessments/activities analyzed

  -- Timestamps
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_ai_insights_user on public.ai_career_insights(user_id);
create index if not exists idx_ai_insights_created on public.ai_career_insights(created_at desc);
create index if not exists idx_ai_insights_confidence on public.ai_career_insights(confidence_score desc);

-- 2) RLS Policies
alter table public.ai_career_insights enable row level security;

create policy "ai_insights_select_own" on public.ai_career_insights
  for select using (auth.uid() = user_id);

create policy "ai_insights_insert_own" on public.ai_career_insights
  for insert with check (auth.uid() = user_id);

create policy "ai_insights_update_own" on public.ai_career_insights
  for update using (auth.uid() = user_id);

-- 3) Helper function to get latest insight for user
create or replace function public.get_latest_ai_insight(p_user_id uuid)
returns public.ai_career_insights
language plpgsql
security definer
as $$
declare
  v_insight public.ai_career_insights;
begin
  select * into v_insight
  from public.ai_career_insights
  where user_id = p_user_id
  order by created_at desc
  limit 1;

  return v_insight;
end;
$$;

-- 4) Helper function to check if user has sufficient data for AI analysis
create or replace function public.can_generate_ai_insight(p_user_id uuid)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_assessment_count int;
  v_activity_count int;
  v_feature_count int;
  v_can_generate boolean;
  v_reason text;
begin
  -- Count assessments
  select count(*) into v_assessment_count
  from public.assessments
  where user_id = p_user_id and completed_at is not null;

  -- Count activity runs
  select count(*) into v_activity_count
  from public.activity_runs
  where user_id = p_user_id and completed_at is not null;

  -- Count features with scores
  select count(*) into v_feature_count
  from public.user_feature_scores
  where user_id = p_user_id and n >= 3;  -- at least 3 observations per feature

  -- Determine if we can generate
  if v_assessment_count >= 1 and v_activity_count >= 2 and v_feature_count >= 10 then
    v_can_generate := true;
    v_reason := 'Sufficient data available';
  else
    v_can_generate := false;
    v_reason := format(
      'Need more data: %s assessments (need 1+), %s activities (need 2+), %s features (need 10+)',
      v_assessment_count, v_activity_count, v_feature_count
    );
  end if;

  return jsonb_build_object(
    'can_generate', v_can_generate,
    'reason', v_reason,
    'assessments', v_assessment_count,
    'activities', v_activity_count,
    'features', v_feature_count
  );
end;
$$;

-- 5) Trigger to update updated_at timestamp
create or replace function public.fn_update_ai_insight_timestamp()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_update_ai_insight_timestamp on public.ai_career_insights;

create trigger trg_update_ai_insight_timestamp
before update on public.ai_career_insights
for each row
execute function public.fn_update_ai_insight_timestamp();

-- 6) Comments for documentation
comment on table public.ai_career_insights is 'AI-generated career insights and recommendations for students';
comment on column public.ai_career_insights.personality_summary is 'Natural language summary of student personality and thinking style';
comment on column public.ai_career_insights.skills_detected is 'Array of key skills identified from student behavior';
comment on column public.ai_career_insights.interest_scores is 'JSON object mapping interest categories to percentage scores';
comment on column public.ai_career_insights.career_recommendations is 'Array of recommended careers with match scores and descriptions';
comment on column public.ai_career_insights.career_reasoning is 'JSON object mapping career titles to reasoning explanations';
comment on column public.ai_career_insights.learning_path is 'Array of suggested next steps and learning resources';
comment on column public.ai_career_insights.confidence_score is 'Confidence level of the analysis (0-1) based on data completeness';
comment on column public.ai_career_insights.data_points_used is 'Number of assessments and activities used in the analysis';

