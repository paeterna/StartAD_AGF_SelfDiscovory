# Supabase Google OAuth Configuration Checklist

Use this checklist to ensure your Google Sign-In is properly configured.

## ✅ Google Cloud Console Setup

### Step 1: Create OAuth Credentials
- [ ] Go to [Google Cloud Console](https://console.cloud.google.com/)
- [ ] Select or create a project
- [ ] Navigate to **APIs & Services** → **Credentials**
- [ ] Click **Create Credentials** → **OAuth 2.0 Client ID**

### Step 2: Configure OAuth Consent Screen
- [ ] Go to **OAuth consent screen**
- [ ] Choose **External** user type (or Internal if using Google Workspace)
- [ ] Fill in required fields:
  - [ ] App name: "SelfMap" (or your app name)
  - [ ] User support email
  - [ ] Developer contact email
- [ ] Add scopes (optional, defaults are usually sufficient):
  - [ ] `.../auth/userinfo.email`
  - [ ] `.../auth/userinfo.profile`
- [ ] Save and continue

### Step 3: Create Web Client ID
- [ ] Select **Web application** as application type
- [ ] Name it: "SelfMap Web Client"
- [ ] Add **Authorized JavaScript origins**:
  ```
  http://localhost:3000
  https://twolnvofpdhfakafdsla.supabase.co
  https://your-site.netlify.app (when you deploy)
  ```
- [ ] Add **Authorized redirect URIs**:
  ```
  http://localhost:3000/auth/v1/callback
  https://twolnvofpdhfakafdsla.supabase.co/auth/v1/callback
  https://your-site.netlify.app/auth/v1/callback (when you deploy)
  ```
- [ ] Click **Create**
- [ ] **IMPORTANT**: Copy the Client ID and Client Secret

## ✅ Supabase Dashboard Setup

### Step 1: Enable Google Provider
- [ ] Go to [Supabase Dashboard](https://app.supabase.com)
- [ ] Select your project
- [ ] Navigate to **Authentication** → **Providers**
- [ ] Find **Google** in the list
- [ ] Toggle it to **Enabled**

### Step 2: Configure Google Provider
- [ ] Paste your **Google Client ID**
- [ ] Paste your **Google Client Secret**
- [ ] (Optional) Configure scopes if needed
- [ ] Click **Save**

### Step 3: Configure URL Settings
- [ ] Go to **Authentication** → **URL Configuration**
- [ ] Set **Site URL**:
  - Development: `http://localhost:3000`
  - Production: `https://your-site.netlify.app`
- [ ] Add **Redirect URLs**:
  ```
  http://localhost:3000/**
  https://your-site.netlify.app/**
  ```
- [ ] Click **Save**

## ✅ Environment Variables

Verify your `.env` file has all required values:

```env
SUPABASE_URL=https://twolnvofpdhfakafdsla.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SECRET_KEY=sb_secret_Hq360I0Mas3dg6Yas_9AKA_GHgkEKmO
```

- [ ] SUPABASE_URL is set
- [ ] SUPABASE_ANON_KEY is set
- [ ] SUPABASE_SECRET_KEY is set
- [ ] `.env` is in `.gitignore` (never commit secrets!)

## ✅ Testing

### Local Testing (Development)
- [ ] Run: `flutter run -d chrome --web-port 3000`
- [ ] Navigate to login page
- [ ] Click "Continue with Google"
- [ ] You should see Google's sign-in page
- [ ] After signing in, you should be redirected back to your app
- [ ] Check browser console for any errors

### Production Testing (After Deployment)
- [ ] Deploy to Netlify: `flutter build web --release`
- [ ] Update Google OAuth redirect URIs with your Netlify URL
- [ ] Update Supabase Site URL and Redirect URLs
- [ ] Test the complete flow on your live site

## ✅ Troubleshooting Checklist

If Google Sign-In isn't working:

- [ ] Check browser console for errors
- [ ] Verify all redirect URIs match exactly (no trailing slashes)
- [ ] Confirm Google OAuth credentials are correct in Supabase
- [ ] Check that http vs https matches in all URLs
- [ ] Verify cookies/localStorage are not blocked
- [ ] Try in incognito/private browsing mode
- [ ] Check Supabase logs: **Authentication** → **Logs**
- [ ] Verify your Google Cloud project is not in testing mode (if you need more users)

## ✅ Security Checklist

- [ ] PKCE auth flow is enabled (already set in `main.dart`)
- [ ] `.env` file is in `.gitignore`
- [ ] Never expose SUPABASE_SECRET_KEY in client code
- [ ] OAuth consent screen is properly configured
- [ ] Redirect URIs are restricted to your domains only
- [ ] Test with a real Google account (not a test account)

## 🎉 Success Indicators

You'll know it's working when:
- ✅ Clicking "Continue with Google" opens Google's sign-in page
- ✅ After authentication, you're redirected back to your app
- ✅ You see a success message or are logged in
- ✅ No errors in browser console
- ✅ User session is persisted (refresh page and still logged in)

## 📞 Support Resources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google OAuth 2.0 Setup](https://developers.google.com/identity/protocols/oauth2)
- [Supabase Discord](https://discord.supabase.com/)
- [Stack Overflow - Supabase](https://stackoverflow.com/questions/tagged/supabase)

---

**Last Updated**: Based on implementation completed on ${new Date().toLocaleDateString()}
**Supabase Project URL**: https://twolnvofpdhfakafdsla.supabase.co
