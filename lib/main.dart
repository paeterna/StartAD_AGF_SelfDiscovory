// dart:html is required for web-specific URL manipulation (history API)
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html show window;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/providers/providers.dart';

/// Consumes OAuth callback from URL (for web only)
///
/// Parses #access_token=... or ?code=... from the URL and stores the session.
/// This is critical for OAuth flows (Google, GitHub, etc.) on web.
/// Without this, the callback URL will 404 and the session won't be captured.
Future<void> _consumeOAuthCallbackIfAny() async {
  if (!kIsWeb) return;

  try {
    // Parse OAuth callback from URL and store session
    // This handles both hash (#access_token=...) and query (?code=...) formats
    await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);

    debugPrint('✓ OAuth callback processed successfully');
  } on Exception catch (e) {
    // Swallow errors - this is fine if no callback is present
    // The app will fall back to unauthenticated state
    debugPrint('OAuth callback processing: $e');
  }

  // Clean up the URL to remove token/hash/query parameters
  // This prevents the token from lingering in the address bar
  // and avoids 404s on manual refresh
  try {
    final currentPath = html.window.location.pathname ?? '/';
    html.window.history.replaceState(null, '', currentPath);
    debugPrint('✓ URL cleaned: $currentPath');
  } on Exception catch (e) {
    debugPrint('URL cleanup error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (local development)
  // For production builds, we use --dart-define instead
  bool envLoaded = false;
  try {
    await dotenv.load(fileName: '.env');
    envLoaded = true;
  } on Exception catch (e) {
    debugPrint('⚠️ .env file not found, using dart-define values ($e)');
  }

  // Get Supabase config from .env (local) or --dart-define (production)
  final supabaseUrl =
      (envLoaded ? dotenv.env['SUPABASE_URL'] : null) ??
      const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey =
      (envLoaded ? dotenv.env['SUPABASE_ANON_KEY'] : null) ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  debugPrint(
    'URL=${supabaseUrl.isNotEmpty ? supabaseUrl.substring(0, 20) : "EMPTY"} '
    'KEY=${supabaseAnonKey.isNotEmpty}',
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      // Use implicit flow for web - works with both OAuth and email/password
      authFlowType: AuthFlowType.implicit,
    ),
  );

  // Consume OAuth callback if present (web only)
  // This MUST run after Supabase.initialize and BEFORE the app starts
  await _consumeOAuthCallbackIfAny();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the SharedPreferences provider with the actual instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SelfMapApp(),
    ),
  );
}
