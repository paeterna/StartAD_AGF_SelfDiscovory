-- Migration: Fix Gamification Profile Auto-Creation
-- Description: Update gamification trigger to integrate with existing profile system
-- Created: 2025-10-19

-- ============================================================================
-- Drop old trigger and function
-- ============================================================================
DROP TRIGGER IF EXISTS on_auth_user_created_gamification ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user_gamification();

-- ============================================================================
-- Update existing profile creation function to also create gamification profile
-- ============================================================================
CREATE OR REPLACE FUNCTION public.fn_create_profile_for_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Insert profile with RLS explicitly bypassed via security definer
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'name',
      NEW.raw_user_meta_data->>'full_name',
      SPLIT_PART(NEW.email, '@', 1)
    )
  )
  ON CONFLICT (id) DO NOTHING;

  -- Also create gamification profile
  INSERT INTO public.gamification_profiles (user_id, theme_key)
  VALUES (NEW.id, 'neon_arcade')
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't block user creation
    RAISE WARNING 'Could not create profile/gamification for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Update comment
COMMENT ON FUNCTION public.fn_create_profile_for_user() IS
  'Auto-creates user profile AND gamification profile on signup. Uses security definer safely with empty search_path.';

-- ============================================================================
-- Add policy to allow users to insert experiments (needed for A/B testing)
-- ============================================================================
DROP POLICY IF EXISTS "Users can insert own experiment assignments" ON public.experiments;
CREATE POLICY "Users can insert own experiment assignments"
  ON public.experiments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- Backfill: Create gamification profiles for existing users
-- ============================================================================
DO $$
DECLARE
  v_user_record RECORD;
BEGIN
  -- Create gamification profiles for any users who don't have one
  FOR v_user_record IN
    SELECT u.id
    FROM auth.users u
    LEFT JOIN public.gamification_profiles g ON u.id = g.user_id
    WHERE g.user_id IS NULL
  LOOP
    INSERT INTO public.gamification_profiles (user_id, theme_key)
    VALUES (v_user_record.id, 'neon_arcade')
    ON CONFLICT (user_id) DO NOTHING;
  END LOOP;

  RAISE NOTICE 'Gamification profile backfill complete';
END $$;
