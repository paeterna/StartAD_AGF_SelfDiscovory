# OpenAI API Setup for Edge Functions

## Required Environment Variables

The Edge Functions need the following OpenAI API configuration:

### 1. OPENAI_API_KEY
Your OpenAI API key (starts with `sk-`)

### 2. OPENAI_MODEL (Optional)
The model to use (e.g., `gpt-4o`, `gpt-3.5-turbo`, etc.)

### 3. OPENAI_ENDPOINT (Optional)
Custom OpenAI endpoint (defaults to `https://api.openai.com/v1`)

## How to Set Secrets

Run these commands in your terminal:

```bash
# Set your OpenAI API key (REQUIRED)
supabase secrets set OPENAI_API_KEY=sk-your_api_key_here

# Optionally set your preferred model
supabase secrets set OPENAI_MODEL=gpt-4o

# Only if using a custom endpoint (e.g., OpenAI-compatible proxy)
supabase secrets set OPENAI_ENDPOINT=https://custom-endpoint.com/v1
```

## How to Get Your OpenAI API Key

### Step 1: Sign up/Login to OpenAI
1. Go to [https://platform.openai.com](https://platform.openai.com)
2. Sign up or log in to your account

### Step 2: Create API Key
1. Click on your profile icon in the top-right
2. Select "API keys" or go to [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
3. Click "Create new secret key"
4. Give it a name (e.g., "StartAD Career Roadmaps")
5. Copy the key (starts with `sk-`) - **you won't be able to see it again!**

### Step 3: Add Billing (If Required)
1. Go to [https://platform.openai.com/account/billing](https://platform.openai.com/account/billing)
2. Add a payment method if you haven't already
3. Set usage limits if desired

## Models Tried (Fallback Order)

If you don't set `OPENAI_MODEL`, the function will try these models in order:

1. `gpt-4o` (recommended - best quality)
2. `gpt-4o-mini` (fast and cost-effective)
3. `gpt-4-turbo`
4. `gpt-4`
5. `gpt-3.5-turbo` (cheapest option)

**Recommendation**: Use `gpt-4o` for best results, or `gpt-4o-mini` for cost savings.

## Verify Configuration

After setting secrets, verify them:

```bash
# List all secrets (values are hidden for security)
supabase secrets list
```

You should see:
```
OPENAI_API_KEY | ****
OPENAI_MODEL | **** (if set)
```

## Deploy the Edge Function

After setting secrets, deploy the Edge Function:

```bash
# Deploy using the script
./deploy-edge-function.sh

# Or manually
supabase functions deploy ai-generate-career-roadmap
```

## Affected Edge Functions

This Edge Function uses OpenAI API and needs the above configuration:

1. `ai-generate-career-roadmap` - Generates personalized career roadmaps

## Troubleshooting

### Error: "Missing environment variables. Please set OPENAI_API_KEY"
- You haven't set the API key secret
- Run: `supabase secrets set OPENAI_API_KEY=sk-your-key-here`
- Then redeploy: `supabase functions deploy ai-generate-career-roadmap`

### Error: "Unauthorized" or "401"
- Your `OPENAI_API_KEY` is incorrect or expired
- Verify your key at [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
- Create a new key if needed

### Error: "insufficient_quota"
- You've exceeded your OpenAI usage quota
- Check your usage at [https://platform.openai.com/account/usage](https://platform.openai.com/account/usage)
- Add billing or upgrade your plan

### Error: "model_not_found" or "invalid_model"
- The specified model doesn't exist or you don't have access
- Check available models at [https://platform.openai.com/docs/models](https://platform.openai.com/docs/models)
- Try a different model from the fallback list

### Error: "rate_limit_exceeded"
- You're making too many requests
- Wait a moment and try again
- Consider upgrading your OpenAI plan for higher rate limits

## Pricing (As of 2025)

Approximate costs per roadmap generation (varies by model):

| Model | Input Cost | Output Cost | Est. Cost/Roadmap |
|-------|-----------|-------------|-------------------|
| gpt-4o | $2.50/1M tokens | $10.00/1M tokens | ~$0.05-0.10 |
| gpt-4o-mini | $0.15/1M tokens | $0.60/1M tokens | ~$0.01-0.02 |
| gpt-3.5-turbo | $0.50/1M tokens | $1.50/1M tokens | ~$0.02-0.04 |

**Note**: Prices may change. Check [https://openai.com/pricing](https://openai.com/pricing) for current rates.

## Example Complete Setup

```bash
# 1. Get your API key from https://platform.openai.com/api-keys

# 2. Set the API key
supabase secrets set OPENAI_API_KEY=sk-proj-abc123def456...

# 3. Optionally set preferred model
supabase secrets set OPENAI_MODEL=gpt-4o-mini

# 4. Deploy function
supabase functions deploy ai-generate-career-roadmap

# 5. Test (from your app)
# Click "Generate AI Roadmap" button on any career
```

## Monitoring Usage

Monitor your OpenAI usage:
1. Go to [https://platform.openai.com/usage](https://platform.openai.com/usage)
2. View costs by day/month
3. Set up usage alerts if needed
