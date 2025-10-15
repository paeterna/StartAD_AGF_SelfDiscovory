# Project Structure Overview

Complete directory structure for the SelfMap Flutter Web MVP.

## 📂 Root Directory

```
StartAD_AGF_SelfDiscovory/
├── .env                          # Environment variables (not in git)
├── .gitignore
├── analysis_options.yaml         # Linting rules (very_good_analysis)
├── l10n.yaml                     # Localization configuration
├── pubspec.yaml                  # Dependencies and assets
├── README.md                     # Main documentation
├── PHASE2_INTEGRATION.md         # Backend integration guide
├── PROJECT_STRUCTURE.md          # This file
│
├── assets/                       # Static assets
│   ├── i18n/                     # Localization files
│   │   ├── app_en.arb           # English translations (100+ strings)
│   │   └── app_ar.arb           # Arabic translations (100+ strings)
│   └── graphics/                 # SVG icons and images (placeholder)
│
├── lib/                          # Main source code
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # Root app widget
│   │
│   ├── core/                     # Core infrastructure
│   │   ├── theme/
│   │   │   ├── app_colors.dart   # Color palette (neon theme)
│   │   │   └── app_theme.dart    # Theme configuration (dark/light)
│   │   ├── router/
│   │   │   └── app_router.dart   # go_router with auth guards
│   │   ├── utils/
│   │   │   └── validators.dart   # Form validators
│   │   ├── constants/
│   │   │   ├── app_constants.dart   # App-wide constants
│   │   │   └── semantics.dart       # Accessibility labels
│   │   └── providers/
│   │       └── providers.dart    # Riverpod providers
│   │
│   ├── domain/                   # Business logic (pure Dart)
│   │   ├── entities/
│   │   │   ├── user.dart         # User entity + ThemeModePreference
│   │   │   ├── assessment.dart   # Assessment + AssessmentType
│   │   │   ├── career.dart       # Career + CareerCluster
│   │   │   └── roadmap.dart      # Roadmap + RoadmapStep + Category
│   │   ├── value_objects/
│   │   │   └── progress.dart     # DiscoveryProgress value object
│   │   └── repositories/         # Repository interfaces
│   │       ├── auth_repository.dart
│   │       ├── assessment_repository.dart
│   │       ├── career_repository.dart
│   │       ├── roadmap_repository.dart
│   │       └── progress_repository.dart
│   │
│   ├── data/                     # Data layer
│   │   ├── models/
│   │   │   └── user_model.dart   # User serialization model
│   │   ├── sources/
│   │   │   ├── local_prefs.dart  # SharedPreferences wrapper
│   │   │   └── mock_data.dart    # Seed data (10 careers, 3 quizzes)
│   │   └── repositories_impl/    # Repository implementations
│   │       ├── auth_repository_impl.dart         # Mock auth
│   │       ├── assessment_repository_impl.dart   # Mock assessments
│   │       ├── career_repository_impl.dart       # Rule-based matching
│   │       ├── roadmap_repository_impl.dart      # Mock roadmaps
│   │       └── progress_repository_impl.dart     # In-memory progress
│   │
│   ├── application/              # Application logic (controllers)
│   │   ├── auth/
│   │   │   └── auth_controller.dart   # Auth state + Riverpod
│   │   └── analytics/
│   │       └── analytics_service.dart # Analytics interface + mock
│   │
│   └── presentation/             # UI layer
│       ├── features/
│       │   ├── auth/
│       │   │   ├── login_page.dart
│       │   │   └── signup_page.dart
│       │   ├── onboarding/
│       │   │   └── onboarding_page.dart    # 5-question quiz
│       │   ├── dashboard/
│       │   │   └── dashboard_page.dart     # Progress + quick actions
│       │   ├── discover/
│       │   │   └── discover_page.dart      # Quizzes/games tabs
│       │   ├── careers/
│       │   │   └── careers_page.dart       # Career cards + match scores
│       │   ├── roadmap/
│       │   │   └── roadmap_page.dart       # Step checklist
│       │   ├── settings/
│       │   │   └── settings_page.dart      # Profile, locale, theme
│       │   └── static_pages/
│       │       ├── privacy_page.dart
│       │       ├── terms_page.dart
│       │       └── about_page.dart
│       └── widgets/                        # Reusable UI components
│           └── (placeholder for shared widgets)
│
├── supabase/                     # Supabase backend (Phase-2)
│   └── migrations/
│       └── 00001_init_schema.sql  # Complete DB schema + RLS
│
├── test/                         # Tests
│   └── widget_test.dart          # Placeholder test
│
└── web/                          # Web-specific files
    ├── index.html                # Enhanced with SEO meta tags
    ├── manifest.json             # PWA manifest (updated)
    ├── favicon.png
    └── icons/                    # PWA icons (192, 512, maskable)
```

