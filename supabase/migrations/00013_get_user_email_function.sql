-- =====================================================
-- Get User Email Function
-- Migration 00013
-- =====================================================
--
-- This migration adds a helper function to retrieve user email
-- from auth.users table (which is normally inaccessible to clients)

-- Function to get user email by user ID
-- This is needed because auth.users table is not directly accessible
create or replace function public.get_user_email(p_user_id uuid)
returns text
language sql
stable
security definer -- Run with elevated privileges to access auth.users
as $$
  select email
  from auth.users
  where id = p_user_id;
$$;

grant execute on function public.get_user_email(uuid) to authenticated;

comment on function public.get_user_email is 'Returns email for a user ID from auth.users table';
