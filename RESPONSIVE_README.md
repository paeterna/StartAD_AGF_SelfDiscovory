# Responsive Web + Desktop Layout Guide

## Overview

This guide explains how the responsive system works and how to adapt pages to support mobile, tablet, and desktop layouts.

## System Architecture

### 1. Core Responsive System

Located in `lib/core/responsive/responsive.dart`, this provides:

#### Breakpoints
```dart
class Breakpoints {
  static const xs = 600.0;   // < 600: phones
  static const sm = 900.0;   // 600-899: large phones/small tablets
  static const md = 1200.0;  // 900-1199: tablets/small laptops
  static const lg = 1600.0;  // 1200-1599: laptops/desktops
  // xl: ≥ 1600: large desktops/ultrawide
}
```

#### Context Extensions
```dart
// Check breakpoints
context.isXs, context.isSm, context.isMd, context.isLg, context.isXl
context.isMobile, context.isTablet, context.isDesktop

// Responsive values
final columns = context.responsive(
  xs: 1,
  sm: 2,
  md: 3,
  lg: 4,
  xl: 5,
);

// Pre-defined responsive values
context.responsivePadding
context.cardPadding
context.cardElevation
context.borderRadius
context.gridColumns
context.gridSpacing
```

### 2. Adaptive Shell

Located in `lib/presentation/shell/adaptive_shell.dart`, this provides:

- **Mobile (xs/sm)**: Bottom navigation bar
- **Tablet (md)**: Compact navigation rail
- **Desktop (lg/xl)**: Expanded navigation rail + optional insights panel

The shell automatically wraps main pages (Dashboard, Discover, Careers, Roadmap, Settings).

### 3. Responsive Components

#### AppScaffoldBody
Centers content and constrains width on wide screens:

```dart
AppScaffoldBody(
  maxWidth: 1240,
  child: YourContent(),
)
```

#### ResponsiveCard
Adapts elevation and enables hover effects on desktop:

```dart
ResponsiveCard(
  enableHover: true,
  onTap: () { },
  child: YourContent(),
)
```

#### ResponsiveGridDelegate
Creates responsive grids:

```dart
GridView(
  gridDelegate: ResponsiveGridDelegate.forContext(context),
  children: [...],
)
```

## Adapting Pages

### Pattern 1: Single Column → Multi-Column Layout

**Mobile (xs)**: Stack vertically
**Tablet (md)**: 2 columns
**Desktop (lg/xl)**: 3+ columns with side content

