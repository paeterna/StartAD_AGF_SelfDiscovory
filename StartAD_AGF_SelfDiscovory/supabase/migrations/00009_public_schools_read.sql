-- Migration: Allow public read access to active schools for signup
-- This allows unauthenticated users to see the school dropdown during signup

-- Only proceed if schools table exists (created in migration 00006)
do $$
begin
  if exists (select from pg_tables where schemaname = 'public' and tablename = 'schools') then
    -- Drop existing restrictive policy
    drop policy if exists "schools_no_write_client" on public.schools;

    -- Allow public read of active schools (for signup dropdown)
    drop policy if exists "schools_select_public_active" on public.schools;
    create policy "schools_select_public_active"
    on public.schools for select
    using (active = true);

    -- Still block all writes from client (managed by ops/service role only)
    create policy "schools_no_write_client" on public.schools
    for insert with check (false);

    create policy "schools_no_update_client" on public.schools
    for update using (false) with check (false);

    create policy "schools_no_delete_client" on public.schools
    for delete using (false);
  end if;
end $$;
