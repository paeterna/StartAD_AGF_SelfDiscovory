# AI-Generated Career Roadmaps System - Implementation Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [Backend Implementation](#backend-implementation)
5. [Domain Layer](#domain-layer)
6. [Data Layer](#data-layer)
7. [Application Layer](#application-layer)
8. [UI Layer](#ui-layer)
9. [User Flow](#user-flow)
10. [API Reference](#api-reference)
11. [Deployment Guide](#deployment-guide)
12. [Testing Guide](#testing-guide)
13. [Troubleshooting](#troubleshooting)

---

## Overview

### Purpose
The AI-Generated Career Roadmaps system provides personalized, actionable career paths for high school students (grades 9-12) in the UAE. Each roadmap is generated using AI based on the student's interests, personality traits, cognitive abilities, and skills.

### Key Features
- ✅ AI-powered personalization using Azure OpenAI
- ✅ UAE-specific context (universities, certifications, salaries in AED)
- ✅ Teen-friendly language appropriate for grades 9-12
- ✅ Max 3 roadmaps per user with managed deletion
- ✅ 4-phase structure: School → University → Skills → Career
- ✅ Real-time updates with Supabase streams
- ✅ Comprehensive analytics tracking
- ✅ Full error handling and retry mechanisms

### Technology Stack
- **Frontend:** Flutter, Riverpod, Material 3
- **Backend:** Supabase (PostgreSQL + Edge Functions)
- **AI:** Azure OpenAI (GPT-4/GPT-4o)
- **Analytics:** Custom analytics service (extensible to GA4/Mixpanel)

---

## Architecture

### System Architecture Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                        Flutter App                             │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                    UI Layer                             │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • CareersPageClustered (cluster-first view)           │  │
│  │ • RoadmapDetailPage (4-phase expandable display)      │  │
│  │ • DeleteRoadmapModal (limit management)               │  │
│  │ • Loading dialogs, error messages, confirmations      │  │
│  └────────────────────┬───────────────────────────────────┘  │
│                       │                                        │
│  ┌────────────────────▼───────────────────────────────────┐  │
│  │             Application Layer                           │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • RoadmapService (orchestration logic)                │  │
│  │ • Riverpod Providers (state management)               │  │
│  │ • Analytics Service (event tracking)                  │  │
│  │ • Router configuration                                │  │
│  └────────────────────┬───────────────────────────────────┘  │
│                       │                                        │
│  ┌────────────────────▼───────────────────────────────────┐  │
│  │               Domain Layer                              │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • AIRoadmapRepository (interface)                     │  │
│  │ • AICareerRoadmap entities                            │  │
│  │ • RoadmapPhase & RoadmapStep entities                 │  │
│  │ • CareerClusterGroup entity                           │  │
│  │ • Custom exceptions                                   │  │
│  └────────────────────┬───────────────────────────────────┘  │
│                       │                                        │
│  ┌────────────────────▼───────────────────────────────────┐  │
│  │                Data Layer                               │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ • AIRoadmapRepositoryImpl (Supabase integration)      │  │
│  │ • Edge Function invocation                            │  │
│  │ • Real-time stream subscriptions                      │  │
│  │ • SQL function calls                                  │  │
│  └────────────────────┬───────────────────────────────────┘  │
│                       │                                        │
└───────────────────────┼────────────────────────────────────────┘
                        │
                        │ HTTPS/WebSocket
                        │
┌───────────────────────▼────────────────────────────────────────┐
│                    Supabase Backend                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           Edge Function: ai-generate-career-roadmap      │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ • Input validation (user_id, career_id, locale)         │  │
│  │ • Max-3 roadmap enforcement                             │  │
│  │ • Duplicate prevention                                  │  │
│  │ • Fetch user feature vectors from DB                    │  │
│  │ • Construct UAE-specific AI prompt                      │  │
│  │ • Call Azure OpenAI                                     │  │
│  │ • Validate AI response against schema                   │  │
│  │ • Persist to database (3 tables)                        │  │
│  │ • Return roadmap_id or error code                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  PostgreSQL Database                      │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ Tables:                                                   │  │
│  │ • user_career_roadmaps (metadata)                        │  │
│  │ • user_roadmap_phases (4 phases per roadmap)            │  │
│  │ • user_roadmap_steps (steps with resources & tips)      │  │
│  │                                                           │  │
│  │ SQL Functions:                                            │  │
│  │ • get_user_career_roadmap_by_id(roadmap_id)             │  │
│  │ • get_user_career_roadmap(user_id, career_title)        │  │
│  │ • has_roadmap_for_career(user_id, career_title)         │  │
│  │                                                           │  │
│  │ RLS Policies:                                             │  │
│  │ • users_own_roadmaps                                     │  │
│  │ • users_own_phases (cascading)                           │  │
│  │ • users_own_steps (multi-level cascading)               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                        │
                        │ HTTPS
                        │
┌───────────────────────▼────────────────────────────────────────┐
│                     Azure OpenAI                                │
├─────────────────────────────────────────────────────────────────┤
│ • Models: GPT-4, GPT-4o, GPT-4-turbo                           │
│ • Response format: JSON                                         │
│ • Temperature: 0.8 (for creative personalization)              │
│ • Max tokens: 4000                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
1. User Action: Click "Generate Roadmap"
   ↓
2. UI Layer: careers_page_clustered.dart
   - Validates user authentication
   - Calls RoadmapService.generateRoadmapWithFlow()
   ↓
3. Application Layer: RoadmapService
   - Logs analytics: career_generate_clicked
   - Checks if roadmap exists for career
   - Shows loading dialog
   ↓
4. Data Layer: AIRoadmapRepositoryImpl
   - Invokes Supabase Edge Function
   - POST /functions/v1/ai-generate-career-roadmap
   - Body: { career_id, locale }
   - Headers: Authorization Bearer token
   ↓
5. Edge Function: ai-generate-career-roadmap
   - Authenticates user via JWT
   - Checks roadmap count (max 3)
   - Checks for duplicates
   - Fetches user vectors from user_feature_scores table
   - Constructs personalized prompt with:
     * User's interests, traits, cognition, skills
     * Career details from careers table
     * UAE-specific context
     * Teen-friendly instructions
   - Calls Azure OpenAI
   - Validates JSON response against schema
   - Inserts into 3 tables:
     * user_career_roadmaps (1 row)
     * user_roadmap_phases (4 rows)
     * user_roadmap_steps (12-20 rows)
   - Returns: { success: true, roadmap_id: "uuid" }
   ↓
6. Data Layer: Response Handling
   - On success: Returns roadmap_id
   - On limit exceeded: Throws RoadmapLimitExceededException
   - On duplicate: Throws RoadmapAlreadyExistsException
   - On AI failure: Throws AIGenerationFailedException
   ↓
7. Application Layer: Flow Control
   - On success:
     * Logs analytics: roadmap_generated
     * Closes loading dialog
     * Navigates to /roadmap/detail/:roadmapId
   - On limit exceeded:
     * Shows DeleteRoadmapModal
     * User selects roadmap to delete
     * Deletes selected roadmap
     * Logs analytics: roadmap_deleted (reason: limit_reached)
     * Retries generation
   - On error:
     * Shows error SnackBar with retry button
     * Logs analytics: roadmap_generation_failed
   ↓
8. UI Layer: Roadmap Detail
   - Watches roadmapByIdProvider(roadmapId)
   - Calls get_user_career_roadmap_by_id SQL function
   - Displays 4 expandable phase cards
   - Each phase shows steps with details, resources, tips
```

---

## Database Schema

### Migration: 00014_roadmap.sql

#### Table: user_career_roadmaps

**Purpose:** Stores metadata for each generated roadmap

```sql
CREATE TABLE public.user_career_roadmaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  career_id UUID NOT NULL REFERENCES public.careers(id) ON DELETE CASCADE,
  career_title TEXT NOT NULL,
  description TEXT NOT NULL,
  estimated_duration TEXT NOT NULL,
  salary_range TEXT NOT NULL,
  icon TEXT DEFAULT '💼',
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, career_id)
);
```

**Indexes:**
- `idx_user_roadmaps_user` on `user_id`
- `idx_user_roadmaps_career` on `career_id`

**Constraints:**
- UNIQUE(user_id, career_id) - Prevents duplicate roadmaps

**Example Row:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "auth-user-uuid",
  "career_id": "career-uuid",
  "career_title": "Software Developer",
  "description": "Your analytical thinking and problem-solving skills make you perfect for software development...",
  "estimated_duration": "8-10 years from high school to senior level",
  "salary_range": "Entry: 6,000 AED, Mid: 12,000 AED, Senior: 25,000+ AED",
  "icon": "💻",
  "generated_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-01-15T10:30:00Z"
}
```

#### Table: user_roadmap_phases

**Purpose:** Stores the 4 phases of each roadmap (School, University, Skills, Career)

```sql
CREATE TABLE public.user_roadmap_phases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  roadmap_id UUID NOT NULL REFERENCES public.user_career_roadmaps(id) ON DELETE CASCADE,
  phase_order INT NOT NULL,
  phase_type TEXT NOT NULL CHECK (phase_type IN ('school', 'university', 'skills', 'career')),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  icon TEXT NOT NULL,
  duration TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(roadmap_id, phase_order)
);
```

**Indexes:**
- `idx_user_roadmap_phases_roadmap` on `roadmap_id`
- `idx_user_roadmap_phases_order` on `(roadmap_id, phase_order)`

**Phase Types:**
1. **school** - High school focus (Grades 9-12)
2. **university** - Higher education
3. **skills** - Professional certifications and skills
4. **career** - Career progression and growth

**Example Row:**
```json
{
  "id": "phase-uuid",
  "roadmap_id": "550e8400-e29b-41d4-a716-446655440000",
  "phase_order": 0,
  "phase_type": "school",
  "title": "High School Foundation",
  "subtitle": "Build your technical foundation",
  "icon": "🎓",
  "duration": "Grades 9-12 (3-4 years)",
  "created_at": "2025-01-15T10:30:00Z"
}
```

#### Table: user_roadmap_steps

**Purpose:** Stores individual actionable steps within each phase

```sql
CREATE TABLE public.user_roadmap_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phase_id UUID NOT NULL REFERENCES public.user_roadmap_phases(id) ON DELETE CASCADE,
  step_order INT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  details TEXT[] NOT NULL DEFAULT '{}',
  resources TEXT[] NOT NULL DEFAULT '{}',
  tip TEXT,
  is_optional BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(phase_id, step_order)
);
```

**Indexes:**
- `idx_user_roadmap_steps_phase` on `phase_id`
- `idx_user_roadmap_steps_order` on `(phase_id, step_order)`

**Example Row:**
```json
{
  "id": "step-uuid",
  "phase_id": "phase-uuid",
  "step_order": 0,
  "title": "Excel in Math and Computer Science",
  "description": "Your analytical thinking gives you a head start in technical subjects",
  "details": [
    "Focus on Advanced Mathematics (Calculus, Statistics)",
    "Take Computer Science if available",
    "Practice coding basics with Python or Scratch",
    "Join math competitions like Math Olympiad"
  ],
  "resources": [
    "Khan Academy - Free math courses",
    "Code.org - Beginner programming",
    "UAE Math Olympiad - Local competitions"
  ],
  "tip": "Your love for problem-solving will make these subjects enjoyable!",
  "is_optional": false,
  "created_at": "2025-01-15T10:30:00Z"
}
```

### SQL Functions

#### get_user_career_roadmap_by_id

**Purpose:** Fetch complete roadmap with all phases and steps as nested JSON

```sql
SELECT public.get_user_career_roadmap_by_id('550e8400-e29b-41d4-a716-446655440000');
```

**Returns:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "auth-user-uuid",
  "career_id": "career-uuid",
  "career_title": "Software Developer",
  "description": "...",
  "estimated_duration": "8-10 years",
  "salary_range": "Entry: 6,000 AED...",
  "icon": "💻",
  "generated_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-01-15T10:30:00Z",
  "phases": [
    {
      "id": "phase-uuid",
      "phase_type": "school",
      "title": "High School Foundation",
      "subtitle": "Build your technical foundation",
      "icon": "🎓",
      "duration": "Grades 9-12 (3-4 years)",
      "steps": [
        {
          "title": "Excel in Math and Computer Science",
          "description": "...",
          "details": ["...", "..."],
          "resources": ["...", "..."],
          "tip": "...",
          "is_optional": false
        }
      ]
    }
  ]
}
```

#### has_roadmap_for_career

**Purpose:** Quick boolean check if user has roadmap for specific career

```sql
SELECT public.has_roadmap_for_career('user-uuid', 'Software Developer');
-- Returns: true or false
```

### RLS Policies

#### users_own_roadmaps
```sql
CREATE POLICY "users_own_roadmaps" ON public.user_career_roadmaps
  FOR ALL USING (auth.uid() = user_id);
```

**Effect:** Users can only SELECT, INSERT, UPDATE, DELETE their own roadmaps

#### users_own_phases
```sql
CREATE POLICY "users_own_phases" ON public.user_roadmap_phases
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.user_career_roadmaps
      WHERE id = roadmap_id AND user_id = auth.uid()
    )
  );
```

**Effect:** Users can only access phases belonging to their roadmaps (via JOIN)

#### users_own_steps
```sql
CREATE POLICY "users_own_steps" ON public.user_roadmap_steps
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.user_roadmap_phases p
      JOIN public.user_career_roadmaps r ON r.id = p.roadmap_id
      WHERE p.id = phase_id AND r.user_id = auth.uid()
    )
  );
```

**Effect:** Users can only access steps belonging to their phases (via multi-level JOIN)

---

## Backend Implementation

### Edge Function: ai-generate-career-roadmap

**File:** `supabase/functions/ai-generate-career-roadmap/index.ts`

#### Request Format

**Endpoint:** `POST /functions/v1/ai-generate-career-roadmap`

**Headers:**
```json
{
  "Authorization": "Bearer <supabase_jwt_token>",
  "Content-Type": "application/json"
}
```

**Body:**
```json
{
  "career_id": "uuid",
  "locale": "en" // Optional, defaults to "en"
}
```

#### Response Format

**Success (200):**
```json
{
  "success": true,
  "roadmap_id": "550e8400-e29b-41d4-a716-446655440000",
  "career_title": "Software Developer"
}
```

**Error - Limit Reached (403):**
```json
{
  "success": false,
  "error": "roadmap_limit_reached",
  "current_count": 3
}
```

**Error - Already Exists (409):**
```json
{
  "success": false,
  "error": "roadmap_already_exists"
}
```

**Error - Authentication (401):**
```json
{
  "success": false,
  "error": "missing_auth" // or "invalid_token"
}
```

**Error - AI Generation Failed (500):**
```json
{
  "success": false,
  "error": "All AI deployments failed. Last error: ..."
}
```

#### Function Flow

```typescript
1. Authenticate user via Supabase JWT
2. Parse request body (career_id, locale)
3. Check if roadmap already exists
   - Query: user_career_roadmaps WHERE user_id AND career_id
   - If exists: Return 409
4. Check roadmap count limit
   - Query: COUNT(*) FROM user_career_roadmaps WHERE user_id
   - If >= 3: Return 403 with current_count
5. Fetch career details
   - Query: careers JOIN clusters WHERE career_id
6. Fetch user feature vectors
   - Query: user_feature_scores JOIN features WHERE user_id
   - Group by family: interests, traits, cognition
   - Extract top values for prompt personalization
7. Build AI prompt
   - Include user vectors
   - Include career details
   - Include UAE context (universities, certifications, salaries)
   - Include teen-friendly language instructions
   - Specify exact JSON schema for response
8. Call Azure OpenAI
   - Try deployments in order: gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-4
   - Temperature: 0.8 (creative personalization)
   - Max tokens: 4000
   - Response format: json_object
9. Validate AI response
   - Check: career_title, phases array length === 4
   - Check: Each phase has required fields
   - Check: Each step has required fields
10. Persist to database
    - BEGIN TRANSACTION
    - INSERT into user_career_roadmaps
    - For each phase (0-3):
      - INSERT into user_roadmap_phases
      - For each step:
        - INSERT into user_roadmap_steps
    - COMMIT
11. Return success with roadmap_id
```

#### AI Prompt Structure

**System Message:**
```
You are an expert UAE-based career counselor for high school students (grades 9-12).
Create personalized, actionable career roadmaps with UAE-specific context.
Always respond with valid JSON only.
```

**User Message Components:**

1. **Student Profile**
   - Top Interests: technology (95%), problem_solving (88%), creative_thinking (82%)
   - Top Personality Traits: analytical (90%), curious (85%), detail_oriented (80%)
   - Top Cognitive Strengths: logical_reasoning (92%), pattern_recognition (88%)
   - Key Skills: problem-solving, analytical thinking, technical aptitude

2. **Target Career**
   - Title: Software Developer
   - Description: Build applications and software solutions
   - Cluster: Technology

3. **Context Requirements**
   - Location: United Arab Emirates
   - Education System: UAE schools, universities
   - Market: UAE job market and salaries in AED
   - Language: Teen-friendly (grades 9-12)

4. **Roadmap Structure Requirements**
   - Exactly 4 phases in order: school → university → skills → career
   - Each phase: title, subtitle, icon, duration, 3-5 steps
   - Each step: title, description, details[], resources[], tip, is_optional

5. **Personalization Requirements**
   - Reference specific user strengths in descriptions
   - Suggest resources matching their interests
   - Use encouraging language acknowledging their traits
   - Include optional steps for flexibility

6. **UAE-Specific Requirements**
   - Universities: UAEU, Khalifa University, AUS, University of Sharjah, ADU, Zayed University
   - Certifications: Recognized by UAE employers (AWS, Google, Microsoft, etc.)
   - Salary Ranges: Entry: 5,000-8,000 AED, Mid: 10,000-15,000 AED, Senior: 18,000-30,000+ AED
   - Resources: UAE-based when available (NAFIS, local competitions, UAE internships)

7. **Output Schema**
```json
{
  "career_title": "string",
  "description": "string (personalized, 2-3 sentences)",
  "estimated_duration": "string",
  "salary_range": "string (in AED)",
  "icon": "emoji",
  "phases": [
    {
      "phase_type": "school|university|skills|career",
      "title": "string",
      "subtitle": "string",
      "icon": "emoji",
      "duration": "string",
      "steps": [
        {
          "title": "string",
          "description": "string (personalized)",
          "details": ["string", "string", ...],
          "resources": ["string", "string", ...],
          "tip": "string (motivating)",
          "is_optional": boolean
        }
      ]
    }
  ]
}
```

---

## Domain Layer

### Entities

#### AICareerRoadmap

**File:** `lib/domain/entities/ai_career_roadmap.dart`

```dart
@immutable
class AICareerRoadmap {
  const AICareerRoadmap({
    required this.id,
    required this.userId,
    required this.careerId,
    required this.careerTitle,
    required this.description,
    required this.estimatedDuration,
    required this.salaryRange,
    required this.icon,
    required this.phases,
    required this.generatedAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String careerId;
  final String careerTitle;
  final String description;
  final String estimatedDuration;
  final String salaryRange;
  final String icon;
  final List<RoadmapPhase> phases;
  final DateTime generatedAt;
  final DateTime? updatedAt;

  factory AICareerRoadmap.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  AICareerRoadmap copyWith({...});
}
```

#### RoadmapPhase

```dart
enum PhaseType {
  school,      // High school (Grades 9-12)
  university,  // Higher education
  skills,      // Certifications and professional skills
  career;      // Career entry and growth
}

@immutable
class RoadmapPhase {
  const RoadmapPhase({
    required this.id,
    required this.phaseType,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.duration,
    required this.steps,
  });

  final String id;
  final PhaseType phaseType;
  final String title;
  final String subtitle;
  final String icon;
  final String duration;
  final List<RoadmapStep> steps;
}
```

#### RoadmapStep

```dart
@immutable
class RoadmapStep {
  const RoadmapStep({
    required this.title,
    required this.description,
    required this.details,
    required this.resources,
    this.tip,
    this.isOptional = false,
  });

  final String title;
  final String description;
  final List<String> details;      // 3-5 bullet points
  final List<String> resources;    // 2-4 specific resources
  final String? tip;                // Motivating tip
  final bool isOptional;            // For flexibility
}
```

#### AICareerRoadmapSummary

```dart
@immutable
class AICareerRoadmapSummary {
  const AICareerRoadmapSummary({
    required this.id,
    required this.careerId,
    required this.careerTitle,
    required this.description,
    required this.icon,
    required this.estimatedDuration,
    required this.generatedAt,
  });

  // Used for list views without loading full roadmap details
}
```

#### CareerClusterGroup

**File:** `lib/domain/entities/career_cluster.dart`

```dart
@immutable
class CareerClusterGroup {
  const CareerClusterGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.topCareers,    // Top 3 careers
    required this.maxMatchScore, // Highest match in cluster
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final List<Career> topCareers;
  final int maxMatchScore;
}
```

### Repository Interface

**File:** `lib/domain/repositories/ai_roadmap_repository.dart`

```dart
abstract class AIRoadmapRepository {
  /// Generate a new AI roadmap for a career
  ///
  /// Throws:
  /// - RoadmapLimitExceededException: User has 3 roadmaps already
  /// - RoadmapAlreadyExistsException: Roadmap for this career exists
  /// - AIGenerationFailedException: AI generation failed
  Future<String> generateRoadmap({
    required String careerId,
    String? locale,
  });

  /// Get detailed roadmap by ID
  Future<AICareerRoadmap?> getRoadmapById(String roadmapId);

  /// Get roadmap for a specific career (if exists)
  Future<AICareerRoadmap?> getRoadmapForCareer({
    required String userId,
    required String careerId,
  });

  /// Check if user has a roadmap for a career
  Future<bool> hasRoadmapForCareer({
    required String userId,
    required String careerId,
  });

  /// Get all user's roadmap summaries
  /// Returns stream for real-time updates
  Stream<List<AICareerRoadmapSummary>> watchUserRoadmaps(String userId);

  /// Get count of user's roadmaps
  Future<int> getUserRoadmapCount(String userId);

  /// Delete a roadmap (cascade deletes phases and steps)
  Future<void> deleteRoadmap(String roadmapId);

  /// Delete roadmap by career ID
  Future<void> deleteRoadmapForCareer({
    required String userId,
    required String careerId,
  });
}
```

### Custom Exceptions

```dart
class RoadmapLimitExceededException implements Exception {
  RoadmapLimitExceededException(this.currentCount);
  final int currentCount;
}

class RoadmapAlreadyExistsException implements Exception {
  RoadmapAlreadyExistsException(this.careerId);
  final String careerId;
}

class AIGenerationFailedException implements Exception {
  AIGenerationFailedException(this.message);
  final String message;
}
```

---

## Data Layer

### AIRoadmapRepositoryImpl

**File:** `lib/data/repositories_impl/ai_roadmap_repository_impl.dart`

```dart
class AIRoadmapRepositoryImpl implements AIRoadmapRepository {
  AIRoadmapRepositoryImpl(this._supabase);
  final SupabaseClient _supabase;

  @override
  Future<String> generateRoadmap({
    required String careerId,
    String? locale,
  }) async {
    // 1. Call Edge Function
    final response = await _supabase.functions.invoke(
      'ai-generate-career-roadmap',
      method: HttpMethod.post,
      body: {
        'career_id': careerId,
        if (locale != null) 'locale': locale,
      },
    );

    // 2. Handle HTTP status codes
    if (response.status != 200) {
      final data = response.data as Map<String, dynamic>?;
      final error = data?['error'] as String? ?? 'Unknown error';

      // 3. Throw typed exceptions
      if (error == 'roadmap_limit_reached') {
        throw RoadmapLimitExceededException(data?['current_count'] ?? 3);
      } else if (error == 'roadmap_already_exists') {
        throw RoadmapAlreadyExistsException(careerId);
      } else if (error == 'missing_auth' || error == 'invalid_token') {
        throw Exception('Authentication failed');
      } else {
        throw AIGenerationFailedException(error);
      }
    }

    // 4. Parse success response
    final data = response.data as Map<String, dynamic>;
    final roadmapId = data['roadmap_id'] as String;
    return roadmapId;
  }

  @override
  Future<AICareerRoadmap?> getRoadmapById(String roadmapId) async {
    // Call SQL function that returns nested JSON
    final response = await _supabase.rpc<Map<String, dynamic>>(
      'get_user_career_roadmap_by_id',
      params: {'p_roadmap_id': roadmapId},
    ).maybeSingle();

    if (response == null) return null;
    return _mapToEntity(response);
  }

  @override
  Stream<List<AICareerRoadmapSummary>> watchUserRoadmaps(String userId) {
    // Real-time stream subscription
    return _supabase
        .from('user_career_roadmaps')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('generated_at', ascending: false)
        .map((data) {
          return data
              .map((json) => AICareerRoadmapSummary.fromJson(json))
              .toList();
        });
  }

  @override
  Future<void> deleteRoadmap(String roadmapId) async {
    // Cascade delete handled by database
    await _supabase
        .from('user_career_roadmaps')
        .delete()
        .eq('id', roadmapId);
  }

  // ... other methods
}
```

---

## Application Layer

### Providers

**File:** `lib/application/roadmaps/roadmap_providers.dart`

```dart
/// Repository provider
final aiRoadmapRepositoryProvider = Provider<AIRoadmapRepository>((ref) {
  return AIRoadmapRepositoryImpl(Supabase.instance.client);
});

/// Stream provider for real-time roadmap updates
final userRoadmapsStreamProvider =
    StreamProvider.autoDispose<List<AICareerRoadmapSummary>>((ref) {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) return Stream.value([]);
  return repository.watchUserRoadmaps(userId);
});

/// Roadmap count provider
final userRoadmapCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) return 0;
  return repository.getUserRoadmapCount(userId);
});

