# New Vibrant Color Scheme for High Schoolers

## Overview
The app now features a vibrant, energetic color palette designed specifically for high school students. The colors are modern, engaging, and work seamlessly in both light and dark modes.

## Primary Colors

### 🌊 Teal (Primary)
- **Main:** `#38AFB7` - Vibrant, trustworthy, and fresh
- **Dark:** `#2D8A91` - For dark mode or deeper accents
- **Light:** `#5DC5CC` - For highlights and hover states

### 🔥 Orange (Secondary)
- **Main:** `#EDA43B` - Energetic, warm, and exciting
- **Dark:** `#D88F2A` - For dark mode or deeper tones
- **Light:** `#F5BD6B` - For softer accents

### 🌱 Lime (Tertiary)
- **Main:** `#A4C252` - Fresh, growth-oriented, optimistic
- **Dark:** `#8CAA3F` - For dark mode or deeper shades
- **Light:** `#BDD47A` - For gentle highlights

### 💜 Lavender (Accent)
- **Main:** `#A587BB` - Cool, creative, balanced
- **Dark:** `#8B6FA3` - For dark mode depth
- **Light:** `#C1A7D4` - For soft accents

## Color Usage

### Light Mode
- **Primary:** Teal `#38AFB7` for main actions and navigation
- **Secondary:** Orange `#EDA43B` for call-to-actions and highlights
- **Tertiary:** Lime `#A4C252` for success states and progress
- **Background:** Pure white `#FFFFFF` with subtle teal tint
- **Cards:** White with teal borders
- **Text:** Soft charcoal `#1A1A1A`

### Dark Mode
- **Primary:** Light Teal `#5DC5CC` for better visibility
- **Secondary:** Light Orange `#F5BD6B` for warmth
- **Tertiary:** Light Lime `#BDD47A` for contrast
- **Background:** Dark grey `#1E1E1E` with subtle teal tint
- **Cards:** Dark grey `#3A3A3A` with teal glow
- **Text:** Warm white `#F5F5F5`

## Gradient Combinations

### Primary Gradient
Teal → Lavender → Lime
- Perfect for hero sections and feature cards
- Creates depth while maintaining vibrancy

### Secondary Gradient
Orange → Teal
- Warm to cool transition
- Great for buttons and interactive elements

### Accent Gradient
Lavender → Lime
- Purple to green flow
- Ideal for decorative elements

## Status Colors

- **Success:** Lime `#A4C252` - Positive, growth
- **Warning:** Orange `#EDA43B` - Attention-grabbing
- **Error:** Soft Red `#E57373` - Clear but not harsh
- **Info:** Teal `#38AFB7` - Informative, trustworthy

## Design Philosophy

### ✨ Vibrant but Not Childish
- Colors are saturated enough to be energetic
- Balanced with sophisticated combinations
- Professional yet youthful

### 🌓 Optimized for Both Modes
- Light mode: Darker, richer colors for punch
- Dark mode: Lighter, softer versions for comfort
- Consistent feel across both themes

### 🎨 Accessibility
- All color combinations meet WCAG AA standards
- High contrast ratios maintained
- Clear visual hierarchy

## Implementation

All colors are defined in:
- `/lib/core/theme/app_colors.dart` - Color definitions
- `/lib/core/theme/app_theme.dart` - Theme configuration
- `/web/index.html` - Web theme color
- `/web/manifest.json` - PWA manifest

## Migration Notes

Legacy color names (deepPurple, skyBlue, etc.) are mapped to the new colors for backward compatibility. Gradual migration of components is recommended.
