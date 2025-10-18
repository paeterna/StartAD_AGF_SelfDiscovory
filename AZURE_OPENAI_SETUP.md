# Azure OpenAI Setup for Edge Functions

## Required Environment Variables

The Edge Functions need the following Azure OpenAI configuration:

### 1. AZURE_OPENAI_API_KEY
Your Azure OpenAI API key

### 2. AZURE_OPENAI_ENDPOINT
Your Azure OpenAI resource endpoint (e.g., `https://your-resource.openai.azure.com`)

### 3. AZURE_OPENAI_DEPLOYMENT (Optional but Recommended)
The name of your deployed model (e.g., `gpt-4o`, `gpt-35-turbo`, etc.)

## How to Set Secrets

Run these commands in your terminal:

```bash
# Set your Azure OpenAI API key
supabase secrets set AZURE_OPENAI_API_KEY=your_api_key_here

# Set your Azure OpenAI endpoint
supabase secrets set AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com

# Set your deployment name (use the actual name from Azure Portal)
supabase secrets set AZURE_OPENAI_DEPLOYMENT=gpt-4o
```

## How to Find These Values

### Finding Your Azure OpenAI Endpoint:
1. Go to [Azure Portal](https://portal.azure.com/)
2. Navigate to your Azure OpenAI resource
3. Click on "Keys and Endpoint" in the left sidebar
4. Copy the **Endpoint** value (e.g., `https://my-resource.openai.azure.com`)

### Finding Your API Key:
1. In the same "Keys and Endpoint" page
2. Copy **KEY 1** or **KEY 2**

### Finding Your Deployment Name:
1. In your Azure OpenAI resource
2. Go to "Model deployments" or click "Go to Azure OpenAI Studio"
3. In Azure OpenAI Studio, go to "Deployments"
4. Copy the **Deployment name** (NOT the model name)
   - Example: If you deployed `gpt-4o` and named the deployment `gpt-4o-prod`, use `gpt-4o-prod`

## Deployment Names Tried (Fallback Order)

If you don't set `AZURE_OPENAI_DEPLOYMENT`, the function will try these names in order:

1. `gpt-4o`
2. `gpt-4o-mini`
3. `gpt-4-turbo`
4. `gpt-4`
5. `gpt-35-turbo`

**Note**: It's better to set the exact deployment name to avoid errors.

## Verify Configuration

After setting secrets, verify them:

```bash
# List all secrets (values are hidden for security)
supabase secrets list
```

You should see:
```
AZURE_OPENAI_API_KEY | ****
AZURE_OPENAI_ENDPOINT | ****
AZURE_OPENAI_DEPLOYMENT | ****
```

## Redeploy After Setting Secrets

After setting/updating secrets, redeploy the Edge Function:

```bash
supabase functions deploy ai-generate-career-roadmap
```

## Affected Edge Functions

These Edge Functions use Azure OpenAI and need the above configuration:

1. `ai-generate-career-roadmap` - Generates personalized career roadmaps
2. `generate_ai_career_insight` - Generates AI career insights

## Troubleshooting

### Error: "DeploymentNotFound"
- Your `AZURE_OPENAI_DEPLOYMENT` name doesn't match what's in Azure
- Check the exact deployment name in Azure OpenAI Studio
- Make sure you're using the deployment name, not the model name

### Error: "Unauthorized" or "401"
- Your `AZURE_OPENAI_API_KEY` is incorrect
- Check if the key has expired
- Try using KEY 2 if KEY 1 doesn't work

### Error: "AZURE_OPENAI_ENDPOINT environment variable is not set"
- You haven't set the endpoint secret
- Run: `supabase secrets set AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com`

## Example Complete Setup

```bash
# Example values (replace with your actual values)
supabase secrets set AZURE_OPENAI_API_KEY=sk-abc123...
supabase secrets set AZURE_OPENAI_ENDPOINT=https://my-openai-resource.openai.azure.com
supabase secrets set AZURE_OPENAI_DEPLOYMENT=gpt-4o

# Deploy function
supabase functions deploy ai-generate-career-roadmap

# Test (from your app)
# Click "Generate AI Roadmap" button on any career
```
