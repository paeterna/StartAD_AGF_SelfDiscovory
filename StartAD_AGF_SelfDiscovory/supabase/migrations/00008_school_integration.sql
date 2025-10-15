-- =====================================================
-- School Integration (Multi-tenant Schools)
-- Migration 00006
-- =====================================================
--
-- This migration adds school multi-tenancy support:
-- - Schools table (tenant entities)
-- - School admins mapping
-- - Link profiles to schools
-- - RLS policies for school data access
-- - Helper views and functions for school dashboards

-- =====================================================
-- 1) Schools Table (Tenant Entities)
-- =====================================================

create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text unique, -- Optional short code for easy lookup
  country text,
  locale locale_t default 'en',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_schools_active on public.schools(active);
create index if not exists idx_schools_code on public.schools(code) where code is not null;
create index if not exists idx_schools_name on public.schools using gin(to_tsvector('english', name));

comment on table public.schools is 'School tenant entities for multi-tenant access';
comment on column public.schools.code is 'Short code for easy school lookup (e.g., "ADHS")';
comment on column public.schools.active is 'Whether school is currently active (for soft delete)';

-- =====================================================
-- 2) Link Profiles to Schools
-- =====================================================

alter table public.profiles
  add column if not exists school_id uuid references public.schools(id) on delete set null;

create index if not exists idx_profiles_school on public.profiles(school_id);

comment on column public.profiles.school_id is 'School the student belongs to (nullable for independent users)';

-- =====================================================
-- 3) School Admins Mapping
-- =====================================================

create table if not exists public.school_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  school_id uuid not null references public.schools(id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists idx_school_admins_school on public.school_admins(school_id);
create index if not exists idx_school_admins_user on public.school_admins(user_id);

comment on table public.school_admins is 'Maps school admin users to their school';

-- =====================================================
-- 4) RLS Policies
-- =====================================================

-- Enable RLS on new tables
alter table public.schools enable row level security;
alter table public.school_admins enable row level security;

-- Schools table: Read allowed to school admins for their own school
drop policy if exists "schools_select_own" on public.schools;
create policy "schools_select_own"
on public.schools for select
using (
  exists (
    select 1 from public.school_admins sa
    where sa.school_id = schools.id
      and sa.user_id = auth.uid()
  )
);

-- Schools table: Allow students to read their own school
drop policy if exists "schools_select_student_own" on public.schools;
create policy "schools_select_student_own"
on public.schools for select
using (
  exists (
    select 1 from public.profiles p
    where p.school_id = schools.id
      and p.id = auth.uid()
  )
);

-- Schools table: Block client writes (managed by ops/service role)
drop policy if exists "schools_no_write_client" on public.schools;
create policy "schools_no_write_client" on public.schools
for all using (false) with check (false);

-- School admins mapping: Read self
drop policy if exists "school_admins_select_self" on public.school_admins;
create policy "school_admins_select_self"
on public.school_admins for select
using (user_id = auth.uid());

-- School admins mapping: Block writes from client
drop policy if exists "school_admins_no_write_client" on public.school_admins;
create policy "school_admins_no_write_client" on public.school_admins
for all using (false) with check (false);

-- Profiles: Allow school admin read by school
drop policy if exists "profiles_select_by_school_admin" on public.profiles;
create policy "profiles_select_by_school_admin"
on public.profiles for select
using (
  exists (
    select 1 from public.school_admins sa
    where sa.user_id = auth.uid()
      and sa.school_id = profiles.school_id
  )
);

-- Assessments: Allow school admin read within their school
drop policy if exists "assessments_select_by_school" on public.assessments;
create policy "assessments_select_by_school"
on public.assessments for select
using (
  exists (
    select 1 from public.profiles p
    join public.school_admins sa on sa.school_id = p.school_id
    where p.id = assessments.user_id
      and sa.user_id = auth.uid()
  )
);

-- Activity runs: Allow school admin read within their school
drop policy if exists "activity_runs_select_by_school" on public.activity_runs;
create policy "activity_runs_select_by_school"
on public.activity_runs for select
using (
  exists (
    select 1 from public.profiles p
    join public.school_admins sa on sa.school_id = p.school_id
    where p.id = activity_runs.user_id
      and sa.user_id = auth.uid()
  )
);

-- User feature scores: Allow school admin read within their school
drop policy if exists "user_feature_scores_select_by_school" on public.user_feature_scores;
create policy "user_feature_scores_select_by_school"
on public.user_feature_scores for select
using (
  exists (
    select 1 from public.profiles p
    join public.school_admins sa on sa.school_id = p.school_id
    where p.id = user_feature_scores.user_id
      and sa.user_id = auth.uid()
  )
);

-- User career matches: Allow school admin read within their school
drop policy if exists "user_career_matches_select_by_school" on public.user_career_matches;
create policy "user_career_matches_select_by_school"
on public.user_career_matches for select
using (
  exists (
    select 1 from public.profiles p
    join public.school_admins sa on sa.school_id = p.school_id
    where p.id = user_career_matches.user_id
      and sa.user_id = auth.uid()
  )
);

-- Discovery progress: Allow school admin read within their school
drop policy if exists "discovery_progress_select_by_school" on public.discovery_progress;
create policy "discovery_progress_select_by_school"
on public.discovery_progress for select
using (
  exists (
    select 1 from public.profiles p
    join public.school_admins sa on sa.school_id = p.school_id
    where p.id = discovery_progress.user_id
      and sa.user_id = auth.uid()
  )
);

-- =====================================================
-- 5) Helper Views for School Dashboard
-- =====================================================

-- Average trait vector for a school's cohort (ordered by features.id)
create or replace view public.v_school_feature_means as
select
  p.school_id,
  f.id as feature_id,
  f.key as feature_key,
  f.family as feature_family,
  avg(ufs.score_mean) as avg_score
