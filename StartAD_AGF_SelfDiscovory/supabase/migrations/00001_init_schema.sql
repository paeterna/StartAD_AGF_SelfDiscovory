-- =====================================================
-- SelfMap Database Schema - Phase 2
-- Production-ready Supabase (PostgreSQL) schema
-- =====================================================

-- 0) Extensions (UUID + helpers)
create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";

-- 1) Domain Types (enums)
create type locale_t as enum ('en','ar');
create type theme_t  as enum ('system','light','dark');
create type activity_type_t as enum ('quiz','game');
create type consent_status_t as enum ('accepted','declined','revoked');

-- 2) Core Tables

-- 2.1 Users / Profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  locale locale_t not null default 'en',
  theme theme_t not null default 'system',
  onboarding_complete boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_profiles_created_at on public.profiles(created_at desc);

-- 2.2 Consents (for minors/privacy)
create table if not exists public.consents (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  version text not null,               -- e.g., "v1.0"
  status consent_status_t not null,    -- accepted/declined/revoked
  accepted_at timestamptz not null default now(),
  constraint uq_consents_user_version unique (user_id, version)
);

create index if not exists idx_consents_user on public.consents(user_id);

-- 2.3 Discovery Progress (1 row / user)
create table if not exists public.discovery_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  percent int not null default 0 check (percent between 0 and 100),
  streak_days int not null default 0 check (streak_days >= 0),
  last_activity_date date,
  updated_at timestamptz not null default now()
);

-- 2.4 Activities Catalog (tests/games)
create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  kind activity_type_t not null,       -- quiz | game
  estimated_minutes int check (estimated_minutes is null or estimated_minutes between 1 and 60),
  active boolean not null default true,
  -- trait weights used for rule-based scoring (e.g., {"creativity":2,"curiosity":1})
  traits_weight jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_activities_active on public.activities(active);
create index if not exists idx_activities_kind on public.activities(kind);
create index if not exists idx_activities_traits_gin on public.activities using gin(traits_weight jsonb_path_ops);

-- 2.5 Activity Runs (user completions → progress)
create table if not exists public.activity_runs (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_id uuid not null references public.activities(id) on delete cascade,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  score int,                                        -- optional raw score
  trait_scores jsonb not null default '{}'::jsonb,  -- computed deltas from this run
  delta_progress int not null default 0 check (delta_progress between 0 and 20)
);

create index if not exists idx_activity_runs_user on public.activity_runs(user_id);
create index if not exists idx_activity_runs_activity on public.activity_runs(activity_id);
create index if not exists idx_activity_runs_trait_gin on public.activity_runs using gin(trait_scores jsonb_path_ops);

-- 2.6 Assessments Snapshot (optional history per user)
create table if not exists public.assessments (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  taken_at timestamptz not null default now(),
  trait_scores jsonb not null default '{}'::jsonb,
  delta_progress int not null default 0 check (delta_progress between 0 and 20)
);

create index if not exists idx_assessments_user on public.assessments(user_id);
create index if not exists idx_assessments_trait_gin on public.assessments using gin(trait_scores jsonb_path_ops);

-- 2.7 Careers Catalog
create table if not exists public.careers (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  cluster text,                  -- e.g., "STEM", "Creative", ...
  tags text[] not null default '{}', -- used for rule-based matching
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_careers_active on public.careers(active);
create index if not exists idx_careers_tags_gin on public.careers using gin(tags);

-- 2.8 Roadmaps & Steps
create table if not exists public.roadmaps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  career_id uuid not null references public.careers(id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists idx_roadmaps_user on public.roadmaps(user_id);

create table if not exists public.roadmap_steps (
  id uuid primary key default gen_random_uuid(),
  roadmap_id uuid not null references public.roadmaps(id) on delete cascade,
  sort_order int not null default 1 check (sort_order >= 1),
  title text not null,
  description text,
  completed boolean not null default false,
  completed_at timestamptz
);

create index if not exists idx_roadmap_steps_roadmap on public.roadmap_steps(roadmap_id);
create index if not exists idx_roadmap_steps_completed on public.roadmap_steps(completed);

-- 3) Security: Row-Level Security (RLS)

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.consents enable row level security;
alter table public.discovery_progress enable row level security;
alter table public.activities enable row level security;
alter table public.activity_runs enable row level security;
alter table public.assessments enable row level security;
alter table public.careers enable row level security;
alter table public.roadmaps enable row level security;
alter table public.roadmap_steps enable row level security;

-- PROFILES
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_insert_self" on public.profiles
  for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- CONSENTS
create policy "consents_select_own" on public.consents
  for select using (auth.uid() = user_id);
create policy "consents_write_own" on public.consents
  for insert with check (auth.uid() = user_id);

-- DISCOVERY PROGRESS
create policy "progress_select_own" on public.discovery_progress
  for select using (auth.uid() = user_id);
create policy "progress_write_own" on public.discovery_progress
  for insert with check (auth.uid() = user_id);
create policy "progress_update_own" on public.discovery_progress
  for update using (auth.uid() = user_id);

-- ACTIVITIES (catalog: read-all)
create policy "activities_read_all" on public.activities
  for select using (true);

-- ACTIVITY RUNS
create policy "runs_select_own" on public.activity_runs
  for select using (auth.uid() = user_id);
create policy "runs_insert_own" on public.activity_runs
  for insert with check (auth.uid() = user_id);
create policy "runs_update_own" on public.activity_runs
  for update using (auth.uid() = user_id);

-- ASSESSMENTS
create policy "assessments_select_own" on public.assessments
  for select using (auth.uid() = user_id);
create policy "assessments_insert_own" on public.assessments
  for insert with check (auth.uid() = user_id);

-- CAREERS (catalog: read-all)
create policy "careers_read_all" on public.careers
  for select using (true);

-- ROADMAPS
create policy "roadmaps_select_own" on public.roadmaps
  for select using (auth.uid() = user_id);
create policy "roadmaps_write_own" on public.roadmaps
  for insert with check (auth.uid() = user_id);

-- ROADMAP STEPS
create policy "steps_select_by_owner" on public.roadmap_steps
  for select using (
    exists (select 1 from public.roadmaps r where r.id = roadmap_id and r.user_id = auth.uid())
  );
create policy "steps_write_by_owner" on public.roadmap_steps
  for insert with check (
    exists (select 1 from public.roadmaps r where r.id = roadmap_id and r.user_id = auth.uid())
  );
create policy "steps_update_by_owner" on public.roadmap_steps
  for update using (
    exists (select 1 from public.roadmaps r where r.id = roadmap_id and r.user_id = auth.uid())
  );

-- 4) Functions & Triggers

