-- Migration: Add grade column to profiles
-- Description: Add grade field to track student's current grade (9-12)
-- Created: 2025-10-19

-- Add grade column to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS grade INTEGER;

-- Add check constraint to ensure grade is between 9 and 12
ALTER TABLE public.profiles
ADD CONSTRAINT profiles_grade_check
CHECK (grade IS NULL OR (grade >= 9 AND grade <= 12));

-- Add comment for documentation
COMMENT ON COLUMN public.profiles.grade IS 'Student grade level (9-12). NULL for users who have not specified their grade yet.';

-- Create index for grade queries (optional but useful for analytics)
CREATE INDEX IF NOT EXISTS idx_profiles_grade
ON public.profiles(grade)
WHERE grade IS NOT NULL;
