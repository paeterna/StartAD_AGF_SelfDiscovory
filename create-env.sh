#!/bin/bash
# Create .env file from Netlify environment variables

echo "Creating .env file from environment variables..."

cat > .env << EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
AI_RECO_ENABLED=true
TEACHER_MODE_ENABLED=true
ENVIRONMENT=production
EOF

echo ".env file created successfully!"
