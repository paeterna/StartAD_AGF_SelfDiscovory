# Quick Start: Supabase Integration

Your Supabase credentials are now configured! Follow these steps to migrate from mock data to production backend.

## ✅ Current Status

**Supabase Project**: https://YOUR-PROJECT-REF.supabase.co
**Environment Variables**: Already configured in `.env`

---

## 🚀 Step 1: Run Database Migration (5 minutes)

### 1.1 Open Supabase SQL Editor
Go to: https://supabase.com/dashboard/project/YOUR-PROJECT-ID/sql/new

### 1.2 Copy & Paste Migration
Copy the entire contents of `supabase/migrations/00001_init_schema.sql` and paste into the SQL editor.

### 1.3 Run the Script
Click "Run" or press `Cmd+Enter`. You should see:
- ✅ 9 tables created
- ✅ RLS policies enabled
- ✅ Triggers configured
- ✅ Seed data inserted (3 activities, 5 careers)

### 1.4 Verify Tables
Go to: https://supabase.com/dashboard/project/YOUR-PROJECT-ID/editor

You should see these tables:
- `profiles`
- `consents`
- `discovery_progress`
- `activities`
- `activity_runs`
- `assessments`
- `careers`
- `roadmaps`
- `roadmap_steps`

---

## 🔧 Step 2: Update Flutter Dependencies (2 minutes)

The `supabase_flutter` package is already in `pubspec.yaml`. Just run:

```bash
flutter pub get
```

---

## 🔌 Step 3: Swap Repository Implementations (15 minutes)

### 3.1 Update Auth Repository

In `lib/core/providers/providers.dart`, change:

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(); // ← Change this

  // OLD (mock):
  // final localPrefs = ref.watch(localPrefsProvider);
  // return AuthRepositoryImpl(localPrefs);
});
```

### 3.2 Create Supabase Repository Implementations

The examples are already documented in [`PHASE2_INTEGRATION.md`](PHASE2_INTEGRATION.md).

Create these files:
- `lib/data/repositories_impl/supabase_auth_repository.dart`
- `lib/data/repositories_impl/supabase_progress_repository.dart`
- `lib/data/repositories_impl/supabase_career_repository.dart`
- `lib/data/repositories_impl/supabase_assessment_repository.dart`
- `lib/data/repositories_impl/supabase_roadmap_repository.dart`

Copy the implementations from the Phase-2 integration guide.

---

## 🧪 Step 4: Test Authentication (5 minutes)

### 4.1 Update main.dart

Already done! The initialization code is in place:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

### 4.2 Run the App

```bash
flutter run -d chrome
```

### 4.3 Test Sign Up

1. Create a new account with a real email
2. Check Supabase dashboard → Authentication → Users
3. Verify your email (check inbox)
4. Log in to the app

### 4.4 Verify Database

Go to: https://supabase.com/dashboard/project/YOUR-PROJECT-ID/editor

Check:
- `profiles` table has your user
- `discovery_progress` was auto-created by trigger

---

## 🌐 Step 5: Deploy to Netlify with Supabase (5 minutes)

### 5.1 Set Environment Variables in Netlify

```bash
netlify env:set SUPABASE_URL "https://YOUR-PROJECT-REF.supabase.co"
netlify env:set SUPABASE_ANON_KEY "your_supabase_anon_key"
```

Or set them in the Netlify dashboard:
https://app.netlify.com/projects/selfmap-startad/settings/env

### 5.2 Deploy

```bash
netlify deploy --prod
```

### 5.3 Test Live Site

Visit: https://selfmap-startad.netlify.app

Sign up with a real email and test the full flow!

---

## 📊 Step 6: Verify Everything Works

### Test Checklist

- [ ] **Sign Up** with real email
- [ ] **Verify Email** in inbox
- [ ] **Log In** to the app
- [ ] **Complete Onboarding** quiz
- [ ] Check `assessments` table has your data
- [ ] Check `discovery_progress` updated automatically
- [ ] **Take Another Quiz** in Discover
- [ ] Verify progress increased
- [ ] Verify streak tracking works
- [ ] **View Careers** with match scores
- [ ] **Create Roadmap** for a career
- [ ] Check `roadmaps` and `roadmap_steps` tables
- [ ] **Mark Steps Complete**
- [ ] **Test Settings** - update profile, theme, language
- [ ] **Log Out** and **Log In** again
- [ ] Verify session persists

---

## 🎯 Current vs. Phase-2

| Feature | Phase-1 (Mock) | Phase-2 (Supabase) | Status |
|---------|----------------|-------------------|---------|
| Authentication | In-memory | Supabase Auth | ⏳ Ready to swap |
| User Data | SharedPreferences | PostgreSQL | ⏳ Ready to swap |
| Progress Tracking | In-memory | Auto-updated by trigger | ⏳ Ready to swap |
| Assessments | Mock list | Database + history | ⏳ Ready to swap |
| Careers | Static seed data | Database with RLS | ⏳ Ready to swap |
| Roadmaps | In-memory | Persistent + shareable | ⏳ Ready to swap |

---

## 🔐 Security Notes

### What's Secure

- ✅ **RLS Policies**: Users can only access their own data
- ✅ **Anon Key**: Safe to expose in client-side code
- ✅ **JWT Authentication**: Automatic session management
- ✅ **HTTPS Only**: All API calls encrypted

### What's NOT in `.env` (Security)

- ❌ Service Role Key (never use in client apps)
- ❌ Database password (Supabase handles this)
- ❌ User passwords (hashed by Supabase)

### Netlify Environment Variables

**Important**: Make sure `.env` is in `.gitignore` (it already is).

Environment variables are set separately in Netlify dashboard, so your secrets aren't committed to git.

---

## 🐛 Troubleshooting

### Error: "Invalid API key"
**Solution**: Double-check the `SUPABASE_ANON_KEY` matches exactly (it's a JWT token).

### Error: "Failed to fetch"
**Solution**: Verify `SUPABASE_URL` is correct and the Supabase project is active.

### Error: "Row Level Security policy violation"
**Solution**: Make sure you ran the migration script completely. Check policies in Supabase dashboard.

### Error: "User not found after signup"
**Solution**: Check Supabase → Authentication → Users. Verify email confirmation.

---

## 📈 Next Steps After Supabase

1. **Add More Careers**: Insert 100+ careers into the database
2. **Create More Assessments**: Add 20+ quizzes and games
3. **Analytics**: Track user behavior with Supabase functions
4. **AI/ML Integration**: Replace rule-based matching with ML model
5. **Real-time Features**: Add collaborative features with Supabase realtime
6. **Storage**: Add profile photos with Supabase Storage
7. **Email Templates**: Customize Supabase auth email templates

---

## 💡 Tips

- **Test Locally First**: Always test Supabase integration locally before deploying
- **Use Seed Data**: The migration includes sample data (3 activities, 5 careers)
- **Monitor Usage**: Check Supabase dashboard for API usage and database size
- **Backup Database**: Supabase has automatic backups, but you can also export manually

---

## 📞 Help & Resources

- **Supabase Dashboard**: https://supabase.com/dashboard/project/YOUR-PROJECT-ID
- **Supabase Docs**: https://supabase.com/docs
- **Flutter Docs**: https://supabase.com/docs/reference/dart/introduction
- **Phase-2 Guide**: [PHASE2_INTEGRATION.md](PHASE2_INTEGRATION.md)

---

**Ready to go live with Supabase?** 🚀

1. Run the SQL migration
2. Swap repository implementations
3. Test locally
4. Deploy to Netlify

**Total time**: ~30 minutes to production backend!
