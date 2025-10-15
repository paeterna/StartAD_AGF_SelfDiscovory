-- Migration 00005: Fix RLS policies for activities table and improve error handling
-- Issue: Users need to be able to upsert activities for seeded data
-- This allows the app to seed activities without admin privileges

-- 1. Fix activities table policies
-- Drop existing activities policies
drop policy if exists "activities_read_all" on public.activities;

-- Recreate with INSERT/UPDATE policies for authenticated users
-- This allows the ActivityService to upsert seeded activities
create policy "activities_select_all" on public.activities
  for select using (true);

create policy "activities_insert_seeded" on public.activities
  for insert with check (true);

create policy "activities_update_seeded" on public.activities
  for update using (true);

-- Add comments explaining these policies
comment on policy "activities_insert_seeded" on public.activities is
  'Allows authenticated users to insert seeded activities. In production, consider restricting this to service role only.';

comment on policy "activities_update_seeded" on public.activities is
  'Allows authenticated users to update seeded activities. In production, consider restricting this to service role only.';

-- 2. Ensure activity_runs table has proper policies
-- These should already exist from migration 00001, but let's verify/update them
drop policy if exists "runs_select_own" on public.activity_runs;
drop policy if exists "runs_insert_own" on public.activity_runs;
drop policy if exists "runs_update_own" on public.activity_runs;

create policy "runs_select_own" on public.activity_runs
  for select using (auth.uid() = user_id);

create policy "runs_insert_own" on public.activity_runs
  for insert with check (auth.uid() = user_id);

create policy "runs_update_own" on public.activity_runs
  for update using (auth.uid() = user_id);

-- 3. Add index on activity_runs for better performance
create index if not exists idx_activity_runs_user_activity
  on public.activity_runs(user_id, activity_id, completed_at);

-- 4. Add helpful comments
comment on table public.activities is
  'Catalog of available activities (quizzes, games). Seeded by app on startup.';

comment on table public.activity_runs is
  'Tracks user completion of activities. INSERT creates run, UPDATE completes it. Trigger maintains discovery_progress.';