/// Check if roadmap exists for career
final hasRoadmapForCareerProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, careerId) async {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) return false;
  return repository.hasRoadmapForCareer(userId: userId, careerId: careerId);
});

/// Get roadmap by ID
final roadmapByIdProvider =
    FutureProvider.autoDispose.family<AICareerRoadmap?, String>(
        (ref, roadmapId) async {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  return repository.getRoadmapById(roadmapId);
});

/// Service provider
final roadmapServiceProvider = Provider<RoadmapService>((ref) {
  final repository = ref.watch(aiRoadmapRepositoryProvider);
  final analyticsService = MockAnalyticsService();
  return RoadmapService(
    roadmapRepository: repository,
    analyticsService: analyticsService,
  );
});
```

### RoadmapService

**File:** `lib/application/roadmaps/roadmap_service.dart`

```dart
class RoadmapService {
  RoadmapService({
    required AIRoadmapRepository roadmapRepository,
    required AnalyticsService analyticsService,
  });

  /// Complete generation flow with error handling
  Future<bool> generateRoadmapWithFlow({
    required BuildContext context,
    required String userId,
    required String careerId,
    required String careerTitle,
    required int matchScore,
    String? locale,
  }) async {
    // 1. Log analytics
    await _analyticsService.logCareerGenerateClicked(...);

    // 2. Check if exists
    final exists = await _roadmapRepository.hasRoadmapForCareer(...);
    if (exists) {
      // Show "already exists" message with View button
      return false;
    }

    // 3. Show loading dialog
    showDialog<void>(...);

    try {
      // 4. Generate roadmap
      final roadmapId = await _roadmapRepository.generateRoadmap(...);

      // 5. Success: Log and navigate
      await _analyticsService.logRoadmapGenerated(...);
      Navigator.of(context).pop(); // Close loading
      context.push('${AppRoutes.roadmapDetail}/$roadmapId');
      return true;

    } on RoadmapLimitExceededException catch (e) {
      // 6. Limit exceeded: Show delete modal
      Navigator.of(context).pop(); // Close loading

      final existingRoadmaps = await _roadmapRepository
          .watchUserRoadmaps(userId)
          .first;

      final selectedRoadmapId = await showDeleteRoadmapModal(...);

      if (selectedRoadmapId == null) return false; // User canceled

      // 7. Delete and retry
      await _roadmapRepository.deleteRoadmap(selectedRoadmapId);
      await _analyticsService.logRoadmapDeleted(..., reason: 'limit_reached');

      return generateRoadmapWithFlow(...); // Recursive retry

    } on AIGenerationFailedException catch (e) {
      // 8. AI failure: Show error with retry
      Navigator.of(context).pop(); // Close loading
      await _analyticsService.logRoadmapGenerationFailed(...);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${e.message}'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => generateRoadmapWithFlow(...),
          ),
        ),
      );
      return false;
    }
  }

  /// Delete with confirmation
  Future<bool> deleteRoadmapWithConfirmation({...}) async {
    final confirmed = await showDialog<bool>(...);
    if (!confirmed) return false;

    await _roadmapRepository.deleteRoadmap(roadmapId);
    await _analyticsService.logRoadmapDeleted(..., reason: 'user_initiated');
    return true;
  }
}
```

### Analytics Service

**File:** `lib/application/analytics/analytics_service.dart`

```dart
abstract class AnalyticsService {
  // Roadmap events
  Future<void> logCareerClusterViewed({...});
  Future<void> logClusterExpanded({...});
  Future<void> logCareerGenerateClicked({...});
  Future<void> logRoadmapGenerated({...});
  Future<void> logRoadmapGenerationFailed({...});
  Future<void> logRoadmapDeleted({...});
  Future<void> logRoadmapViewNavigated({...});
}

