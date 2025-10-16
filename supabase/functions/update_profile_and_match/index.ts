// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';

/**
 * Type definitions
 */
interface BatchFeature {
  key: string;
  mean: number;  // 0..100 scale
  n: number;
  quality: number;  // 0..1 confidence/quality score
}

interface RequestBody {
  user_id: string;
  batch_features: BatchFeature[];
}

interface Career {
  id: string;
  title: string;
  vector: number[];
  description?: string;
  tags?: string[];
}

interface Feature {
  id: number;
  key: string;
  family: string;
}

interface UserFeatureScore {
  feature_key: string;
  score_mean: number;
  n: number;
}

interface TopFeatureContribution {
  feature_key: string;
  contribution: number;
}

interface CareerMatch {
  career_id: string;
  similarity: number;
  confidence: number;
  top_features: TopFeatureContribution[];
}

/**
 * CORS headers
 */
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

/**
 * Compute cosine similarity between two vectors
 */
function cosineSimilarity(vecA: number[], vecB: number[]): number {
  if (vecA.length !== vecB.length) {
    throw new Error(`Vector dimension mismatch: ${vecA.length} vs ${vecB.length}`);
  }

  let dotProduct = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < vecA.length; i++) {
    dotProduct += vecA[i] * vecB[i];
    normA += vecA[i] * vecA[i];
    normB += vecB[i] * vecB[i];
  }

  normA = Math.sqrt(normA);
  normB = Math.sqrt(normB);

  if (normA === 0 || normB === 0) {
    return 0;
  }

  return dotProduct / (normA * normB);
}

/**
 * Clamp value between min and max
 */
function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

/**
 * Compute top N contributing features
 */