from public.profiles p
join public.user_feature_scores ufs on ufs.user_id = p.id
join public.features f on f.key = ufs.feature_key
where p.school_id is not null
group by p.school_id, f.id, f.key, f.family
order by p.school_id, f.id;

comment on view public.v_school_feature_means is 'Average feature scores per school for cohort analytics';

-- =====================================================
-- 6) Helper Functions for School Dashboard
-- =====================================================

-- Get school KPIs (dashboard metrics)
create or replace function public.get_school_kpis(p_school_id uuid)
returns table(
  total_students bigint,
  avg_profile_completion float8,
  avg_match_confidence float8,
  top_career_cluster text
)
language sql
stable
security definer
as $$
  with students as (
    select id from public.profiles where school_id = p_school_id
  ),
  k_total as (
    select count(*) as total_students from students
  ),
  k_completion as (
    select avg(public.get_profile_completeness(s.id)) as avg_profile_completion
    from students s
  ),
  k_confidence as (
    select avg(ucm.confidence) as avg_match_confidence
    from students s
    left join public.user_career_matches ucm on ucm.user_id = s.id
  ),
  k_cluster as (
    select c.cluster as top_career_cluster
    from students s
    join public.user_career_matches ucm on ucm.user_id = s.id
    join public.careers c on c.id = ucm.career_id
    where c.cluster is not null
    group by c.cluster
    order by avg(ucm.similarity) desc, count(*) desc
    limit 1
  )
  select
    k_total.total_students,
    coalesce(k_completion.avg_profile_completion, 0.0),
    coalesce(k_confidence.avg_match_confidence, 0.0),
    (select top_career_cluster from k_cluster)
  from k_total
  cross join k_completion
  cross join k_confidence;
$$;

grant execute on function public.get_school_kpis(uuid) to authenticated;

comment on function public.get_school_kpis is 'Returns KPI metrics for school dashboard';

-- Get top students for a school
create or replace function public.get_school_top_students(
  p_school_id uuid,
  p_limit int default 5
)
returns table(
  user_id uuid,
  display_name text,
  email text,
  profile_completion float8,
  overall_strength float8,
  last_activity timestamptz
)
language sql
stable
security definer
as $$
  with student_scores as (
    select
      p.id as user_id,
      p.display_name,
      u.email,
      public.get_profile_completeness(p.id) as profile_completion,
      coalesce(avg(ufs.score_mean), 50.0) as overall_strength,
      (
        select max(ar.completed_at)
        from public.activity_runs ar
        where ar.user_id = p.id
      ) as last_activity
    from public.profiles p
    join auth.users u on u.id = p.id
    left join public.user_feature_scores ufs on ufs.user_id = p.id
    where p.school_id = p_school_id
    group by p.id, p.display_name, u.email
  )
  select *
  from student_scores
  order by overall_strength desc, profile_completion desc
  limit p_limit;
$$;

grant execute on function public.get_school_top_students(uuid, int) to authenticated;

comment on function public.get_school_top_students is 'Returns top performing students for a school';

-- Get career distribution for a school
create or replace function public.get_school_career_distribution(p_school_id uuid)
returns table(
  cluster text,
  career_count bigint,
  avg_similarity float8,
  student_count bigint
)
language sql
stable
security definer
as $$
  select
    c.cluster,
    count(distinct c.id) as career_count,
    avg(ucm.similarity) as avg_similarity,
    count(distinct ucm.user_id) as student_count
  from public.profiles p
  join public.user_career_matches ucm on ucm.user_id = p.id
  join public.careers c on c.id = ucm.career_id
  where p.school_id = p_school_id
    and c.cluster is not null
  group by c.cluster
  order by student_count desc, avg_similarity desc;
$$;

grant execute on function public.get_school_career_distribution(uuid) to authenticated;

comment on function public.get_school_career_distribution is 'Returns career cluster distribution for school cohort';

-- Get school students list with filters
create or replace function public.get_school_students(
  p_school_id uuid,
  p_search text default null,
  p_limit int default 50,
  p_offset int default 0
)
returns table(
  user_id uuid,
  display_name text,
  email text,
  profile_completion float8,
  discovery_percent int,
  last_activity timestamptz,
  top_career text
)
language sql
stable
security definer
as $$
  select
    p.id as user_id,
    p.display_name,
    u.email,
    public.get_profile_completeness(p.id) as profile_completion,
    coalesce(dp.percent, 0) as discovery_percent,
    (
      select max(ar.completed_at)
      from public.activity_runs ar
      where ar.user_id = p.id
    ) as last_activity,
    (
      select c.title
      from public.user_career_matches ucm
      join public.careers c on c.id = ucm.career_id
      where ucm.user_id = p.id
      order by ucm.similarity desc
      limit 1
    ) as top_career
  from public.profiles p
  join auth.users u on u.id = p.id
  left join public.discovery_progress dp on dp.user_id = p.id
  where p.school_id = p_school_id
    and (
      p_search is null
      or p.display_name ilike '%' || p_search || '%'
      or u.email ilike '%' || p_search || '%'
    )
  order by p.display_name
  limit p_limit
  offset p_offset;
$$;

grant execute on function public.get_school_students(uuid, text, int, int) to authenticated;

comment on function public.get_school_students is 'Returns paginated list of students for a school with search';

-- =====================================================
-- 7) Updated Timestamp Trigger for Schools
-- =====================================================

create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists update_schools_updated_at on public.schools;
create trigger update_schools_updated_at
  before update on public.schools
  for each row
  execute function public.update_updated_at_column();

-- =====================================================
-- Migration Complete
-- =====================================================

-- Note: Run 00007_school_seed_data.sql separately to populate demo schools
