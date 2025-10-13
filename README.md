# SelfMap - Discover Your Future

A Flutter web MVP for self-discovery designed to help high-school students explore their interests, discover careers, and plan their future.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.32.5-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-Proprietary-red)
![Deployment](https://img.shields.io/badge/deployed-Netlify-00C7B7?logo=netlify)

## 🌐 Live Demo

**Production**: [https://selfmap-startad.netlify.app](https://selfmap-startad.netlify.app)

📖 **See [DEPLOYMENT.md](DEPLOYMENT.md)** for deployment guide and configuration.

## 🎯 Features (Phase-1)

✅ **Authentication** - Email/password login and signup with password reset
✅ **Onboarding** - Personality quiz for new users
✅ **Dashboard** - Progress tracking, streaks, and quick actions
✅ **Discover** - Personality quizzes and mini-games
✅ **Careers** - Browse careers with match scores (rule-based)
✅ **Roadmap** - Step-by-step tasks for selected careers
✅ **Settings** - Profile, language (EN/AR), theme, notifications
✅ **Localization** - English and Arabic with RTL support
✅ **Theming** - Futuristic design with neon accents, dark/light mode
✅ **PWA** - Progressive Web App with offline support

## 🏗 Architecture

This project follows **Clean Architecture** principles with clear separation of concerns.

📖 **See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** for complete file-by-file breakdown.

```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # Entry point
├── core/                       # Core functionality
│   ├── theme/                  # App theming (colors, styles)
│   ├── localization/           # i18n setup
│   ├── router/                 # Navigation (go_router)
│   ├── utils/                  # Validators, helpers
│   ├── constants/              # App-wide constants
│   └── providers/              # Riverpod providers
├── domain/                     # Business logic layer
│   ├── entities/               # Core business entities
│   ├── value_objects/          # Domain value objects
│   └── repositories/           # Repository interfaces
├── data/                       # Data layer
│   ├── models/                 # Data models
│   ├── sources/                # Local storage (SharedPreferences)
│   └── repositories_impl/      # Mock repository implementations
├── application/                # Application layer
│   ├── auth/                   # Auth state management
│   ├── analytics/              # Analytics service interface
│   └── [other controllers]
└── presentation/               # UI layer
    ├── features/               # Feature screens
    └── widgets/                # Reusable widgets
```

## 🛠 Tech Stack

- **Framework**: Flutter 3.32.5 (Web)
- **State Management**: Riverpod 2.6.1
- **Routing**: go_router 14.6.2
- **Localization**: intl 0.20.2
- **UI**: google_fonts 6.2.1, flutter_svg 2.0.10
- **Storage**: shared_preferences 2.3.3
- **Config**: flutter_dotenv 5.2.1
- **Linting**: very_good_analysis 6.0.0

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.32.5 or higher
- Chrome browser for web development

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd StartAD_AGF_SelfDiscovory
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d chrome
   ```

### Development Commands

```bash
# Run the app in debug mode
flutter run -d chrome

# Run with specific port
flutter run -d chrome --web-port=8080

# Build for production
flutter build web --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Generate localization
flutter gen-l10n
```

## ⚙️ Configuration

### Environment Variables

The `.env` file contains feature flags:

```env
# Feature Flags
AI_RECO_ENABLED=false
TEACHER_MODE_ENABLED=false

# Environment
ENVIRONMENT=development
```

### Localization

The app supports English and Arabic. Localization files are in `assets/i18n/`:
- `app_en.arb` - English translations
- `app_ar.arb` - Arabic translations

To regenerate localizations:
```bash
flutter gen-l10n
```

## 📱 Features Deep Dive

### Authentication (Mock)
- Email/password authentication
- User registration with validation
- Password reset flow
- Session persistence via SharedPreferences

**Extension Point**: Replace `AuthRepositoryImpl` with Firebase Auth or Supabase in Phase-2.

### Career Matching (Rule-Based)
The career matching algorithm uses weighted overlap:

1. User completes assessments → trait scores (0-100)
2. Each career has predefined tags
3. Match score calculated based on trait-tag overlap
4. Careers sorted by match score

**Extension Point**: Replace with ML-based matching in Phase-2.

## 🔌 Phase-2: Backend Integration

**Phase-1 is complete with mock data. Phase-2 backend is READY! ✅**

### 📚 Documentation

- **[SCHEMA_ANALYSIS.md](SCHEMA_ANALYSIS.md)** - Complete schema compliance report
- **[SCORING_SYSTEM.md](SCORING_SYSTEM.md)** - Feature-based scoring & career matching system
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - How to integrate the new services
- **[PHASE2_INTEGRATION.md](PHASE2_INTEGRATION.md)** - Original integration guide

### What's Included in Phase-2:

#### ✅ Database Schema (PostgreSQL)
- 18 tables with proper constraints and indexes
- 22-dimensional feature space (RIASEC + cognition + traits)
- RLS policies for all tables
- Triggers for automatic progress tracking
- See: [supabase/migrations/](supabase/migrations/)

#### ✅ Scoring & Matching System
- **Quiz Scoring**: Likert scale with EMA aggregation
- **Game Scoring**: Telemetry-based cognitive metrics
- **Career Matching**: Cosine similarity with confidence weighting
- **Edge Function**: `update_profile_and_match` computes matches
- See: [SCORING_SYSTEM.md](SCORING_SYSTEM.md)

#### ✅ Service Layer
- `ActivityService` - Manages activity_runs and discovery_progress
- `AssessmentService` - Manages assessments and audit trail
- `ScoringService` - Feature scoring and career matching
- `CompleteAssessmentOrchestrator` - Orchestrates complete flow
- See: [lib/application/](lib/application/)

#### ✅ Data Contract Compliance
- All tables match the official data contract
- Proper flow: activity_runs → trigger → discovery_progress
- Audit trail: assessments + assessment_items
- Career matching: user_feature_scores → cosine similarity → user_career_matches
- See: [SCHEMA_ANALYSIS.md](SCHEMA_ANALYSIS.md)

### 🚀 Quick Start

1. **Run Migrations**
   ```bash
   # In Supabase SQL Editor
   # Run: supabase/migrations/00001_init_schema.sql
   # Run: supabase/migrations/00002_fix_profile_trigger_best.sql
   # Run: supabase/migrations/00003_scoring_and_matching_system.sql
   ```

2. **Deploy Edge Function**
   ```bash
   supabase functions deploy update_profile_and_match
   ```

3. **Update Flutter Code**
   ```dart
   // Use the new orchestrator for quiz/game completion
   final orchestrator = CompleteAssessmentOrchestrator(...);
   await orchestrator.completeAssessment(...);
   ```

4. **See Full Guide**
   👉 [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)

### ✨ New Features

- ✅ **Discovery Progress**: Track completion % and daily streaks
- ✅ **Profile Completeness**: Based on feature score confidence
- ✅ **Career Matching**: 22-dimensional cosine similarity
- ✅ **Audit Trail**: Full history of assessments and items
- ✅ **EMA Scoring**: Incremental learning for feature scores

### Future Extensions:
- **Database-Driven Quizzes**: Fetch quiz items from `quiz_items` table
- **Consent Flow**: Use `consents` table for GDPR compliance
- **Roadmap Feature**: Tables exist, UI pending
- **Background Matching**: Move career matching to scheduled job
- **A/B Testing**: Test different quiz questions and scoring algorithms

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/domain/entities/user_test.dart
```

## 📦 Deployment

### Build for Production
```bash
flutter build web --release --web-renderer canvaskit
```

The built files will be in `build/web/`.

### Deploy to Hosting
- Firebase Hosting
- Vercel
- Netlify
- AWS S3 + CloudFront

### PWA Installation
Users can install as standalone app:
1. Open in Chrome
2. Click install icon in address bar
3. Runs as native-like application

## 🐛 Troubleshooting

**Issue**: Version conflicts
**Solution**: Use `flutter pub get` and ensure Flutter SDK is up to date

**Issue**: App not loading
**Solution**: `flutter clean && flutter pub get && flutter run`

**Issue**: Localization not updating
**Solution**: Run `flutter gen-l10n` after editing ARB files

## 📄 License

Copyright © 2025 SelfMap. All rights reserved.

## 📧 Contact

- Email: support@selfmap.app
- Website: www.selfmap.app

---

**Built with Flutter** 💙 | **Phase-1 MVP Complete** ✅
