# SelfMap Deployment Guide

## 🚨 Issue Encountered: Flutter Not Found on Netlify

### The Problem
Your first deployment failed with:
```
bash: line 1: flutter: command not found
```

**Root Cause**: Netlify doesn't have Flutter SDK installed by default.

### ✅ The Solution
We've added a build script (`build-netlify.sh`) that:
1. Installs Flutter SDK during build
2. Configures Flutter for web
3. Gets dependencies
4. Builds your app

---

# SelfMap Deployment Guide

## 🚀 Live Deployment

**Production URL**: https://selfmap-startad.netlify.app

**Admin Dashboard**: https://app.netlify.com/projects/selfmap-startad

**Latest Deploy**: https://68ea73dbca7a7a9f6fbae92b--selfmap-startad.netlify.app

---

## ✅ Deployment Summary

### Platform: Netlify
- **Status**: ✅ Live
- **Build Time**: ~2.5 minutes
- **CDN**: Global edge network
- **SSL**: Automatic HTTPS
- **Deploy ID**: 68ea73dbca7a7a9f6fbae92b

### Build Configuration
- **Build Command**: `flutter build web --release`
- **Publish Directory**: `build/web`
- **Flutter Version**: 3.32.5

### Optimizations
- ✅ Tree-shaken icons (99.4% reduction)
  - CupertinoIcons: 257KB → 1.5KB
  - MaterialIcons: 1.6MB → 10.6KB
- ✅ PWA manifest configured
- ✅ Service worker for offline support
- ✅ CDN caching for static assets
- ✅ Client-side routing with redirects

---

## 📋 Configuration Files

### netlify.toml
Complete configuration including:
- Build settings
- Redirect rules for Flutter routing
- Cache headers for PWA
- Security headers
- Lighthouse performance plugin

**Location**: [`netlify.toml`](netlify.toml)

### Environment Variables
Configured in `.env` (not deployed):
- `SUPABASE_URL` (for Phase-2)
- `SUPABASE_ANON_KEY` (for Phase-2)
- `AI_RECO_ENABLED=false`
- `TEACHER_MODE_ENABLED=false`

---

## 🔄 CI/CD Workflow

### Automatic Deployments
Netlify is configured to auto-deploy on git push:

```bash
git add .
git commit -m "Update feature"
git push origin main
# Netlify automatically builds and deploys
```

### Manual Deployments

#### Production Deploy
```bash
netlify deploy --prod
```

#### Preview Deploy (Draft)
```bash
netlify deploy
# Returns a preview URL for testing
```

#### Build Only (No Deploy)
```bash
flutter build web --release
```

---

## 🌍 Testing the Deployment

### Test Authentication
1. Visit: https://selfmap-startad.netlify.app
2. Sign up with any email + password (mock auth)
3. Complete onboarding quiz
4. Explore dashboard

### Test Features
- ✅ Login/Signup flow
- ✅ Onboarding quiz (5 questions)
- ✅ Dashboard with progress
- ✅ Discover page (quizzes/games)
- ✅ Careers page (10 careers with match scores)
- ✅ Roadmap page (step-by-step plans)
- ✅ Settings (language, theme toggle)

### Test PWA
1. Chrome: Click install icon in address bar
2. Installs as standalone app
3. Works offline (shell + cached assets)

### Test Responsive Design
- Desktop: Full layout with sidebar
- Tablet: Adaptive layout
- Mobile: Mobile-optimized UI

### Test RTL (Arabic)
1. Go to Settings
2. Change language to العربية
3. Entire UI flips to RTL

---

## 📊 Performance Metrics

### Lighthouse Scores
Ran automatically on each deploy:
- **Performance**: Target 80+
- **Accessibility**: Target 90+
- **Best Practices**: Target 80+
- **SEO**: Target 90+
- **PWA**: Target 80+

View latest report in Netlify dashboard.

