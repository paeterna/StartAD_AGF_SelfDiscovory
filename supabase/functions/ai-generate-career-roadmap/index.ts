// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface RoadmapRequest {
  career_id: string;
  locale?: string;
}

interface UserVectors {
  interests: Record<string, number>;
  traits: Record<string, number>;
  cognition: Record<string, number>;
  skills: string[];
}

interface RoadmapStep {
  title: string;
  description: string;
  details: string[];
  resources: string[];
  tip: string | null;
  is_optional: boolean;
}

interface RoadmapPhase {
  phase_type: 'school' | 'university' | 'skills' | 'career';
  title: string;
  subtitle: string;
  icon: string;
  duration: string;
  steps: RoadmapStep[];
}

interface AIRoadmapResponse {
  career_title: string;
  description: string;
  estimated_duration: string;
  salary_range: string;
  icon: string;
  phases: RoadmapPhase[];
}

/**
 * Fetch user feature vectors from the database
 */
async function fetchUserVectors(supabase: any, userId: string): Promise<UserVectors> {
  // Fetch feature scores
  const { data: featureScores, error } = await supabase
    .from('user_feature_scores')
    .select(`
      feature_key,
      score_mean,
      features!inner(key, family)
    `)
    .eq('user_id', userId)
    .gte('score_mean', 0.3) // Only fetch significant scores
    .order('score_mean', { ascending: false });

  if (error) {
    throw new Error(`Failed to fetch user vectors: ${error.message}`);
  }

  const vectors: UserVectors = {
    interests: {},
    traits: {},
    cognition: {},
    skills: [],
  };

  for (const score of featureScores || []) {
    const family = score.features.family;
    const key = score.features.key.replace(`${family}_`, '');
    const value = score.score_mean;

    if (family === 'interests') {
      vectors.interests[key] = value;
    } else if (family === 'traits') {
      vectors.traits[key] = value;
    } else if (family === 'cognition') {
      vectors.cognition[key] = value;
    }
  }

  // Extract skills from top cognition and traits
  const topCognition = Object.entries(vectors.cognition)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 3)
    .map(([key]) => key);

  const topTraits = Object.entries(vectors.traits)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 3)
    .map(([key]) => key);

  vectors.skills = [...topCognition, ...topTraits];

  return vectors;
}

/**
 * Fetch career details from database
 */
async function fetchCareerDetails(supabase: any, careerId: string): Promise<any> {
  const { data: career, error } = await supabase
    .from('careers')
    .select('id, title, description, cluster, tags')
    .eq('id', careerId)
    .single();

  if (error) {
    throw new Error(`Failed to fetch career: ${error.message}`);
  }

  if (!career) {
    throw new Error('Career not found');
  }

  return career;
}

/**
 * Check roadmap limit (max 3 per user)
 */
async function checkRoadmapLimit(supabase: any, userId: string): Promise<{ allowed: boolean; current_count: number }> {
  const { data, error } = await supabase
    .from('user_career_roadmaps')
    .select('id', { count: 'exact', head: false })
    .eq('user_id', userId);

  if (error) {
    throw new Error(`Failed to check roadmap limit: ${error.message}`);
  }

  const count = data?.length || 0;
  return {
    allowed: count < 3,
    current_count: count,
  };
}

/**
 * Check if roadmap already exists for this career
 */
async function hasExistingRoadmap(supabase: any, userId: string, careerId: string): Promise<boolean> {
  const { data, error } = await supabase
    .from('user_career_roadmaps')
    .select('id')
    .eq('user_id', userId)
    .eq('career_id', careerId)
    .maybeSingle();

  if (error) {
    console.error('Error checking existing roadmap:', error);
    return false;
  }

  return !!data;
}

/**
 * Build AI prompt for roadmap generation
 */