class MockAnalyticsService implements AnalyticsService {
  @override
  Future<void> logCareerGenerateClicked({
    required String userId,
    required String careerId,
    required String careerTitle,
    required int matchScore,
  }) async {
    developer.log(
      '[Analytics] career_generate_clicked: '
      'user=$userId career=$careerTitle score=$matchScore',
      name: 'AnalyticsService',
    );
  }

  // ... other events
}
```

---

## UI Layer

### RoadmapDetailPage

**File:** `lib/presentation/features/roadmaps/roadmap_detail_page.dart`

**Features:**
- Material 3 design with gradient header
- 4 expandable phase cards
- Step items with details, resources, tips
- Visual phase connectors
- Options menu (delete, share)

```dart
class RoadmapDetailPage extends ConsumerWidget {
  const RoadmapDetailPage({required this.roadmap});
  final AICareerRoadmap roadmap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roadmap.careerTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient background
            _RoadmapHeader(roadmap: roadmap),

            // Phase cards
            ...roadmap.phases.map((phase) => _PhaseCard(phase: phase)),
          ],
        ),
      ),
    );
  }
}
```

**Header Design:**
```
┌─────────────────────────────────────────┐
│  💻                                     │
│  Software Developer                     │
│  AI-Generated Roadmap                   │
│                                         │
│  Your analytical thinking and problem-  │
│  solving skills make you perfect for... │
│                                         │
│  ⏱ 8-10 years    💰 6k-25k+ AED        │
└─────────────────────────────────────────┘
```

**Phase Card (Collapsed):**
```
┌─────────────────────────────────────────┐
│  ① 🎓  High School Foundation           │
│     Build your technical foundation     │
│     Grades 9-12 (3-4 years)            │
│                                    ▼    │
└─────────────────────────────────────────┘
```

**Phase Card (Expanded):**
```
┌─────────────────────────────────────────┐
│  ① 🎓  High School Foundation           │
│     Build your technical foundation     │
│     Grades 9-12 (3-4 years)            │
│                                    ▲    │
├─────────────────────────────────────────┤
│  1  Excel in Math and Computer Science  │
│     Your analytical thinking gives...   │
│     • Focus on Advanced Mathematics     │
│     • Take Computer Science if avail... │
│     • Practice coding basics            │
│     🔗 Khan Academy, Code.org           │
│     💡 Your love for problem-solving... │
│                                         │
│  2  Join Coding Club or Competitions    │
│     ...                                 │
└─────────────────────────────────────────┘
```

### DeleteRoadmapModal

**File:** `lib/presentation/features/roadmaps/delete_roadmap_modal.dart`

**Features:**
- Shows when limit exceeded
- Lists existing 3 roadmaps
- Radio button selection
- Warning message
- Relative date formatting

```dart
class DeleteRoadmapModal extends StatefulWidget {
  const DeleteRoadmapModal({
    required this.existingRoadmaps,
    required this.newCareerTitle,
  });

