# Color Palette Reference

## Primary Colors

### 🌊 Teal (Primary)
```
Main:  #38AFB7  RGB(56, 175, 183)   - Vibrant, trustworthy
Light: #5DC5CC  RGB(93, 197, 204)   - For dark mode
Dark:  #2D8A91  RGB(45, 138, 145)   - For emphasis
```

**Usage:**
- Primary buttons and CTAs
- Navigation active states
- Links and interactive elements
- Focus states
- Primary icons

**Psychology:** Trust, clarity, calmness, professionalism

---

### 🔥 Orange (Secondary)
```
Main:  #EDA43B  RGB(237, 164, 59)   - Energetic, warm
Light: #F5BD6B  RGB(245, 189, 107)  - For dark mode
Dark:  #D88F2A  RGB(216, 143, 42)   - For emphasis
```

**Usage:**
- Secondary buttons
- Call-to-action highlights
- Warning messages
- Attention-grabbing elements
- Important notifications

**Psychology:** Energy, enthusiasm, creativity, warmth

---

### 🌱 Lime (Tertiary)
```
Main:  #A4C252  RGB(164, 194, 82)   - Fresh, optimistic
Light: #BDD47A  RGB(189, 212, 122)  - For dark mode
Dark:  #8CAA3F  RGB(140, 170, 63)   - For emphasis
```

**Usage:**
- Success messages and states
- Progress indicators
- Growth/achievement badges
- Positive feedback
- Completion states

**Psychology:** Growth, freshness, optimism, achievement

---

### 💜 Lavender (Accent)
```
Main:  #A587BB  RGB(165, 135, 187)  - Creative, balanced
Light: #C1A7D4  RGB(193, 167, 212)  - For dark mode
Dark:  #8B6FA3  RGB(139, 111, 163)  - For emphasis
```

**Usage:**
- Personality-related features
- Creative sections
- Artistic elements
- Decorative accents
- Subtle highlights

**Psychology:** Creativity, intuition, wisdom, balance

---

## Background & Surface Colors

### Light Mode
```
Background:     #FFFFFF  RGB(255, 255, 255)  - Pure white
Surface:        #FFFFFF  RGB(255, 255, 255)  - Pure white
Card:           #FBFBFB  RGB(251, 251, 251)  - Subtle off-white
Text Primary:   #1A1A1A  RGB(26, 26, 26)     - Soft charcoal
Text Secondary: #5A5A5A  RGB(90, 90, 90)     - Medium grey
```

### Dark Mode
```
Background:     #0A0A0A  RGB(10, 10, 10)     - Near black
Surface:        #121212  RGB(18, 18, 18)     - Dark grey
Card:           #1E1E1E  RGB(30, 30, 30)     - Card background
Text Primary:   #F5F5F5  RGB(245, 245, 245)  - Warm white
Text Secondary: #E0E0E0  RGB(224, 224, 224)  - Light grey
```

---

## Status Colors

### Success
```
Color:  #A4C252  (Lime)
Usage:  Completed tasks, successful operations, achievements
```

### Warning
```
Color:  #EDA43B  (Orange)
Usage:  Alerts, important notices, required actions
```

### Error
```
Color:  #E57373  RGB(229, 115, 115)  - Soft red
Usage:  Errors, failed operations, validation issues
```

### Info
```
Color:  #38AFB7  (Teal)
Usage:  Information messages, tips, neutral notifications
```

---

## Gradients

### Primary Gradient (Teal → Lavender → Lime)
```css
linear-gradient(135deg, #38AFB7 0%, #A587BB 50%, #A4C252 100%)
```
**Usage:** Hero sections, feature cards, main highlights

### Secondary Gradient (Orange → Teal)
```css
linear-gradient(135deg, #EDA43B 0%, #38AFB7 100%)
```
**Usage:** Buttons, interactive elements, warm-to-cool transitions

### Accent Gradient (Lavender → Lime)
```css
linear-gradient(135deg, #A587BB 0%, #A4C252 100%)
```
**Usage:** Decorative elements, personality features, creative sections

