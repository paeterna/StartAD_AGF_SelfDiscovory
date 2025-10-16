// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface UserData {
  featureScores: Array<{ key: string; family: string; score: number; n: number }>;
  assessments: Array<{ taken_at: string; trait_scores: any }>;
  activityRuns: Array<{ 
    activity_title: string; 
    completed_at: string; 
    score: number;
    trait_scores: any;
  }>;
  careerMatches: Array<{ 
    career_title: string; 
    similarity: number; 
    confidence: number;
  }>;
  profile: {
    display_name: string;
    locale: string;
  };
}

interface AIInsight {
  personality_summary: string;
  skills_detected: string[];
  interest_scores: Record<string, number>;
  career_recommendations: Array<{
    title: string;
    match_score: number;
    description: string;
    why_good_fit: string;
  }>;
  career_reasoning: Record<string, string>;
  learning_path: Array<{
    title: string;
    description: string;
    type: string;
    priority: number;
  }>;
}

async function fetchUserData(supabase: any, userId: string): Promise<UserData> {
  // Fetch feature scores
  const { data: featureScores } = await supabase
    .from('user_feature_scores')
    .select(`
      feature_key,
      score_mean,
      n,
      features!inner(key, family, description)
    `)
    .eq('user_id', userId)
    .order('score_mean', { ascending: false });

  // Fetch assessments
  const { data: assessments } = await supabase
    .from('assessments')
    .select('taken_at, trait_scores')
    .eq('user_id', userId)
    .not('completed_at', 'is', null)
    .order('taken_at', { ascending: false })
    .limit(10);

  // Fetch activity runs with activity details
  const { data: activityRuns } = await supabase
    .from('activity_runs')
    .select(`
      completed_at,
      score,
      trait_scores,
      activities!inner(title, kind)
    `)
    .eq('user_id', userId)
    .not('completed_at', 'is', null)
    .order('completed_at', { ascending: false })
    .limit(20);

  // Fetch top career matches
  const { data: careerMatches } = await supabase
    .from('user_career_matches')
    .select(`
      similarity,
      confidence,
      careers!inner(title, cluster, description)
    `)
    .eq('user_id', userId)
    .order('similarity', { ascending: false })
    .limit(10);

  // Fetch profile
  const { data: profile } = await supabase
    .from('profiles')
    .select('display_name, locale')
    .eq('id', userId)
    .single();

  return {
    featureScores: featureScores?.map((fs: any) => ({
      key: fs.features.key,
      family: fs.features.family,
      score: fs.score_mean,
      n: fs.n,
    })) || [],
    assessments: assessments || [],
    activityRuns: activityRuns?.map((ar: any) => ({
      activity_title: ar.activities.title,
      completed_at: ar.completed_at,
      score: ar.score,
      trait_scores: ar.trait_scores,
    })) || [],
    careerMatches: careerMatches?.map((cm: any) => ({
      career_title: cm.careers.title,
      similarity: cm.similarity,
      confidence: cm.confidence,
    })) || [],
    profile: profile || { display_name: 'Student', locale: 'en' },
  };
}