function buildRoadmapPrompt(
  career: any,
  vectors: UserVectors,
  locale: string
): string {
  const isArabic = locale === 'ar';

  const topInterests = Object.entries(vectors.interests)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5)
    .map(([key, val]) => `${key} (${(val * 100).toFixed(0)}%)`)
    .join(', ');

  const topTraits = Object.entries(vectors.traits)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5)
    .map(([key, val]) => `${key} (${(val * 100).toFixed(0)}%)`)
    .join(', ');

  const topCognition = Object.entries(vectors.cognition)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5)
    .map(([key, val]) => `${key} (${(val * 100).toFixed(0)}%)`)
    .join(', ');

  const languageInstruction = isArabic
    ? 'Respond in Arabic language. Use Arabic text for all fields.'
    : 'Respond in English language.';

  return `You are an expert career counselor creating a personalized roadmap for a high school student (grades 9-12) in the UAE.

**Student Profile:**
- Top Interests: ${topInterests}
- Top Personality Traits: ${topTraits}
- Top Cognitive Strengths: ${topCognition}
- Key Skills: ${vectors.skills.join(', ')}

**Target Career:**
- Title: ${career.title}
- Description: ${career.description}
- Cluster: ${career.cluster || 'General'}

**Context:**
- Location: United Arab Emirates
- Education System: UAE schools, universities, and certifications
- Market: UAE job market and salary expectations

**Your Task:**
Create a highly personalized, actionable roadmap for this student to achieve their career goal. The roadmap must be:
1. **Personalized**: Reference their specific interests, traits, and strengths
2. **UAE-Specific**: Include UAE universities, certifications recognized in UAE, local market context
3. **Teen-Friendly**: Use motivating, relatable language for grades 9-12 students (avoid jargon)
4. **Actionable**: Provide specific, concrete steps with real resources
5. **Realistic**: Include timelines, salary ranges in AED, and honest career progression

**Roadmap Structure:**
The roadmap MUST have exactly 4 phases in this order:

**Phase 1: School (High School - Grades 9-12)**
- **Title**: Focus on relevant subjects and build foundation
- **Duration**: "Grades 9-12 (3-4 years)"
- **Icon**: "🎓"
- **Steps**: 3-4 specific steps like:
  - "Excel in Math and Physics" with details on which topics to master
  - "Join relevant clubs" with specific club suggestions
  - "Build early projects" with project ideas
  - Include resources (websites, books, competitions in UAE)
  - Add motivating tips for each step

**Phase 2: University (Higher Education)**
- **Title**: Get the right degree and build skills
- **Duration**: "4-5 years"
- **Icon**: "🏛️"
- **Steps**: 3-4 specific steps like:
  - "Choose the right degree" - list 2-3 specific programs and UAE universities (UAEU, Khalifa University, AUS, ADU, etc.)
  - "Build practical experience" - internships, projects, competitions
  - "Network with professionals" - conferences, LinkedIn, mentorship
  - Include resources (university websites, scholarship info, student organizations)

**Phase 3: Skills & Certifications (Professional Development)**
- **Title**: Gain market-ready skills
- **Duration**: "1-2 years (can overlap with university)"
- **Icon**: "💪"
- **Steps**: 4-5 specific steps like:
  - "Learn [specific technical skill]" with platform recommendations (Coursera, Udemy, etc.)
  - "Get certified in [specific certification]" - AWS, Google, Microsoft, etc.
  - "Build portfolio projects" with specific project ideas
  - "Master Arabic business communication" (if relevant for UAE market)
  - Include resources (online courses, certification providers, practice platforms)

**Phase 4: Career Entry & Growth**
- **Title**: Launch and grow your career
- **Duration**: "0-10 years"
- **Icon**: "🚀"
- **Steps**: 4-5 specific steps like:
  - "Land your first role as [entry title]" - where to apply, what to expect
  - "Master core skills in first 2 years" - specific skills to develop
  - "Grow to mid-level [title] in 3-5 years" - what advancement looks like
  - "Reach senior level [title] in 5-10 years" - leadership path
  - Include resources (job boards, professional networks, mentors)
  - Include realistic AED salary ranges for each level

**Personalization Requirements:**
- Reference their specific strengths in step descriptions (e.g., "Your strong analytical thinking will help you excel in...")
- Suggest resources that match their interests
- Include optional steps for less confident students
- Use encouraging language that acknowledges their traits

**UAE-Specific Requirements:**
- Universities: UAEU, Khalifa University, AUS, University of Sharjah, ADU, Zayed University, etc.
- Certifications: Prioritize those recognized by UAE employers
- Salary Ranges: Provide realistic AED amounts (Entry: 5,000-8,000, Mid: 10,000-15,000, Senior: 18,000-30,000+ AED)
- Resources: Include UAE-based resources when available (NAFIS, virtual internships, UAE competitions)

**Tone:**
- Speak like a supportive mentor, not a formal advisor
- Use "you" and "your" frequently
- Be encouraging and specific: "Your curiosity in [interest] makes you perfect for..."
- Avoid corporate jargon - use teen-friendly language

**${languageInstruction}**

**Output Format (JSON):**
Return ONLY valid JSON with this exact structure:

{
  "career_title": "string",
  "description": "Brief, personalized description of the career (2-3 sentences, reference their strengths)",
  "estimated_duration": "string (e.g., '8-10 years from high school to senior level')",
  "salary_range": "string (e.g., 'Entry: 6,000 AED, Mid: 12,000 AED, Senior: 25,000+ AED')",
  "icon": "emoji representing the career",
  "phases": [
    {
      "phase_type": "school" | "university" | "skills" | "career",
      "title": "string",
      "subtitle": "string (brief motivating subtitle)",
      "icon": "emoji",
      "duration": "string",
      "steps": [
        {
          "title": "string (action-oriented, specific)",
          "description": "string (1-2 sentences, personalized to student)",
          "details": ["string array (3-5 specific bullet points)"],
          "resources": ["string array (2-4 specific resources with names)"],
          "tip": "string or null (motivating tip referencing their strengths)",
          "is_optional": boolean
        }
      ]
    }
  ]
}`;
}