## 📊 File Count Summary

| Directory | Files | Description |
|-----------|-------|-------------|
| **Core** | 7 | Theme, router, utilities, constants |
| **Domain** | 9 | Entities, value objects, interfaces |
| **Data** | 8 | Models, sources, mock implementations |
| **Application** | 2 | Controllers, services |
| **Presentation** | 15 | All UI pages and screens |
| **Assets** | 2 | Localization ARB files |
| **Supabase** | 1 | Database migration |
| **Web** | 5+ | PWA configuration |
| **Total** | **50+** | Complete production-ready MVP |

## 🎯 Key Files by Purpose

### Authentication Flow
```
lib/presentation/features/auth/login_page.dart          # Entry point
lib/application/auth/auth_controller.dart               # State mgmt
lib/data/repositories_impl/auth_repository_impl.dart    # Mock impl
lib/domain/repositories/auth_repository.dart            # Interface
```

### Career Matching
```
lib/presentation/features/careers/careers_page.dart     # UI
lib/data/repositories_impl/career_repository_impl.dart  # Rule engine
lib/data/sources/mock_data.dart                         # 10 careers
lib/domain/entities/career.dart                         # Entity
```

### Theme System
```
lib/core/theme/app_colors.dart                          # Neon palette
lib/core/theme/app_theme.dart                           # Dark/light themes
lib/app.dart                                            # Theme provider
```

### Localization
```
assets/i18n/app_en.arb                                  # 100+ EN strings
assets/i18n/app_ar.arb                                  # 100+ AR strings
l10n.yaml                                               # Config
lib/generated/l10n/                                     # Generated (auto)
```

## 🚀 Entry Points

1. **`lib/main.dart`** - App initialization
   - Loads `.env`
   - Initializes `SharedPreferences`
   - Sets up Riverpod providers

2. **`lib/app.dart`** - Root widget
   - Theme configuration
   - Router setup
   - Locale handling

3. **`lib/core/router/app_router.dart`** - Navigation
   - Route definitions
   - Auth guards
   - Onboarding gates

## 🔗 Dependency Flow

```
Presentation Layer (UI)
    ↓ uses
Application Layer (Controllers)
    ↓ calls
Domain Layer (Interfaces)
    ↓ implemented by
Data Layer (Repositories)
    ↓ uses
Sources (Local/Remote)
```

## 📝 Code Style

- **Naming**: snake_case for files, PascalCase for classes
- **Linting**: `very_good_analysis` rules
- **Comments**: Extension points marked with `// Extension point: ...`
- **TODOs**: Phase-2 items marked with `// TODO: Phase-2`

## 🔄 State Management

All state is managed via **Riverpod**:

```dart
// Provider definition
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(...);

// Usage in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    // ...
  }
}
```

## 🗄️ Data Flow Example

**User Sign Up Flow:**

```
1. User enters email/password in signup_page.dart
2. SignupPage calls authController.signUp()
3. AuthController calls authRepository.signUp()
4. AuthRepositoryImpl creates mock user
5. User data stored in SharedPreferences
6. AuthController updates state
7. Router redirects to onboarding
```

## 📦 Build Outputs

After `flutter build web --release`:

```
build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── manifest.json
├── icons/
└── assets/
    ├── fonts/
    ├── packages/
    └── AssetManifest.json
```

## 🎨 Theme Structure

```dart
AppTheme
├── lightTheme
│   ├── ColorScheme (neon teal primary)
│   ├── TextTheme (Inter font)
│   ├── CardTheme (glassmorphism)
│   └── InputDecoration (rounded)
└── darkTheme
    ├── ColorScheme (same neon)
    ├── TextTheme (high contrast)
    ├── CardTheme (glass + glow)
    └── InputDecoration (dark)
```

## 🌍 Localization Keys

All UI strings are in ARB files under these categories:

- `app*` - App metadata
- `auth*` - Authentication screens
- `onboarding*` - Onboarding flow
- `dashboard*` - Dashboard elements
- `discover*` - Discovery features
- `careers*` - Career pages
- `roadmap*` - Roadmap features
- `settings*` - Settings options
- `privacy*`, `terms*`, `about*` - Static pages
- `error*` - Error messages
- `empty*` - Empty states
- `*Button` - Action buttons

## 🔐 Security Considerations

### Phase-1 (Mock)
- Auth state in memory + SharedPreferences
- No sensitive data persisted
- Client-side validation only

### Phase-2 (Supabase)
- JWT-based authentication
- Row-Level Security (RLS) policies
- Server-side validation
- HTTPS enforced

---

**This structure supports:**
- ✅ Clean separation of concerns
- ✅ Easy testing (mock dependencies)
- ✅ Simple Phase-2 migration (swap implementations)
- ✅ Scalable architecture
- ✅ Maintainable codebase
