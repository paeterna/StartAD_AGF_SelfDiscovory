-- =====================================================
-- School Integration - Seed Data
-- Migration 00007
-- =====================================================
--
-- This migration populates demo schools and school admin mappings
-- Run this AFTER 00006_school_integration.sql

-- =====================================================
-- 1) Insert Demo Schools
-- =====================================================

insert into public.schools (id, name, code, country, locale, active) values
  (
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'Abu Dhabi International School',
    'ADIS',
    'UAE',
    'en',
    true
  ),
  (
    '550e8400-e29b-41d4-a716-446655440002'::uuid,
    'Dubai American Academy',
    'DAA',
    'UAE',
    'en',
    true
  ),
  (
    '550e8400-e29b-41d4-a716-446655440003'::uuid,
    'Sharjah International School',
    'SIS',
    'UAE',
    'en',
    true
  )
on conflict (id) do update
set
  name = excluded.name,
  code = excluded.code,
  country = excluded.country,
  locale = excluded.locale,
  active = excluded.active,
  updated_at = now();

-- =====================================================
-- 2) Create School Admin Users
-- =====================================================
--
-- NOTE: These users must be created through Supabase Auth first.
-- This migration assumes you will create them manually or via script.
--
-- For demo purposes, use these credentials:
--
-- School Admin 1 (ADIS):
-- Email: admin@adis.ae
-- Password: (set via Supabase Dashboard)
-- After creation, get user_id and insert into school_admins
--
-- School Admin 2 (DAA):
-- Email: admin@daa.ae
-- Password: (set via Supabase Dashboard)
--
-- School Admin 3 (SIS):
-- Email: admin@sis.ae
-- Password: (set via Supabase Dashboard)

-- =====================================================
-- 3) School Admin Mapping (Example)
-- =====================================================
--
-- After creating the auth users, insert mappings like this:
--
-- insert into public.school_admins (user_id, school_id) values
--   ('<admin1_user_id>', '550e8400-e29b-41d4-a716-446655440001'),
--   ('<admin2_user_id>', '550e8400-e29b-41d4-a716-446655440002'),
--   ('<admin3_user_id>', '550e8400-e29b-41d4-a716-446655440003');
--
-- Also set their metadata:
-- update auth.users
-- set raw_user_meta_data = jsonb_set(raw_user_meta_data, '{role}', '"school_admin"')
-- where id in ('<admin1_user_id>', '<admin2_user_id>', '<admin3_user_id>');

-- =====================================================
-- 4) Assign Some Students to Schools (Demo)
-- =====================================================
--
-- Update existing student profiles to belong to schools:
--
-- Example:
-- update public.profiles
-- set school_id = '550e8400-e29b-41d4-a716-446655440001'
-- where id in (
--   select id from public.profiles
--   where school_id is null
--   order by random()
--   limit 10
-- );

-- =====================================================
-- Helper SQL for Manual Setup
-- =====================================================

-- List all schools
-- select * from public.schools order by name;

-- Check school admins
-- select sa.*, s.name as school_name, u.email
-- from public.school_admins sa
-- join public.schools s on s.id = sa.school_id
-- join auth.users u on u.id = sa.user_id;

-- Count students per school
-- select s.name, count(p.id) as student_count
-- from public.schools s
-- left join public.profiles p on p.school_id = s.id
-- group by s.id, s.name
-- order by student_count desc;

-- =====================================================
-- Migration Complete
-- =====================================================
--
-- Next steps:
-- 1. Create school admin users via Supabase Dashboard or API
-- 2. Insert mappings into school_admins table
-- 3. Update student profiles to assign school_id
-- 4. Test school dashboard by logging in as school admin
