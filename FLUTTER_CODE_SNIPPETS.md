# Flutter Code Snippets for Theme & Logo

## 1. Updated pubspec.yaml Configuration

```yaml
name: startad_agf_selfdiscovery
description: "SelfMap - A self-discovery platform for high-school students"

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/i18n/
    - assets/assessments/
    - assets/images/
    - assets/images/memory_cards/
    - assets/images/logo_selfmap.png  # Logo asset
    - .env
```

## 2. Theme Configuration (ThemeData)

### Complete Light Theme
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData get lightTheme {
  final colorScheme = ColorScheme.light(
    primary: const Color(0xFF38AFB7), // Teal
    secondary: const Color(0xFFEDA43B), // Orange
    tertiary: const Color(0xFFA4C252), // Lime
    error: const Color(0xFFE57373), // Soft red
    surface: Colors.white,
    onSurface: const Color(0xFF1A1A1A), // Soft charcoal
    surfaceContainerHighest: const Color(0xFFFBFBFB), // Subtle off-white
    outline: const Color(0xFFA587BB).withValues(alpha: 0.3), // Lavender
    primaryContainer: const Color(0xFF5DC5CC), // Light teal
    secondaryContainer: const Color(0xFFF5BD6B), // Light orange
    tertiaryContainer: const Color(0xFFBDD47A), // Light lime
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,

    // Typography
    textTheme: GoogleFonts.poppinsTextTheme(),

    // Card theme - Minimalist
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      color: Colors.white,
    ),

    // AppBar theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFBFBFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    ),
  );
}
```

### Complete Dark Theme
```dart
ThemeData get darkTheme {
  final colorScheme = ColorScheme.dark(
    primary: const Color(0xFF5DC5CC), // Light teal for dark mode
    secondary: const Color(0xFFF5BD6B), // Light orange for dark mode
    tertiary: const Color(0xFFBDD47A), // Light lime for dark mode
    error: const Color(0xFFE57373), // Soft red
    surface: const Color(0xFF121212), // Dark grey
    onSurface: const Color(0xFFF5F5F5), // Warm white
    surfaceContainerHighest: const Color(0xFF1E1E1E), // Card background
    outline: const Color(0xFFC1A7D4).withValues(alpha: 0.3), // Light lavender
    primaryContainer: const Color(0xFF2D8A91), // Dark teal
    secondaryContainer: const Color(0xFFD88F2A), // Dark orange
    tertiaryContainer: const Color(0xFF8CAA3F), // Dark lime
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),

    // Typography
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

    // Card theme - Minimalist dark
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      color: const Color(0xFF1E1E1E),
    ),

    // AppBar theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xFF0A0A0A),
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),

    // Same button and input themes as light mode
    // (colors automatically adapt through colorScheme)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: const Color(0xFF0A0A0A),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
```

## 3. Logo Widget Component

```dart
import 'package:flutter/material.dart';

/// Reusable logo widget for the SelfMap application
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_selfmap.png',
      height: height,
      width: width,
      fit: fit,
    );
  }
}

/// Small logo for navigation bars (40px)
class AppLogoSmall extends StatelessWidget {
  const AppLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(height: 40);
  }
}

/// Medium logo for login screens (120px)
class AppLogoMedium extends StatelessWidget {
  const AppLogoMedium({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(height: 120);
  }
}

/// Large logo for splash screens (180px)
class AppLogoLarge extends StatelessWidget {
  const AppLogoLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(height: 180);
  }
}
```

## 4. Login Screen with Logo

```dart
import 'package:flutter/material.dart';
import 'app_logo.dart'; // Import the logo widget

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo centered on top
                  const Center(
                    child: AppLogoMedium(),
                  ),
                  const SizedBox(height: 24),
                  
                  // App Name
                  Text(
                    'SelfMap',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Discover Your Future',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      // Handle login
                    },
                    child: const Text('Log In'),
                  ),
                  const SizedBox(height: 16),

                  // Sign up link
                  TextButton(
                    onPressed: () {
                      // Navigate to signup
                    },
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## 5. Home Screen with Logo in AppBar

```dart
import 'package:flutter/material.dart';
import 'app_logo.dart'; // Import the logo widget

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // Logo in top-left corner
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: AppLogoSmall(),
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Feature cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Your Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete your personality assessment to unlock personalized career recommendations.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to assessment
                      },
                      child: const Text('Start Assessment'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 6. Accessing Theme Colors in Code

```dart
// Get current theme's color scheme
final colorScheme = Theme.of(context).colorScheme;

// Primary color (Teal in light mode, Light Teal in dark mode)
final primaryColor = colorScheme.primary;

// Secondary color (Orange in light mode, Light Orange in dark mode)
final secondaryColor = colorScheme.secondary;

// Tertiary color (Lime in light mode, Light Lime in dark mode)
final tertiaryColor = colorScheme.tertiary;

// Accent color (Lavender)
final accentColor = colorScheme.outline;

// Use colors with opacity
Container(
  decoration: BoxDecoration(
    color: colorScheme.primary.withValues(alpha: 0.1),
    border: Border.all(
      color: colorScheme.primary.withValues(alpha: 0.3),
    ),
    borderRadius: BorderRadius.circular(16),
  ),
)
```

## 7. Complete App Setup

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SelfMap',
      debugShowCheckedModeBanner: false,
      
      // Apply light theme
      theme: lightTheme,
      
      // Apply dark theme
      darkTheme: darkTheme,
      
      // Let system decide which theme to use
      themeMode: ThemeMode.system,
      
      // Start with login page
      home: const LoginPage(),
    );
  }
}
```

## Color Reference Table

| Color Name | Light Mode | Dark Mode | Usage |
|------------|-----------|-----------|-------|
| Primary (Teal) | `#38AFB7` | `#5DC5CC` | Main CTAs, navigation |
| Secondary (Orange) | `#EDA43B` | `#F5BD6B` | Attention-grabbing elements |
| Tertiary (Lime) | `#A4C252` | `#BDD47A` | Success states, growth |
| Accent (Lavender) | `#A587BB` | `#C1A7D4` | Creative sections |
| Background | `#FFFFFF` | `#0A0A0A` | Main background |
| Surface | `#FFFFFF` | `#121212` | AppBar, bottom nav |
| Card | `#FBFBFB` | `#1E1E1E` | Card surfaces |
| Text Primary | `#1A1A1A` | `#F5F5F5` | Main text |

## Testing Theme Changes

```dart
// Toggle theme mode for testing
ThemeMode _themeMode = ThemeMode.light;

void toggleTheme() {
  setState(() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
  });
}
```
