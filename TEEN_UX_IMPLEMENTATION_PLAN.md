# Teen UX Upgrade - Implementation Plan

## 📊 Progress Summary

**Phases Completed**: 3 / 7
- ✅ Phase 1: Core Infrastructure (100%)
- ✅ Phase 2: Gamification Widgets (100%)
- ✅ Phase 2.5: Badge System (100%)
- ✅ Phase 3: Dashboard Refactor (75% - story feed/weekly digest cancelled)
- ⏳ Phase 4: Career Clusters Refactor (0%)
- ⏳ Phase 5: Roadmaps Refactor (0%)
- ⏳ Phase 6: Onboarding Stories (0%)
- ⏳ Phase 7: Telemetry & A/B Testing (0%)

**Key Achievements**:
- Complete gamification system with XP, levels, streaks
- 15 badges with unlock animations and collection UI
- Memory Match & Quiz XP integration
- Dashboard with live streak/level display
- Theme system with 5 teen themes
- Confetti celebrations and XP popovers

## ✅ Completed

### 1. Database Schema
- **File**: `supabase/migrations/00016_teen_ux_gamification.sql`
- ✅ Created `remote_config` table for centralized configuration
- ✅ Created `gamification_profiles` table (XP, level, streaks, theme)
- ✅ Created `badges` table for achievements
- ✅ Created `events` table for telemetry
- ✅ Created `experiments` table for A/B testing
- ✅ Added RLS policies for all tables
- ✅ Created helper functions: `calculate_level()`, `update_streak()`
- ✅ Added trigger to auto-create gamification profile on user signup

### 2. Theme System
- **File**: `lib/common/theme/teen_palette_extension.dart`
- ✅ Created `TeenPalette` ThemeExtension with all theme parameters
- ✅ Defined 5 teen themes:
  1. **Neon Arcade** - Electric blue/magenta with neon energy
  2. **Galaxy Pulse** - Ultraviolet/teal cosmic vibes
  3. **Street Pop** - Coral/canary urban style
  4. **Ocean Wave** - Aqua/navy fluid motion
  5. **Retro Pixel** - Gameboy green retro gaming
- ✅ Each theme includes: colors, gradients, motion params, emoji packs, lottie sets

### 3. Phase 1: Core Infrastructure ✅ COMPLETE
**Files Created**: See [PHASE_1_COMPLETION_SUMMARY.md](PHASE_1_COMPLETION_SUMMARY.md) for details

#### 3.1 Gamification Data Layer ✅
- ✅ **File**: `lib/domain/entities/gamification.dart`
  - GamificationProfile with XP, levels, streaks, theme
  - Badge and BadgeDefinition entities
  - XpConstants for remote config
  - TelemetryEvent for analytics
  - Helper classes: XpAward

- ✅ **File**: `lib/data/repositories/gamification_repository.dart`
  - Award XP and update levels
  - Manage daily streaks
  - Grant and check badges
  - Log telemetry events
  - Fetch remote config
  - A/B testing support
  - Leaderboard queries

- ✅ **File**: `lib/application/gamification/gamification_providers.dart`
  - Riverpod providers for all gamification state
  - Stream providers for real-time updates
  - Action providers (awardXp, updateStreak, awardBadge)
  - Remote config providers

- ✅ **File**: `lib/application/gamification/remote_config_service.dart`
  - Type-safe remote config access
  - Feature flag management
  - XP constants fetching

#### 3.2 Theme Integration ✅
- ✅ **Updated**: `lib/app.dart`
  - Integrated teen theme system
  - Dynamic theme loading from user preference
  - Fallback to default Neon Arcade theme

- ✅ **File**: `lib/application/theme/theme_providers.dart`
  - Theme state management with Riverpod
  - ThemeController for changing themes
  - Theme data builders from TeenPalette
  - ThemeMode notifier

- ✅ **File**: `lib/presentation/widgets/theme_picker_dialog.dart`
  - Reusable theme picker dialog
  - Grid view of all 5 themes
  - Visual previews with gradients and colors
  - Selection state with animations

- ✅ **File**: `lib/presentation/features/onboarding/theme_selection_page.dart`
  - Post-signup theme selection page
  - Full-screen theme picker
  - Animated theme cards
  - Saves selection and navigates to dashboard

#### 3.3 Lottie Setup ✅
- ✅ **Updated**: `pubspec.yaml`
  - Added `lottie: ^3.1.3` package
  - Added `assets/lottie/` to assets

- ✅ **Created**: `assets/lottie/` directory
- ✅ **File**: `assets/lottie/README.md`
  - Documentation for required Lottie animations
  - Theme-specific animation requirements
  - Sources and usage examples

### Phase 2: Gamification Widgets ✅ COMPLETE
**Files Created**: See [PHASE_2_COMPLETION_SUMMARY.md](PHASE_2_COMPLETION_SUMMARY.md) for details

