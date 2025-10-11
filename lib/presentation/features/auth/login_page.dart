import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('🔴 [LOGIN] Validation failed');
      return;
    }

    final email = _emailController.text.trim();
    debugPrint('🔵 [LOGIN] Starting login for: $email');

    try {
      debugPrint('🔵 [LOGIN] Calling auth controller signIn...');
      await ref.read(authControllerProvider.notifier).signIn(
            email: email,
            password: _passwordController.text,
          );

      debugPrint('✅ [LOGIN] Sign in successful for: $email');

      if (mounted) {
        debugPrint('🔵 [LOGIN] Navigating to dashboard...');
        context.go(AppRoutes.dashboard);
        debugPrint('✅ [LOGIN] Navigation complete');
      }
    } catch (e) {
      debugPrint('🔴 [LOGIN] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('🔵 [GOOGLE_SIGNIN] Starting Google OAuth sign in...');

    try {
      debugPrint('🔵 [GOOGLE_SIGNIN] Calling auth controller signInWithGoogle...');
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      debugPrint('✅ [GOOGLE_SIGNIN] OAuth request initiated successfully');
      debugPrint('🔵 [GOOGLE_SIGNIN] User will be redirected to Google consent screen');
      // The OAuth flow will redirect the user, so no need to manually navigate
    } catch (e) {
      debugPrint('🔴 [GOOGLE_SIGNIN] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    debugPrint('🔵 [FORGOT_PASSWORD] Opening forgot password dialog...');

    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validators.email,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final email = emailController.text.trim();
      debugPrint('🔵 [FORGOT_PASSWORD] User confirmed, sending reset link to: $email');

      try {
        debugPrint('🔵 [FORGOT_PASSWORD] Calling auth controller resetPassword...');
        await ref
            .read(authControllerProvider.notifier)
            .resetPassword(email: email);

        debugPrint('✅ [FORGOT_PASSWORD] Reset email sent successfully to: $email');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset link sent! Check your email.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('🔴 [FORGOT_PASSWORD] Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      debugPrint('🔵 [FORGOT_PASSWORD] User cancelled the dialog');
    }

    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Title
                    const Text(
                      'SelfMap',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover Your Future',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: Validators.password,
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 8),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => _showForgotPasswordDialog(),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login button
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 16),

                    // Sign up link
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.go(AppRoutes.signup),
                      child: const Text("Don't have an account? Sign up"),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Google Sign-In button
                    OutlinedButton.icon(
                      onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Privacy & Terms
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => context.push(AppRoutes.privacy),
                          child: const Text('Privacy'),
                        ),
                        const Text(' • '),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.terms),
                          child: const Text('Terms'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