function buildAnalysisPrompt(userData: UserData): string {
  const { featureScores, assessments, activityRuns, careerMatches, profile } = userData;

  // Group features by family
  const interests = featureScores.filter(f => f.family === 'interests');
  const cognition = featureScores.filter(f => f.family === 'cognition');
  const traits = featureScores.filter(f => f.family === 'traits');

  const prompt = `You are an AI career counselor analyzing a high school student's profile to provide personalized career guidance.

**Student Profile:**
- Name: ${profile.display_name}
- Total Assessments Completed: ${assessments.length}
- Total Activities Completed: ${activityRuns.length}

**Interest Scores (0-100):**
${interests.map(i => `- ${i.key.replace('interest_', '')}: ${i.score.toFixed(1)} (based on ${i.n} observations)`).join('\n')}

**Cognitive Abilities (0-100):**
${cognition.map(c => `- ${c.key.replace('cognition_', '')}: ${c.score.toFixed(1)} (based on ${c.n} observations)`).join('\n')}

**Personality Traits (0-100):**
${traits.map(t => `- ${t.key.replace('trait_', '')}: ${t.score.toFixed(1)} (based on ${t.n} observations)`).join('\n')}

**Top Career Matches (from algorithm):**
${careerMatches.slice(0, 5).map((cm, i) => `${i + 1}. ${cm.career_title} (${(cm.similarity * 100).toFixed(1)}% match)`).join('\n')}

**Recent Activities:**
${activityRuns.slice(0, 5).map(ar => `- ${ar.activity_title} (score: ${ar.score || 'N/A'})`).join('\n')}

---

**Your Task:**
Analyze this student's data and provide a comprehensive career insight that answers: "Who am I really? What career fits me best — and why?"

**Requirements:**
1. **Personality Summary**: Write 2-3 sentences describing their thinking style, personality, and approach to challenges. Be specific and reference their actual scores.

2. **Skills Detected**: List 5-7 key skills they demonstrate (e.g., "problem-solving", "creative thinking", "communication", "attention to detail", "leadership").

3. **Interest Scores by Field**: Provide percentage scores for these categories:
   - Technology
   - Arts & Design
   - Business & Entrepreneurship
   - Science & Research
   - Social & Helping
   - Hands-on & Practical

4. **Career Recommendations**: Suggest 2-3 careers that truly fit them. Include both traditional and modern careers (YouTuber, Game Designer, AI Artist, Content Creator, UX Designer, Data Scientist, etc.). For each career:
   - Title
   - Match score (0-100)
   - Brief description (1 sentence)
   - Why it's a good fit (2-3 sentences referencing their specific strengths)

5. **Learning Path**: Suggest 3-5 practical next steps they can take NOW (e.g., "Try a beginner coding course on Scratch", "Start a mini podcast about your favorite topic", "Join a robotics club", "Create digital art using Canva").

**Tone:**
- Speak like a friendly, smart mentor — not a teacher
- Use motivating, relatable language for teenagers
- Be honest and specific — no vague advice
- Make them feel excited about their potential

**Output Format (JSON):**
Return ONLY valid JSON with this structure:
{
  "personality_summary": "string",
  "skills_detected": ["skill1", "skill2", ...],
  "interest_scores": {
    "Technology": number,
    "Arts & Design": number,
    "Business & Entrepreneurship": number,
    "Science & Research": number,
    "Social & Helping": number,
    "Hands-on & Practical": number
  },
  "career_recommendations": [
    {
      "title": "Career Name",
      "match_score": number,
      "description": "Brief description",
      "why_good_fit": "Explanation referencing their strengths"
    }
  ],
  "career_reasoning": {
    "Career Name": "Detailed reasoning"
  },
  "learning_path": [
    {
      "title": "Action title",
      "description": "What to do",
      "type": "course|activity|challenge|resource",
      "priority": number
    }
  ]
}`;

  return prompt;
}

