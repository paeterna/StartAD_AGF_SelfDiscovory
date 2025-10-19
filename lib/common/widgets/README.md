# Gamification Widgets

This directory contains the core gamification UI widgets for the Teen UX system.

## Widget Catalog

### 🎯 XP Bar (`xp_bar.dart`)
Display and animate XP progress towards the next level.

```dart
// Full XP bar with labels
XpBar(
  currentXp: 750,
  xpForNextLevel: 1000,
  level: 5,
  showLabel: true,
  animate: true,
)

// Compact version for headers
CompactXpBar(
  currentXp: 750,
  xpForNextLevel: 1000,
  height: 6,
)
```

**Features**:
- Animated gradient fill
- Glow effects
- Percentage display (when height ≥ 24px)
- Theme-aware colors

---

### 🏆 Level Badge (`level_badge.dart`)
Display user level with pulsing animations.

```dart
// Animated badge
LevelBadge(
  level: 12,
  size: 60,
  animate: true,
  onTap: () => showLevelDetails(),
)

// Compact inline
CompactLevelBadge(level: 12, size: 32)

// With label
LevelBadgeWithLabel(
  level: 12,
  label: 'Explorer',
)
```

**Features**:
- Pulsing glow animation (1.5s loop)
- Radial gradient background
- Configurable size
- Optional tap callback

---

### 🔥 Streak Chip (`streak_chip.dart`)
Show daily login streaks with fire emoji.

```dart
// Animated streak counter
StreakChip(
  streakDays: 15,
  showLabel: true,
  animate: true,
)

// Compact version
CompactStreakChip(streakDays: 15)

// Milestone celebration
StreakMilestone(
  streakDays: 30,
  message: 'You\'re on fire! Keep it up!',
)
```

**Emoji Tiers**:
- 0 days: 💨 (no streak)
- 1-6 days: ✨ (starting)
- 7-13 days: 🔥 (week streak)
- 14-29 days: 🔥🔥 (hot streak)
- 30+ days: 🔥🔥🔥 (fire streak!)

---

### 🎉 Confetti Overlay (`confetti_overlay.dart`)
Celebrate achievements with confetti particles.

```dart
// Simple confetti
showConfetti(context);

// Full celebration dialog
showConfettiCelebration(
  context,
  title: 'Level Up!',
  subtitle: 'You reached Level 10',
  emoji: '🎉',
);

// Manual control
ConfettiOverlay(
  show: true,
  duration: Duration(seconds: 3),
  particleCount: 100,
  onComplete: () => print('Done!'),
)
```

**Features**:
- Physics-based particles (gravity, velocity, rotation)
- 100 particles by default
- Theme-aware colors
- Auto-cleanup

---

### ⭐ XP Popover (`xp_popover.dart`)
Floating "+XP" notification when users earn XP.

```dart
// Show floating notification
showXpPopover(
  context,
  xpAmount: 50,
  reason: 'Memory Match',
);

// Result sheet card
XpGainedCard(
  xpAmount: 75,
  reason: 'Perfect score!',
  newLevel: 6,
  showLevelUp: true,
)

// Inline indicator
CompactXpIndicator(
  xpAmount: 25,
  showPlus: true,
)
```

**Features**:
- Slide-up + fade animation
- Elastic scale pop
- Auto-removal after 2s
- Optional reason text

---

## Integration Guide

### 1. Theme Setup
All widgets require TeenPalette theme extension:

```dart
// Access theme in widget
final teenTheme = Theme.of(context).extension<TeenPalette>()!;

// Used colors
teenTheme.primary    // Main brand color
teenTheme.secondary  // Complementary accent
teenTheme.tertiary   // Playful tertiary
teenTheme.background // Background color
```

### 2. XP Flow Integration

