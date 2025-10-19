# Lottie Animations

This directory contains Lottie animation files for the Teen UX upgrade.

## Required Animations

### Theme-Specific Animations

Each theme needs the following animations:

#### Neon Arcade Theme
- `neon_success.json` - Success/completion animation
- `neon_confetti.json` - Confetti celebration
- `neon_pulse.json` - Idle/pulse animation

#### Galaxy Pulse Theme
- `galaxy_success.json` - Success/completion animation
- `galaxy_confetti.json` - Confetti celebration
- `galaxy_pulse.json` - Idle/pulse animation

#### Street Pop Theme
- `street_success.json` - Success/completion animation
- `street_confetti.json` - Confetti celebration
- `street_pulse.json` - Idle/pulse animation

#### Ocean Wave Theme
- `ocean_success.json` - Success/completion animation
- `ocean_confetti.json` - Confetti celebration
- `ocean_pulse.json` - Idle/pulse animation

#### Retro Pixel Theme
- `retro_success.json` - Success/completion animation
- `retro_confetti.json` - Confetti celebration
- `retro_pulse.json` - Idle/pulse animation

## Sources

You can find free Lottie animations at:
- [LottieFiles](https://lottiefiles.com/)
- [Lordicon](https://lordicon.com/)
- Create custom animations with After Effects + Bodymovin plugin

## Usage in Code

```dart
import 'package:lottie/lottie.dart';
import '../common/theme/teen_palette_extension.dart';

// Get current theme
final theme = Theme.of(context).teenPalette;

// Load theme-specific animation
Lottie.asset(
  theme.lottieSet['success']!,
  width: 200,
  height: 200,
  repeat: false,
)
```

## Animation Guidelines

- **Duration**: 1-3 seconds for success/confetti, infinite loop for pulse
- **File Size**: < 100KB per file (optimize with LottieFiles)
- **Colors**: Match theme primary/secondary colors when possible
- **Format**: JSON format exported from After Effects or downloaded from LottieFiles