/**
 * Generate roadmap using OpenAI API
 */
async function generateAIRoadmap(
  prompt: string,
  openaiApiKey: string
): Promise<AIRoadmapResponse> {
  // Get OpenAI configuration from environment variables
  const openaiEndpoint = Deno.env.get('OPENAI_ENDPOINT') || 'https://api.openai.com/v1';

  // Get model from environment, or use fallback list
  const primaryModel = Deno.env.get('OPENAI_MODEL');
  const models = primaryModel
    ? [primaryModel, 'gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-4', 'gpt-3.5-turbo']
    : ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-4', 'gpt-3.5-turbo'];

  let lastError = '';

  for (const model of models) {
    try {
      console.log(`Attempting OpenAI model: ${model}`);

      const openaiUrl = `${openaiEndpoint}/chat/completions`;

      const response = await fetch(openaiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${openaiApiKey}`,
        },
        body: JSON.stringify({
          model: model,
          messages: [
            {
              role: 'system',
              content: 'You are an expert UAE-based career counselor for high school students (grades 9-12). Create personalized, actionable career roadmaps with UAE-specific context. Always respond with valid JSON only.',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
          temperature: 0.8,
          max_tokens: 4000,
          response_format: { type: 'json_object' },
        }),
      });

      if (!response.ok) {
        const errorData = await response.text();
        lastError = errorData;

        try {
          const errorJson = JSON.parse(errorData);
          const errorCode = errorJson.error?.code;

          if (errorCode === 'insufficient_quota' || errorCode === 'model_not_found' || errorCode === 'invalid_model') {
            console.log(`Model ${model} unavailable, trying next...`);
            continue;
          }
        } catch (parseError) {
          console.log(`Could not parse error for ${model}`);
        }

        continue;
      }

      const data = await response.json();
      const content = data.choices[0].message.content;

      console.log(`Successfully generated roadmap using: ${model}`);
      const roadmap = JSON.parse(content);

      // Validate response structure
      if (!roadmap.career_title || !roadmap.phases || roadmap.phases.length !== 4) {
        throw new Error('Invalid roadmap structure from AI');
      }

      return roadmap;
    } catch (error) {
      console.log(`Error with model ${model}: ${error.message}`);
      lastError = error.message;
      continue;
    }
  }

  throw new Error(`All AI models failed. Last error: ${lastError}`);
}

/**
 * Persist roadmap to database
 */
async function persistRoadmap(
  supabase: any,
  userId: string,
  careerId: string,
  roadmap: AIRoadmapResponse
): Promise<string> {
  // Insert main roadmap
  const { data: roadmapData, error: roadmapError } = await supabase
    .from('user_career_roadmaps')
    .insert({
      user_id: userId,
      career_id: careerId,
      career_title: roadmap.career_title,
      description: roadmap.description,
      estimated_duration: roadmap.estimated_duration,
      salary_range: roadmap.salary_range,
      icon: roadmap.icon,
    })
    .select('id')
    .single();

  if (roadmapError) {
    throw new Error(`Failed to insert roadmap: ${roadmapError.message}`);
  }

  const roadmapId = roadmapData.id;

  // Insert phases
  for (let phaseIndex = 0; phaseIndex < roadmap.phases.length; phaseIndex++) {
    const phase = roadmap.phases[phaseIndex];

    const { data: phaseData, error: phaseError } = await supabase
      .from('user_roadmap_phases')
      .insert({
        roadmap_id: roadmapId,
        phase_order: phaseIndex,
        phase_type: phase.phase_type,
        title: phase.title,
        subtitle: phase.subtitle,
        icon: phase.icon,
        duration: phase.duration,
      })
      .select('id')
      .single();

    if (phaseError) {
      throw new Error(`Failed to insert phase ${phaseIndex}: ${phaseError.message}`);
    }

    const phaseId = phaseData.id;

    // Insert steps for this phase
    for (let stepIndex = 0; stepIndex < phase.steps.length; stepIndex++) {
      const step = phase.steps[stepIndex];

      const { error: stepError } = await supabase
        .from('user_roadmap_steps')
        .insert({
          phase_id: phaseId,
          step_order: stepIndex,
          title: step.title,
          description: step.description,
          details: step.details,
          resources: step.resources,
          tip: step.tip,
          is_optional: step.is_optional || false,
        });

      if (stepError) {
        throw new Error(`Failed to insert step ${stepIndex}: ${stepError.message}`);
      }
    }
  }

  console.log(`Roadmap persisted successfully: ${roadmapId}`);
  return roadmapId;
}

/**
 * Main handler
 */
serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Get environment variables
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')!;

    if (!supabaseUrl || !supabaseKey || !openaiApiKey) {
      throw new Error('Missing environment variables. Please set OPENAI_API_KEY');
    }

    const supabase = createClient(supabaseUrl, supabaseKey);

    // Authenticate user
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ success: false, error: 'missing_auth' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: 'invalid_token' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 }
      );
    }

    const userId = user.id;

    // Parse request body
    const body: RoadmapRequest = await req.json();
    const { career_id, locale = 'en' } = body;

    if (!career_id) {
      return new Response(
        JSON.stringify({ success: false, error: 'missing_career_id' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // Check if roadmap already exists
    const exists = await hasExistingRoadmap(supabase, userId, career_id);
    if (exists) {
      return new Response(
        JSON.stringify({ success: false, error: 'roadmap_already_exists' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 409 }
      );
    }

    // Check roadmap limit
    const limitCheck = await checkRoadmapLimit(supabase, userId);
    if (!limitCheck.allowed) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'roadmap_limit_reached',
          current_count: limitCheck.current_count,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 403 }
      );
    }

    // Fetch career details
    console.log('Fetching career details...');
    const career = await fetchCareerDetails(supabase, career_id);

    // Fetch user vectors
    console.log('Fetching user vectors...');
    const vectors = await fetchUserVectors(supabase, userId);

    // Build AI prompt
    console.log('Building AI prompt...');
    const prompt = buildRoadmapPrompt(career, vectors, locale);

    // Generate roadmap
    console.log('Generating AI roadmap...');
    const roadmap = await generateAIRoadmap(prompt, openaiApiKey);

    // Persist to database
    console.log('Persisting roadmap to database...');
    const roadmapId = await persistRoadmap(supabase, userId, career_id, roadmap);

    return new Response(
      JSON.stringify({
        success: true,
        roadmap_id: roadmapId,
        career_title: roadmap.career_title,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