Example:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return AppScaffoldBody(
    child: context.isDesktop
        ? Row(  // Desktop: side-by-side layout
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _MainContent(),
              ),
              SizedBox(width: context.gridSpacing),
              Expanded(
                flex: 1,
                child: _SidebarContent(),
              ),
            ],
          )
        : SingleChildScrollView(  // Mobile/Tablet: stacked
            padding: context.responsivePadding,
            child: Column(
              children: [
                _MainContent(),
                SizedBox(height: context.gridSpacing),
                _SidebarContent(),
              ],
            ),
          ),
  );
}
```

### Pattern 2: Responsive Grid

```dart
GridView.builder(
  gridDelegate: ResponsiveGridDelegate.forContext(context),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ResponsiveCard(
      enableHover: true,
      onTap: () => onItemTap(items[index]),
      child: ItemWidget(item: items[index]),
    );
  },
)
```

### Pattern 3: Responsive Typography

```dart
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge?.scaleForBreakpoint(context),
)
```

### Pattern 4: Responsive Spacing

```dart
Column(
  children: [
    Widget1(),
    SizedBox(height: ResponsiveSpacing.md(context)),
    Widget2(),
    SizedBox(height: ResponsiveSpacing.lg(context)),
    Widget3(),
  ],
)
```

## Specific Page Guidelines

### Dashboard Page

**Layout**:
- **xs/sm**: Single column, cards stack vertically
- **md**: 2 columns (progress cards side-by-side, radar full width)
- **lg/xl**: 3 columns (main content + sidebar with quick actions)

**Cards to make responsive**:
- Profile progress card
- Discovery progress card
- Radar traits card
- Quick action cards

**Implementation checklist**:
- [ ] Wrap with `AppScaffoldBody`
- [ ] Remove `GradientBackground` (shell handles background)
- [ ] Remove `Scaffold` and `AppBar` (shell provides navigation)
- [ ] Use `context.responsive()` for column counts
- [ ] Replace fixed padding with `context.responsivePadding`
- [ ] Use `ResponsiveCard` instead of `Card`
- [ ] Add grid layout for quick actions on tablet+

### Discover Page

**Layout**:
- **xs**: 1 column grid
- **sm**: 2 column grid
- **md**: 3 column grid
- **lg**: 4 column grid
- **xl**: 5 column grid

**Implementation checklist**:
- [ ] Replace `GridView` with `ResponsiveGridDelegate.forContext(context)`
- [ ] Use `ResponsiveCard` for quiz/game cards with hover effects
- [ ] Add search bar that expands on desktop
- [ ] Category chips responsive wrapping

### Careers Page

**Layout**:
- **xs/sm**: List view with minimal info
- **md**: Grid with 2 columns, expanded cards
- **lg/xl**: Grid with 3 columns + detailed side panel on selection

**Implementation checklist**:
- [ ] Career list → responsive grid
- [ ] Career detail: full screen on mobile, side panel on desktop
- [ ] Filter/sort controls: bottom sheet on mobile, sidebar on desktop

### Roadmap Page

**Layout**:
- **xs/sm**: Vertical timeline
- **md+**: Horizontal timeline with larger nodes

**Implementation checklist**:
- [ ] Responsive timeline orientation
- [ ] Node size adapts to breakpoint
- [ ] Touch targets 44x44 on mobile, smaller hit areas ok on desktop

### Settings Page

**Layout**:
- **xs/sm**: Full width form
- **md+**: Centered form with max width 600px

**Implementation checklist**:
- [ ] Constrain form width on desktop
- [ ] Add hover states to list tiles
- [ ] Larger spacing on desktop

### Auth Screens (Login/Signup)

**Layout**:
- **xs**: Full width card, padding 16
- **sm**: Centered card, width 400
- **md**: Centered card, width 480
- **lg/xl**: Centered card, width 560

**Implementation checklist**:
- [ ] Wrap content in `AppScaffoldBody`
- [ ] Use `Center` with `ConstrainedBox` for form card
- [ ] Responsive card width: `context.responsive(xs: 340, sm: 400, md: 480, lg: 560)`
- [ ] Keep Google sign-in as popup on web
- [ ] Add subtle glass morphism on desktop

## Radar Chart Responsiveness

The radar chart (spider graph) needs to adapt its size and label density:

```dart
AspectRatio(
  aspectRatio: context.responsive(
    xs: 1.0,
    sm: 1.1,
    md: 1.2,
    lg: 1.4,
    xl: 1.4,
  ),
  child: RadarChart(
    labelDensity: context.responsive(
      xs: 0.6,  // Fewer labels on mobile
      sm: 0.8,
      md: 1.0,
      lg: 1.0,
    ),
    // ...
  ),
)
```

## Desktop Interaction Polish

### Hover Effects

Use `ResponsiveCard` which automatically adds hover on desktop, or implement manually:

```dart
class _MyCard extends StatefulWidget {
  @override
  State<_MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<_MyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) {
      // Mobile: no hover
      return Card(child: content);
    }

    // Desktop: hover effects
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Card(
          elevation: _isHovered ? 4 : 2,
          child: content,
        ),
      ),
    );
  }
}
```

### Focus Indicators

Ensure all interactive elements have visible focus indicators:

```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    // Focus indicator automatically provided by Material
  ),
  onPressed: () {},
  child: Text('Action'),
)
```

### Keyboard Shortcuts

Add shortcuts for common actions on desktop:

```dart
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
        const _OpenSearchIntent(),
  },
  child: Actions(
    actions: {
      _OpenSearchIntent: CallbackAction<_OpenSearchIntent>(
        onInvoke: (_) => _openSearch(),
      ),
    },
    child: child,
  ),
)
```

## RTL (Arabic) Support

The responsive system automatically supports RTL:

- Navigation rail mirrors
- Padding/margin directions reverse
- Icons (chevrons) flip automatically

Ensure your custom layouts respect directionality:

```dart
// ✅ Good: Directional padding
Padding(
  padding: EdgeInsetsDirectional.only(start: 16),
  child: child,
)

// ❌ Bad: Hardcoded left padding
Padding(
  padding: EdgeInsets.only(left: 16),
  child: child,
)
```

## Testing Checklist

Test each page at these breakpoints:

- [ ] 360px (xs - small phone)
- [ ] 414px (xs - large phone)
- [ ] 768px (md - tablet)
- [ ] 1024px (lg - small laptop)
- [ ] 1280px (lg - laptop)
- [ ] 1440px (lg - desktop)
- [ ] 1920px (xl - large desktop)

For each breakpoint, verify:

- [ ] No overflows
- [ ] Text readable (not too small/large)
- [ ] Touch targets 44x44 on mobile
- [ ] Hover states on desktop
- [ ] Navigation works correctly
- [ ] Content width constrained on wide screens
- [ ] RTL layout correct (test with Arabic language)
- [ ] Focus indicators visible
- [ ] Keyboard navigation works on desktop

## Performance Considerations

### Avoid Overdraw

On desktop, use solid backgrounds behind gradients:

```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    gradient: context.isDesktop ? linearGradient : null,
  ),
)
```

### Defer Heavy Widgets

Use `FutureBuilder` or deferred loading for heavy content on xl screens:

```dart
if (context.isXl)
  FutureBuilder(
    future: Future.delayed(Duration(milliseconds: 100)),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return SizedBox.shrink();
      }
      return _HeavyInsightsPanel();
    },
  )
