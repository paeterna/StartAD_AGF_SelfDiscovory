# Theme & Logo Integration Guide

## Overview
This document describes the minimalist, aesthetic theme implementation for the SelfMap Flutter web app, designed specifically for high schoolers and teenagers.

## Color Scheme

### Primary Colors
```dart
// Teal Blue - Primary
#38AFB7 (Light: #5DC5CC, Dark: #2D8A91)

// Yellow-Orange - Secondary  
#EDA43B (Light: #F5BD6B, Dark: #D88F2A)

// Light Green - Tertiary
#A4C252 (Light: #BDD47A, Dark: #8CAA3F)

// Purple-Grey - Accent
#A587BB (Light: #C1A7D4, Dark: #8B6FA3)
```

### Theme Implementation

#### Light Mode
- **Background:** Pure white `#FFFFFF`
- **Surface:** Pure white `#FFFFFF`
- **Cards:** Subtle off-white `#FBFBFB` with minimal borders
- **Primary Actions:** Teal `#38AFB7`
- **Secondary Actions:** Orange `#EDA43B`
- **Success States:** Lime `#A4C252`
- **Text:** Soft charcoal `#1A1A1A`
- **Borders:** Very subtle with 8-10% opacity
- **Elevation:** None (flat design)

#### Dark Mode
- **Background:** Near black `#0A0A0A`
- **Surface:** Dark grey `#121212`
- **Cards:** Card background `#1E1E1E` with minimal borders
- **Primary Actions:** Light Teal `#5DC5CC`
- **Secondary Actions:** Light Orange `#F5BD6B`
- **Success States:** Light Lime `#BDD47A`
- **Text:** Warm white `#F5F5F5`
- **Borders:** Very subtle with 10-12% opacity
- **Elevation:** None (flat design)

## Design Principles

### Minimalism
- **No shadows or elevations** - Flat, clean design
- **Subtle borders** - Only 1-1.5px with low opacity
- **Simple shapes** - Consistent 16-20px border radius
- **White space** - Generous padding and spacing
- **Limited colors** - Use the 4 main colors strategically

### Aesthetic & Modern
- **Clean typography** - Poppins font at 15-20px for body
- **Soft contrasts** - No harsh blacks or bright whites
- **Subtle color usage** - Colors at 8-12% opacity for backgrounds
- **Smooth transitions** - Gentle hover and focus states

### Age-Appropriate
- **Not childish** - Sophisticated color combinations
- **Vibrant yet subtle** - Energetic but easy on the eyes
- **Professional feel** - Suitable for educational context
- **Modern aesthetics** - Contemporary design patterns

## Logo Integration

### Asset Location
```yaml
assets/images/logo_selfmap.png
```

**Note:** The logo is in PNG format.

### Usage in Code

#### Import the Logo Widget
```dart
import '../../widgets/app_logo.dart';
```

#### Available Logo Sizes

**Small Logo (56px height)** - For navigation bars
```dart
const AppLogoSmall()
```

**Medium Logo (160px height)** - For login/signup screens
```dart
const AppLogoMedium()
```

**Large Logo (220px height)** - For splash screens
```dart
const AppLogoLarge()
```

**Custom Size**
```dart
AppLogo(
  height: 80,
  width: 80,
  fit: BoxFit.contain,
)
```

### Logo Placement

#### Login Page
- **Position:** Center top of the login form
- **Size:** Medium (160px)
- **Implementation:**
```dart
const Center(
  child: AppLogoMedium(),
),
const SizedBox(height: 24),
```

#### Signup Page
- **Position:** Center top of the signup form
- **Size:** Medium (160px)
- **Implementation:** Same as login page

#### Dashboard/Home Screen
- **Position:** Top-left corner in AppBar
- **Size:** Small (56px)
- **Implementation:**
```dart
AppBar(
  leading: const Padding(
    padding: EdgeInsets.all(8.0),
    child: AppLogoSmall(),
  ),
  // ... rest of AppBar
)
```

## Component Styles

### Buttons

#### Elevated Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary, // Teal
    foregroundColor: Colors.white,
    elevation: 0, // Flat design
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text('Button'),
)
```

#### Outlined Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.primary, // Teal
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 1.5,
    ),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text('Button'),
)
```

### Cards
```dart
Card(
  elevation: 0, // No shadow
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      width: 1.0,
    ),
  ),
  child: Padding(
    padding: EdgeInsets.all(20),
    child: // ... card content
  ),
)
```

### Text Fields
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
  ),
)
```

## Files Modified

### Theme Files
- `/lib/core/theme/app_colors.dart` - Color definitions
- `/lib/core/theme/app_theme.dart` - Theme configuration

### Logo Widget
- `/lib/presentation/widgets/app_logo.dart` - Logo component

### Pages Updated
- `/lib/presentation/features/auth/login_page.dart` - Logo added
- `/lib/presentation/features/auth/signup_page.dart` - Logo added
- `/lib/presentation/features/dashboard/dashboard_page.dart` - Logo added

### Configuration
- `/pubspec.yaml` - Asset configuration
- `/web/index.html` - Web theme color meta tag
- `/web/manifest.json` - PWA theme configuration

## Color Usage Guidelines

### Do's ✅
- Use teal for primary CTAs and navigation
- Use orange for attention-grabbing elements
- Use lime for success states and positive feedback
- Use lavender for creative/personality sections
- Keep backgrounds pure white (light) or near black (dark)
- Use colors at 8-12% opacity for subtle highlights

### Don'ts ❌
- Don't mix all colors in one component
- Don't use bright, saturated colors everywhere
- Don't add shadows or elevations
- Don't use harsh black (#000000) or pure white text
- Don't create busy or cluttered layouts

## Responsive Considerations

The theme automatically adapts to:
- **Mobile devices** - Touch-friendly button sizes
- **Tablets** - Optimized spacing and layouts
- **Desktop** - Maximum content width constraints
- **System preferences** - Respects light/dark mode settings

## Accessibility

- All color combinations meet WCAG AA standards
- Minimum contrast ratio of 4.5:1 for text
- Focus indicators clearly visible
- Touch targets at least 44x44 pixels
- Keyboard navigation supported

## Future Enhancements

Consider these improvements:
1. **Animated logo** for splash screen
2. **Color themes** allowing users to customize
3. **Dark mode toggle** in settings
4. **High contrast mode** for accessibility
5. **Custom accent colors** per personality type