#### Memory Match Game
```dart
// After game completion
final gamificationRepo = ref.read(gamificationRepositoryProvider);
final profile = await ref.read(gamificationProfileProvider.future);

// Calculate XP
final xpGain = calculateXpGain(scores);

// Award XP
await gamificationRepo.awardXp(
  reason: 'memory_match',
  amount: xpGain,
);

// Show popover
if (mounted) {
  showXpPopover(
    context,
    xpAmount: xpGain,
    reason: 'Memory Match',
  );
}

// Check for level up
final newProfile = await ref.refresh(gamificationProfileProvider.future);
if (newProfile.level > profile.level) {
  showConfettiCelebration(
    context,
    title: 'Level ${newProfile.level}!',
    subtitle: 'Keep crushing it!',
    emoji: '🎉',
  );
}
```

#### Dashboard Header
```dart
// Display gamification status
Consumer(
  builder: (context, ref, child) {
    final profile = ref.watch(gamificationProfileProvider).value;
    if (profile == null) return SizedBox();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Streak
            StreakChip(
              streakDays: profile.currentStreak,
              showLabel: false,
            ),

            // Level
            LevelBadge(
              level: profile.level,
              size: 48,
              animate: false,
            ),
          ],
        ),

        SizedBox(height: 12),

        // XP Progress
        XpBar(
          currentXp: profile.currentXp,
          xpForNextLevel: profile.xpForNextLevel,
          level: profile.level,
        ),
      ],
    );
  },
)
```

### 3. Celebration Triggers

```dart
// Level up
if (didLevelUp) {
  showConfettiCelebration(
    context,
    title: 'Level ${newLevel}!',
    subtitle: 'You\'re getting better every day',
    emoji: '🎉',
  );
}

// Streak milestone
if (streakDays % 7 == 0 && streakDays > 0) {
  showConfettiCelebration(
    context,
    title: '$streakDays Day Streak!',
    subtitle: 'You\'re on fire! 🔥',
    emoji: '🔥',
  );
}

// Achievement unlocked
if (badgeUnlocked) {
  showConfettiCelebration(
    context,
    title: badge.name,
    subtitle: badge.description,
    emoji: badge.emoji,
  );
}
```

---

## Performance Tips

### Animations
- Set `animate: false` for widgets in lists
- Use `CompactXpBar` instead of full `XpBar` in tight spaces
- Limit confetti particles for low-end devices:
  ```dart
  ConfettiOverlay(
    show: true,
    particleCount: isLowEndDevice ? 50 : 100,
  )
  ```

### Memory
- Widgets auto-dispose animation controllers
- Overlays auto-remove after completion
- No manual cleanup needed

### Testing
```dart
// Disable animations in tests
XpBar(
  currentXp: 500,
  xpForNextLevel: 1000,
  level: 5,
  animate: false, // Important for widget tests
)
```

---

## Accessibility

All widgets follow accessibility best practices:

- ✅ Sufficient color contrast (WCAG AA)
- ✅ Text sizes follow Material guidelines
- ✅ Interactive elements ≥ 48px tap target
- ✅ Animations can be disabled
- ✅ Semantic labels for screen readers

### Reduce Motion Support
```dart
// Check system settings
final reducedMotion = MediaQuery.of(context)
    .platformBrightness == Brightness.dark; // Simplified

// Apply to widgets
XpBar(
  currentXp: xp,
  xpForNextLevel: nextLevel,
  level: level,
  animate: !reducedMotion,
)
```

---

## Widget States

### XP Bar
- **Idle**: Static progress bar
- **Animating**: Fill animates from previous → current progress
- **Full**: Progress at 100% (ready to level up)

### Level Badge
- **Static**: No animation
- **Pulsing**: Continuous scale + glow pulse
- **Level Up**: One-shot animation then resume pulsing

### Streak Chip
- **No Streak**: Gray with 💨
- **Active Streak**: Colored with animated flame
- **Milestone**: Special celebration state

### Confetti
- **Hidden**: Not rendering
- **Active**: Particles falling with physics
- **Complete**: Auto-removed from tree

### XP Popover
- **Entering**: Fade in + scale pop
- **Visible**: Sliding up
- **Exiting**: Fade out
- **Complete**: Removed from overlay

---

## Common Patterns

