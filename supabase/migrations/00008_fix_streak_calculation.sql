-- =====================================================
-- Fix Streak Calculation
-- Migration 00008
-- =====================================================

-- Improve the streak calculation logic to be more explicit and handle edge cases
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

  -- streak logic (improved)
  if v_last is null then
    -- First activity ever
    v_streak := 1;
  elsif v_last = v_today - interval '1 day' then
    -- Activity yesterday, continue streak
    v_streak := v_streak + 1;
  elsif v_last = v_today then
    -- Same day, keep current streak (don't increment)
    v_streak := coalesce(v_streak, 1);
  else
    -- Gap in activity, reset streak
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