---

## Opacity Guidelines

### Subtle Backgrounds
```
5%  opacity (0.05)  - Very subtle hint of color
8%  opacity (0.08)  - Barely noticeable tint
10% opacity (0.10)  - Gentle background tint
```

### Borders & Dividers
```
10% opacity (0.10)  - Minimal border
15% opacity (0.15)  - Subtle border
20% opacity (0.20)  - Visible but soft border
```

### Hover & Focus States
```
20% opacity (0.20)  - Light hover effect
30% opacity (0.30)  - Medium hover effect
40% opacity (0.40)  - Strong hover effect
```

---

## Color Combinations

### For Cards & Containers
```
Light Mode:
- Background: #FFFFFF
- Border: #38AFB7 at 8% opacity
- Text: #1A1A1A

Dark Mode:
- Background: #1E1E1E
- Border: #5DC5CC at 10% opacity
- Text: #F5F5F5
```

### For Buttons
```
Primary (Teal):
- Background: #38AFB7 (light) / #5DC5CC (dark)
- Text: #FFFFFF (light) / #0A0A0A (dark)

Secondary (Orange):
- Background: #EDA43B (light) / #F5BD6B (dark)
- Text: #FFFFFF (light) / #0A0A0A (dark)

Outlined:
- Border: Primary color
- Text: Primary color
- Background: Transparent
```

---

## Accessibility (WCAG AA)

### Contrast Ratios - Light Mode
```
#1A1A1A on #FFFFFF  = 15.2:1  ✅ AAA (Normal & Large)
#38AFB7 on #FFFFFF  = 2.8:1   ⚠️  Use for large text only
#FFFFFF on #38AFB7  = 3.8:1   ✅ AA (Large text)
#EDA43B on #FFFFFF  = 2.4:1   ⚠️  Use for large text only
```

### Contrast Ratios - Dark Mode
```
#F5F5F5 on #0A0A0A  = 17.8:1  ✅ AAA (Normal & Large)
#5DC5CC on #0A0A0A  = 8.5:1   ✅ AAA (Normal & Large)
#F5BD6B on #0A0A0A  = 9.2:1   ✅ AAA (Normal & Large)
#BDD47A on #0A0A0A  = 8.9:1   ✅ AAA (Normal & Large)
```

**Note:** For text on colored backgrounds, always ensure minimum 4.5:1 contrast ratio.

---

## Quick Copy-Paste

### Hex Codes
```
#38AFB7  Teal
#EDA43B  Orange
#A4C252  Lime
#A587BB  Lavender
```

### RGB Values
```
rgb(56, 175, 183)    Teal
rgb(237, 164, 59)    Orange
rgb(164, 194, 82)    Lime
rgb(165, 135, 187)   Lavender
```

### Flutter Color Constructors
```dart
Color(0xFF38AFB7)  // Teal
Color(0xFFEDA43B)  // Orange
Color(0xFFA4C252)  // Lime
Color(0xFFA587BB)  // Lavender
```

### CSS Variables (if needed)
```css
:root {
  --color-teal: #38AFB7;
  --color-orange: #EDA43B;
  --color-lime: #A4C252;
  --color-lavender: #A587BB;
}
```

---

## Design Tokens (Figma/Design Tools)

```
Primary/Main           #38AFB7
Primary/Light          #5DC5CC
Primary/Dark           #2D8A91

Secondary/Main         #EDA43B
Secondary/Light        #F5BD6B
Secondary/Dark         #D88F2A

Tertiary/Main          #A4C252
Tertiary/Light         #BDD47A
Tertiary/Dark          #8CAA3F

Accent/Main            #A587BB
Accent/Light           #C1A7D4
Accent/Dark            #8B6FA3

Neutral/White          #FFFFFF
Neutral/Black          #0A0A0A
Neutral/Grey-50        #FBFBFB
Neutral/Grey-100       #F5F5F5
Neutral/Grey-200       #E0E0E0
Neutral/Grey-800       #1E1E1E
Neutral/Grey-900       #121212
```