### Combo Widget
```dart
// XP gained with confetti
void celebrateXpGain(BuildContext context, int xp, {int? newLevel}) {
  // Show confetti first
  showConfetti(context);

  // Then show XP popover
  Future.delayed(Duration(milliseconds: 300), () {
    showXpPopover(
      context,
      xpAmount: xp,
      reason: 'Great job!',
    );
  });

  // If leveled up, show dialog after confetti settles
  if (newLevel != null) {
    Future.delayed(Duration(milliseconds: 1500), () {
      showConfettiCelebration(
        context,
        title: 'Level $newLevel!',
        subtitle: 'Keep up the awesome work!',
        emoji: '🎉',
      );
    });
  }
}
```

### Dashboard Header
```dart
Widget buildGamificationHeader(GamificationProfile profile) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        // Top row: Streak + Level
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CompactStreakChip(streakDays: profile.currentStreak),
            CompactLevelBadge(level: profile.level, size: 40),
          ],
        ),

        SizedBox(height: 12),

        // XP progress bar
        XpBar(
          currentXp: profile.currentXp,
          xpForNextLevel: profile.xpForNextLevel,
          level: profile.level,
        ),
      ],
    ),
  );
}
```

### Result Sheet
```dart
Widget buildGameResultSheet(int score, int xpGained, bool leveledUp, int? newLevel) {
  return Column(
    children: [
      // Score display
      Text('Score: $score', style: TextStyle(fontSize: 32)),

      SizedBox(height: 24),

      // XP gained card
      XpGainedCard(
        xpAmount: xpGained,
        reason: 'Awesome performance!',
        newLevel: leveledUp ? newLevel : null,
        showLevelUp: leveledUp,
      ),
    ],
  );
}
```

---

## Troubleshooting

### XP Bar not animating
- Check `animate: true` is set
- Ensure `currentXp` actually changed (not just setState)
- Verify `xpForNextLevel > 0`

### Level Badge not pulsing
- Check `animate: true`
- Ensure widget is visible (not offscreen)
- Try increasing `size` parameter

### Confetti not showing
- Verify `Overlay.of(context)` is available
- Check `show: true` is set
- Ensure parent allows overflow (not clipped)

### XP Popover immediately disappearing
- Verify `Overlay.of(context)` is available
- Check console for errors
- Try increasing `duration`

### Colors look wrong
- Ensure TeenPalette is properly set in Theme
- Check `Theme.of(context).extension<TeenPalette>()` is not null
- Verify theme is applied to MaterialApp

---

## Testing Examples

```dart
// Widget test
testWidgets('XpBar displays correct progress', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: [TeenThemes.neonArcade],
      ),
      home: Scaffold(
        body: XpBar(
          currentXp: 500,
          xpForNextLevel: 1000,
          level: 5,
          animate: false, // Disable for testing
        ),
      ),
    ),
  );

  // Verify text displayed
  expect(find.text('500 / 1000 XP'), findsOneWidget);
  expect(find.text('Level 5'), findsOneWidget);
});

// Integration test
testWidgets('XP popover shows and dismisses', (tester) async {
  await tester.pumpWidget(MyApp());

  // Trigger XP gain
  showXpPopover(
    tester.element(find.byType(Scaffold)),
    xpAmount: 50,
    reason: 'Test',
  );

  await tester.pump(); // Start animation
  expect(find.text('+50 XP'), findsOneWidget);

  await tester.pump(Duration(seconds: 3)); // Wait for completion
  expect(find.text('+50 XP'), findsNothing);
});
```

---

## Resources

- **Phase 2 Summary**: See `PHASE_2_COMPLETION_SUMMARY.md`
- **Implementation Plan**: See `TEEN_UX_IMPLEMENTATION_PLAN.md`
- **Theme System**: See `lib/common/theme/teen_palette_extension.dart`
- **Gamification Data**: See `lib/domain/entities/gamification.dart`

---

**Last Updated**: 2025-10-19
**Total Widgets**: 13 (5 main + 8 variants)
**Total Lines**: ~1,551
