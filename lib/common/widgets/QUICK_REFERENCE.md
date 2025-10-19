# Gamification Widgets - Quick Reference

## Import Statements
```dart
// Individual widgets
import 'package:startad_agf_selfdiscovery/common/widgets/xp_bar.dart';
import 'package:startad_agf_selfdiscovery/common/widgets/level_badge.dart';
import 'package:startad_agf_selfdiscovery/common/widgets/streak_chip.dart';
import 'package:startad_agf_selfdiscovery/common/widgets/confetti_overlay.dart';
import 'package:startad_agf_selfdiscovery/common/widgets/xp_popover.dart';
```

---

## Quick Copy-Paste Examples

### Dashboard Header
```dart
Consumer(
  builder: (context, ref, child) {
    final profile = ref.watch(gamificationProfileProvider).value;
    if (profile == null) return SizedBox();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CompactStreakChip(streakDays: profile.currentStreak),
              CompactLevelBadge(level: profile.level, size: 40),
            ],
          ),
          SizedBox(height: 12),
          XpBar(
            currentXp: profile.currentXp,
            xpForNextLevel: profile.xpForNextLevel,
            level: profile.level,
          ),
        ],
      ),
    );
  },
)
```

---

### Award XP After Game
```dart
Future<void> _handleGameComplete(int score) async {
  final gamificationRepo = ref.read(gamificationRepositoryProvider);
  final oldProfile = await ref.read(gamificationProfileProvider.future);

  // Calculate XP
  final xpGain = _calculateXpGain(score);

  // Award XP
  await gamificationRepo.awardXp(
    reason: 'memory_match',
    amount: xpGain,
  );

  // Refresh profile
  final newProfile = await ref.refresh(gamificationProfileProvider.future);

  // Show popover
  if (mounted) {
    showXpPopover(
      context,
      xpAmount: xpGain,
      reason: 'Memory Match',
    );

    // Level up celebration
    if (newProfile.level > oldProfile.level) {
      await Future.delayed(Duration(milliseconds: 500));
      showConfettiCelebration(
        context,
        title: 'Level ${newProfile.level}!',
        subtitle: 'You\'re improving fast!',
        emoji: '🎉',
      );
    }
  }
}
```

---

### Game Result Sheet
```dart
void _showResultSheet(BuildContext context, int score, int xpGained) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Great Job!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          XpGainedCard(
            xpAmount: xpGained,
            reason: 'Excellent performance!',
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue'),
          ),
        ],
      ),
    ),
  );
}
```

---

### Streak Milestone Check
```dart
Future<void> _checkStreakMilestone() async {
  final profile = await ref.read(gamificationProfileProvider.future);
  final streak = profile.currentStreak;

  // Check for milestone (every 7 days)
  if (streak > 0 && streak % 7 == 0) {
    showConfettiCelebration(
      context,
      title: '$streak Day Streak! 🔥',
      subtitle: 'You\'re unstoppable!',
      emoji: '🔥',
    );
  }
}
```

---

### Profile Card
```dart
Widget buildProfileCard(GamificationProfile profile) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level ${profile.level}'),
                  Text('${profile.totalXp} total XP'),
                ],
              ),
              LevelBadge(
                level: profile.level,
                size: 60,
                animate: true,
              ),
            ],
          ),
          SizedBox(height: 16),
          XpBar(
            currentXp: profile.currentXp,
            xpForNextLevel: profile.xpForNextLevel,
            level: profile.level,
          ),
          SizedBox(height: 12),
          StreakChip(
            streakDays: profile.currentStreak,
            showLabel: true,
          ),
        ],
      ),
    ),
  );
}
```

---

### Achievement Unlock
```dart
void _unlockBadge(Badge badge) {
  // Show confetti immediately
  showConfetti(context);

  // Show celebration dialog after brief delay
  Future.delayed(Duration(milliseconds: 300), () {
    showConfettiCelebration(
      context,
      title: badge.name,
      subtitle: badge.description,
      emoji: badge.emoji,
      onDismiss: () {
        // Award XP for the badge
        ref.read(gamificationRepositoryProvider).awardXp(
          reason: 'badge_unlock',
          amount: 100,
        );
      },
    );
  });
}
```

---

### Daily Login Bonus
```dart
Future<void> _handleDailyLogin() async {
  final gamificationRepo = ref.read(gamificationRepositoryProvider);

  // Update streak
  final wasUpdated = await gamificationRepo.updateStreak();

  if (wasUpdated) {
    // Award daily XP
    await gamificationRepo.awardXp(
      reason: 'daily_login',
      amount: 10,
    );

    // Show notification
    if (mounted) {
      showXpPopover(
        context,
        xpAmount: 10,
        reason: 'Daily Login',
      );
    }
  }
}
```

---

### Compact Inline Displays
```dart
// In a ListTile
ListTile(
  title: Text('Memory Match'),
  subtitle: Text('Match pairs to test your memory'),
  trailing: CompactXpIndicator(xpAmount: 25),
)

// In a chip row
Row(
  children: [
    CompactLevelBadge(level: 8, size: 24),
    SizedBox(width: 8),
    CompactStreakChip(streakDays: 15),
    SizedBox(width: 8),
    CompactXpIndicator(xpAmount: 1250, showPlus: false),
  ],
)
```