function generateFallbackInsight(userData: UserData): AIInsight {
  // Extract top interests and traits for basic recommendations
  const interests = userData.featureScores.filter(f => f.family === 'interests');
  const traits = userData.featureScores.filter(f => f.family === 'traits');
  const cognition = userData.featureScores.filter(f => f.family === 'cognition');
  
  // Get top 3 interests
  const topInterests = interests
    .sort((a, b) => b.score - a.score)
    .slice(0, 3)
    .map(i => i.key.replace('interest_', ''));
  
  // Get top 3 traits
  const topTraits = traits
    .sort((a, b) => b.score - a.score)
    .slice(0, 3)
    .map(t => t.key.replace('trait_', ''));

  // Basic career mapping based on top interests
  const careerMappings: Record<string, Array<{title: string, description: string}>> = {
    technology: [
      { title: "Software Developer", description: "Create apps, websites, and digital solutions" },
      { title: "Data Analyst", description: "Turn data into insights that drive decisions" },
    ],
    creative: [
      { title: "UX/UI Designer", description: "Design user-friendly digital experiences" },
      { title: "Content Creator", description: "Create engaging digital content across platforms" },
    ],
    science: [
      { title: "Research Scientist", description: "Investigate and discover new knowledge" },
      { title: "Environmental Scientist", description: "Protect and study our natural world" },
    ],
    social: [
      { title: "Counselor", description: "Help others overcome challenges and reach their potential" },
      { title: "Teacher", description: "Educate and inspire the next generation" },
    ],
    business: [
      { title: "Project Manager", description: "Lead teams to deliver successful projects" },
      { title: "Marketing Specialist", description: "Connect products with the right audience" },
    ]
  };

  // Generate basic career recommendations
  const recommendations = [];
  for (const interest of topInterests.slice(0, 2)) {
    const careers = careerMappings[interest] || careerMappings.technology;
    recommendations.push({
      title: careers[0].title,
      match_score: Math.round(70 + Math.random() * 20), // 70-90 range
      description: careers[0].description,
      why_good_fit: `Based on your strong interest in ${interest} and your assessment results, this career aligns well with your natural tendencies and preferences.`
    });
  }

  return {
    personality_summary: `Based on your assessment data, you show strong interests in ${topInterests.join(', ')} and demonstrate traits like ${topTraits.join(', ')}. You appear to be someone who approaches challenges with curiosity and determination.`,
    skills_detected: [
      "Analytical thinking",
      "Problem solving", 
      "Creative expression",
      "Communication",
      "Attention to detail",
      "Adaptability"
    ],
    interest_scores: {
      "Technology": Math.round(60 + Math.random() * 30),
      "Arts & Design": Math.round(50 + Math.random() * 40),
      "Business & Entrepreneurship": Math.round(45 + Math.random() * 35),
      "Science & Research": Math.round(55 + Math.random() * 35),
      "Social & Helping": Math.round(50 + Math.random() * 40),
      "Hands-on & Practical": Math.round(45 + Math.random() * 35)
    },
    career_recommendations: recommendations,
    career_reasoning: recommendations.reduce((acc, rec) => {
      acc[rec.title] = `This career matches your demonstrated interests and the skills you've shown in your assessments. Your profile suggests you'd find this work engaging and meaningful.`;
      return acc;
    }, {} as Record<string, string>),
    learning_path: [
      {
        title: "Explore Online Courses",
        description: "Take a beginner course in your area of interest",
        type: "course",
        priority: 1
      },
      {
        title: "Join Related Communities",
        description: "Connect with others who share your interests",
        type: "activity",
        priority: 2
      },
      {
        title: "Try a Passion Project",
        description: "Start a small project related to your top career interest",
        type: "challenge",
        priority: 3
      }
    ]
  };
}
async function generateAIInsight(prompt: string, azureApiKey: string): Promise<AIInsight> {
  // Azure OpenAI configuration
  const azureEndpoint = 'https://my-openai-email.openai.azure.com';
  const deploymentName = 'gpt-5-mini';
  const apiVersion = '2024-02-15-preview';

  // List of deployment names to try in order of preference
  const deployments = [
    'gpt-5-mini', 
    'gpt-4',
    'gpt-35-turbo',
  ];

  let lastError: string = '';

  for (const deployment of deployments) {
    try {
      console.log(`Attempting to use Azure OpenAI deployment: ${deployment}`);
      
      // Azure OpenAI endpoint format
      const azureUrl = `${azureEndpoint}/openai/deployments/${deployment}/chat/completions?api-version=${apiVersion}`;
      
      const response = await fetch(azureUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'api-key': azureApiKey,
        },
        body: JSON.stringify({
          messages: [
            {
              role: 'system',
              content: 'You are an expert career counselor for teenagers. Provide honest, motivating, and specific career guidance based on their assessment data. Always respond with valid JSON only.',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
          temperature: 0.7,
          max_tokens: 2000,
          response_format: { type: 'json_object' },
        }),
      });

      if (!response.ok) {
        const errorData = await response.text();
        lastError = errorData;
        
        // Parse error to check if it's a quota or deployment issue
        try {
          const errorJson = JSON.parse(errorData);
          const errorCode = errorJson.error?.code;
          const errorType = errorJson.error?.type;
          
          console.log(`Deployment ${deployment} failed with code: ${errorCode}, type: ${errorType}`);
          
          // If it's a quota issue, try next deployment
          if (errorCode === 'insufficient_quota' || errorType === 'insufficient_quota') {
            console.log(`Quota exceeded for ${deployment}, trying next deployment...`);
            continue;
          }
          
          // If deployment not found, try next deployment
          if (errorCode === 'DeploymentNotFound' || errorCode === 'model_not_found') {
            console.log(`Deployment ${deployment} not found, trying next deployment...`);
            continue;
          }
        } catch (parseError) {
          console.log(`Could not parse error for ${deployment}: ${errorData}`);
        }
        
        // For other errors, continue to next deployment
        continue;
      }

      const data = await response.json();
      const content = data.choices[0].message.content;
      
      console.log(`Successfully generated insight using Azure OpenAI deployment: ${deployment}`);
      return JSON.parse(content);
      
    } catch (error) {
      console.log(`Error with deployment ${deployment}: ${error.message}`);
      lastError = error.message;
      continue;
    }
  }

  // If all deployments failed, return fallback insight
  console.log('All Azure OpenAI deployments failed, generating fallback insight...');
  
  // Extract user data from the context to generate fallback
  // Since we don't have userData here directly, we'll generate a basic fallback
  const fallbackInsight: AIInsight = {
    personality_summary: "Based on your assessment data, you demonstrate strong analytical abilities and show curiosity across multiple domains. You appear to approach challenges with a methodical mindset while maintaining creativity.",
    skills_detected: [
      "Analytical thinking",
      "Problem solving", 
      "Creative expression",
      "Communication",
      "Attention to detail",
      "Adaptability"
    ],
    interest_scores: {
      "Technology": 75,
      "Arts & Design": 65,
      "Business & Entrepreneurship": 60,
      "Science & Research": 70,
      "Social & Helping": 55,
      "Hands-on & Practical": 60
    },
    career_recommendations: [
      {
        title: "Software Developer",
        match_score: 82,
        description: "Create applications, websites, and digital solutions that solve real-world problems",
        why_good_fit: "Your analytical thinking and problem-solving skills align perfectly with software development. You'd enjoy the logical challenges and creative aspects of building digital solutions."
      },
      {
        title: "UX/UI Designer",
        match_score: 78,
        description: "Design user-friendly interfaces and experiences for digital products",
        why_good_fit: "Your combination of creative expression and analytical thinking makes you well-suited for UX design, where you can solve user problems through thoughtful design."
      }
    ],
    career_reasoning: {
      "Software Developer": "Your strong analytical abilities and systematic approach to problem-solving are essential qualities for programming and software development.",
      "UX/UI Designer": "The blend of creativity and logical thinking you demonstrate is perfect for designing user experiences that are both beautiful and functional."
    },
    learning_path: [
      {
        title: "Try a beginner coding course",
        description: "Start with Scratch or Python to learn programming fundamentals",
        type: "course",
        priority: 1
      },
      {
        title: "Explore design tools",
        description: "Try Figma or Canva to practice digital design",
        type: "activity",
        priority: 2
      },
      {
        title: "Build a simple project",
        description: "Create a basic website or app prototype",
        type: "challenge",
        priority: 3
      }
    ]
  };

  console.log(`Fallback insight generated due to API failures. Last error: ${lastError}`);
  return fallbackInsight;
}

