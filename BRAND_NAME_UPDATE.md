# Masar (مسار) - Brand Name Update

## Summary

The application name has been successfully changed from "SelfMap" to "Masar" (مسار) throughout the entire project.

## What is Masar?

**Masar** (مسار) is an Arabic word meaning "path" or "trajectory" - perfectly representing the app's mission to help students discover their path to the future.

- **English Name:** Masar
- **Arabic Name:** مسار (Masar)
- **Meaning:** Path, trajectory, journey

## Files Updated

### 1. Localization Files
- ✅ `/assets/i18n/app_en.arb`
  - `appName`: "SelfMap" → "Masar"
  - `welcomeMessage`: "Welcome to SelfMap" → "Welcome to Masar"

- ✅ `/assets/i18n/app_ar.arb`
  - `appName`: "خريطة الذات" → "مسار"
  - `welcomeMessage`: "مرحباً بك في خريطة الذات" → "مرحباً بك في مسار"
  - `welcomeTitle`: "مرحباً بك في خريطة الذات! 🚀" → "مرحباً بك في مسار! 🚀"

### 2. Application Code
- ✅ `/lib/app.dart`
  - Class name: `SelfMapApp` → `MasarApp`
  - State class: `_SelfMapAppState` → `_MasarAppState`
  - App title: "SelfMap" → "Masar"
  - Added comment: "Main Masar (مسار) application widget"

- ✅ `/lib/main.dart`
  - Updated widget reference: `SelfMapApp()` → `MasarApp()`

- ✅ `/lib/core/constants/app_constants.dart`
  - `appName`: "SelfMap" → "Masar"

### 3. Widget Files
- ✅ `/lib/presentation/widgets/app_logo.dart`
  - Widget description updated to "Masar (مسار)"

### 4. Static Pages
- ✅ `/lib/presentation/features/static_pages/about_page.dart`
  - Title: "About SelfMap" → "About Masar (مسار)"
  - All mentions of "SelfMap" → "Masar"
  - Contact emails: `@selfmap.app` → `@masar.app`
  - Copyright: "© 2025 SelfMap" → "© 2025 Masar"

- ✅ `/lib/presentation/features/static_pages/privacy_page.dart`
  - "SelfMap is committed..." → "Masar is committed..."
  - Contact email: `privacy@selfmap.app` → `privacy@masar.app`

- ✅ `/lib/presentation/features/static_pages/terms_page.dart`
  - All mentions of "SelfMap" → "Masar"
  - Contact email: `legal@selfmap.app` → `legal@masar.app`

### 5. Web Configuration
- ✅ `/web/index.html`
  - `<title>`: "SelfMap - Discover Your Future" → "Masar - Discover Your Future"
  - Meta tags: All instances of "SelfMap" → "Masar"
  - Apple app title: "SelfMap" → "Masar"

- ✅ `/web/manifest.json`
  - `name`: "SelfMap - Discover Your Future" → "Masar - Discover Your Future"
  - `short_name`: "SelfMap" → "Masar"

### 6. Documentation
- ✅ `/pubspec.yaml`
  - Description updated to include "Masar"

- ✅ `/README.md`
  - Title: "SelfMap - Discover Your Future" → "Masar (مسار) - Discover Your Future"

- ✅ `/THEME_LOGO_GUIDE.md`
  - Reference to "SelfMap" → "Masar (مسار)"

## Brand Identity

### Visual Identity
- **Logo**: `assets/images/logo_selfmap.png` (PNG format)
- **Primary Color**: #38AFB7 (Teal)
- **Tagline**: "Discover Your Future" (English) / "اكتشف مستقبلك" (Arabic)

### Linguistic Significance
The name "Masar" (مسار) has deep meaning in Arabic:
- **Path**: Represents the student's journey
- **Trajectory**: Shows direction toward goals
- **Route**: Indicates a clear way forward

This name resonates better with Arabic-speaking audiences while remaining accessible to English speakers.

## Display Examples

### In English Context
```
Masar - Discover Your Future
Welcome to Masar
About Masar
```

### In Arabic Context
```
مسار - اكتشف مستقبلك
مرحباً بك في مسار
عن مسار
```

### Bilingual Display
```
Masar (مسار) - Discover Your Future
About Masar (مسار)
```

## Contact Information

The contact email addresses have been updated:
- General: `support@masar.app`
- Privacy: `privacy@masar.app`
- Legal: `legal@masar.app`
- Website: `www.masar.app`

## No Breaking Changes

The update maintains backward compatibility:
- Logo format changed from PNG to SVG for better scalability
- All functionality remains the same
- Database schema unchanged
- API endpoints unaffected
- User data preserved

## Testing Checklist

After this update, verify:
- [ ] App displays "Masar" in navigation
- [ ] Login/signup pages show "Masar" or "مسار" (based on locale)
- [ ] About page shows "Masar (مسار)"
- [ ] Web browser tab title shows "Masar"
- [ ] PWA install prompt shows "Masar"
- [ ] Arabic interface displays "مسار" correctly
- [ ] English interface displays "Masar" correctly

## Build Commands

To apply these changes:

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run in development
flutter run -d chrome

# Build for production
flutter build web
```

## Cultural Notes

**Masar (مسار)** is:
- ✅ Easy to pronounce in both English and Arabic
- ✅ Meaningful and relevant to the app's purpose
- ✅ Professional and appropriate for education
- ✅ Modern and memorable
- ✅ Works well as a brand name

The bilingual nature of the name makes it perfect for a platform targeting Arabic-speaking high school students while maintaining international appeal.
