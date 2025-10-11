# Phase-2 Integration: Next Steps Guide

## 📍 Where You Are Now

You've completed the initial Supabase setup:
- ✅ Supabase Flutter package installed
- ✅ Environment variables configured
- ✅ Supabase initialized in `main.dart`
- ✅ Google Sign-In integrated (bonus feature!)

## 🎯 What's Next

### Immediate Next Steps (Complete in Order)

#### Step 1: Database Setup ⏳ REQUIRED

Before you can use Supabase authentication with real data, you need to set up the database schema.

**Action Items:**
1. Open your Supabase dashboard: https://app.supabase.com
2. Select your project (URL: https://twolnvofpdhfakafdsla.supabase.co)
3. Go to **SQL Editor**
4. Open `supabase/migrations/00001_init_schema.sql` in VS Code
5. Copy the entire SQL script
6. Paste into Supabase SQL Editor
7. Click **Run**
8. Verify tables are created in **Table Editor**

**Expected Tables:**
- `profiles` - User profile data
- `consents` - User consent records
- `discovery_progress` - User progress tracking
- `activities` - Discovery activities
- `activity_runs` - Completed activities
- `assessments` - Quiz results
- `careers` - Career information
- `roadmaps` - Career roadmaps
- `roadmap_steps` - Roadmap steps

**Why This Matters:**
Without these tables, authentication will work but user profiles won't be created, causing errors when trying to fetch user data.

---

#### Step 2: Enable Authentication in Supabase ⏳ REQUIRED

Configure Supabase authentication settings.

**Action Items:**
1. In Supabase Dashboard → **Authentication** → **Providers**
2. Verify **Email** provider is enabled
3. Configure email templates (optional but recommended):
   - Confirmation email
   - Password reset email
   - Magic link email
4. Set **Site URL** to your app URL:
   - Development: `http://localhost:3000`
   - Production: Your Netlify URL (when deployed)

---

#### Step 3: Test Current Setup ⏳ IMPORTANT

Before replacing repositories, verify your current setup works.

**Action Items:**
1. Run the app:
   ```bash
   flutter run -d chrome --web-port 3000
   ```

2. Test the mock authentication (should still work):
   - Go to signup page
   - Create an account with mock data
   - Verify you can log in
   - Check that onboarding works

3. Check browser console for any Supabase errors

**Expected Behavior:**
- App runs without errors
- Mock authentication still works
- Supabase is initialized (check console logs)
- Google Sign-In button appears (but won't work until OAuth is configured)

---

#### Step 4: Configure Google Sign-In (Optional but Recommended)

Set up Google OAuth for a better user experience.

**Action Items:**
1. Follow `GOOGLE_SIGNIN_SETUP.md` for detailed instructions
2. Or use `SUPABASE_CONFIG_CHECKLIST.md` for a step-by-step checklist
3. Main steps:
   - Create Google OAuth credentials in Google Cloud Console
   - Add redirect URIs: `https://twolnvofpdhfakafdsla.supabase.co/auth/v1/callback`
   - Enable Google provider in Supabase
   - Add Client ID and Secret to Supabase

**Why Do This Now:**
Google Sign-In is already implemented in your code. Once you configure OAuth, it will work immediately without any code changes!

**Test It:**
```bash
flutter run -d chrome
# Click "Continue with Google" on login page
```

---

#### Step 5: Replace Mock Repositories 🎯 MAIN TASK

This is the big step - replacing mock data with real Supabase calls.

**Start with Authentication (Easiest):**

1. Create `lib/data/repositories_impl/supabase_auth_repository.dart`
2. Copy the implementation from `PHASE2_INTEGRATION.md` (Step 4.1)
3. Update imports to use your domain entities
4. Test each method individually

**Implementation Order:**
1. ✅ Start: Auth Repository (most critical)
2. ✅ Next: Progress Repository (enables progress tracking)
3. ✅ Then: Career Repository (enables career matching)
4. ✅ Later: Activities, Assessments, Roadmaps

**How to Switch:**
In `lib/core/providers/providers.dart`:
```dart
// OLD (Mock):
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localPrefs = ref.watch(localPrefsProvider);
  return AuthRepositoryImpl(localPrefs);
});

// NEW (Supabase):
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});
```

**Testing Strategy:**
1. Implement one repository at a time
2. Test each implementation before moving to the next
3. Keep mock implementations as backup (don't delete files)
4. Use feature flags to switch between mock and real data if needed

---

## 🚀 Quick Win Path (Recommended)

Want to see Supabase working ASAP? Follow this minimal path:

### Option A: Test with Google Sign-In (Fastest - 15 minutes)
1. ✅ Run database migrations (Step 1 above)
2. ✅ Configure Google OAuth (Step 4 above)
3. ✅ Test Google Sign-In
4. ✅ Check Supabase dashboard for new user

**Why This Works:**
Google Sign-In already uses Supabase! Once OAuth is configured, you'll have a working Supabase authentication flow without writing any additional code.

### Option B: Replace Auth Repository Only (30 minutes)
1. ✅ Run database migrations (Step 1 above)
2. ✅ Create `SupabaseAuthRepository` (Step 5 above)
3. ✅ Switch provider to use Supabase
4. ✅ Test email/password authentication
5. ✅ Verify user profiles are created in Supabase

**Why This Works:**
Auth is the foundation. Once working, you can gradually add other repositories.

---

## 📝 Detailed Step-by-Step for Auth Repository

Let's implement the auth repository together:

### 1. Create the File

```bash
touch lib/data/repositories_impl/supabase_auth_repository.dart
```

### 2. Add Imports and Class Structure

```dart
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // TODO: Implement methods
}
```

**Note:** We hide `User` from Supabase to avoid conflicts with your domain `User` entity.

### 3. Implement getCurrentUser

```dart
@override
Future<User?> getCurrentUser() async {
  final authUser = _supabase.auth.currentUser;
  if (authUser == null) return null;

  // Fetch profile data from profiles table
  final profileData = await _supabase
      .from('profiles')
      .select()
      .eq('id', authUser.id)
      .single();

  return User(
    id: authUser.id,
    email: authUser.email!,
    displayName: profileData['display_name'] as String,
    onboardingComplete: profileData['onboarding_complete'] as bool,
    locale: profileData['locale'] as String,
    theme: ThemeModePreference.fromJson(profileData['theme'] as String),
    createdAt: DateTime.parse(profileData['created_at'] as String),
    lastLoginAt: DateTime.now(),
  );
}
```

### 4. Implement signIn

```dart
@override
Future<User> signIn({
  required String email,
  required String password,
}) async {
  try {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed - no user returned');
    }

    return await getCurrentUser() as User;
  } on AuthException catch (e) {
    if (e.statusCode == '400') {
      throw Exception('Invalid credentials');
    }
    throw Exception(e.message);
  } catch (e) {
    throw Exception('Failed to sign in: $e');
  }
}
```

### 5. Implement signUp

```dart
@override
Future<User> signUp({
  required String email,
  required String password,
  required String displayName,
}) async {
  try {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user == null) {
      throw Exception('Signup failed - no user returned');
    }

    // Profile is auto-created by database trigger
    // Wait a moment for trigger to complete
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return await getCurrentUser() as User;
  } on AuthException catch (e) {
    if (e.statusCode == '400') {
      throw Exception('Email already in use');
    }
    throw Exception(e.message);
  } catch (e) {
    throw Exception('Failed to sign up: $e');
  }
}
```

### 6. Implement signOut

```dart
@override
Future<void> signOut() async {
  await _supabase.auth.signOut();
}
```

### 7. Implement Other Methods

Continue implementing:
- `resetPassword`
- `updateProfile`
- `completeOnboarding`
- `signInWithGoogle` (already works via OAuth!)
- `authStateChanges` stream

See `PHASE2_INTEGRATION.md` Step 4.1 for complete implementation.

### 8. Switch Provider

In `lib/core/providers/providers.dart`:

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});
```

### 9. Test!

```bash
flutter run -d chrome
```

Try:
1. Creating a new account
2. Logging out
3. Logging back in
4. Check Supabase dashboard → Authentication → Users
5. Check Supabase dashboard → Table Editor → profiles

---

## 🐛 Common Issues & Solutions

### Issue 1: "profiles table doesn't exist"
**Solution:** Run the database migrations (Step 1)

### Issue 2: "Profile not found" after signup
**Solution:** Check that the database trigger is working. The trigger should auto-create a profile when a user signs up.

**Verify trigger:**
```sql
-- In Supabase SQL Editor
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
```

### Issue 3: User type conflicts
**Solution:** Use `import 'package:supabase_flutter/supabase_flutter.dart' hide User;`

### Issue 4: Google Sign-In not working
**Solution:** Follow `GOOGLE_SIGNIN_SETUP.md` to configure OAuth properly

---

## 📊 Progress Checklist

Use this to track your progress:

### Database Setup
- [ ] Opened Supabase dashboard
- [ ] Ran migration script
- [ ] Verified all tables exist
- [ ] Tested table creation (insert a test row)

### Authentication Setup
- [ ] Enabled Email provider in Supabase
- [ ] Set Site URL
- [ ] Configured email templates (optional)

### Google Sign-In (Optional)
- [ ] Created Google OAuth credentials
- [ ] Added redirect URIs
- [ ] Enabled Google provider in Supabase
- [ ] Added Client ID and Secret
- [ ] Tested Google Sign-In flow

### Code Implementation
- [ ] Created `SupabaseAuthRepository`
- [ ] Implemented all required methods
- [ ] Switched provider to use Supabase
- [ ] Tested signup flow
- [ ] Tested login flow
- [ ] Tested logout flow
- [ ] Verified data in Supabase dashboard

### Additional Repositories
- [ ] Progress Repository
- [ ] Career Repository
- [ ] Activities Repository
- [ ] Assessment Repository
- [ ] Roadmap Repository

---

## 🎓 Learning Resources

- **Supabase Docs:** https://supabase.com/docs
- **Supabase Flutter Docs:** https://supabase.com/docs/reference/dart
- **Supabase Auth Guide:** https://supabase.com/docs/guides/auth
- **Your Project Files:**
  - `PHASE2_INTEGRATION.md` - Complete integration guide
  - `GOOGLE_SIGNIN_SETUP.md` - Google OAuth setup
  - `SUPABASE_CONFIG_CHECKLIST.md` - Configuration checklist

---

## 💡 Pro Tips

1. **Start Small:** Don't try to replace all repositories at once
2. **Test Frequently:** Test after each small change
3. **Use Dashboard:** Supabase dashboard is your friend - check it often
4. **Keep Mocks:** Don't delete mock implementations until Supabase is fully working
5. **Read Logs:** Check browser console and Supabase logs for errors
6. **Ask for Help:** Use Supabase Discord or Stack Overflow if stuck

---

## 🚀 Ready to Continue?

Pick one of these paths:

### Path 1: Google Sign-In First (Recommended - Quick Win!)
1. Run database migrations
2. Configure Google OAuth (15 min)
3. Test it immediately - satisfaction guaranteed! 🎉

### Path 2: Auth Repository First (Traditional)
1. Run database migrations
2. Create `SupabaseAuthRepository`
3. Test email/password authentication
4. Add Google Sign-In later

### Path 3: Full Integration (For the Ambitious)
1. Complete all database setup
2. Implement all repositories at once
3. Test everything together

**My Recommendation:** Start with Path 1 (Google Sign-In). It's the quickest way to see Supabase working in your app, and it's already implemented in your code! 🚀

---

**Need Help?** Check the documentation files or reach out for assistance!
