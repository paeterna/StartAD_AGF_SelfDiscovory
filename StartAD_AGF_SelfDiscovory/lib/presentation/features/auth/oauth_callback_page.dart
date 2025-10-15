import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_controller.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/gradient_background.dart';

/// OAuth callback handler page
/// This page is shown after OAuth redirect and waits for Supabase to process the auth tokens
class OAuthCallbackPage extends ConsumerStatefulWidget {
  const OAuthCallbackPage({super.key});

  @override
  ConsumerState<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends ConsumerState<OAuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    debugPrint('🔵 [OAUTH_CALLBACK] Handling OAuth callback...');
    
    // Wait a moment for Supabase to process the auth tokens from URL
    await Future.delayed(const Duration(milliseconds: 1500));
    
    try {
      // Refresh the auth state to get the current user
      final authController = ref.read(authControllerProvider.notifier);
      await authController.refreshUser();
      
      // Get the current auth state
      final authState = ref.read(authControllerProvider);
      final user = authState.user;
      
      if (user != null) {
        debugPrint('✅ [OAUTH_CALLBACK] User authenticated: ${user.email}');
        
        // Navigate based on onboarding status
        if (mounted) {
          if (user.onboardingComplete) {
            context.go(AppRoutes.dashboard);
          } else {
            context.go(AppRoutes.onboarding);
          }
        }
      } else {
        debugPrint('🔴 [OAUTH_CALLBACK] Authentication failed');
        if (mounted) {
          context.go(AppRoutes.login);
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🔴 [OAUTH_CALLBACK] Error: $e');
      if (mounted) {
        context.go(AppRoutes.login);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Completing sign in...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please wait while we finish setting up your account.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