4. **Core Widgets** ✅
   - ✅ **File**: `lib/common/widgets/xp_bar.dart` (246 lines)
     - XpBar - Animated progress bar with gradient fill, glow effects, percentage display
     - CompactXpBar - 6px minimal bar for headers

   - ✅ **File**: `lib/common/widgets/level_badge.dart` (263 lines)
     - LevelBadge - Circular badge with pulsing glow animation
     - CompactLevelBadge - 32px static inline version
     - LevelBadgeWithLabel - Badge with text label below

   - ✅ **File**: `lib/common/widgets/streak_chip.dart` (293 lines)
     - StreakChip - Animated counter with dynamic emoji (💨/✨/🔥/🔥🔥/🔥🔥🔥)
     - CompactStreakChip - Minimal header version
     - StreakMilestone - Celebration widget for achievements

   - ✅ **File**: `lib/common/widgets/confetti_overlay.dart` (392 lines)
     - ConfettiOverlay - Physics-based particle system (100+ particles)
     - ConfettiCelebration - Full-screen celebration dialog
     - Helper functions: showConfetti(), showConfettiCelebration()

   - ✅ **File**: `lib/common/widgets/xp_popover.dart` (357 lines)
     - XpPopover - Floating "+XP" notification with slide-up animation
     - XpGainedCard - Result sheet XP display with level-up badge
     - CompactXpIndicator - Inline XP chip
     - Helper function: showXpPopover()

**Total**: 5 files, ~1,551 lines, 13 widget variants

### Phase 2.5: Badge System ✅ COMPLETE
**Files Created**: Badge catalog migration, badge UI, and integration services

5. **Badge System** ✅
   - ✅ **Migration**: `supabase/migrations/00017_badge_catalog.sql`
     - 15 badge definitions in remote_config
     - Tiers: bronze, silver, gold, platinum
     - Categories: activity, streak, level, time, achievement

   - ✅ **File**: `lib/presentation/features/gamification/badges_sheet.dart`
     - Badge collection UI with grid layout
     - Locked/unlocked state display
     - Tier-based coloring and sorting
     - Badge detail modal with progress info

   - ✅ **File**: `lib/presentation/features/gamification/badge_unlock_modal.dart`
     - Animated badge reveal with confetti
     - Tier-specific glow effects
     - Scale and rotation animations
     - Full-screen celebration modal

   - ✅ **File**: `lib/application/gamification/badge_checker.dart`
     - Badge eligibility checking service
     - Activity-based badge awards
     - Streak, level, and time-based badges
     - Automatic badge granting logic

   - ✅ **File**: `lib/application/gamification/gamification_service.dart`
     - High-level gamification orchestration
     - XP + badge checking combined
     - Memory Match integration
     - Quiz completion integration
     - Roadmap generation rewards
     - Streak milestone celebrations

   - ✅ **Updated**: `lib/presentation/features/dashboard/dashboard_page.dart`
     - Added badge collection button (trophy icon) in app bar

   - ✅ **Updated**: `lib/application/gamification/xp_calculator.dart`
     - Added quiz XP calculation
     - Added career exploration constants

### Phase 3: Dashboard Refactor ✅ PARTIALLY COMPLETE
6. **Dashboard Updates** (Modified scope - story feed & weekly digest cancelled)
   - ✅ Refactored `lib/presentation/features/dashboard/dashboard_page.dart`
   - ✅ Added header with streak + level badges
   - ✅ Theme name displayed in settings page
   - ✅ Static circular XP progress indicator (animated XP bar not needed)
   - ❌ Story feed - CANCELLED per user request
   - ❌ Weekly digest - CANCELLED per user request
   - ✅ XP awards hooked to Memory Match
   - ✅ XP calculator supports quizzes and all activities
   - ✅ Badge collection accessible from dashboard

### Phase 4: Career Clusters Refactor (Priority 4)
7. **Clusters View**
   - [ ] Refactor `lib/presentation/features/careers/careers_page_clustered.dart`
   - [ ] Add gradient backgrounds per theme
   - [ ] Implement expand/collapse animations
   - [ ] Add Hero transitions to career details
   - [ ] Add micro-interactions (scale on tap, animated bars)

### Phase 5: Roadmaps Refactor (Priority 5)
8. **Roadmap Details**
   - [ ] Refactor `lib/presentation/features/roadmaps/roadmap_detail_page.dart`
   - [ ] Create `lib/features/roadmaps/widgets/phase_tabbar.dart` - Emoji tabs
   - [ ] Create `lib/features/roadmaps/widgets/animated_step_card.dart` - Flip/expand cards
   - [ ] Add confetti on phase completion
   - [ ] Add "Mark done" functionality with XP rewards

### Phase 6: Onboarding Stories (Priority 6)
9. **Onboarding**
   - [ ] Create `lib/presentation/features/onboarding/onboarding_stories_page.dart`
   - [ ] Create 4 story cards explaining: themes, clusters, roadmaps, games
   - [ ] Add tappable PageView with progress indicator
   - [ ] Save `has_seen_onboarding` flag to profiles
   - [ ] Add re-launch option in settings

### Phase 7: Telemetry & A/B Testing (Priority 7)
10. **Analytics**
    - [ ] Create `lib/application/telemetry/telemetry_service.dart`
    - [ ] Log events: `theme_selected`, `cluster_expanded`, `career_generate_clicked`, etc.
    - [ ] Create `lib/application/experiments/ab_testing_service.dart`
    - [ ] Implement bucket assignment logic
    - [ ] Add feature flag checks throughout app