-- 4.1 Update discovery progress (percent, streak) after each run
create or replace function public.fn_update_progress_after_run()
returns trigger
language plpgsql
as $$
declare
  v_user uuid;
  v_today date := (now() at time zone 'utc')::date;
  v_last date;
  v_percent int;
  v_new_percent int;
  v_streak int;
begin
  v_user := new.user_id;

  -- Ensure progress row exists
  insert into public.discovery_progress(user_id, percent, streak_days, last_activity_date)
  values (v_user, 0, 0, null)
  on conflict (user_id) do nothing;

  select percent, streak_days, last_activity_date
    into v_percent, v_streak, v_last
  from public.discovery_progress
  where user_id = v_user
  for update;

  -- streak logic
  if v_last is null then
    v_streak := 1;
  elsif v_last = v_today - 1 then
    v_streak := v_streak + 1;
  elsif v_last = v_today then
    -- same day, keep streak
  else
    v_streak := 1;
  end if;

  -- progress add (cap 100)
  v_new_percent := least(100, coalesce(v_percent,0) + greatest(new.delta_progress, 0));

  update public.discovery_progress
     set percent = v_new_percent,
         streak_days = v_streak,
         last_activity_date = v_today,
         updated_at = now()
   where user_id = v_user;

  return new;
end;
$$;

drop trigger if exists trg_update_progress_after_run on public.activity_runs;
drop trigger if exists trg_update_progress_after_insert on public.activity_runs;
drop trigger if exists trg_update_progress_after_update on public.activity_runs;

-- Separate triggers for INSERT and UPDATE to handle OLD/NEW properly
create trigger trg_update_progress_after_insert
after insert on public.activity_runs
for each row
when (new.completed_at is not null)
execute function public.fn_update_progress_after_run();

create trigger trg_update_progress_after_update
after update on public.activity_runs
for each row
when (new.completed_at is not null and old.completed_at is null)
execute function public.fn_update_progress_after_run();

-- 4.2 Auto-create profile row on first sign-in
create or replace function public.fn_create_profile_for_user()
returns trigger
language plpgsql
as $$
begin
  insert into public.profiles(id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)))
  on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists trg_create_profile_for_user on auth.users;

create trigger trg_create_profile_for_user
after insert on auth.users
for each row execute function public.fn_create_profile_for_user();

-- 5) Views

-- 5.1 Latest traits per user (to simplify client queries)
create or replace view public.v_latest_traits as
select a.user_id,
       (select trait_scores
          from public.assessments a2
         where a2.user_id = a.user_id
         order by a2.taken_at desc
         limit 1) as trait_scores
from public.assessments a
group by a.user_id;

-- 6) Seed Data (activities, careers)

-- Activities (rule-based trait signals)
insert into public.activities (title, kind, estimated_minutes, traits_weight) values
  ('Creativity Sparks', 'quiz', 5, '{"creativity": 2, "curiosity": 1}'),
  ('Pattern Puzzles',  'game', 7, '{"analytical": 2, "persistence": 1}'),
  ('Team Play Quest',  'game', 6, '{"collaboration": 2, "communication": 1}');

-- Careers (tags will overlap with trait names)
insert into public.careers (title, cluster, tags) values
  ('Software Developer', 'STEM',      array['analytical','persistence','curiosity']),
  ('Graphic Designer',   'Creative',  array['creativity','communication']),
  ('Data Analyst',       'STEM',      array['analytical','curiosity']),
  ('Teacher',            'Public',    array['communication','collaboration']),
  ('Entrepreneur',       'Business',  array['creativity','persistence','communication']);