function getTopContributingFeatures(
  userVector: number[],
  careerVector: number[],
  features: Feature[],
  topN = 3,
): TopFeatureContribution[] {
  const contributions: TopFeatureContribution[] = [];

  for (let i = 0; i < userVector.length && i < features.length; i++) {
    const contribution = userVector[i] * careerVector[i];
    contributions.push({
      feature_key: features[i].key,
      contribution,
    });
  }

  // Sort by contribution descending
  contributions.sort((a, b) => b.contribution - a.contribution);

  return contributions.slice(0, topN);
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
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Parse request body
    const body: RequestBody = await req.json();
    const { user_id, batch_features } = body;

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: 'user_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    if (!batch_features || !Array.isArray(batch_features) || batch_features.length === 0) {
      return new Response(
        JSON.stringify({ error: 'batch_features must be a non-empty array' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Step 1: Update user feature scores via EMA
    console.log(`Processing ${batch_features.length} features for user ${user_id}`);

    for (const feature of batch_features) {
      const { key, mean, n, quality } = feature;

      // Validate inputs
      if (!key || typeof mean !== 'number' || typeof n !== 'number' || typeof quality !== 'number') {
        console.warn(`Skipping invalid feature:`, feature);
        continue;
      }

      // Use quality as weight (clamped between 0.15 and 0.7 in the function)
      const weight = clamp(quality, 0.15, 0.7);

      // Call the upsert_feature_ema function
      const { error: emaError } = await supabase.rpc('upsert_feature_ema', {
        p_user_id: user_id,
        p_key: key,
        p_value: mean,
        p_weight: weight,
        p_n: n,
      });

      if (emaError) {
        console.error(`Error updating feature ${key}:`, emaError);
        throw emaError;
      }
    }

    // Step 2: Fetch all features in order
    const { data: features, error: featuresError } = await supabase
      .from('features')
      .select('id, key, family')
      .order('id', { ascending: true });

    if (featuresError) {
      throw featuresError;
    }

    if (!features || features.length === 0) {
      throw new Error('No features found in database');
    }

    const featureCount = features.length;
    console.log(`Loaded ${featureCount} features`);

    // Step 3: Build user feature vector
    const { data: userScores, error: scoresError } = await supabase
      .from('user_feature_scores')
      .select('feature_key, score_mean, n')
      .eq('user_id', user_id);

    if (scoresError) {
      throw scoresError;
    }

    // Create a map for quick lookup
    const scoresMap = new Map<string, UserFeatureScore>();
    if (userScores) {
      for (const score of userScores) {
        scoresMap.set(score.feature_key, score);
      }
    }

    // Build ordered user vector (0..1 scale)
    const userVector: number[] = [];
    let totalObservations = 0;
    let validFeatures = 0;

    for (const feature of features) {
      const score = scoresMap.get(feature.key);
      if (score) {
        // Scale from [0..100] to [0..1]
        userVector.push(score.score_mean / 100.0);
        totalObservations += score.n;
        if (score.n > 0) validFeatures++;
      } else {
        // Default to 0.5 (neutral) for missing features
        userVector.push(0.5);
      }
    }

    console.log(`User vector built: ${validFeatures}/${featureCount} features with data, ${totalObservations} total observations`);

    // Compute overall confidence (min(1, n_avg / 12))
    const avgObservations = validFeatures > 0 ? totalObservations / validFeatures : 0;
    const overallConfidence = Math.min(1.0, avgObservations / 12.0);

    console.log(`Overall confidence: ${overallConfidence.toFixed(3)}`);

    // Step 4: Fetch all careers
    const { data: careers, error: careersError } = await supabase
      .from('careers')
      .select('id, title, vector, description, tags')
      .eq('active', true);

    if (careersError) {
      throw careersError;
    }

    if (!careers || careers.length === 0) {
      console.warn('No active careers found');
      return new Response(
        JSON.stringify({ ok: true, matches_computed: 0, top: [] }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    console.log(`Loaded ${careers.length} active careers`);

    // Step 5: Compute similarity for each career
    const matches: CareerMatch[] = [];

    for (const career of careers) {
      if (!career.vector || career.vector.length !== featureCount) {
        console.warn(`Career ${career.title} has invalid vector (expected ${featureCount}, got ${career.vector?.length || 0})`);
        continue;
      }

      // Compute cosine similarity
      const cosSim = cosineSimilarity(userVector, career.vector);

      // Apply confidence weighting
      const finalSimilarity = cosSim * overallConfidence;

      // Get top contributing features
      const topFeatures = getTopContributingFeatures(userVector, career.vector, features);

      matches.push({
        career_id: career.id,
        similarity: finalSimilarity,
        confidence: overallConfidence,
        top_features: topFeatures,
      });
    }

    // Sort by similarity descending
    matches.sort((a, b) => b.similarity - a.similarity);

    // Keep top 50
    const topMatches = matches.slice(0, 50);

    console.log(`Computed ${matches.length} matches, keeping top ${topMatches.length}`);

    // Step 6: Upsert matches to database
    const matchRecords = topMatches.map((m) => ({
      user_id,
      career_id: m.career_id,
      similarity: m.similarity,
      confidence: m.confidence,
      top_features: m.top_features,
      last_updated: new Date().toISOString(),
    }));

    // Delete old matches first
    const { error: deleteError } = await supabase
      .from('user_career_matches')
      .delete()
      .eq('user_id', user_id);

    if (deleteError) {
      console.error('Error deleting old matches:', deleteError);
      throw deleteError;
    }

    // Insert new matches
    const { error: insertError } = await supabase
      .from('user_career_matches')
      .insert(matchRecords);

    if (insertError) {
      console.error('Error inserting matches:', insertError);
      throw insertError;
    }

    console.log(`Successfully upserted ${topMatches.length} career matches`);

    // Return top matches
    const responseData = {
      ok: true,
      matches_computed: matches.length,
      matches_stored: topMatches.length,
      confidence: overallConfidence,
      top: topMatches.slice(0, 10).map((m) => ({
        career_id: m.career_id,
        similarity: m.similarity,
        top_features: m.top_features,
      })),
    };

    return new Response(
      JSON.stringify(responseData),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error: any) {
    console.error('Error in update_profile_and_match:', error);

    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
