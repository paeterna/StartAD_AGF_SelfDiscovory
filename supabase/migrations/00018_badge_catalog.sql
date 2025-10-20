-- Migration: Badge Catalog
-- Description: Populate remote_config with badge definitions
-- Created: 2025-10-20

-- Insert badge catalog into remote_config
INSERT INTO public.remote_config (key, value, description) VALUES
  ('badge_catalog', '{
    "first_steps": {
      "key": "first_steps",
      "name": "First Steps",
      "description": "Complete your first activity",
      "icon_path": "🎯",
      "condition": "Complete any game or quiz",
      "tier": "bronze"
    },
    "perfect_score": {
      "key": "perfect_score",
      "name": "Perfect Score",
      "description": "Achieve 100% on any activity",
      "icon_path": "⭐",
      "condition": "Score 100% on a quiz or game",
      "tier": "gold"
    },
    "week_warrior": {
      "key": "week_warrior",
      "name": "Week Warrior",
      "description": "Maintain a 7-day streak",
      "icon_path": "🔥",
      "condition": "Active for 7 consecutive days",
      "tier": "silver"
    },
    "memory_master": {
      "key": "memory_master",
      "name": "Memory Master",
      "description": "Complete 10 memory match games",
      "icon_path": "🧠",
      "condition": "Complete 10 Memory Match games",
      "tier": "silver"
    },
    "speed_demon": {
      "key": "speed_demon",
      "name": "Speed Demon",
      "description": "Complete Memory Match in under 30 seconds",
      "icon_path": "⚡",
      "condition": "Finish Memory Match in under 30s",
      "tier": "gold"
    },
    "level_five": {
      "key": "level_five",
      "name": "Rising Star",
      "description": "Reach level 5",
      "icon_path": "🌟",
      "condition": "Achieve level 5",
      "tier": "bronze"
    },
    "level_ten": {
      "key": "level_ten",
      "name": "Expert",
      "description": "Reach level 10",
      "icon_path": "💎",
      "condition": "Achieve level 10",
      "tier": "silver"
    },
    "career_explorer": {
      "key": "career_explorer",
      "name": "Career Explorer",
      "description": "Generate your first career roadmap",
      "icon_path": "🗺️",
      "condition": "Generate 1 career roadmap",
      "tier": "bronze"
    },
    "roadmap_collector": {
      "key": "roadmap_collector",
      "name": "Roadmap Collector",
      "description": "Generate 5 different career roadmaps",
      "icon_path": "📚",
      "condition": "Generate 5 career roadmaps",
      "tier": "silver"
    },
    "theme_switcher": {
      "key": "theme_switcher",
      "name": "Style Icon",
      "description": "Try 3 different themes",
      "icon_path": "🎨",
      "condition": "Switch between 3 themes",
      "tier": "bronze"
    },
    "quiz_ace": {
      "key": "quiz_ace",
      "name": "Quiz Ace",
      "description": "Complete 5 quizzes",
      "icon_path": "📝",
      "condition": "Complete 5 quizzes",
      "tier": "silver"
    },
    "early_bird": {
      "key": "early_bird",
      "name": "Early Bird",
      "description": "Complete an activity before 9 AM",
      "icon_path": "🌅",
      "condition": "Activity completed before 9 AM",
      "tier": "bronze"
    },
    "night_owl": {
      "key": "night_owl",
      "name": "Night Owl",
      "description": "Complete an activity after 9 PM",
      "icon_path": "🦉",
      "condition": "Activity completed after 9 PM",
      "tier": "bronze"
    },
    "comeback_king": {
      "key": "comeback_king",
      "name": "Comeback King",
      "description": "Return after 7+ days away",
      "icon_path": "👑",
      "condition": "Return after week-long break",
      "tier": "silver"
    },
    "perfectionist": {
      "key": "perfectionist",
      "name": "Perfectionist",
      "description": "Score 90+ on 10 activities",
      "icon_path": "💯",
      "condition": "Score 90%+ on 10 activities",
      "tier": "gold"
    }
  }'::jsonb, 'Badge catalog with all available badges')
ON CONFLICT (key) DO UPDATE
  SET value = EXCLUDED.value,
      description = EXCLUDED.description,
      updated_at = NOW();
