#!/bin/bash

# Deploy the AI roadmap generation Edge Function to Supabase

echo "🚀 Deploying ai-generate-career-roadmap Edge Function..."

# Deploy the function
supabase functions deploy ai-generate-career-roadmap

if [ $? -eq 0 ]; then
    echo "✅ Edge Function deployed successfully!"
    echo ""
    echo "The function is now available at:"
    echo "https://bklsuvhswylxbjpcpasw.supabase.co/functions/v1/ai-generate-career-roadmap"
    echo ""
    echo "Make sure you have set the following secrets:"
    echo "- OPENAI_API_KEY (required)"
    echo "- OPENAI_MODEL (optional - defaults to gpt-4o)"
    echo ""
    echo "To set secrets, run:"
    echo "supabase secrets set OPENAI_API_KEY=sk-your-key-here"
    echo "supabase secrets set OPENAI_MODEL=gpt-4o-mini"
    echo ""
    echo "See OPENAI_SETUP.md for detailed instructions"
else
    echo "❌ Deployment failed"
    exit 1
fi