  final List<AICareerRoadmapSummary> existingRoadmaps;
  final String newCareerTitle;
}
```

**Modal Design:**
```
┌─────────────────────────────────────────┐
│  ⚠️  Roadmap Limit Reached          ✕  │
├─────────────────────────────────────────┤
│  You can only have 3 roadmaps at a time │
│  to keep your focus sharp.              │
│                                         │
│  To generate a roadmap for "UX          │
│  Designer", please choose one to delete:│
│                                         │
│  Your Current Roadmaps                  │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 💻 Software Developer       ○  │   │
│  │ Build apps and software...     │   │
│  │ Generated 2 days ago           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 📊 Data Scientist           ●  │   │
│  │ Analyze data and build AI...   │   │
│  │ Generated 1 week ago           │   │
│  └─────────────────────────────────┘   │ Selected
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🎨 Graphic Designer         ○  │   │
│  │ Create visual designs...       │   │
│  │ Generated 2 weeks ago          │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ℹ️ This action cannot be undone.      │
│                                         │
│  [ Cancel ]  [ Delete & Continue ]     │
└─────────────────────────────────────────┘
```

### CareersPageClustered

**File:** `lib/presentation/features/careers/careers_page_clustered.dart`

**Features:**
- Cluster-first view (top 4 clusters)
- Each cluster shows top 3 careers
- Expandable cluster cards
- Generate roadmap buttons
- Match score indicators

```dart
class CareersPageClustered extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Top Career Matches'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_tree),
            onPressed: () => context.push(AppRoutes.careerTree),
          ),
          IconButton(
            icon: Icon(Icons.map),
            tooltip: 'My Roadmaps',
            onPressed: () {
              // Navigate to roadmaps list
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Padding(...),

          // Cluster list
          Expanded(
            child: ListView.builder(
              itemCount: clusters.length,
              itemBuilder: (context, index) {
                return _ClusterCard(cluster: clusters[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

**Cluster Card:**
```
┌─────────────────────────────────────────┐
│  💻                                     │
│  Technology                             │
│  Software, AI, Data, and Digital...    │
│  📈 Best Match: 95%                     │
│                                    ▼    │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐ │
│  │ 95  Software Developer        🗺  │ │
│  │     Build apps and software...    │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ 88  Data Scientist            🗺  │ │
│  │     Analyze data and build AI...  │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ 82  UX Designer               🗺  │ │
│  │     Design user-friendly exp...   │ │
│  └───────────────────────────────────┘ │
│                                         │
│  → View all Technology careers         │
└─────────────────────────────────────────┘
```

---

## User Flow

### Complete Generation Flow

```
1. User opens Careers page
   ↓
2. System displays top 4 clusters with top 3 careers each
   - Clusters ranked by best match score
   - Analytics: career_cluster_viewed
   ↓
3. User expands cluster
   - Analytics: cluster_expanded
   ↓
4. User clicks 🗺 "Generate Roadmap" button on a career
   ↓
5. System validates authentication
   - If not authenticated: Show login prompt
   ↓
6. System checks if roadmap exists
   - Query: hasRoadmapForCareer(userId, careerId)
   - If exists: Show "View" button in SnackBar
   ↓
7. System shows loading dialog
   - "Generating your personalized roadmap..."
   - Analytics: career_generate_clicked
   ↓
8. System calls Edge Function
   - POST /functions/v1/ai-generate-career-roadmap
   - Body: { career_id, locale: 'en' }
   ↓
9. Edge Function checks limit
   - Query: COUNT(*) FROM user_career_roadmaps WHERE user_id
   - If >= 3: Return 403 with error 'roadmap_limit_reached'
   ↓
10. Edge Function generates roadmap
    - Fetches user vectors
    - Constructs AI prompt
    - Calls Azure OpenAI
    - Validates response
    - Persists to 3 tables
    - Returns roadmap_id
    ↓
11. System handles response

    ┌─── SUCCESS (200) ───┐
    │                     │
    │ • Close loading     │
    │ • Log analytics:    │
    │   roadmap_generated │
    │ • Navigate to:      │
    │   /roadmap/detail/  │
    │   :roadmapId        │
    └─────────────────────┘

    ┌─── LIMIT EXCEEDED (403) ───┐
    │                             │
    │ • Close loading             │
    │ • Fetch existing roadmaps   │
    │ • Show DeleteRoadmapModal   │
    │ • User selects roadmap      │
    │ • Delete selected           │
    │ • Log analytics:            │
    │   roadmap_deleted           │
    │   (reason: limit_reached)   │
    │ • Retry generation (goto 7) │
    └─────────────────────────────┘

    ┌─── ERROR (500) ───┐
    │                   │
    │ • Close loading   │
    │ • Show SnackBar:  │
    │   "Failed: ..."   │
    │   [Retry] button  │
    │ • Log analytics:  │
    │   roadmap_        │
    │   generation_     │
    │   failed          │
    └───────────────────┘
    ↓
12. User views Roadmap Detail page
    - Fetches: get_user_career_roadmap_by_id(roadmapId)
    - Analytics: roadmap_view_navigated
    - Displays 4 expandable phases
    - Each phase shows steps with details, resources, tips
    ↓
13. User can:
    - Expand/collapse phases to read steps
    - Click options menu → Delete roadmap
    - Navigate back to careers
```

### Delete Flow (User-Initiated)

```
1. User on Roadmap Detail page
   ↓
2. User clicks ⋮ options menu
   ↓
3. User selects "Delete Roadmap"
   ↓
4. System shows confirmation dialog
   - "Are you sure you want to delete your roadmap for [title]?"
   - "This action cannot be undone."
   - [Cancel] [Delete] buttons
   ↓
5. User confirms deletion
   ↓
6. System deletes roadmap
   - DELETE FROM user_career_roadmaps WHERE id = roadmapId
   - Cascade deletes phases and steps automatically
   ↓
7. System logs analytics
   - Event: roadmap_deleted
   - Reason: 'user_initiated'
   ↓
8. System shows success message
   - SnackBar: "Roadmap for [title] deleted"
   ↓
9. System navigates back
   - Returns to previous page (usually careers)
```

---

## API Reference

### Riverpod Providers

#### aiRoadmapRepositoryProvider
```dart
final aiRoadmapRepositoryProvider = Provider<AIRoadmapRepository>((ref) { ... });
```
**Returns:** Singleton instance of AIRoadmapRepositoryImpl
**Usage:** Access repository methods

#### userRoadmapsStreamProvider
```dart
final userRoadmapsStreamProvider = StreamProvider.autoDispose<List<AICareerRoadmapSummary>>((ref) { ... });
```
**Returns:** Real-time stream of user's roadmap summaries
**Auto-disposes:** Yes
**Usage:** Display list of roadmaps with live updates

```dart
// In widget
final roadmapsAsync = ref.watch(userRoadmapsStreamProvider);
roadmapsAsync.when(
  data: (roadmaps) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, _) => Text('Error: $error'),
);
```

#### userRoadmapCountProvider
```dart
final userRoadmapCountProvider = FutureProvider.autoDispose<int>((ref) { ... });
```
**Returns:** Count of user's roadmaps (0-3)
**Auto-disposes:** Yes
**Usage:** Check limit before generation

#### hasRoadmapForCareerProvider
```dart
final hasRoadmapForCareerProvider = FutureProvider.autoDispose.family<bool, String>((ref, careerId) { ... });
```
**Parameter:** careerId (String)
**Returns:** Boolean indicating existence
**Auto-disposes:** Yes
**Usage:** Show/hide generate button

```dart
final hasRoadmap = ref.watch(hasRoadmapForCareerProvider(career.id));
hasRoadmap.when(
  data: (exists) => exists ? Text('View') : FilledButton('Generate'),
  loading: () => SizedBox.shrink(),
  error: (_, __) => FilledButton('Generate'),
);
```

#### roadmapByIdProvider
```dart
final roadmapByIdProvider = FutureProvider.autoDispose.family<AICareerRoadmap?, String>((ref, roadmapId) { ... });
```
**Parameter:** roadmapId (String)
**Returns:** Complete roadmap with phases and steps
**Auto-disposes:** Yes
**Usage:** Display detail page

#### roadmapServiceProvider
```dart
final roadmapServiceProvider = Provider<RoadmapService>((ref) { ... });
```
**Returns:** Singleton RoadmapService instance
**Usage:** Call generation flow

```dart
final roadmapService = ref.read(roadmapServiceProvider);
await roadmapService.generateRoadmapWithFlow(
  context: context,
  userId: userId,
  careerId: career.id,
  careerTitle: career.title,
  matchScore: career.matchScore,
  locale: 'en',
);
```

### RoadmapService Methods

#### generateRoadmapWithFlow
```dart
Future<bool> generateRoadmapWithFlow({
  required BuildContext context,
  required String userId,
  required String careerId,
  required String careerTitle,
  required int matchScore,
  String? locale,
});
```
**Returns:** true if successful, false if canceled/failed
**Side effects:**
- Shows loading dialog
- Shows delete modal if limit exceeded
- Shows error SnackBar on failure
- Navigates to detail page on success
- Logs analytics events

**Usage:**
```dart
final success = await roadmapService.generateRoadmapWithFlow(
  context: context,
  userId: currentUser.id,
  careerId: 'career-uuid',
  careerTitle: 'Software Developer',
  matchScore: 95,
  locale: 'en',
);

if (success) {
  // User is now viewing their new roadmap
}
```

#### deleteRoadmapWithConfirmation
```dart
Future<bool> deleteRoadmapWithConfirmation({
  required BuildContext context,
  required String userId,
  required String roadmapId,
  required String careerTitle,
});
```
**Returns:** true if deleted, false if canceled
**Side effects:**
- Shows confirmation dialog
- Deletes roadmap if confirmed
- Shows success SnackBar
- Navigates back
- Logs analytics event

### Analytics Events

All events are logged via `AnalyticsService`:

#### career_cluster_viewed
```dart
await analyticsService.logCareerClusterViewed(
  userId: userId,
  clusterId: cluster.id,
  clusterName: cluster.name,
);
```

#### cluster_expanded
```dart
await analyticsService.logClusterExpanded(
  userId: userId,
  clusterId: cluster.id,
  clusterName: cluster.name,
);
```

#### career_generate_clicked
```dart
await analyticsService.logCareerGenerateClicked(
  userId: userId,
  careerId: career.id,
  careerTitle: career.title,
  matchScore: career.matchScore,
);
```

#### roadmap_generated
```dart
await analyticsService.logRoadmapGenerated(
  userId: userId,
  roadmapId: roadmapId,
  careerId: career.id,
  careerTitle: career.title,
);
```

#### roadmap_generation_failed
```dart
await analyticsService.logRoadmapGenerationFailed(
  userId: userId,
  careerId: career.id,
  careerTitle: career.title,
  errorCode: 'ai_generation_failed', // or 'unknown_error'
);
```

#### roadmap_deleted
```dart
await analyticsService.logRoadmapDeleted(
  userId: userId,
  roadmapId: roadmapId,
  careerTitle: careerTitle,
  reason: 'limit_reached', // or 'user_initiated'
);
```

#### roadmap_view_navigated
```dart
await analyticsService.logRoadmapViewNavigated(
  userId: userId,
  roadmapId: roadmapId,
  careerTitle: careerTitle,
);
```

---

## Deployment Guide

### Prerequisites

- ✅ Supabase project created
- ✅ Supabase CLI installed
- ✅ Azure OpenAI account with API key
- ✅ Flutter SDK installed
- ✅ Git repository initialized

### Step 1: Deploy Database Migration

```bash
cd supabase

# Push migration to Supabase
supabase db push

# Verify tables created
supabase db remote status

# Expected output:
# ✓ user_career_roadmaps
# ✓ user_roadmap_phases
# ✓ user_roadmap_steps
```

**Verify in Supabase Dashboard:**
1. Go to Database → Tables
2. Confirm 3 new tables exist
3. Check Indexes tab for 6 indexes
4. Check Policies tab for 3 RLS policies

### Step 2: Deploy Edge Function

```bash
cd supabase/functions

# Deploy function
supabase functions deploy ai-generate-career-roadmap

# Set environment variable
supabase secrets set OPENAI_AZURE=your_azure_api_key_here

# Verify deployment
supabase functions list
```

**Expected output:**
```
ai-generate-career-roadmap (deployed)
generate_ai_career_insight (deployed)
update_profile_and_match (deployed)
```

### Step 3: Test Edge Function

```bash
# Get your Supabase JWT token from browser DevTools
# Network tab → Headers → Authorization

curl -X POST \
  https://your-project.supabase.co/functions/v1/ai-generate-career-roadmap \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "career_id": "test-career-uuid",
    "locale": "en"
  }'
```

**Expected success response:**
```json
{
  "success": true,
  "roadmap_id": "550e8400-e29b-41d4-a716-446655440000",
  "career_title": "Software Developer"
}
```

### Step 4: Configure Flutter App

```bash
cd ..  # Back to project root

# Install dependencies
flutter pub get

# Verify no errors
flutter analyze
```

### Step 5: Run App and Test

```bash
# Run on device/simulator
flutter run

# Or run on web
flutter run -d chrome
```

**Test Flow:**
1. Log in as test user
2. Navigate to Careers page
3. Click "Generate Roadmap" button
4. Verify loading dialog appears
5. Wait for generation (10-30 seconds)
6. Verify navigation to roadmap detail page
7. Verify 4 phases displayed correctly
8. Try generating 3 more roadmaps
9. On 4th attempt, verify delete modal shows
10. Select a roadmap and confirm deletion
11. Verify generation succeeds after deletion

### Step 6: Monitor Logs

**Supabase Logs:**
```bash
# Real-time function logs
supabase functions logs ai-generate-career-roadmap --follow

# Database logs
supabase db logs --follow
```

**Flutter Logs:**
```bash
# Console output shows analytics events
[Analytics] career_generate_clicked: user=xxx career=Software Developer
[Analytics] roadmap_generated: roadmap_id=xxx
```

### Step 7: Production Checklist

- [ ] Migration deployed successfully
- [ ] Edge Function deployed successfully
- [ ] OPENAI_AZURE secret set
- [ ] Test user can generate roadmap
- [ ] Test limit enforcement (3 max)
- [ ] Test delete modal shows at limit
- [ ] Test roadmap detail page displays correctly
- [ ] Test analytics events logged
- [ ] Verify RLS policies prevent unauthorized access
- [ ] Test error handling (disconnect network)
- [ ] Test Arabic locale support
- [ ] Monitor function execution time (<30s)
- [ ] Monitor database query performance
- [ ] Set up error alerting (Sentry, etc.)

---

## Testing Guide

### Unit Tests

#### Test: AIRoadmapRepository

```dart
void main() {
  group('AIRoadmapRepository', () {
    late MockSupabaseClient mockSupabase;
    late AIRoadmapRepositoryImpl repository;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      repository = AIRoadmapRepositoryImpl(mockSupabase);
    });

    test('generateRoadmap returns roadmap_id on success', () async {
      // Arrange
      when(mockSupabase.functions.invoke('ai-generate-career-roadmap', ...))
          .thenAnswer((_) async => FunctionResponse(
                status: 200,
                data: {'success': true, 'roadmap_id': 'test-id'},
              ));

      // Act
      final roadmapId = await repository.generateRoadmap(
        careerId: 'career-id',
        locale: 'en',
      );

      // Assert
      expect(roadmapId, equals('test-id'));
    });

    test('generateRoadmap throws RoadmapLimitExceededException on 403', () async {
      // Arrange
      when(mockSupabase.functions.invoke('ai-generate-career-roadmap', ...))
          .thenAnswer((_) async => FunctionResponse(
                status: 403,
                data: {
                  'success': false,
                  'error': 'roadmap_limit_reached',
                  'current_count': 3
                },
              ));

      // Act & Assert
      expect(
        () => repository.generateRoadmap(careerId: 'career-id'),
        throwsA(isA<RoadmapLimitExceededException>()),
      );
    });

    test('watchUserRoadmaps returns stream of summaries', () async {
      // Arrange
      final mockStream = Stream.value([
        {
          'id': 'roadmap-1',
          'career_id': 'career-1',
          'career_title': 'Software Developer',
          'description': 'Test description',
          'icon': '💻',
          'estimated_duration': '8-10 years',
          'generated_at': '2025-01-15T10:30:00Z',
        }
      ]);

      when(mockSupabase.from('user_career_roadmaps').stream(...))
          .thenAnswer((_) => mockStream);

      // Act
      final summaries = await repository
          .watchUserRoadmaps('user-id')
          .first;

      // Assert
      expect(summaries.length, equals(1));
      expect(summaries[0].careerTitle, equals('Software Developer'));
    });
  });
}
```

#### Test: RoadmapService

```dart
void main() {
  group('RoadmapService', () {
    late MockAIRoadmapRepository mockRepository;
    late MockAnalyticsService mockAnalytics;
    late RoadmapService service;

    setUp(() {
      mockRepository = MockAIRoadmapRepository();
      mockAnalytics = MockAnalyticsService();
      service = RoadmapService(
        roadmapRepository: mockRepository,
        analyticsService: mockAnalytics,
      );
    });

    testWidgets('generateRoadmapWithFlow shows loading and navigates on success',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.hasRoadmapForCareer(...))
          .thenAnswer((_) async => false);
      when(mockRepository.generateRoadmap(...))
          .thenAnswer((_) async => 'roadmap-id');

      await tester.pumpWidget(MaterialApp(home: TestWidget(service)));

      // Act
      await tester.tap(find.text('Generate'));
      await tester.pump();

      // Assert - loading dialog shown
      expect(find.text('Generating your personalized roadmap...'), findsOneWidget);

      await tester.pumpAndSettle();

      // Assert - navigated to detail page
      verify(mockAnalytics.logRoadmapGenerated(...)).called(1);
      expect(find.byType(RoadmapDetailPage), findsOneWidget);
    });

    testWidgets('generateRoadmapWithFlow shows delete modal on limit',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.hasRoadmapForCareer(...))
          .thenAnswer((_) async => false);
      when(mockRepository.generateRoadmap(...))
          .thenThrow(RoadmapLimitExceededException(3));
      when(mockRepository.watchUserRoadmaps(...))
          .thenAnswer((_) => Stream.value([/* 3 summaries */]));

      await tester.pumpWidget(MaterialApp(home: TestWidget(service)));

      // Act
      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();

      // Assert - delete modal shown
      expect(find.text('Roadmap Limit Reached'), findsOneWidget);
      expect(find.text('Delete & Continue'), findsOneWidget);
    });
  });
}
```

### Integration Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Roadmap Generation Flow', () {
    testWidgets('Complete generation flow', (WidgetTester tester) async {
      // 1. Start app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 2. Navigate to careers
      await tester.tap(find.text('Careers'));
      await tester.pumpAndSettle();

      // 3. Find and tap generate button
      final generateButton = find.widgetWithIcon(IconButton, Icons.map).first;
      await tester.tap(generateButton);
      await tester.pump();

      // 4. Verify loading dialog
      expect(find.text('Generating your personalized roadmap...'), findsOneWidget);

      // 5. Wait for generation (timeout 60s)
      await tester.pumpAndSettle(Duration(seconds: 60));

      // 6. Verify navigation to detail page
      expect(find.byType(RoadmapDetailPage), findsOneWidget);
      expect(find.textContaining('Phase 1'), findsOneWidget);

      // 7. Expand first phase
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // 8. Verify steps visible
      expect(find.textContaining('Excel in'), findsOneWidget);
      expect(find.textContaining('details'), findsWidgets);
      expect(find.textContaining('resources'), findsWidgets);
    });
  });
}
```

### Manual Testing Checklist

#### Functional Tests

- [ ] **Generate First Roadmap**
  - Click generate button
  - Loading dialog appears
  - Generation succeeds (10-30s)
  - Navigates to detail page
  - 4 phases displayed
  - All steps have details and resources

- [ ] **Generate Second Roadmap**
  - Return to careers
  - Generate for different career
  - Succeeds without issues

- [ ] **Generate Third Roadmap**
  - Generate for third career
  - Succeeds
  - Count now at 3/3

- [ ] **Test Limit Enforcement**
  - Try to generate 4th roadmap
  - Delete modal appears
  - Shows 3 existing roadmaps
  - Select one to delete
  - Generation retries and succeeds

- [ ] **Test Duplicate Prevention**
  - Try to generate roadmap for career that exists
  - Shows "already exists" message
  - "View" button navigates to existing roadmap

- [ ] **Test User-Initiated Delete**
  - Open roadmap detail
  - Click options menu (⋮)
  - Select "Delete Roadmap"
  - Confirmation dialog appears
  - Confirm deletion
  - Returns to previous page
  - Roadmap removed from list

#### Error Handling Tests

- [ ] **Network Error**
  - Disconnect network
  - Try to generate
  - Error SnackBar shown
  - "Retry" button available
  - Reconnect and retry works

- [ ] **Authentication Error**
  - Log out (or expire token)
  - Try to generate
  - "Please log in" message shown

- [ ] **AI Generation Failure**
  - (Simulate by temporarily breaking OPENAI_AZURE secret)
  - Error message shows
  - Analytics event logged

#### UI/UX Tests

- [ ] **Loading States**
  - Loading dialog shows immediately
  - Spinner animates correctly
  - Dialog prevents interaction
  - Dialog closes on success/error

- [ ] **Delete Modal**
  - All 3 roadmaps listed
  - Radio buttons work
  - Selection highlighted
  - Cancel button dismisses
  - Delete button disabled when none selected

- [ ] **Roadmap Detail**
  - Header gradient displays
  - Icon and title correct
  - Description personalized
  - Duration and salary shown
  - Phases expand/collapse
  - Steps formatted correctly
  - Resources clickable (if implemented)
  - Tips styled distinctly
  - Optional badges visible

- [ ] **Responsive Design**
  - Works on phone (portrait/landscape)
  - Works on tablet
  - Works on web/desktop

#### Performance Tests

- [ ] **Generation Speed**
  - First generation: <30s
  - Subsequent generations: <20s
  - No memory leaks after multiple generations

- [ ] **Database Performance**
  - Detail page loads: <2s
  - Stream updates: <1s
  - Delete operation: <1s

- [ ] **App Performance**
  - No frame drops during animations
  - Smooth scrolling in detail page
  - No lag when expanding phases

#### Analytics Tests

- [ ] **Events Logged**
  - Check console logs for all events
  - career_cluster_viewed on page load
  - cluster_expanded on expansion
  - career_generate_clicked on button click
  - roadmap_generated on success
  - roadmap_generation_failed on error
  - roadmap_deleted on deletion (both reasons)
  - roadmap_view_navigated on detail view

---

## Troubleshooting

### Common Issues

#### Issue: "Edge Function not found"

**Symptoms:**
- Error: "Function 'ai-generate-career-roadmap' not found"
- HTTP 404

**Solutions:**
```bash
# Verify function deployed
supabase functions list

# If not listed, deploy again
cd supabase/functions
supabase functions deploy ai-generate-career-roadmap

# Check function logs
supabase functions logs ai-generate-career-roadmap
```

#### Issue: "Missing environment variable OPENAI_AZURE"

**Symptoms:**
- Edge Function returns 500
- Logs show: "Deno.env.get('OPENAI_AZURE') is undefined"

**Solutions:**
```bash
# Set the secret
supabase secrets set OPENAI_AZURE=your_api_key_here

# Verify it's set
supabase secrets list

# Redeploy function to pick up new secret
supabase functions deploy ai-generate-career-roadmap
```

#### Issue: "RLS policy denies access"

**Symptoms:**
- Error: "permission denied for table user_career_roadmaps"
- User can't view own roadmaps

**Solutions:**
```sql
-- Check if RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'user_career_roadmaps';

-- Check policies exist
SELECT * FROM pg_policies
WHERE tablename = 'user_career_roadmaps';

-- Verify user's JWT token is valid
SELECT auth.uid();  -- Should return user's UUID

-- If policies missing, rerun migration
-- supabase db reset
```

#### Issue: "Roadmap limit not enforced"

**Symptoms:**
- User can generate more than 3 roadmaps

**Solutions:**
```typescript
// Check Edge Function logic
// File: supabase/functions/ai-generate-career-roadmap/index.ts

// Verify checkRoadmapLimit function
const limitCheck = await checkRoadmapLimit(supabase, userId);
if (!limitCheck.allowed) {
  return new Response(
    JSON.stringify({
      success: false,
      error: 'roadmap_limit_reached',
      current_count: limitCheck.current_count,
    }),
    { status: 403 }
  );
}
```

#### Issue: "AI response invalid"

**Symptoms:**
- Error: "Invalid roadmap structure from AI"
- Generation fails after AI call succeeds

**Solutions:**
```typescript
// Add more detailed logging in Edge Function
console.log('AI Response:', JSON.stringify(roadmap, null, 2));

// Check if response has required fields
if (!roadmap.career_title || !roadmap.phases || roadmap.phases.length !== 4) {
  console.error('Invalid structure:', {
    has_title: !!roadmap.career_title,
    has_phases: !!roadmap.phases,
    phases_count: roadmap.phases?.length,
  });
  throw new Error('Invalid roadmap structure from AI');
}

// Check Azure OpenAI deployment
// Ensure model supports JSON mode
// Try different deployment (gpt-4o vs gpt-4-turbo)
```

#### Issue: "Navigation doesn't work after generation"

**Symptoms:**
- Roadmap generated successfully
- Page doesn't navigate to detail view
- No errors in console

**Solutions:**
```dart
// Check if context is mounted before navigation
if (context.mounted) {
  context.push('${AppRoutes.roadmapDetail}/$roadmapId');
}

// Verify route is registered in app_router.dart
GoRoute(
  path: '${AppRoutes.roadmapDetail}/:roadmapId',
  pageBuilder: (context, state) {
    final roadmapId = state.pathParameters['roadmapId']!;
    return MaterialPage(child: ...);
  },
),

// Check if roadmapByIdProvider is working
final roadmapAsync = ref.watch(roadmapByIdProvider(roadmapId));
print('Roadmap data: ${roadmapAsync.value}');
```

#### Issue: "Delete modal doesn't show existing roadmaps"

**Symptoms:**
- Modal opens but list is empty
- Shows "Loading..." forever

**Solutions:**
```dart
// Check if stream provider returns data
final roadmapsAsync = ref.watch(userRoadmapsStreamProvider);
roadmapsAsync.when(
  data: (roadmaps) {
    print('Roadmaps count: ${roadmaps.length}');
    // Should print 3
  },
  loading: () => print('Still loading...'),
  error: (error, stack) {
    print('Error loading roadmaps: $error');
    print('Stack: $stack');
  },
);

// Verify RLS allows SELECT
SELECT * FROM user_career_roadmaps WHERE user_id = auth.uid();

// Check if stream is configured correctly
.stream(primaryKey: ['id'])  // Must specify primary key
.eq('user_id', userId)       // Must filter by user
```

#### Issue: "Arabic locale not working"

**Symptoms:**
- Roadmap generated in English even when locale='ar' passed

**Solutions:**
```typescript
// Check Edge Function receives locale
console.log('Request body:', JSON.stringify(body));

// Verify prompt includes language instruction
const languageInstruction = isArabic
  ? 'Respond in Arabic language. Use Arabic text for all fields.'
  : 'Respond in English language.';

// Check AI response
console.log('AI Response language detected:',
  /[\u0600-\u06FF]/.test(roadmap.career_title) ? 'Arabic' : 'English'
);

// Ensure Azure OpenAI supports Arabic
// Some older models may not handle Arabic well
// Try gpt-4o or newer models
```

### Debug Logging

#### Enable Detailed Logs

**Flutter App:**
```dart
// In main.dart
void main() {
  // Enable detailed logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(MyApp());
}
```

**Edge Function:**
```typescript
// Add at start of function
console.log('=== ROADMAP GENERATION START ===');
console.log('User ID:', userId);
console.log('Career ID:', careerId);
console.log('Locale:', locale);

// Before each major step
console.log('Step 1: Checking limit...');
console.log('Step 2: Fetching vectors...');
console.log('Step 3: Building prompt...');
console.log('Step 4: Calling AI...');
console.log('Step 5: Validating response...');
console.log('Step 6: Persisting...');

console.log('=== ROADMAP GENERATION COMPLETE ===');
```

#### Monitor Real-Time

**Terminal 1 - Flutter logs:**
```bash
flutter run --verbose | grep -E "(Analytics|Roadmap|Error)"
```

**Terminal 2 - Supabase logs:**
```bash
supabase functions logs ai-generate-career-roadmap --follow
```

**Terminal 3 - Database queries:**
```bash
supabase db logs --follow | grep user_career_roadmaps
```

### Performance Optimization

#### Slow Generation (>60s)

**Causes:**
- Azure OpenAI rate limiting
- Large prompt size
- Network latency

**Solutions:**
```typescript
// Reduce max_tokens if response is too long
max_tokens: 3000  // Instead of 4000

// Use faster model
const deployments = [
  'gpt-4o-mini',     // Fastest
  'gpt-4o',          // Fast
  'gpt-4-turbo',     // Slower
];

// Simplify prompt (fewer examples)
// Cache user vectors to avoid repeated DB queries
```

#### Slow Detail Page Load (>5s)

**Causes:**
- SQL function inefficient
- Missing indexes
- Large roadmap data

**Solutions:**
```sql
-- Add indexes if missing
CREATE INDEX IF NOT EXISTS idx_phases_roadmap
ON user_roadmap_phases(roadmap_id);

CREATE INDEX IF NOT EXISTS idx_steps_phase
ON user_roadmap_steps(phase_id);

-- Analyze query performance
EXPLAIN ANALYZE
SELECT public.get_user_career_roadmap_by_id('roadmap-uuid');

-- Optimize JSON aggregation
-- Consider adding LIMIT if steps are excessive
```

---

## Appendix

### Database ERD

```
┌─────────────────────────────────┐
│ auth.users                       │
├─────────────────────────────────┤
│ id (PK)                         │
│ email                           │
│ ...                             │
└────────────┬────────────────────┘
             │ 1
             │
             │ N
┌────────────▼────────────────────┐
│ user_career_roadmaps            │
├─────────────────────────────────┤
│ id (PK)                         │
│ user_id (FK → auth.users)       │
│ career_id (FK → careers)        │
│ career_title                    │
│ description                     │
│ estimated_duration              │
│ salary_range                    │
│ icon                            │
│ generated_at                    │
│ updated_at                      │
│ UNIQUE(user_id, career_id)      │
└────────────┬────────────────────┘
             │ 1
             │
             │ 4 (exactly)
┌────────────▼────────────────────┐
│ user_roadmap_phases             │
├─────────────────────────────────┤
│ id (PK)                         │
│ roadmap_id (FK → roadmaps)      │
│ phase_order (0-3)               │
│ phase_type (enum)               │
│ title                           │
│ subtitle                        │
│ icon                            │
│ duration                        │
│ created_at                      │
│ UNIQUE(roadmap_id, phase_order) │
└────────────┬────────────────────┘
             │ 1
             │
             │ 3-5 (typically)
┌────────────▼────────────────────┐
│ user_roadmap_steps              │
├─────────────────────────────────┤
│ id (PK)                         │
│ phase_id (FK → phases)          │
│ step_order                      │
│ title                           │
│ description                     │
│ details (TEXT[])                │
│ resources (TEXT[])              │
│ tip                             │
│ is_optional                     │
│ created_at                      │
│ UNIQUE(phase_id, step_order)    │
└─────────────────────────────────┘
```

### File Structure

```
lib/
├── application/
│   ├── analytics/
│   │   └── analytics_service.dart         # Analytics interface + Mock
│   └── roadmaps/
│       ├── roadmap_providers.dart         # Riverpod providers
│       └── roadmap_service.dart           # Generation flow orchestration
├── core/
│   └── router/
│       └── app_router.dart                # Route configuration
├── data/
│   └── repositories_impl/
│       ├── ai_roadmap_repository_impl.dart  # Supabase implementation
│       └── career_repository_impl.dart      # Mock + cluster logic
├── domain/
│   ├── entities/
│   │   ├── ai_career_roadmap.dart         # AICareerRoadmap, RoadmapPhase, RoadmapStep
│   │   ├── career_cluster.dart            # CareerClusterGroup
│   │   └── career.dart                    # Career entity
│   └── repositories/
│       ├── ai_roadmap_repository.dart     # Repository interface
│       └── career_repository.dart         # Career repo interface
└── presentation/
    └── features/
        ├── careers/
        │   ├── careers_page.dart          # Original careers page
        │   └── careers_page_clustered.dart # New cluster-first view
        └── roadmaps/
            ├── roadmap_detail_page.dart   # 4-phase detail view
            └── delete_roadmap_modal.dart  # Limit management modal

supabase/
├── functions/
│   └── ai-generate-career-roadmap/
│       └── index.ts                       # Edge Function
└── migrations/
    └── 00014_roadmap.sql                  # Database schema

docs/
└── AI_CAREER_ROADMAPS_IMPLEMENTATION.md   # This file
```

### Related Documentation

- **Migration 00014:** Database schema and RLS policies
- **Edge Function README:** AI prompt engineering guide
- **API Spec:** Supabase Edge Functions API
- **Flutter Docs:** Riverpod state management
- **Supabase Docs:** Real-time subscriptions
- **Azure OpenAI Docs:** GPT-4 API reference

---

**Document Version:** 1.0
**Last Updated:** 2025-01-15
**Author:** Claude (Anthropic)
**Status:** Complete

**Change Log:**
- 2025-01-15: Initial comprehensive documentation
- Covers all aspects of AI-generated career roadmaps system
- Includes architecture, API reference, deployment, testing, troubleshooting

---

For questions or issues, please refer to:
- GitHub Issues: [Project Repository]
- Supabase Dashboard: [Your Project URL]
- Team Contact: [Your Team]

**End of Documentation**