```

### Image Optimization

Precache images on desktop for faster loading:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (context.isDesktop) {
    precacheImage(AssetImage('assets/hero.png'), context);
  }
}
```

## Common Patterns Summary

### Responsive Padding
```dart
padding: context.responsivePadding
padding: EdgeInsets.all(ResponsiveSpacing.md(context))
```

### Responsive Grid
```dart
GridView(
  gridDelegate: ResponsiveGridDelegate.forContext(context),
  children: items.map((item) => ResponsiveCard(...)).toList(),
)
```

### Conditional Layout
```dart
context.isMobile ? _MobileLayout() : _DesktopLayout()
```

### Responsive Values
```dart
final value = context.responsive(
  xs: mobileValue,
  md: tabletValue,
  lg: desktopValue,
)
```

### Constrained Content
```dart
AppScaffoldBody(
  maxWidth: 1240,
  child: content,
)
```

## Next Steps

1. ✅ Responsive utilities created
2. ✅ Adaptive shell implemented
3. ✅ Router updated with shell route
4. **TODO**: Update Dashboard page layout
5. **TODO**: Update Discover page grid
6. **TODO**: Update Careers page layout
7. **TODO**: Make radar chart responsive
8. **TODO**: Update auth screens
9. **TODO**: Add desktop polish (hover, focus, keyboard)
10. **TODO**: Test across all breakpoints

## Example: Complete Responsive Page

```dart
class MyResponsivePage extends ConsumerWidget {
  const MyResponsivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffoldBody(
      child: SingleChildScrollView(
        padding: context.responsivePadding,
        child: context.isDesktop
            ? _DesktopLayout()
            : _MobileLayout(),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _HeaderCard(),
              SizedBox(height: ResponsiveSpacing.lg(context)),
              GridView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: ResponsiveGridDelegate.forContext(context),
                children: items.map((item) {
                  return ResponsiveCard(
                    enableHover: true,
                    onTap: () => onItemTap(item),
                    child: ItemWidget(item),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveSpacing.xl(context)),
        Expanded(
          flex: 1,
          child: _Sidebar(),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderCard(),
        SizedBox(height: ResponsiveSpacing.md(context)),
        ...items.map((item) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveSpacing.sm(context),
            ),
            child: ResponsiveCard(
              onTap: () => onItemTap(item),
              child: ItemWidget(item),
            ),
          );
        }),
        SizedBox(height: ResponsiveSpacing.lg(context)),
        _Sidebar(),
      ],
    );
  }
}
```

## Migration Strategy

For each existing page:

1. **Remove outer Scaffold**: The shell provides this
2. **Remove GradientBackground**: Shell handles backgrounds
3. **Remove AppBar**: Navigation in shell
4. **Wrap content with AppScaffoldBody**: Constrains width
5. **Replace fixed padding**: Use `context.responsivePadding`
6. **Replace Card with ResponsiveCard**: Adds hover on desktop
7. **Add responsive layout**: Use `context.isDesktop` for conditional layouts
8. **Use responsive grid delegates**: For GridView widgets
9. **Scale typography**: Use `.scaleForBreakpoint(context)`
10. **Test at all breakpoints**: Verify no overflows

## File Structure

```
lib/
├── core/
│   └── responsive/
│       └── responsive.dart          # Breakpoints, helpers, components
├── presentation/
│   ├── shell/
│   │   └── adaptive_shell.dart      # Adaptive navigation shell
│   └── features/
│       ├── dashboard/
│       │   └── dashboard_page.dart  # TODO: Make responsive
│       ├── discover/
│       │   └── discover_page.dart   # TODO: Make responsive
│       ├── careers/
│       │   └── careers_page.dart    # TODO: Make responsive
│       ├── roadmap/
│       │   └── roadmap_page.dart    # TODO: Make responsive
│       ├── settings/
│       │   └── settings_page.dart   # TODO: Make responsive
│       └── auth/
│           ├── login_page.dart      # TODO: Make responsive
│           └── signup_page.dart     # TODO: Make responsive
```

## Support

For questions or issues with the responsive system:
1. Check this guide first
2. Review `lib/core/responsive/responsive.dart` for available helpers
3. Look at the adaptive shell implementation for navigation patterns
4. Test at multiple breakpoints before finalizing changes

---

**Ready to ship responsive web + desktop!** 🚀