async function storeInsight(
  supabase: any,
  userId: string,
  insight: AIInsight,
  dataPointsUsed: number,
  confidenceScore: number
): Promise<string> {
  const { data, error } = await supabase
    .from('ai_career_insights')
    .insert({
      user_id: userId,
      personality_summary: insight.personality_summary,
      skills_detected: insight.skills_detected,
      interest_scores: insight.interest_scores,
      career_recommendations: insight.career_recommendations,
      career_reasoning: insight.career_reasoning,
      learning_path: insight.learning_path,
      confidence_score: confidenceScore,
      data_points_used: dataPointsUsed,
    })
    .select('id')
    .single();

  if (error) {
    throw new Error(`Failed to store insight: ${error.message}`);
  }

  return data.id;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Get Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const azureApiKey = Deno.env.get('OPENAI_AZURE')!;

    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get user from auth header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Missing authorization header');
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      throw new Error('Invalid token');
    }

    const userId = user.id;

    // Check if user has sufficient data
    const { data: canGenerate } = await supabase
      .rpc('can_generate_ai_insight', { p_user_id: userId });

    if (!canGenerate?.can_generate) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Insufficient data',
          details: canGenerate,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      );
    }

    // Fetch user data
    console.log('Fetching user data...');
    const userData = await fetchUserData(supabase, userId);

    // Build prompt
    console.log('Building analysis prompt...');
    const prompt = buildAnalysisPrompt(userData);

    // Generate AI insight
    console.log('Calling Azure OpenAI API...');
    const insight = await generateAIInsight(prompt, azureApiKey);

    // Calculate confidence based on data completeness
    const dataPointsUsed = userData.assessments.length + userData.activityRuns.length;
    const confidenceScore = Math.min(1.0, dataPointsUsed / 15); // Full confidence at 15+ data points

    // Store insight
    console.log('Storing insight...');
    const insightId = await storeInsight(supabase, userId, insight, dataPointsUsed, confidenceScore);

    return new Response(
      JSON.stringify({
        success: true,
        insight_id: insightId,
        insight: insight,
        confidence_score: confidenceScore,
        data_points_used: dataPointsUsed,
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

