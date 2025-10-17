-- BEST FIX: Use Supabase's recommended approach
-- Temporarily disable RLS for the insert operation, then re-enable
-- This is the safest because it's explicit about what we're allowing

drop trigger if exists trg_create_profile_for_user on auth.users;
drop function if exists public.fn_create_profile_for_user();

-- Create function that handles profile creation
create or replace function public.fn_create_profile_for_user()
returns trigger
language plpgsql
security definer -- Required for auth.users triggers
set search_path = ''  -- Security: empty search path, use fully qualified names
as $$
begin
  -- Insert profile with RLS explicitly bypassed via security definer
  -- This is safe because:
  -- 1. Function only runs on auth.users insert (controlled by Supabase)
  -- 2. We're only inserting a row with id = new.id (the new user)
  -- 3. No user input is processed beyond metadata from Supabase auth
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'name',
      new.raw_user_meta_data->>'full_name',
      split_part(new.email, '@', 1)
    )
  )
  on conflict (id) do nothing;

  return new;
exception
  when others then
    -- Log error but don't block user creation
    raise warning 'Could not create profile for user %: %', new.id, sqlerrm;
    return new;
end;
$$;

-- Security: Revoke public access, only postgres and service role can execute
revoke all on function public.fn_create_profile_for_user() from public, anon, authenticated;
grant execute on function public.fn_create_profile_for_user() to postgres;

-- Add helpful comment
comment on function public.fn_create_profile_for_user() is
  'Auto-creates user profile on signup. Uses security definer safely with empty search_path.';

-- Create the trigger
create trigger trg_create_profile_for_user
  after insert on auth.users
  for each row
  execute function public.fn_create_profile_for_user();
