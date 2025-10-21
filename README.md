# Wejha (وجهة) - Discover Your Future

A comprehensive gamified Flutter web platform designed to help high-school students explore their interests, discover career paths, and plan their future through AI-powered insights, interactive assessments, and engaging games.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-2.8.0-3FCF8E?logo=supabase)
![License](https://img.shields.io/badge/license-MIT-green)
![Deployment](https://img.shields.io/badge/deployed-Netlify-00C7B7?logo=netlify)

## 🌐 Live Demo

**Production**: [https://masar-startad.netlify.app](https://masar-startad.netlify.app)

## 📚 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Key Features Deep Dive](#-key-features-deep-dive)
- [Backend Integration](#-backend-integration)
- [Deployment](#-deployment)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### Core Features

#### 🔐 **Authentication & User Management**
- Email/password authentication with Supabase
- OAuth integration (Google)
- Password reset flow
- Session management with JWT tokens
- Profile management with avatar support

#### 🎯 **Onboarding Experience**
- Interactive personality quiz for new users
- Forced-choice assessments for rapid trait identification
- Real-time progress tracking
- Personalized welcome experience
- Theme selection from 5 teen-friendly themes
- Direct integration with feature scoring system

#### 🎮 **Gamification System**
- **XP & Leveling**: Earn experience points from activities, level up with visual celebrations
- **Daily Streaks**: Track consecutive days of engagement with fire emoji indicators
- **Badge System**: 15 unlockable badges across 4 tiers (Bronze, Silver, Gold, Platinum)
  - Activity badges (First Steps, Quiz Master, Memory Master)
  - Streak badges (Week Warrior, Month Champion)
  - Level badges (Rising Star, Elite Explorer)
  - Time-based badges (Early Bird, Night Owl)
- **Confetti Celebrations**: Animated celebrations for achievements
- **XP Popovers**: Real-time feedback showing XP earned
- **Badge Unlock Animations**: Tier-specific animations with glow effects
- **Theme Switching**: Choose from 5 unique teen themes:
  - **Neon Arcade**: Electric blue/magenta with neon energy
  - **Galaxy Pulse**: Ultraviolet/teal cosmic vibes
  - **Street Pop**: Coral/canary urban style
  - **Ocean Wave**: Aqua/navy fluid motion
  - **Retro Pixel**: Gameboy green retro gaming

#### 📊 **Student Dashboard**
- **Gamification Header**: Live XP, level, and streak display with animated badges
- **Circular Progress Indicators**: Smooth animated circles showing profile completion and level progress
- **Theme Display**: Current theme shown with ability to change in settings
- **Radar Chart**: Multi-dimensional visualization of RIASEC + cognitive traits
- **Quick Actions**: Direct access to assessments, games, and careers
- **Badge Collection**: Trophy button to view all earned and locked badges
- **Profile Completeness**: Real-time indicator based on assessment confidence
- **Responsive Layout**: Adapts to desktop and mobile views

#### 🧪 **Discovery & Assessments**
- **Personality Quizzes**:
  - RIASEC-based career interest assessment
  - Big Five personality traits
  - Holland Code evaluation
  - Dynamic quiz loading from JSON
- **Interactive Mini-Games**:
  - **Memory Match**: Tests cognitive memory and attention with difficulty levels
    - Teen-friendly loading animations with emoji and cycling messages
    - XP rewards based on performance (100-300 XP)
    - Badge unlocks for completing games
    - Confetti celebrations on completion
    - Real-time telemetry tracking
    - Immediate scoring and feedback
    - Parallel processing for optimal performance

#### 🎯 **Career Exploration**
- **Career Clusters View**:
  - Hierarchical visualization of 100+ careers grouped by clusters
  - Color-coded match scores (0-100%)
  - **Theme-aware gradients**: Unique gradients per cluster using theme colors
  - **Smooth animations**: Scale effects on tap, expand/collapse with AnimatedSize
  - **Animated progress bars**: Match scores animate from 0 to actual value
  - **Hover micro-interactions**: Subtle scale effect on career items
  - **Hero transitions**: Smooth navigation to career details with shared elements
  - Category-based organization (STEM, Creative, Business, Healthcare, etc.)
- **Advanced Filtering**:
  - Search by career name
  - Filter by match score threshold
  - Sort by relevance, alphabetically, or by category
  - Real-time filter updates
- **Career Details**:
  - Comprehensive career information
  - Match score explanation with visual indicators
  - Required skills and education
  - Salary ranges and job outlook
  - Related careers suggestions

#### 🤖 **AI Career Insights**
- **Personalized Analysis**:
  - AI-generated personality summaries
  - Skill detection from assessment data
  - RIASEC interest profile analysis
  - Confidence scoring on recommendations
- **Career Recommendations**:
  - Top 3-5 career matches with explanations
  - Match score justification
  - "Why this is a good fit" personalized reasoning
- **Learning Paths**:
  - Customized next steps for career development
  - Activity recommendations
  - Course suggestions
  - Challenge proposals
- **Eligibility System**:
  - Minimum 50% profile completeness required
  - 7-day cooldown between generations
  - Progress tracking toward next insight

#### 🗺️ **Career Roadmaps**
- **AI-Generated Roadmaps**: Personalized step-by-step career planning
- **Hero Transitions**: Smooth animations from career cards to roadmap details
- **Responsive Layout**: Info chips (duration, salary) wrap dynamically on smaller screens
- **Educational Requirements**: Detailed pathways and milestones
- **Skill Development**: Structured learning progression
- **Timeline Visualization**: Visual roadmap with phases
- **Resource Links**: Curated recommendations and next steps

#### 🏫 **School Integration** (Admin Mode)
- **School Dashboard**:
  - Aggregate statistics for all students
  - Average trait scores by cohort
  - Completion rates and engagement metrics
  - Export data for analysis
- **Student Management**:
  - View individual student profiles
  - Track assessment progress
  - Monitor career exploration activity
  - Generate reports for counselors
- **Cohort Analytics**:
  - Compare individual students to school averages
  - Identify trends and patterns
  - Support data-driven career counseling

#### ⚙️ **Settings & Customization**
- **Profile Management**:
  - Edit personal information
  - Upload profile picture
  - Update email/password
- **Localization**:
  - English and Arabic language support
  - Full RTL (Right-to-Left) support
  - Dynamic language switching
- **Theme Customization**:
  - Dark/Light mode toggle
  - Futuristic design with gradient backgrounds
  - Glassmorphism effects throughout
- **Notifications**:
  - Email notification preferences
  - In-app notification settings
  - Activity reminders

#### 📱 **Progressive Web App (PWA)**
- Installable on mobile and desktop
- Native-like app experience
- PWA manifest configuration
- Offline support (planned)
- Push notifications (planned)

## 🏗 Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  (UI Components, Pages, Widgets, Controllers)               │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                    Application Layer                         │
│  (Services, Orchestrators, State Management, Providers)     │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                      Domain Layer                            │
│  (Entities, Value Objects, Repository Interfaces)           │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                       Data Layer                             │
│  (Models, Data Sources, Repository Implementations)         │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Patterns

- **Clean Architecture**: Clear separation between layers
- **Repository Pattern**: Abstraction over data sources
- **Provider Pattern**: State management with Riverpod
- **Service Layer**: Business logic encapsulation
- **Dependency Injection**: Via Riverpod providers
- **Feature-First Structure**: Self-contained feature modules

## 🛠 Tech Stack

### Framework & Core
- **Flutter 3.8.1**: Cross-platform UI framework
- **Dart 3.8.1**: Programming language

### State Management
- **Riverpod 2.5.1**: Reactive state management
- **Riverpod Annotation**: Code generation for providers
- **State Notifier**: State management pattern

### Backend & Database
- **Supabase Flutter 2.8.0**: Backend-as-a-Service
  - PostgreSQL database
  - Authentication (JWT)
  - Real-time subscriptions
  - Edge Functions
  - Row Level Security (RLS)

### Routing & Navigation
- **go_router 16.2.4**: Declarative routing with deep linking

### UI & Design
- **Material Design 3**: Modern UI components
- **Google Fonts 6.2.1**: Typography
- **flutter_svg 2.0.10**: Vector graphics
- **fl_chart 0.68.0**: Data visualization and charts

### Networking & Data
- **Dio 5.7.0**: HTTP client for API calls
- **shared_preferences 2.3.3**: Local storage
- **flutter_dotenv 6.0.0**: Environment configuration

### Localization
- **intl 0.20.2**: Internationalization
- **flutter_localizations**: Built-in l10n support

### Development Tools
- **very_good_analysis 9.0.0**: Strict linting rules
- **build_runner 2.4.13**: Code generation
- **riverpod_generator 2.4.0**: Provider code generation

### Testing
- **flutter_test**: Unit and widget testing
- **mocktail 1.0.4**: Mocking framework
- **golden_toolkit 0.15.0**: Golden file testing

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Chrome browser (for web development)
- Node.js 16+ (for Netlify CLI, optional)
- Supabase account (for backend integration)

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

3. **Set up environment variables**

   Create a `.env` file in the project root:
   ```env
   # Supabase Configuration
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key

   # Feature Flags
   AI_RECO_ENABLED=true
   TEACHER_MODE_ENABLED=true

   # Environment
   ENVIRONMENT=development
   ```

4. **Run the app**
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
flutter build web --release --web-renderer canvaskit

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format .

# Generate code (Riverpod providers, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n
```

## 📁 Project Structure

```
lib/
├── app.dart                          # Main app configuration
├── main.dart                         # Entry point
│
├── core/                             # Core functionality
│   ├── constants/                    # App-wide constants
│   │   ├── app_constants.dart
│   │   └── semantics.dart
│   ├── localization/                 # i18n setup
│   ├── providers/                    # Global Riverpod providers
│   │   └── providers.dart
│   ├── responsive/                   # Responsive design utilities
│   │   └── responsive.dart
│   ├── router/                       # Navigation setup
│   │   └── app_router.dart
│   ├── scoring/                      # Scoring algorithms
│   │   ├── scoring_pipeline.dart
│   │   ├── submit_batch.dart
│   │   └── features_registry.dart
│   ├── theme/                        # App theming
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── utils/                        # Helper utilities
│       ├── validators.dart
│       ├── feature_labels.dart
│       └── match_score_colors.dart
│
├── domain/                           # Business logic layer
│   ├── entities/                     # Core business entities
│   │   ├── user.dart
│   │   ├── career.dart
│   │   ├── assessment.dart
│   │   ├── roadmap.dart
│   │   └── ai_insight.dart
│   ├── repositories/                 # Repository interfaces
│   │   ├── auth_repository.dart
│   │   ├── career_repository.dart
│   │   ├── assessment_repository.dart
│   │   ├── progress_repository.dart
│   │   ├── roadmap_repository.dart
│   │   └── ai_insight_repository.dart
│   └── value_objects/                # Domain value objects
│       └── progress.dart
│
├── data/                             # Data layer
│   ├── models/                       # Data models
│   │   ├── user_model.dart
│   │   ├── career_tree.dart
│   │   ├── feature_score.dart
│   │   ├── radar_data.dart
│   │   ├── quiz_instrument.dart
│   │   └── school.dart
│   ├── sources/                      # Data sources
│   │   ├── local_prefs.dart
│   │   └── mock_data.dart
│   └── repositories_impl/            # Repository implementations
│       ├── auth_repository_impl.dart
│       ├── career_repository_impl.dart
│       ├── assessment_repository_impl.dart
│       ├── progress_repository_impl.dart
│       ├── roadmap_repository_impl.dart
│       └── ai_insight_repository_impl.dart
│
├── application/                      # Application layer
│   ├── activity/                     # Activity tracking
│   │   ├── activity_service.dart
│   │   └── activity_providers.dart
│   ├── ai_insight/                   # AI insights
│   │   ├── ai_insight_service.dart
│   │   └── ai_insight_providers.dart
│   ├── analytics/                    # Analytics service
│   │   └── analytics_service.dart
│   ├── assessment/                   # Assessment management
│   │   ├── assessment_service.dart
│   │   ├── assessment_providers.dart
│   │   └── complete_assessment_orchestrator.dart
│   ├── auth/                         # Authentication
│   │   └── auth_controller.dart
│   ├── consent/                      # GDPR consent
│   │   ├── consent_service.dart
│   │   └── consent_providers.dart
│   ├── profiles/                     # User profiles
│   │   ├── profiles_service.dart
│   │   └── profiles_providers.dart
│   ├── progress/                     # Progress tracking
│   │   ├── progress_service.dart
│   │   └── progress_providers.dart
│   ├── quiz/                         # Quiz management
│   │   ├── quiz_providers.dart
│   │   ├── quiz_item_seeder.dart
│   │   └── quiz_scoring_helper.dart
│   ├── roadmap/                      # Career roadmaps
│   │   ├── roadmap_service.dart
│   │   └── roadmap_providers.dart
│   ├── school/                       # School integration
│   │   └── school_providers.dart
│   ├── scoring/                      # Scoring system
│   │   ├── scoring_service.dart
│   │   ├── scoring_providers.dart
│   │   ├── quiz_scorer.dart
│   │   └── game_scorer.dart
│   └── traits/                       # Trait management
│       ├── traits_repository.dart
│       └── traits_providers.dart
│
├── presentation/                     # UI layer
│   ├── features/                     # Feature screens
│   │   ├── ai_insights/              # AI insights page
│   │   │   └── ai_insights_page.dart
│   │   ├── assessment/               # Assessment page
│   │   │   └── assessment_page.dart
│   │   ├── auth/                     # Authentication screens
│   │   │   ├── login_page.dart
│   │   │   ├── signup_page.dart
│   │   │   ├── school_login_page.dart
│   │   │   └── oauth_callback_page.dart
│   │   ├── careers/                  # Career browsing
│   │   │   └── careers_page.dart
│   │   ├── dashboard/                # Main dashboard
│   │   │   └── dashboard_page.dart
│   │   ├── discover/                 # Discovery page
│   │   │   └── discover_page.dart
│   │   ├── games/                    # Mini-games
│   │   │   ├── memory_match/
│   │   │   │   ├── memory_match_page.dart
│   │   │   │   ├── memory_match_controller.dart
│   │   │   │   └── memory_match_telemetry.dart
│   │   │   └── common/
│   │   │       └── game_result_sheet.dart
│   │   ├── onboarding/               # Onboarding flow
│   │   │   ├── onboarding_page.dart
│   │   │   └── widgets/
│   │   │       └── welcome_screen.dart
│   │   ├── quiz/                     # Quiz interface
│   │   │   └── quiz_page.dart
│   │   ├── roadmap/                  # Career roadmap
│   │   │   └── roadmap_page.dart
│   │   ├── school/                   # School admin
│   │   │   ├── school_dashboard_page.dart
│   │   │   └── student_detail_page.dart
│   │   ├── settings/                 # Settings page
│   │   │   └── settings_page.dart
│   │   └── static_pages/             # Static pages
│   │       ├── about_page.dart
│   │       ├── privacy_page.dart
│   │       └── terms_page.dart
│   ├── shell/                        # App shell/scaffold
│   │   └── adaptive_shell.dart
│   └── widgets/                      # Reusable widgets
│       ├── gradient_background.dart
│       ├── enhanced_glassy_card.dart
│       ├── language_switcher.dart
│       └── radar_traits_card.dart
│
└── features/                         # Feature modules
    └── careers/                      # Career tree feature
        ├── presentation/
        │   ├── controllers/
        │   │   └── career_tree_controller.dart
        │   ├── pages/
        │   │   └── career_tree_page.dart
        │   └── widgets/
        │       ├── career_tree_node.dart
        │       ├── career_tree_legend.dart
        │       └── career_tree_filter_bar.dart
        └── README.md
```

## 🔍 Key Features Deep Dive

### Career Matching System

The career matching system uses a sophisticated multi-dimensional scoring algorithm:

1. **22-Dimensional Feature Space**:
   - **RIASEC**: 6 interest dimensions (Realistic, Investigative, Artistic, Social, Enterprising, Conventional)
   - **Big Five**: 5 personality traits (Openness, Conscientiousness, Extraversion, Agreeableness, Neuroticism)
   - **Cognitive**: 4 cognitive abilities (Memory, Attention, Processing Speed, Spatial Reasoning)
   - **Work Values**: 7 value dimensions (Achievement, Independence, Recognition, etc.)

2. **Cosine Similarity Matching**:
   - User profile vector vs. career requirement vector
   - Confidence-weighted scoring
   - Produces match scores from 0-100%

3. **Dynamic Updates**:
   - Recalculated after each assessment
   - Incremental learning with EMA (Exponential Moving Average)
   - Quality scores for confidence tracking

### Assessment Scoring Pipeline

```
User Response → Quiz Scorer / Game Scorer
                      ↓
              Feature Extraction
                      ↓
           EMA Score Aggregation
                      ↓
          Update user_feature_scores
                      ↓
     Trigger Career Match Calculation
                      ↓
        Update user_career_matches
                      ↓
         Refresh Dashboard UI
```

### Memory Match Game Telemetry

The Memory Match game tracks detailed metrics:
- **Total time**: Completion time in seconds
- **Moves count**: Total card flips
- **Match accuracy**: Matches / moves ratio
- **Grid configuration**: Difficulty level and seed
- **Memory score**: Based on perfect match rate
- **Attention score**: Based on time and accuracy

### AI Insights Generation

AI Career Insights use OpenAI's GPT-4 to analyze:
1. User's RIASEC profile
2. Big Five personality traits
3. Completed assessments and game performance
4. Current career matches

Output includes:
- Personality summary (2-3 paragraphs)
- Detected skills (list)
- Interest scores (RIASEC breakdown)
- Top 3-5 career recommendations with justifications
- Personalized learning path (next steps)

## 🔌 Backend Integration

### Supabase Setup

1. **Database Schema**:
   - 18 tables with proper constraints
   - Row Level Security (RLS) policies
   - Triggers for automatic updates
   - See [migrations](/supabase/migrations/)

2. **Key Tables**:
   - `profiles`: User profiles and metadata
   - `user_feature_scores`: 22-dimensional trait scores
   - `user_career_matches`: Computed career matches
   - `activities`: Available assessments and games
   - `activity_runs`: User activity completion records
   - `assessments`: Assessment audit trail
   - `assessment_items`: Individual item responses
   - `schools`: School organizations
   - `school_students`: School-student relationships
   - `ai_career_insights`: Generated AI insights

3. **Edge Functions**:
   - `update_profile_and_match`: Updates feature scores and recalculates matches
   - See [supabase/functions](/supabase/functions/)

4. **Authentication**:
   - Email/password with Supabase Auth
   - OAuth providers (Google)
   - JWT token management
   - Automatic session refresh

### Environment Configuration

Required environment variables (set in Netlify/Supabase):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
OPENAI_API_KEY=your-openai-key  # For AI insights
```

## 📦 Deployment

### Production Build

```bash
# Build for web
flutter build web --release --web-renderer canvaskit

# The output will be in build/web/
```

### Netlify Deployment

The project is configured for Netlify deployment:

1. **netlify.toml** configuration included
2. **Automatic deployments** from main branch
3. **Environment variables** set in Netlify dashboard
4. **Custom redirects** for SPA routing

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions.

### PWA Installation

Users can install Wejha as a Progressive Web App:
1. Visit the site in Chrome/Edge
2. Click the install icon in the address bar
3. Confirm installation
4. App launches as standalone application

## 📖 Documentation

Comprehensive documentation is available:

- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)**: Complete file structure breakdown
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**: Deployment instructions
- **[SCHEMA_ANALYSIS.md](SCHEMA_ANALYSIS.md)**: Database schema details
- **[SCORING_SYSTEM.md](SCORING_SYSTEM.md)**: Scoring algorithms explained
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)**: Service integration guide
- **[SCHOOL_INTEGRATION_STATUS.md](SCHOOL_INTEGRATION_STATUS.md)**: School admin features
- **[COHORT_AVERAGES_IMPLEMENTATION.md](COHORT_AVERAGES_IMPLEMENTATION.md)**: Cohort analytics
- **[RADAR_AND_ASSESSMENTS.md](RADAR_AND_ASSESSMENTS.md)**: Assessment system details
- **[TEEN_UX_IMPLEMENTATION_PLAN.md](TEEN_UX_IMPLEMENTATION_PLAN.md)**: Gamification & UX upgrades
- **[UX_IMPROVEMENTS_SUMMARY.md](UX_IMPROVEMENTS_SUMMARY.md)**: Performance optimizations
- **[lib/features/careers/README.md](lib/features/careers/README.md)**: Career tree feature docs

## ⚡ Performance & UX Enhancements

### Gamification Optimizations
- **Parallel Badge Checking**: 3-5x faster (100-200ms vs 500-1000ms) through concurrent processing
- **Loading Animations**: Eliminated "stuck" feeling with teen-friendly loading overlays
  - Pulsing emoji animations
  - Rotating dots with gradient opacity
  - Cycling messages every 1.5 seconds
- **Confetti System**: Optimized particle rendering for smooth celebrations

### Animation System
- **TweenAnimationBuilder**: Smooth, controlled animations for circular progress and radar charts
- **Hero Transitions**: Seamless navigation between screens with shared elements
- **Theme-Aware Gradients**: Dynamic gradients based on selected teen theme
- **Micro-interactions**: Scale effects, hover states, and animated progress bars

### Responsive Design
- **Wrap Widgets**: Dynamic layout adjustments for smaller screens
- **Flexible Components**: Text truncation and overflow handling
- **Adaptive Shell**: Desktop and mobile optimized layouts

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/utils/match_score_colors_test.dart

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🐛 Troubleshooting

**Issue**: Version conflicts
**Solution**: Run `flutter pub get` and ensure Flutter SDK is up to date

**Issue**: App not loading
**Solution**: Run `flutter clean && flutter pub get && flutter run`

**Issue**: Localization not updating
**Solution**: Run `flutter gen-l10n` after editing ARB files

**Issue**: Supabase connection errors
**Solution**: Check `.env` file and verify Supabase credentials

**Issue**: Build errors after git pull
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `very_good_analysis` linting rules
- Run `flutter format` before committing
- Write tests for new features

## 📄 License

This project is developed as part of the **AI Sandbox Challenge**, under the principle of open innovation.

- **Code & Software:** Licensed under the [MIT License](https://opensource.org/licenses/MIT).
- **Creative Works & Documentation:** Licensed under the [CC-BY 4.0 International License](https://creativecommons.org/licenses/by/4.0/).  

## 📧 Contact

- **Email**: support@wejha.app
- **Website**: www.wejha.app

---

**Built with Flutter** 💙 | **Powered by Supabase** ⚡ | **Enhanced by AI** 🤖