### Bundle Size
- **Main JS**: ~1.8MB (gzipped)
- **Flutter Engine**: ~400KB (gzipped)
- **Assets**: ~50KB (fonts + images)
- **Total**: ~2.3MB initial load

---

## 🔐 Security Features

### Headers
- `X-Frame-Options: DENY` (prevent clickjacking)
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: no-referrer-when-downgrade`

### HTTPS
- Automatic SSL certificate from Let's Encrypt
- HTTP → HTTPS redirect
- HSTS enabled

### Content Security
- No inline scripts in production
- All assets loaded from CDN
- Service worker for secure caching

---

## 🛠 Troubleshooting

### Issue: App shows blank page
**Solution**: Check browser console for errors. Ensure `.env` file exists (even if empty).

### Issue: Routes not working (404)
**Solution**: Netlify redirect rule in `netlify.toml` handles this. Verify file is committed.

### Issue: Theme not applying
**Solution**: Clear browser cache and hard reload (Cmd+Shift+R on Mac).

### Issue: Localization not loading
**Solution**: Check that `assets/i18n/` files are included in build. Verify `pubspec.yaml` assets config.

---

## 📈 Monitoring

### Netlify Analytics
- **Pageviews**: Track user visits
- **Bandwidth**: Monitor data usage
- **Build minutes**: Track CI/CD usage

### Error Tracking (Future)
Integrate with:
- Sentry for error logging
- LogRocket for session replay
- Google Analytics for user behavior

---

## 🔄 Rollback Strategy

### Rollback to Previous Deploy
1. Go to: https://app.netlify.com/projects/selfmap-startad/deploys
2. Find the previous successful deploy
3. Click "Publish deploy"
4. Site rolls back instantly

### Emergency Rollback (CLI)
```bash
netlify rollback
```

---

## 🚦 Deploy Checklist

Before deploying to production:

- [ ] Run `flutter analyze` (no errors)
- [ ] Run `flutter test` (all tests pass)
- [ ] Test locally: `flutter run -d chrome`
- [ ] Build successfully: `flutter build web --release`
- [ ] Review `netlify.toml` configuration
- [ ] Check `.env` file (don't commit secrets!)
- [ ] Test auth flow end-to-end
- [ ] Test PWA installation
- [ ] Test on mobile device
- [ ] Deploy: `netlify deploy --prod`
- [ ] Verify live site loads correctly
- [ ] Test critical user flows
- [ ] Check Lighthouse scores
- [ ] Monitor for errors in first hour

---

## 🎯 Next Steps

### Phase-2: Backend Integration
1. Set up Supabase project
2. Run database migration
3. Add Supabase environment variables to Netlify
4. Deploy updated app with real backend

### Performance Optimization
- [ ] Enable code splitting
- [ ] Implement lazy loading for routes
- [ ] Optimize images (WebP format)
- [ ] Add service worker pre-caching

### Monitoring & Analytics
- [ ] Set up Sentry error tracking
- [ ] Add Google Analytics
- [ ] Configure Netlify Analytics
- [ ] Set up uptime monitoring

### SEO Improvements
- [ ] Add sitemap.xml
- [ ] Configure robots.txt
- [ ] Add structured data (JSON-LD)
- [ ] Optimize meta descriptions per route

---

## 📞 Support

### Netlify Support
- **Docs**: https://docs.netlify.com
- **Forums**: https://answers.netlify.com
- **Status**: https://www.netlifystatus.com

### SelfMap Support
- **Email**: support@selfmap.app
- **Issues**: Create GitHub issue
- **Docs**: See [README.md](README.md)

---

## 📝 Deployment History

| Date | Deploy ID | Status | Notes |
|------|-----------|--------|-------|
| 2025-10-11 | 68ea73dbca7a7a9f6fbae92b | ✅ Live | Initial production deployment |

---

**Deployed with ❤️ on Netlify** | **Built with Flutter** 💙
