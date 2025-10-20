# Phase 2.5 Badge System - Integration Guide

## 📋 Overview

This guide explains how the badge system is integrated into the app and how to verify everything is working correctly.

## 🗄️ Database Setup

### Step 1: Run the Migration

**File**: `supabase/migrations/00017_badge_catalog.sql`

Run this migration to populate the badge catalog in your remote_config table:

```bash
cd supabase
supabase migration up
```

Or manually execute the SQL in your Supabase dashboard.

This creates 15 badges with the following structure:
```json
{
  "first_steps": {
    "key": "first_steps",
    "name": "First Steps",
    "description": "Complete your first activity",
    "icon_path": "🎯",
    "condition": "Complete any game or quiz",
    "tier": "bronze"
  },
  ...
}
```

## 🎯 How to See Badges in the UI

### 1. Dashboard Badge Collection Button

**Location**: Dashboard app bar (top right)
**Icon**: Trophy (emoji_events)
**Action**: Opens the badge collection sheet

```dart
// In dashboard_page.dart line 56-60
IconButton(
  icon: const Icon(Icons.emoji_events),
  tooltip: 'Badges',
  onPressed: () => BadgesSheet.show(context),
),
```

**To test**:
1. Open the app
2. Navigate to Dashboard
3. Look for the trophy icon in the top right (between streak/level and settings)
4. Tap it to see your badge collection

### 2. Badge Collection Sheet

**File**: `lib/presentation/features/gamification/badges_sheet.dart`

Shows:
- Grid of all 15 badges
- Locked badges (greyed out with lock icon)
- Unlocked badges (colorful with tier border)
- Tap any badge to see details

**Features**:
- Sorted by: earned first, then by tier (platinum > gold > silver > bronze)
- Tier-based colors and glowing effects
- Shows earned count in header

### 3. Badge Unlock Modal

**File**: `lib/presentation/features/gamification/badge_unlock_modal.dart`

**When shown**:
- Automatically after earning a badge
- Animated reveal with confetti
- Shows badge icon, name, tier, description
- Auto-dismisses or tap "Awesome!" button

## 🎮 How Badges are Earned

### Memory Match Game

**File**: `lib/presentation/features/games/memory_match/memory_match_page.dart` (line 573)

**Flow**:
1. User completes game
2. `gamificationService.handleMemoryMatchCompletion()` is called
3. Awards XP based on performance
4. Checks for these badges:
   - **first_steps**: First time playing any game
   - **perfect_score**: 100% accuracy
   - **speed_demon**: Completed in under 30 seconds
   - **early_bird**: Played before 9 AM
   - **night_owl**: Played after 9 PM
   - **memory_master**: 10 Memory Match games completed
   - **level_five**: Reached level 5
   - **level_ten**: Reached level 10

5. Shows confetti + XP popover
6. Shows badge unlock modals for newly earned badges
7. Shows level-up celebration if leveled up

**Code**:
```dart
final gamificationService = ref.read(gamificationServiceProvider);
await gamificationService.handleMemoryMatchCompletion(
  context: context,
  score: scores.composite.round(),
  timeSeconds: telemetry.totalSeconds,
  scores: scores,
);
```

### Quizzes (Ready for integration)

**Service method**: `gamificationService.handleQuizCompletion()`

**Parameters**:
- `context`: BuildContext
- `totalQuestions`: int
- `correctAnswers`: int
- `timeSeconds`: int

**Badges that can be earned**:
- first_steps
- perfect_score
- quiz_ace (5 quizzes)
- perfectionist (90+ score on 10 activities)
- Time-based badges

**To integrate**: Call this method after quiz completion, similar to Memory Match.

### Roadmap Generation (Ready for integration)

**Service method**: `gamificationService.handleRoadmapGeneration()`

**Badges**:
- career_explorer (first roadmap)
- roadmap_collector (5 roadmaps)

**To integrate**: Call after successful roadmap creation.

### Streak Milestones

**Service method**: `gamificationService.handleDailyLogin()`

**Badges**:
- week_warrior (7-day streak)

**To integrate**: Call on app startup or first activity of the day.

## 🔌 Provider Architecture

### Main Providers

1. **gamificationServiceProvider**
   - Location: `lib/application/gamification/gamification_providers.dart:259`
   - Provides: `GamificationService` instance
   - Use: `ref.read(gamificationServiceProvider)`

2. **badgeCatalogProvider**
   - Location: `lib/presentation/features/gamification/badges_sheet.dart:503`
   - Provides: `Map<String, BadgeDefinition>`
   - Source: remote_config table
   - Use: `ref.watch(badgeCatalogProvider)`

3. **badgesProvider**
   - Location: `lib/application/gamification/gamification_providers.dart` (existing)
   - Provides: Stream of user's earned badges
   - Use: `ref.watch(badgesProvider)`

4. **remoteConfigServiceProvider**
   - Location: `lib/application/gamification/remote_config_service.dart:108`
   - Provides: `RemoteConfigService` instance
   - Method: `getBadgeCatalog()` returns badge definitions

## 🧪 Testing Checklist

### Visual Testing

- [ ] **Dashboard badge button visible**
  - Go to Dashboard
  - Trophy icon appears in app bar
  - Between streak/level and settings icon

