# School Admin Setup Guide

## Overview

To use the school admin login feature, you need to:
1. Create a user in Supabase Auth
2. Set their user metadata with `role: "school_admin"`
3. Link them to a school in the `school_admins` table

## Step-by-Step Instructions

### Option 1: Using Supabase Dashboard (Recommended for Demo)

1. **Go to Supabase Dashboard**
   - Navigate to your project at https://supabase.com/dashboard
   - Go to Authentication → Users

2. **Create New User**
   - Click "Add user" → "Create new user"
   - Email: `admin@adis.ae`
   - Password: Choose a secure password (e.g., `AdminADIS2024!`)
   - ✅ Confirm email automatically
   - Click "Create user"

3. **Copy the User ID**
   - After creation, click on the user
   - Copy their User ID (UUID format)

4. **Set User Metadata**
   - Go to SQL Editor in Supabase Dashboard
   - Run this query (replace `<USER_ID>` with the copied UUID):

   ```sql
   -- Set the user as school admin
   update auth.users
   set raw_user_meta_data = jsonb_set(
     coalesce(raw_user_meta_data, '{}'::jsonb),
     '{role}',
     '"school_admin"'
   )
   where id = '<USER_ID>';
   ```

5. **Link to School**
   - Still in SQL Editor, run this query:

   ```sql
   -- Get the ADIS school ID
   select id, name from public.schools where code = 'ADIS';

   -- Link user to ADIS school (replace <USER_ID> with actual UUID)
   insert into public.school_admins (user_id, school_id)
   values (
     '<USER_ID>',
     '550e8400-e29b-41d4-a716-446655440001'  -- ADIS school ID
   );
   ```

6. **Test Login**
   - Go to your app at `/auth/school`
   - Email: `admin@adis.ae`
   - Password: (the password you set)
   - Click "Sign In"

### Option 2: Using Supabase API (Programmatic)

```javascript
// 1. Create user
const { data: authData, error: authError } = await supabase.auth.admin.createUser({
  email: 'admin@adis.ae',
  password: 'AdminADIS2024!',
  email_confirm: true,
  user_metadata: {
    role: 'school_admin',
  },
});

if (authError) {
  console.error('Error creating user:', authError);
} else {
  const userId = authData.user.id;

  // 2. Link to school
  const { error: linkError } = await supabase
    .from('school_admins')
    .insert({
      user_id: userId,
      school_id: '550e8400-e29b-41d4-a716-446655440001', // ADIS
    });

  if (linkError) {
    console.error('Error linking to school:', linkError);
  } else {
    console.log('School admin created successfully!');
  }
}
```

## Creating Multiple School Admins

For the other demo schools:

```sql
-- DAA School Admin
-- Email: admin@daa.ae
-- School ID: 550e8400-e29b-41d4-a716-446655440002

update auth.users
set raw_user_meta_data = jsonb_set(
  coalesce(raw_user_meta_data, '{}'::jsonb),
  '{role}',
  '"school_admin"'
)
where email = 'admin@daa.ae';

insert into public.school_admins (user_id, school_id)
select id, '550e8400-e29b-41d4-a716-446655440002'
from auth.users
where email = 'admin@daa.ae';

-- SIS School Admin
-- Email: admin@sis.ae
-- School ID: 550e8400-e29b-41d4-a716-446655440003

update auth.users
set raw_user_meta_data = jsonb_set(
  coalesce(raw_user_meta_data, '{}'::jsonb),
  '{role}',
  '"school_admin"'
)
where email = 'admin@sis.ae';

insert into public.school_admins (user_id, school_id)
select id, '550e8400-e29b-41d4-a716-446655440003'
from auth.users
where email = 'admin@sis.ae';
```

## Verification

Check if the setup worked:

```sql
-- List all school admins
select
  sa.user_id,
  u.email,
  s.name as school_name,
  s.code as school_code,
  u.raw_user_meta_data->>'role' as role
from public.school_admins sa
join auth.users u on u.id = sa.user_id
join public.schools s on s.id = sa.school_id
order by s.name;
```

Expected output:
```
user_id                              | email           | school_name                        | school_code | role
-------------------------------------|-----------------|------------------------------------|--------------|--------------
<uuid>                               | admin@adis.ae   | Abu Dhabi International School     | ADIS         | school_admin
<uuid>                               | admin@daa.ae    | Dubai American Academy             | DAA          | school_admin
<uuid>                               | admin@sis.ae    | Sharjah International School       | SIS          | school_admin
```

## Troubleshooting

### "Invalid login credentials"
- Make sure the user exists in Supabase Auth
- Verify the password is correct
- Check email is confirmed (in Auth → Users)

### "This account is not authorized as a school administrator"
- Check user metadata has `role: "school_admin"`:
  ```sql
  select email, raw_user_meta_data->>'role' as role
  from auth.users
  where email = 'admin@adis.ae';
  ```
- Make sure user is linked in school_admins table:
  ```sql
  select * from public.school_admins
  where user_id = (select id from auth.users where email = 'admin@adis.ae');
  ```

### Cannot access school dashboard
- Check RLS policies are enabled
- Verify user has a school_id in school_admins table
- Check browser console for errors

## Testing Data

To add test students to schools for demo:

```sql
-- Assign 10 random students to ADIS
update public.profiles
set school_id = '550e8400-e29b-41d4-a716-446655440001'
where id in (
  select id from public.profiles
  where school_id is null
  order by random()
  limit 10
);

-- Assign 10 random students to DAA
update public.profiles
set school_id = '550e8400-e29b-41d4-a716-446655440002'
where id in (
  select id from public.profiles
  where school_id is null
  order by random()
  limit 10
);
```

## Security Notes

- School admins can **only** see their own school's data (enforced by RLS)
- Students cannot access school routes
- School admins cannot access student app routes
- All access is validated at the database level with Row Level Security

## Next Steps

After setting up the school admin:

1. Login at `/auth/school` with your credentials
2. You'll be redirected to `/school/dashboard`
3. View school KPIs and student list
4. Click on students to see their details
5. View cohort analytics and feature averages

## Demo Credentials (After Setup)

| School | Email | Password (example) |
|--------|-------|--------------------|
| ADIS | admin@adis.ae | AdminADIS2024! |
| DAA | admin@daa.ae | AdminDAA2024! |
| SIS | admin@sis.ae | AdminSIS2024! |

**Note:** These are example credentials. Use strong, unique passwords in production!
