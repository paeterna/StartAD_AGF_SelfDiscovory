# School Integration Migration Guide

## Quick Start

### Step 1: Apply Migrations

```bash
# Navigate to your project
cd /Users/omar/development/StartAD_AGF_SelfDiscovory

# Push migrations to Supabase
supabase db push
```

This will apply both migrations:
- `00006_school_integration.sql` - Creates schema and RLS policies
- `00007_school_seed_data.sql` - Seeds 3 demo schools

### Step 2: Create School Admin User

#### Via Supabase Dashboard

1. Go to: https://bklsuvhswylxbjpcpasw.supabase.co/project/_/auth/users
2. Click "Add user" → "Create new user"
3. Fill in:
   - Email: `admin@adis.ae`
   - Password: (choose a secure password)
   - Auto Confirm User: ✅ (checked)
4. Click "Create user"
5. **Copy the User ID** (you'll need it in the next step)

#### Set Role and Mapping

Open SQL Editor in Supabase Dashboard and run:

```sql
-- Replace <USER_ID> with the actual user ID from step 5 above
DO $$
DECLARE
  admin_user_id uuid := '<USER_ID>'; -- e.g., '123e4567-e89b-12d3-a456-426614174000'
  school_id_adis uuid := '550e8400-e29b-41d4-a716-446655440001';
BEGIN
  -- Set user role to school_admin
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{role}',
    '"school_admin"'
  )
  WHERE id = admin_user_id;

  -- Create school admin mapping
  INSERT INTO public.school_admins (user_id, school_id)
  VALUES (admin_user_id, school_id_adis)
  ON CONFLICT (user_id) DO NOTHING;

  RAISE NOTICE 'School admin created successfully!';
END $$;
```

### Step 3: Assign Students to School (Optional - for testing)

```sql
-- Assign 5 random students to ADIS for testing
UPDATE public.profiles
SET school_id = '550e8400-e29b-41d4-a716-446655440001'
WHERE id IN (
  SELECT id FROM public.profiles
  WHERE school_id IS NULL
  ORDER BY RANDOM()
  LIMIT 5
);
```

### Step 4: Test School Login

1. Navigate to: `http://localhost:PORT/auth/school` (or your deployed URL)
2. Login with:
   - Email: `admin@adis.ae`
   - Password: (the password you set)
3. You should be redirected to `/school/dashboard`

## Verification Queries

### Check Schools

```sql
SELECT * FROM public.schools ORDER BY name;
```

Expected: 3 schools (ADIS, DAA, SIS)

### Check School Admins

```sql
SELECT
  sa.user_id,
  s.name as school_name,
  u.email,
  u.raw_user_meta_data->>'role' as role
FROM public.school_admins sa
JOIN public.schools s ON s.id = sa.school_id
JOIN auth.users u ON u.id = sa.user_id;
```

Expected: At least 1 admin with role = 'school_admin'

### Check Students per School

```sql
SELECT
  s.name as school_name,
  s.code,
  COUNT(p.id) as student_count
FROM public.schools s
LEFT JOIN public.profiles p ON p.school_id = s.id
GROUP BY s.id, s.name, s.code
ORDER BY student_count DESC;
```

### Test KPIs Function

```sql
-- Get KPIs for ADIS
SELECT * FROM public.get_school_kpis('550e8400-e29b-41d4-a716-446655440001');
```

Expected output:
```
total_students | avg_profile_completion | avg_match_confidence | top_career_cluster
---------------|------------------------|---------------------|-------------------
5              | 34.5                   | 0.65                | Technology
```

### Test Top Students Function

```sql
-- Get top 5 students for ADIS
SELECT * FROM public.get_school_top_students('550e8400-e29b-41d4-a716-446655440001', 5);
```

## Common Issues

### Issue: "relation public.schools does not exist"

**Cause**: Migration 00006 failed before creating the schools table.

**Fix**: Check the error in migration 00006 and fix it, then re-run `supabase db push`.

### Issue: "column p.email does not exist"

**Cause**: Old version of migration trying to access email from profiles table.

**Fix**: ✅ Already fixed in the updated migration. Email now comes from `auth.users` table.

### Issue: "permission denied for function get_school_kpis"

**Cause**: RLS policy preventing access or user not authenticated.

**Fix**: Ensure you're logged in as a school admin user.

### Issue: Dashboard shows 0 students

**Cause**: No students assigned to the school yet.

**Fix**: Run the "Assign Students to School" query from Step 3.

## Creating Additional School Admins

For the other demo schools (DAA, SIS):

```sql
-- After creating auth users via Dashboard, run this for each:

DO $$
DECLARE
  admin_user_id uuid := '<USER_ID_FOR_DAA_ADMIN>';
  school_id_daa uuid := '550e8400-e29b-41d4-a716-446655440002';
BEGIN
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{role}',
    '"school_admin"'
  )
  WHERE id = admin_user_id;

  INSERT INTO public.school_admins (user_id, school_id)
  VALUES (admin_user_id, school_id_daa)
  ON CONFLICT (user_id) DO NOTHING;
END $$;
```

## Security Testing

### Test 1: School Isolation

Login as ADIS admin and try to access DAA's data:

```sql
-- Should return empty or error
SELECT * FROM public.get_school_kpis('550e8400-e29b-41d4-a716-446655440002');
```

Expected: Empty result or RLS error (data should be filtered by RLS policies).

### Test 2: Student Cannot Access School Functions

Login as a regular student and try:

```sql
SELECT * FROM public.get_school_kpis('550e8400-e29b-41d4-a716-446655440001');
```

Expected: Permission denied or empty result.

### Test 3: School Admin Cannot Modify Student Data

Login as school admin and try:

```sql
UPDATE public.profiles
SET display_name = 'Hacked'
WHERE school_id = '550e8400-e29b-41d4-a716-446655440001';
```

Expected: RLS policy violation (admins can only READ, not WRITE).

## Next Steps

After successful migration:

1. ✅ Apply migrations
2. ✅ Create school admin user
3. ✅ Assign test students to school
4. ⏳ Update Flutter app router (add school routes)
5. ⏳ Update student signup with school selector
6. ⏳ Test school dashboard UI
7. ⏳ Create student detail page

## Rollback (If Needed)

If you need to rollback the migrations:

```sql
-- Drop school-related tables
DROP TABLE IF EXISTS public.school_admins CASCADE;
DROP TABLE IF EXISTS public.schools CASCADE;

-- Remove school_id from profiles
ALTER TABLE public.profiles DROP COLUMN IF EXISTS school_id;

-- Drop functions
DROP FUNCTION IF EXISTS public.get_school_kpis(uuid);
DROP FUNCTION IF EXISTS public.get_school_top_students(uuid, int);
DROP FUNCTION IF EXISTS public.get_school_career_distribution(uuid);
DROP FUNCTION IF EXISTS public.get_school_students(uuid, text, int, int);

-- Drop view
DROP VIEW IF EXISTS public.v_school_feature_means;
```

---

**Ready to apply migrations!** 🚀

Run `supabase db push` to get started.