## 🎨 Asset Requirements

### Lottie Animations (Need to create/acquire)
For each theme, create 3 Lottie files:
- `assets/lottie/{theme}_success.json`
- `assets/lottie/{theme}_confetti.json`
- `assets/lottie/{theme}_pulse.json`

**Free Lottie Resources**:
- https://lottiefiles.com/
- Search for: confetti, success, celebration, pulse, glow

### Icons & Illustrations
- Theme preview thumbnails
- Badge icons (at least 10-15 badges)
- Avatar builder parts (optional for v1)

## 📊 XP Calculation Logic

### Integration Points
Update existing game completion flows to award XP:

**Memory Match** (`lib/presentation/features/games/memory_match/memory_match_page.dart`):
```dart
// After saving results, before showing result sheet
final xpConstants = await ref.read(remoteConfigProvider).getXpConstants();
final deltaComposite = scores.composite - previousComposite; // Track previous
final deltaAttention = scores.cognitionAttention - previousAttention;
final deltaMemory = scores.cognitionMemory - previousMemory;

final xpGain = xpConstants.base +
    xpConstants.k1 * deltaComposite +
    xpConstants.k2 * deltaAttention +
    xpConstants.k3 * deltaMemory;

await gamificationRepo.awardXp(
  reason: 'memory_match',
  amount: xpGain.round(),
);

// Show XP popover
showXpPopover(context, xpGain.round());
```

**Similar integration needed for**:
- Quiz completions
- Assessment completions
- Roadmap generation
- Daily login bonuses

## 🎯 Success Metrics

### Technical Metrics
- [ ] Dashboard build time < 10ms (use DevTools)
- [ ] 60 fps maintained during animations (use Performance overlay)
- [ ] Theme switching < 100ms
- [ ] XP calculations < 5ms

### UX Metrics (via events table)
- [ ] Theme selection distribution
- [ ] Streak retention rate (% users maintaining 3+ day streaks)
- [ ] Badge unlock rate
- [ ] Career cluster expansion rate

## 🚀 Deployment Strategy

### Phase Rollout
1. **Week 1**: Database migration + theme system + basic widgets
2. **Week 2**: Dashboard refactor + XP integration
3. **Week 3**: Gamification full flow + badges
4. **Week 4**: Onboarding stories + telemetry
5. **Week 5**: Polish + A/B testing setup

### A/B Test Ideas
- Confetti vs no confetti (measure engagement)
- XP constants (k1, k2, k3) optimization
- Theme recommendations based on quiz results
- Badge unlock difficulty tuning

## 📖 Code Patterns

### Accessing Theme
```dart
final teenTheme = Theme.of(context).teenPalette;
final primaryColor = teenTheme.primary;
final animDuration = teenTheme.motionDuration;
```

### Motion Wrapper
```dart
AnimatedContainer(
  duration: teenTheme.motionDuration,
  curve: Curves.easeOutCubic,
  transform: Matrix4.identity()..scale(isExpanded ? 1.0 : 0.95),
  decoration: BoxDecoration(
    gradient: teenTheme.bgGradient,
    borderRadius: BorderRadius.circular(teenTheme.buttonRadius),
    boxShadow: [
      BoxShadow(
        color: teenTheme.primary.withOpacity(teenTheme.cardGlow * 0.1),
        blurRadius: teenTheme.cardGlow,
      ),
    ],
  ),
  child: child,
)
```

### XP Award
```dart
final repo = ref.read(gamificationRepositoryProvider);
await repo.awardXp(
  userId: currentUser.id,
  reason: 'quiz_completed',
  amount: 25,
  metadata: {'quiz_id': quizId},
);

// Update streak
await repo.updateStreak(currentUser.id);
```

### Event Logging
```dart
await ref.read(telemetryServiceProvider).logEvent(
  kind: 'cluster_expanded',
  metadata: {
    'cluster_id': cluster.id,
    'theme': currentTheme.themeKey,
  },
);
```

## ⚠️ Important Notes

1. **Performance**: Test on low-end Android emulator (Pixel 3a API 29)
2. **Accessibility**: All colors must pass WCAG AA contrast
3. **Privacy**: No PII in events; aggregate analytics only
4. **Testing**: Create integration tests for XP calculations
5. **Fallbacks**: Gracefully degrade if Lottie fails to load

## 🔧 pubspec.yaml Dependencies

Add these packages:
```yaml
dependencies:
  lottie: ^3.0.0
  flutter_animate: ^4.5.0  # For easy micro-animations
  confetti: ^0.7.0  # Confetti particles

dev_dependencies:
  # Already have flutter_test
```

## Next Immediate Action

**START HERE**:
1. Apply database migration `00016_teen_ux_gamification.sql` in Supabase
2. Add `lottie` to `pubspec.yaml`
3. Create gamification repository
4. Update dashboard to show XP bar
5. Test XP award flow after completing Memory Match

This is a foundation to build upon systematically.
