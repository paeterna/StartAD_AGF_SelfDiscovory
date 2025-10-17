# Custom Icons Directory

This directory contains all custom SVG icons used in the SelfMap application.

## Required Icons (91 total)

Place your SVG icon files here following this naming convention:

### Navigation Icons (12)
- dashboard.svg, dashboard_outlined.svg
- explore.svg, explore_outlined.svg
- work.svg, work_outline.svg
- map.svg, map_outlined.svg
- psychology.svg, psychology_outlined.svg
- settings.svg, settings_outlined.svg

### Settings Icons (14)
- person.svg, person_outline.svg
- email.svg, email_outlined.svg
- language.svg, brightness_6.svg
- notifications.svg, privacy_tip.svg
- description.svg, info.svg, info_outline.svg
- feedback.svg, bug_report.svg
- arrow_forward_ios.svg

### Dashboard & Discovery Icons (10)
- local_fire_department.svg
- schedule.svg
- verified.svg
- trending_up.svg
- quiz.svg, quiz_outlined.svg
- games.svg, games_outlined.svg
- emoji_events.svg, emoji_events_outlined.svg

### Career Icons (8)
- account_tree.svg
- search.svg, search_off.svg
- star.svg, star_outline.svg
- category.svg

### Game & Assessment Icons (10)
- timer.svg
- touch_app.svg
- check_circle.svg, check_circle_outline.svg
- play_arrow.svg, pause.svg, pause_circle.svg
- refresh.svg
- sports_esports.svg

### AI Insights Icons (8)
- auto_awesome.svg
- lightbulb_outline.svg
- rocket_launch.svg
- favorite.svg, favorite_outline.svg
- analytics.svg
- data_usage.svg

### School/Admin Icons (5)
- school.svg, school_outlined.svg
- people.svg
- insert_chart.svg
- radar.svg

### UI Control Icons (11)
- help_outline.svg
- close.svg, clear.svg, check.svg
- arrow_back.svg, arrow_forward.svg
- chevron_right.svg
- expand_more.svg, expand_less.svg
- unfold_more.svg, unfold_less.svg

### Status Icons (5)
- error_outline.svg
- cancel_outlined.svg
- remove_circle_outline.svg
- image_not_supported.svg
- construction_outlined.svg

### Authentication Icons (6)
- lock.svg, lock_outline.svg
- logout.svg
- visibility_outlined.svg, visibility_off_outlined.svg
- account_circle.svg

### Miscellaneous Icons (12)
- link.svg
- list.svg
- history.svg
- thumb_up.svg
- question_mark.svg
- access_time.svg
- g_mobiledata.svg

## Icon Sources

You can download icons from:

1. **Material Symbols** (Recommended): https://fonts.google.com/icons
2. **Heroicons**: https://heroicons.com/
3. **Lucide Icons**: https://lucide.dev/icons
4. **Tabler Icons**: https://tabler-icons.io/
5. **Bootstrap Icons**: https://icons.getbootstrap.com/

## Icon Requirements

- **Format**: SVG
- **Size**: 24x24px (will scale automatically)
- **Color**: Should be single-color or use currentColor
- **Naming**: Lowercase with underscores (e.g., `dashboard_outlined.svg`)

## SVG Optimization

Before adding icons, optimize them using SVGO:

```bash
# Install SVGO
npm install -g svgo

# Optimize all SVGs in this directory
svgo -f assets/icons
```

## Example SVG Structure

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M12 2L2 7v10l10 5 10-5V7L12 2z"/>
</svg>
```

Remove any fill or stroke attributes so the icon can be colored dynamically.

## Usage

Once icons are added:

1. Run `flutter pub get`
2. Restart the app (hot reload won't load new assets)
3. Use the `AppIcon` widget:

```dart
import 'package:startad_agf_selfdiscovery/core/assets/app_icons.dart';
import 'package:startad_agf_selfdiscovery/core/widgets/app_icon.dart';

AppIcon(
  AppIcons.dashboard,
  size: 24,
  color: Colors.blue,
)
```

See [ICONS_GUIDE.md](../../ICONS_GUIDE.md) for complete implementation instructions.
