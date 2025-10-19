-- Migration: Teen UX Gamification System
-- Description: Add XP, levels, streaks, badges, and remote config for teen-friendly UX
-- Created: 2025-10-19

-- ============================================================================
-- Remote Config Table
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.remote_config (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.remote_config IS 'Centralized remote configuration for themes, XP constants, feature flags, etc.';

-- Insert default configurations
INSERT INTO public.remote_config (key, value, description) VALUES
  -- XP calculation constants
  ('xp_constants', '{
    "base": 10,
    "k1": 2.0,
    "k2": 1.5,
    "k3": 1.5
  }'::jsonb, 'XP calculation: base + k1*Δcomposite + k2*Δattention + k3*Δmemory'),

  -- Copy tone mode
  ('copy_tone', '"friendly"'::jsonb, 'Microcopy tone: friendly, neutral, or coach'),

  -- Feature flags
  ('animations_enabled', 'true'::jsonb, 'Global animations toggle'),
  ('haptics_enabled', 'true'::jsonb, 'Haptic feedback toggle'),
  ('confetti_enabled', 'true'::jsonb, 'Confetti animations on achievements'),

  -- Cluster labels
  ('cluster_labels', '{
    "technology": {"name": "Technology", "emoji": "💻"},
    "healthcare": {"name": "Healthcare", "emoji": "🏥"},
    "business": {"name": "Business", "emoji": "💼"},
    "creative": {"name": "Creative", "emoji": "🎨"}
  }'::jsonb, 'Career cluster display names and emojis')
ON CONFLICT (key) DO NOTHING;

-- ============================================================================
-- Gamification Profiles Table
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.gamification_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_xp INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 1,
  current_streak INTEGER NOT NULL DEFAULT 0,
  longest_streak INTEGER NOT NULL DEFAULT 0,
  last_activity_date DATE,
  theme_key TEXT DEFAULT 'neon_arcade',
  avatar_config JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.gamification_profiles IS 'User XP, levels, streaks, theme preferences, and avatar config';

-- Index for XP leaderboards
CREATE INDEX IF NOT EXISTS idx_gamification_total_xp ON public.gamification_profiles(total_xp DESC);

-- ============================================================================
-- Badges Table
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.badges (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  badge_key TEXT NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb,
  UNIQUE(user_id, badge_key)
);

COMMENT ON TABLE public.badges IS 'User earned badges and achievements';

CREATE INDEX IF NOT EXISTS idx_badges_user ON public.badges(user_id);
CREATE INDEX IF NOT EXISTS idx_badges_earned ON public.badges(earned_at DESC);

-- ============================================================================
-- Events Table (Telemetry & Analytics)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.events (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  event_kind TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.events IS 'Telemetry events for analytics and A/B testing';

CREATE INDEX IF NOT EXISTS idx_events_user ON public.events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_kind ON public.events(event_kind);
CREATE INDEX IF NOT EXISTS idx_events_created ON public.events(created_at DESC);

-- ============================================================================
-- Experiments Table (A/B Testing)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.experiments (
  key TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  bucket TEXT NOT NULL,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (key, user_id)
);

COMMENT ON TABLE public.experiments IS 'A/B test experiment bucket assignments';

CREATE INDEX IF NOT EXISTS idx_experiments_user ON public.experiments(user_id);

-- ============================================================================
-- Add theme_key to profiles if not exists
-- ============================================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'theme_key'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN theme_key TEXT DEFAULT 'neon_arcade';
  END IF;
END $$;

-- ============================================================================
-- Row Level Security (RLS)
-- ============================================================================

-- Remote Config: Read-only for authenticated users
ALTER TABLE public.remote_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read remote config"
  ON public.remote_config FOR SELECT
  TO authenticated
  USING (true);

-- Gamification Profiles: Users can only access their own
ALTER TABLE public.gamification_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own gamification profile"
  ON public.gamification_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own gamification profile"
  ON public.gamification_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own gamification profile"
  ON public.gamification_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Badges: Users can only access their own
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own badges"
  ON public.badges FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own badges"
  ON public.badges FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Events: Users can only insert and view their own
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own events"
  ON public.events FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own events"
  ON public.events FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Experiments: Users can only view their own assignments
ALTER TABLE public.experiments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own experiment assignments"
  ON public.experiments FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- ============================================================================
-- Functions
-- ============================================================================

-- Function to auto-create gamification profile on user creation
CREATE OR REPLACE FUNCTION public.handle_new_user_gamification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.gamification_profiles (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created_gamification ON auth.users;
CREATE TRIGGER on_auth_user_created_gamification
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_gamification();

-- Function to calculate level from XP
CREATE OR REPLACE FUNCTION public.calculate_level(xp INTEGER)
RETURNS INTEGER AS $$
BEGIN
  RETURN FLOOR(POW(xp::FLOAT / 100.0, 0.75))::INTEGER;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to update streak
CREATE OR REPLACE FUNCTION public.update_streak(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  v_last_activity_date DATE;
  v_current_streak INTEGER;
  v_longest_streak INTEGER;
  v_today DATE := CURRENT_DATE;
BEGIN
  SELECT last_activity_date, current_streak, longest_streak
  INTO v_last_activity_date, v_current_streak, v_longest_streak
  FROM public.gamification_profiles
  WHERE user_id = p_user_id;

  -- If no activity today yet
  IF v_last_activity_date IS NULL OR v_last_activity_date < v_today THEN
    -- Check if yesterday or earlier
    IF v_last_activity_date IS NULL OR v_last_activity_date = v_today - 1 THEN
      -- Continue streak
      v_current_streak := COALESCE(v_current_streak, 0) + 1;
    ELSE
      -- Streak broken, reset to 1
      v_current_streak := 1;
    END IF;

    -- Update longest streak if needed
    IF v_current_streak > COALESCE(v_longest_streak, 0) THEN
      v_longest_streak := v_current_streak;
    END IF;

    -- Update profile
    UPDATE public.gamification_profiles
    SET
      current_streak = v_current_streak,
      longest_streak = v_longest_streak,
      last_activity_date = v_today,
      updated_at = NOW()
    WHERE user_id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.calculate_level TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_streak TO authenticated;
