# Changelog

## 2025-01-XX - Deploy Fixes and School Integration

### Fixed

#### 1. Streak Calculation Bug
- **File**: `supabase/migrations/00008_fix_streak_calculation.sql`
- Fixed streak calculation logic in `fn_update_progress_after_run()` trigger
- Made streak logic more explicit with proper handling of edge cases
- Changed date arithmetic to use `interval '1 day'` for better PostgreSQL compatibility
- Added explicit `coalesce()` to handle NULL streak values

#### 2. Icons Not Showing on Deployed Web Build
- **Files**: `build-netlify.sh`, `netlify.toml`
- Added `--no-tree-shake-icons` flag to Flutter web build command
- Added CORS header `Access-Control-Allow-Origin: *` for `/assets/*` routes
- Verified `pubspec.yaml` has `uses-material-design: true`

#### 3. School Integration Navigation Bug
- **File**: `lib/core/router/app_router.dart`
- Fixed redirect logic to allow school admins to access `/settings` page
- Added explicit check for settings route in school admin section
- Settings icon now correctly navigates to settings page instead of dashboard

#### 4. Sign in as School Button Position
- **File**: `lib/presentation/features/auth/login_page.dart`
- Moved "Sign in as School" button from bottom center to top-left corner
- Used `Positioned` widget with `top: 16, left: 16`
- Removed duplicate button from bottom of form
- Reduced button size and padding for compact corner placement

#### 5. Memory Match Card Reveal
- **File**: `lib/presentation/features/games/memory_match/memory_match_controller.dart`
- Added 1-second card reveal animation at game start
- All cards are revealed initially with `isRevealed: true`
- Game is paused during initial reveal with `isPaused: true`
- After 1 second, cards flip back and gameplay begins

#### 6. Student Detail Page Layout
- **File**: `lib/presentation/features/school/student_detail_page.dart`
- Fixed locked student header card that was obscuring content
- Restructured layout from fixed header + TabBarView to header inside each tab
- Each tab now independently scrollable with header at top

#### 7. School Dashboard Improvements
- **File**: `lib/presentation/features/school/school_dashboard_page.dart`
- Added settings button in AppBar
- Added logout button in AppBar
- Fixed dark theme background with GradientBackground wrapper
- Added legend to career distribution pie chart showing cluster names and counts

#### 8. Radar Chart Integration
- **File**: `lib/presentation/features/school/student_detail_page.dart`
- Replaced TODO placeholder with actual RadarTraitsCard widget
- Shows actual spider graph for student traits
- Note: Currently shows logged-in user data (needs userId parameter for school admin view)

#### 9. Sign-up School Selection
- **File**: `lib/presentation/features/auth/signup_page.dart`
- Removed "Optional" label from school selection
- Made school selection required with validation
- Removed "I'm not in a listed school" checkbox
- Added validator to DropdownButtonFormField
- Updated signup handler to enforce school selection
- Schools are already loaded from database via `activeSchoolsProvider`

#### 10. Google OAuth Redirect Fix
- **Files**: `lib/core/router/app_router.dart`, `lib/application/auth/auth_controller.dart`
- Added dedicated `/auth/callback` route for OAuth redirects
- Created `_AuthCallbackPage` widget to handle OAuth completion
- Added redirect loop guards checking current location before redirecting
- Improved redirect logic to allow callback route
- OAuth now properly redirects to appropriate dashboard (student/school)

#### 11. Spider Graph Improvements
- **Files**: `lib/presentation/widgets/radar_traits_card.dart`, `lib/core/utils/feature_labels.dart` (NEW)
- Created utility function `getShortFeatureLabel()` to strip family prefixes
- Updated radar chart to use short labels (e.g., "Creative" instead of "interest_creative")
- Changed minimum data threshold from 0 to 3 features
- Updated empty state message: "Not enough data yet - Complete more activities to see your profile"
- Chart already shows global averages (cohortMean) as grey line

#### 12. IPIP-50 Canonical Features Integration
- **Files**: `lib/core/scoring/features_registry.dart`, `lib/application/quiz/quiz_scoring_helper.dart`
- Added Big Five (IPIP-50) to canonical trait mapping
- Created `bigFiveToCanonical()` function similar to `riasecToCanonical()`
- Maps Big Five dimensions to canonical traits (Extraversion→Communication, Agreeableness→Collaboration, etc.)
- IPIP-50 now uses same submission pipeline as RIASEC

#### 13. Quiz UX Improvements
- **File**: `lib/presentation/features/assessment/assessment_page.dart`
- Added ScrollController with automatic scroll to top after navigation
- Added `_canProceed()` validation - Next button disabled until all current page questions answered
- Smooth scroll animation (250ms, easeOut curve) on Previous/Next clicks

#### 14. Memory Match Grid Fix
- **File**: `lib/presentation/features/games/memory_match/memory_match_page.dart`
- Replaced `Wrap` with `GridView.count` for strict grid layout
- Grid maintains proper dimensions (4×4, 6×6) on all screen sizes
- Added ConstrainedBox to center grid with max width

#### 15. Welcome Page Simplification
- **File**: `lib/presentation/features/onboarding/widgets/welcome_screen.dart`
- Removed three large GlassyCard widgets
- Replaced with simple bullet points
- Start button always visible and accessible

### All Tasks Completed ✅

✅ Streak calculation bug fixed
✅ Icons showing on deployed web build
✅ School settings navigation fixed
✅ "Sign in as school" button moved to top-left
✅ School selection required in sign-up
✅ Schools loaded from database
✅ Google OAuth redirect fixed
✅ Spider graph improvements (global averages, empty state, short labels)
✅ IPIP-50 using canonical features
✅ Quiz UX improvements (validation, scroll)
✅ Memory match grid fixed for desktop
✅ Welcome page simplified

### Files Changed (16 files)
1. `supabase/migrations/00008_fix_streak_calculation.sql` (NEW)
2. `build-netlify.sh` (MODIFIED)
3. `netlify.toml` (MODIFIED)
4. `lib/core/router/app_router.dart` (MODIFIED - OAuth callback)
5. `lib/presentation/features/auth/login_page.dart` (MODIFIED)
6. `lib/presentation/features/auth/signup_page.dart` (MODIFIED)
7. `lib/presentation/features/games/memory_match/memory_match_controller.dart` (MODIFIED)
8. `lib/presentation/features/games/memory_match/memory_match_page.dart` (MODIFIED)
9. `lib/presentation/features/school/school_dashboard_page.dart` (MODIFIED)
10. `lib/presentation/features/school/student_detail_page.dart` (MODIFIED)
11. `lib/presentation/widgets/radar_traits_card.dart` (MODIFIED)
12. `lib/presentation/features/assessment/assessment_page.dart` (MODIFIED)
13. `lib/presentation/features/onboarding/widgets/welcome_screen.dart` (MODIFIED)
14. `lib/core/utils/feature_labels.dart` (NEW)
15. `lib/core/scoring/features_registry.dart` (MODIFIED)
16. `lib/application/quiz/quiz_scoring_helper.dart` (MODIFIED)
