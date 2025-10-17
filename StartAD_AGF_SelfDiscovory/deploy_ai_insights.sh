#!/bin/bash

# =====================================================
# AI Career Insights - Deployment Script
# =====================================================
# This script deploys the AI Career Insights system
# to your Supabase project.
#
# Prerequisites:
# - Supabase CLI installed (https://supabase.com/docs/guides/cli)
# - Logged in to Supabase CLI (supabase login)
# - OpenAI API key
#
# Usage:
#   ./deploy_ai_insights.sh

set -e

echo "🚀 AI Career Insights Deployment Script"
echo "========================================"
echo ""

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Error: Supabase CLI is not installed"
    echo "Install it from: https://supabase.com/docs/guides/cli"
    exit 1
fi

echo "✅ Supabase CLI found"

# Check if logged in
if ! supabase projects list &> /dev/null; then
    echo "❌ Error: Not logged in to Supabase CLI"
    echo "Run: supabase login"
    exit 1
fi

echo "✅ Authenticated with Supabase"
echo ""

# Prompt for OpenAI API key
read -p "Enter your OpenAI API key: " OPENAI_KEY
if [ -z "$OPENAI_KEY" ]; then
    echo "❌ Error: OpenAI API key is required"
    exit 1
fi

echo ""
echo "📋 Deployment Steps:"
echo "1. Run database migration"
echo "2. Deploy edge function"
echo "3. Set environment variables"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

echo ""
echo "Step 1: Running database migration..."
echo "--------------------------------------"

# Check if migration file exists
if [ ! -f "supabase/migrations/00006_ai_career_insights.sql" ]; then
    echo "❌ Error: Migration file not found"
    exit 1
fi

# Run migration
echo "Applying migration 00006_ai_career_insights.sql..."
supabase db push

echo "✅ Database migration completed"
echo ""

echo "Step 2: Deploying edge function..."
echo "-----------------------------------"

# Check if edge function exists
if [ ! -d "supabase/functions/generate_ai_career_insight" ]; then
    echo "❌ Error: Edge function directory not found"
    exit 1
fi

# Deploy edge function
echo "Deploying generate_ai_career_insight function..."
supabase functions deploy generate_ai_career_insight

echo "✅ Edge function deployed"
echo ""

echo "Step 3: Setting environment variables..."
echo "----------------------------------------"

# Set OpenAI API key as secret
echo "Setting OPENAI_API_KEY..."
echo "$OPENAI_KEY" | supabase secrets set OPENAI_API_KEY

echo "✅ Environment variables configured"
echo ""

echo "🎉 Deployment Complete!"
echo "======================="
echo ""
echo "Next steps:"
echo "1. Test the edge function:"
echo "   supabase functions invoke generate_ai_career_insight --method POST"
echo ""
echo "2. Update your Flutter app:"
echo "   flutter pub get"
echo "   flutter run"
echo ""
echo "3. Navigate to /ai-insights in your app"
echo ""
echo "4. Review the documentation:"
echo "   - AI_INSIGHTS_GUIDE.md"
echo "   - test_ai_insights.md"
echo ""
echo "For support, check the documentation or contact your team."
echo ""

