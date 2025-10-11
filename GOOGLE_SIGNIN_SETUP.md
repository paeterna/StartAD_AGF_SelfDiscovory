# Google Sign-In Setup Guide

This guide explains how Google Sign-In has been integrated into your SelfMap Flutter application using Supabase.

## What's Been Implemented

### 1. Dependencies Added
- **supabase_flutter**: Added to `pubspec.yaml` for Supabase authentication

### 2. Supabase Initialization
In `lib/main.dart`, Supabase is now initialized with:
```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? '',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce, // recommended for web
  ),
);
```

### 3. Repository Layer
- **Auth Repository Interface** (`lib/domain/repositories/auth_repository.dart`):
  - Added `signInWithGoogle()` method

- **Auth Repository Implementation** (`lib/data/repositories_impl/auth_repository_impl.dart`):
  - Implemented Google OAuth sign-in using Supabase
  - Uses `OAuthProvider.google` for authentication
  - Handles both web and mobile platforms automatically

### 4. Controller Layer
- **Auth Controller** (`lib/application/auth/auth_controller.dart`):
  - Added `signInWithGoogle()` method to handle Google sign-in flow
  - Manages loading states and error handling

### 5. UI Layer
- **Login Page** (`lib/presentation/features/auth/login_page.dart`):
  - Added "Continue with Google" button
  - Divider with "OR" text for visual separation
  - Error handling with SnackBar feedback

- **Signup Page** (`lib/presentation/features/auth/signup_page.dart`):
  - Added "Continue with Google" button
  - Consistent UI with login page

## Supabase Configuration Required

### 1. Enable Google Provider in Supabase Dashboard

1. Go to your Supabase dashboard: https://app.supabase.com
2. Select your project
3. Navigate to **Authentication** → **Providers**
4. Find **Google** in the list and click on it
5. Enable the Google provider
6. You'll need to set up OAuth credentials from Google Cloud Console

### 2. Get Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API
4. Go to **APIs & Services** → **Credentials**
5. Click **Create Credentials** → **OAuth 2.0 Client ID**
6. Configure the OAuth consent screen if you haven't already
7. For Application type, select:
   - **Web application** for web deployment
   - Add additional client IDs for iOS/Android if needed

### 3. Configure Authorized Redirect URIs

Add these redirect URIs to your Google OAuth client:

For **Development** (local testing):
```
http://localhost:3000/auth/v1/callback
http://127.0.0.1:3000/auth/v1/callback
```

For **Production** (replace with your Supabase project URL):
```
https://twolnvofpdhfakafdsla.supabase.co/auth/v1/callback
```

For **Netlify** (when you deploy):
```
https://YOUR-SITE.netlify.app/auth/v1/callback
```

### 4. Add Credentials to Supabase

1. Copy the **Client ID** and **Client Secret** from Google Cloud Console
2. Paste them into the Supabase Google provider settings
3. Save the configuration

### 5. Configure Redirect URL in Supabase

1. In Supabase Dashboard → **Authentication** → **URL Configuration**
2. Add your site URLs:
   - **Site URL**: Your production URL (e.g., `https://your-site.netlify.app`)
   - **Redirect URLs**: Add all URLs where users can be redirected after authentication

## Testing Google Sign-In

### Local Development (Web)

1. Start your Flutter web app:
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://twolnvofpdhfakafdsla.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

2. Navigate to the login page
3. Click "Continue with Google"
4. You'll be redirected to Google's sign-in page
5. After successful authentication, you'll be redirected back to your app

### Production Deployment

For web deployment on Netlify:

1. Your `.env` file should contain:
```env
SUPABASE_URL=https://twolnvofpdhfakafdsla.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SECRET_KEY=sb_secret_Hq360I0Mas3dg6Yas_9AKA_GHgkEKmO
```

2. Build for web:
```bash
flutter build web --release
```

3. Deploy to Netlify (it will use the configuration from `netlify.toml`)

## How It Works

### Authentication Flow

1. **User clicks "Continue with Google"**
   - Triggers `_handleGoogleSignIn()` in the UI
   - Calls `signInWithGoogle()` in the auth controller

2. **OAuth redirect**
   - Supabase redirects to Google's OAuth consent page
   - User authorizes the app

3. **Callback handling**
   - Google redirects back to your app with an auth code
   - Supabase exchanges the code for user tokens
   - User session is created automatically

4. **Session management**
   - Supabase Flutter SDK manages the session automatically
   - Auth state changes can be listened to via `authStateChanges` stream

### Code Example

The implementation follows this pattern:

```dart
// In your UI
Future<void> _handleGoogleSignIn() async {
  try {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    // OAuth flow handles the redirect automatically
  } catch (e) {
    // Show error to user
  }
}
```

## Additional Configuration for Mobile

If you plan to support mobile platforms (iOS/Android), you'll need additional setup:

### iOS
1. Add URL scheme to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR-BUNDLE-ID</string>
    </array>
  </dict>
</array>
```

### Android
1. Add intent filter to `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter android:label="flutter_app">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="YOUR-PACKAGE-NAME" />
</intent-filter>
```

## Troubleshooting

### Common Issues

1. **"redirect_uri_mismatch" error**
   - Make sure the redirect URI in Google Cloud Console matches exactly with your Supabase callback URL
   - Check for trailing slashes and http vs https

2. **No callback after Google sign-in**
   - Verify your Site URL and Redirect URLs in Supabase dashboard
   - Check browser console for errors

3. **Session not persisting**
   - Supabase automatically stores the session in localStorage (web) or secure storage (mobile)
   - Check that cookies/storage are enabled

4. **Development testing issues**
   - Use `http://localhost` instead of `127.0.0.1` or vice versa depending on your setup
   - Make sure both are added to Google OAuth redirect URIs

## Security Notes

- ✅ Uses PKCE (Proof Key for Code Exchange) for enhanced security
- ✅ The secret key should never be exposed in client-side code (it's only in `.env`)
- ✅ Google OAuth tokens are handled securely by Supabase
- ✅ Session tokens are stored securely by the Supabase SDK

## Next Steps

1. ✅ Complete Google OAuth setup in Google Cloud Console
2. ✅ Configure Supabase Google provider
3. ✅ Test locally with `flutter run -d chrome`
4. ✅ Deploy to Netlify for production testing
5. Consider adding more OAuth providers (Apple, GitHub, etc.)
6. Implement proper user profile creation after first Google sign-in
7. Add analytics tracking for Google sign-in events

## Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google OAuth 2.0 Setup](https://support.google.com/cloud/answer/6158849)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
