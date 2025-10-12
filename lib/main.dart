import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (local development)
  // For production builds, we use --dart-define instead
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env file not found, using dart-define values');
  }

  // Get Supabase config from .env (local) or --dart-define (production)
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
                      const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
                          const String.fromEnvironment('SUPABASE_ANON_KEY');

  debugPrint('URL=${supabaseUrl.isNotEmpty ? supabaseUrl.substring(0, 20) : "EMPTY"} '
             'KEY=${supabaseAnonKey.isNotEmpty}');

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      // Use implicit flow for web - works with both OAuth and email/password
      authFlowType: AuthFlowType.implicit,
    ),
  );

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
