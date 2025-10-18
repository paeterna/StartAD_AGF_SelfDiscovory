-- =====================================================
-- Career Roadmaps System
-- Stores AI-generated roadmaps for any career
-- =====================================================

-- 1) User roadmaps table - stores generated roadmaps per user
CREATE TABLE IF NOT EXISTS public.user_career_roadmaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  career_id UUID NOT NULL REFERENCES public.careers(id) ON DELETE CASCADE,
  career_title TEXT NOT NULL,
  description TEXT NOT NULL,
  estimated_duration TEXT NOT NULL,
  salary_range TEXT NOT NULL,
  icon TEXT DEFAULT '💼',
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, career_id)
);

-- 2) Roadmap phases table
CREATE TABLE IF NOT EXISTS public.user_roadmap_phases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  roadmap_id UUID NOT NULL REFERENCES public.user_career_roadmaps(id) ON DELETE CASCADE,
  phase_order INT NOT NULL,
  phase_type TEXT NOT NULL CHECK (phase_type IN ('school', 'university', 'skills', 'career')),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  icon TEXT NOT NULL,
  duration TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(roadmap_id, phase_order)
);

-- 3) Roadmap steps table
CREATE TABLE IF NOT EXISTS public.user_roadmap_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phase_id UUID NOT NULL REFERENCES public.user_roadmap_phases(id) ON DELETE CASCADE,
  step_order INT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  details TEXT[] NOT NULL DEFAULT '{}',
  resources TEXT[] NOT NULL DEFAULT '{}',
  tip TEXT,
  is_optional BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(phase_id, step_order)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_roadmaps_user ON public.user_career_roadmaps(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roadmaps_career ON public.user_career_roadmaps(career_id);
CREATE INDEX IF NOT EXISTS idx_user_roadmap_phases_roadmap ON public.user_roadmap_phases(roadmap_id);
CREATE INDEX IF NOT EXISTS idx_user_roadmap_phases_order ON public.user_roadmap_phases(roadmap_id, phase_order);
CREATE INDEX IF NOT EXISTS idx_user_roadmap_steps_phase ON public.user_roadmap_steps(phase_id);
CREATE INDEX IF NOT EXISTS idx_user_roadmap_steps_order ON public.user_roadmap_steps(phase_id, step_order);

-- RLS Policies
ALTER TABLE public.user_career_roadmaps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roadmap_phases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roadmap_steps ENABLE ROW LEVEL SECURITY;

-- Users can only access their own roadmaps
DROP POLICY IF EXISTS "users_own_roadmaps" ON public.user_career_roadmaps;
CREATE POLICY "users_own_roadmaps" ON public.user_career_roadmaps
  FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "users_own_phases" ON public.user_roadmap_phases;
CREATE POLICY "users_own_phases" ON public.user_roadmap_phases
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.user_career_roadmaps
      WHERE id = roadmap_id AND user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "users_own_steps" ON public.user_roadmap_steps;
CREATE POLICY "users_own_steps" ON public.user_roadmap_steps
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.user_roadmap_phases p
      JOIN public.user_career_roadmaps r ON r.id = p.roadmap_id
      WHERE p.id = phase_id AND r.user_id = auth.uid()
    )
  );

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION public.fn_update_roadmap_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_user_roadmaps_timestamp ON public.user_career_roadmaps;
CREATE TRIGGER trg_update_user_roadmaps_timestamp
  BEFORE UPDATE ON public.user_career_roadmaps
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_update_roadmap_timestamp();

-- Helper function to get complete roadmap for a user and career
CREATE OR REPLACE FUNCTION public.get_user_career_roadmap(p_user_id UUID, p_career_title TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_roadmap JSONB;
BEGIN
  SELECT jsonb_build_object(
    'id', r.id,
    'career_title', r.career_title,
    'description', r.description,
    'estimated_duration', r.estimated_duration,
    'salary_range', r.salary_range,
    'icon', r.icon,
    'generated_at', r.generated_at,
    'phases', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', p.id,
          'phase_type', p.phase_type,
          'title', p.title,
          'subtitle', p.subtitle,
          'icon', p.icon,
          'duration', p.duration,
          'steps', (
            SELECT jsonb_agg(
              jsonb_build_object(
                'title', s.title,
                'description', s.description,
                'details', s.details,
                'resources', s.resources,
                'tip', s.tip,
                'is_optional', s.is_optional
              ) ORDER BY s.step_order
            )
            FROM public.user_roadmap_steps s
            WHERE s.phase_id = p.id
          )
        ) ORDER BY p.phase_order
      )
      FROM public.user_roadmap_phases p
      WHERE p.roadmap_id = r.id
    )
  ) INTO v_roadmap
  FROM public.user_career_roadmaps r
  WHERE r.user_id = p_user_id AND r.career_title = p_career_title;

  RETURN v_roadmap;
END;
$$;

-- Helper function to check if user has roadmap for career
CREATE OR REPLACE FUNCTION public.has_roadmap_for_career(p_user_id UUID, p_career_title TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM public.user_career_roadmaps
    WHERE user_id = p_user_id AND career_title = p_career_title
  ) INTO v_exists;

  RETURN v_exists;
END;
$$;

-- Helper function to get complete roadmap by ID
CREATE OR REPLACE FUNCTION public.get_user_career_roadmap_by_id(p_roadmap_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_roadmap JSONB;
BEGIN
  SELECT jsonb_build_object(
    'id', r.id,
    'user_id', r.user_id,
    'career_id', r.career_id,
    'career_title', r.career_title,
    'description', r.description,
    'estimated_duration', r.estimated_duration,
    'salary_range', r.salary_range,
    'icon', r.icon,
    'generated_at', r.generated_at,
    'updated_at', r.updated_at,
    'phases', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', p.id,
          'phase_type', p.phase_type,
          'title', p.title,
          'subtitle', p.subtitle,
          'icon', p.icon,
          'duration', p.duration,
          'steps', (
            SELECT jsonb_agg(
              jsonb_build_object(
                'title', s.title,
                'description', s.description,
                'details', s.details,
                'resources', s.resources,
                'tip', s.tip,
                'is_optional', s.is_optional
              ) ORDER BY s.step_order
            )
            FROM public.user_roadmap_steps s
            WHERE s.phase_id = p.id
          )
        ) ORDER BY p.phase_order
      )
      FROM public.user_roadmap_phases p
      WHERE p.roadmap_id = r.id
    )
  ) INTO v_roadmap
  FROM public.user_career_roadmaps r
  WHERE r.id = p_roadmap_id;

  RETURN v_roadmap;
END;
$$;

-- Comments
COMMENT ON TABLE public.user_career_roadmaps IS 'Stores AI-generated career roadmaps for users';
COMMENT ON TABLE public.user_roadmap_phases IS 'Stores phases within user career roadmaps (School, University, Skills, Career)';
COMMENT ON TABLE public.user_roadmap_steps IS 'Stores individual steps within roadmap phases';
COMMENT ON FUNCTION public.get_user_career_roadmap IS 'Retrieves complete roadmap for a user and career as JSON';
COMMENT ON FUNCTION public.get_user_career_roadmap_by_id IS 'Retrieves complete roadmap by ID as JSON';
COMMENT ON FUNCTION public.has_roadmap_for_career IS 'Checks if user already has a roadmap for a career';