- [ ] **Badge sheet opens**
  - Tap trophy icon
  - Bottom sheet slides up
  - Shows "Badge Collection" header
  - Shows grid of 15 badges

- [ ] **Locked badges display correctly**
  - Greyed out emoji
  - Lock icon overlay
  - Tier label (BRONZE, SILVER, etc.)
  - Border color muted

- [ ] **Badge detail modal**
  - Tap any badge
  - Dialog appears with large icon
  - Shows name, tier, description, condition
  - If earned: shows "Earned [date]"

### Functional Testing

- [ ] **Play Memory Match**
  - Complete a game
  - See confetti animation
  - See "+XP" popover
  - See "First Steps" badge unlock modal (first time)
  - Badge collection updates

- [ ] **Perfect score**
  - Play Memory Match with 100% accuracy
  - See "Perfect Score" badge unlock

- [ ] **Speed demon**
  - Complete Memory Match in under 30 seconds
  - See "Speed Demon" badge unlock

- [ ] **Level up**
  - Earn enough XP to level up
  - See level-up celebration
  - See "Rising Star" badge at level 5
  - See "Expert" badge at level 10

- [ ] **Badge collection persists**
  - Reload app
  - Open badge collection
  - Previously earned badges still shown
  - Dates preserved

## 🐛 Troubleshooting

### Badge collection empty

**Issue**: Trophy icon works but no badges show

**Causes**:
1. Migration not run → Run `00017_badge_catalog.sql`
2. Remote config table empty → Check Supabase dashboard
3. Provider error → Check console for errors

**Fix**: Verify remote_config table has `badge_catalog` key

```sql
SELECT * FROM remote_config WHERE key = 'badge_catalog';
```

### Badges not unlocking

**Issue**: Play game but no badge unlock modal

**Causes**:
1. Badge already earned (can only earn once)
2. Badge checker logic not matching activity
3. Error in gamification service

**Debug**:
```dart
// Check console logs
developer.log('Failed to award XP and badges', ...);
```

**Fix**: Check `badge_checker.dart` conditions match your activity

### XP awards but no badges

**Issue**: XP popover shows but no badge modal

**Possible causes**:
1. Badge conditions not met
2. Badge already owned
3. Error fetching badge catalog

**Check**: Open badge collection to see if badge appears there

### Dashboard button not visible

**Issue**: Can't find trophy icon

**Causes**:
1. Import missing in dashboard_page.dart
2. User not logged in (profile is null)

**Fix**: Check line 17 in dashboard_page.dart imports badges_sheet.dart

## 📊 Badge Catalog Reference

| Badge Key | Name | Tier | Condition |
|-----------|------|------|-----------|
| first_steps | First Steps | Bronze | Complete first activity |
| perfect_score | Perfect Score | Gold | Score 100% on any activity |
| week_warrior | Week Warrior | Silver | 7-day streak |
| memory_master | Memory Master | Silver | 10 Memory Match games |
| speed_demon | Speed Demon | Gold | Memory Match under 30s |
| level_five | Rising Star | Bronze | Reach level 5 |
| level_ten | Expert | Silver | Reach level 10 |
| career_explorer | Career Explorer | Bronze | Generate 1 roadmap |
| roadmap_collector | Roadmap Collector | Silver | Generate 5 roadmaps |
| theme_switcher | Style Icon | Bronze | Try 3 themes |
| quiz_ace | Quiz Ace | Silver | Complete 5 quizzes |
| early_bird | Early Bird | Bronze | Activity before 9 AM |
| night_owl | Night Owl | Bronze | Activity after 9 PM |
| comeback_king | Comeback King | Silver | Return after 7+ days |
| perfectionist | Perfectionist | Gold | Score 90+ on 10 activities |

## 🔄 Integration Status

### ✅ Fully Integrated
- Memory Match game
- Dashboard badge button
- Badge collection UI
- Badge unlock animations
- XP awards

### ⏳ Ready for Integration
- Quiz completion (need to call `handleQuizCompletion`)
- Roadmap generation (need to call `handleRoadmapGeneration`)
- Daily login (need to call `handleDailyLogin`)
- Theme switching counter (need to track switches)
- Comeback detection (need to track last login)

### 📝 Implementation Example

To integrate badges into a new activity:

```dart
// In your quiz/activity completion method
final gamificationService = ref.read(gamificationServiceProvider);

await gamificationService.handleQuizCompletion(
  context: context,
  totalQuestions: 10,
  correctAnswers: correctCount,
  timeSeconds: timeElapsed,
);

// That's it! The service handles:
// - XP calculation
// - XP award
// - Badge checking
// - Confetti animation
// - XP popover
// - Badge unlock modals
// - Level-up celebrations
// - UI refresh
```

## 🎉 Success Indicators

When everything is working correctly, you should see:

1. **Trophy icon** in dashboard app bar
2. **Badge collection** opens when tapped
3. **15 badges** displayed in grid
4. **Confetti** + **XP popover** after Memory Match
5. **Badge unlock modal** for first activity
6. **Badge appears unlocked** in collection
7. **Badge count** increments in header

---

**Last Updated**: 2025-10-20
**Phase**: 2.5 Complete
**Status**: Ready for testing