---

### Full Celebration Flow
```dart
Future<void> _celebrateAchievement({
  required String title,
  required String subtitle,
  required int xpReward,
  String emoji = '🎉',
}) async {
  // 1. Confetti
  showConfetti(context);

  // 2. Brief pause
  await Future.delayed(Duration(milliseconds: 300));

  // 3. XP Popover
  showXpPopover(
    context,
    xpAmount: xpReward,
    reason: title,
  );

  // 4. Award XP in background
  await ref.read(gamificationRepositoryProvider).awardXp(
    reason: title.toLowerCase().replaceAll(' ', '_'),
    amount: xpReward,
  );

  // 5. Celebration dialog
  await Future.delayed(Duration(milliseconds: 800));
  if (mounted) {
    showConfettiCelebration(
      context,
      title: title,
      subtitle: subtitle,
      emoji: emoji,
    );
  }
}
```

---

## Common XP Amounts

```dart
const xpRewards = {
  'daily_login': 10,
  'memory_match_complete': 25,
  'quiz_perfect': 50,
  'assessment_complete': 100,
  'roadmap_generated': 75,
  'week_streak': 100,
  'month_streak': 500,
  'badge_unlock': 100,
  'profile_complete': 50,
};
```

---

## Emoji Reference

### Streak Tiers
- 💨 No streak (0 days)
- ✨ Starting (1-6 days)
- 🔥 Week streak (7-13 days)
- 🔥🔥 Hot streak (14-29 days)
- 🔥🔥🔥 Fire streak (30+ days)

### Celebrations
- 🎉 General celebration
- 🏆 Achievement
- ⭐ XP/Points
- 🎯 Goal reached
- 💪 Strength/Progress
- 🚀 Level up
- 🎊 Milestone
- 💎 Premium/Special

---

## Animation Durations

```dart
// XP Bar
duration: Duration(milliseconds: 800)

// Level Badge
duration: Duration(milliseconds: 1500) // repeating

// Streak Chip
duration: Duration(milliseconds: 1200) // repeating

// Confetti
duration: Duration(seconds: 3)

// XP Popover
duration: Duration(milliseconds: 2000)
```

---

## Widget Sizes

```dart
// Level Badge
size: 60  // Default
size: 48  // Medium
size: 40  // Compact header
size: 32  // Inline
size: 24  // Tiny

// XP Bar
height: 24  // Default (shows percentage)
height: 16  // Compact
height: 6   // Minimal

// Streak Chip
// Auto-sizes based on content
```

---

## Conditional Rendering

```dart
// Only show if profile loaded
final profileAsync = ref.watch(gamificationProfileProvider);
profileAsync.when(
  data: (profile) => XpBar(
    currentXp: profile.currentXp,
    xpForNextLevel: profile.xpForNextLevel,
    level: profile.level,
  ),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => SizedBox(),
)

// Hide animations in tests
XpBar(
  currentXp: xp,
  xpForNextLevel: nextLevel,
  level: level,
  animate: !kIsTest,
)

// Responsive sizing
final isSmallScreen = MediaQuery.of(context).size.width < 360;
LevelBadge(
  level: level,
  size: isSmallScreen ? 40 : 60,
)
```

---

## Error Handling

```dart
// Safe overlay usage
void safeShowXpPopover(BuildContext context, int xp) {
  try {
    if (context.mounted) {
      showXpPopover(context, xpAmount: xp);
    }
  } catch (e) {
    debugPrint('Failed to show XP popover: $e');
  }
}

// Safe theme access
final teenTheme = Theme.of(context).extension<TeenPalette>();
if (teenTheme == null) {
  return Text('Theme not available');
}

// Use theme safely
final primaryColor = teenTheme.primary;
```

---

## Performance Tips

```dart
// Disable animations in lists
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      leading: CompactLevelBadge(
        level: levels[index],
        // Static, no animation
      ),
    );
  },
)

// Limit confetti on low-end devices
final isLowEnd = MediaQuery.of(context).size.width < 360;
ConfettiOverlay(
  show: true,
  particleCount: isLowEnd ? 50 : 100,
)

// Use const where possible
const CompactXpIndicator(xpAmount: 25)
```

---

## Testing Helpers

```dart
// Pump widget with theme
Future<void> pumpWithTheme(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: [TeenThemes.neonArcade],
      ),
      home: Scaffold(body: widget),
    ),
  );
}

// Test XP bar
testWidgets('Shows XP progress', (tester) async {
  await pumpWithTheme(
    tester,
    XpBar(
      currentXp: 500,
      xpForNextLevel: 1000,
      level: 5,
      animate: false,
    ),
  );

  expect(find.text('500 / 1000 XP'), findsOneWidget);
});
```

---

**Quick Tip**: Copy-paste these examples and adjust the parameters to fit your use case!
