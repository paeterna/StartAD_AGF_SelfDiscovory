import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/language_switcher.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('🔴 [SIGNUP] Validation failed');
      return;
    }

    final email = _emailController.text.trim();
    final displayName = _displayNameController.text.trim();
    debugPrint(
      '🔵 [SIGNUP] Starting signup for: $email (Display Name: $displayName)',
    );

    try {
      debugPrint('🔵 [SIGNUP] Calling auth controller signUp...');
      await ref
          .read(authControllerProvider.notifier)
          .signUp(
            email: email,
            password: _passwordController.text,
            displayName: displayName,
          );

      debugPrint('✅ [SIGNUP] Sign up successful for: $email');

      if (mounted) {
        debugPrint('🔵 [SIGNUP] Navigating to onboarding...');
        context.go(AppRoutes.onboarding);
        debugPrint('✅ [SIGNUP] Navigation complete');
      }
    } catch (e) {
      debugPrint('🔴 [SIGNUP] Error: $e');
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
    debugPrint(
      '🔵 [SIGNUP_GOOGLE] Starting Google OAuth sign in from signup page...',
    );

    try {
      debugPrint(
        '🔵 [SIGNUP_GOOGLE] Calling auth controller signInWithGoogle...',
      );
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      debugPrint('✅ [SIGNUP_GOOGLE] OAuth request initiated successfully');
      debugPrint(
        '🔵 [SIGNUP_GOOGLE] User will be redirected to Google consent screen',
      );
      // The OAuth flow will redirect the user, so no need to manually navigate
    } catch (e) {
      debugPrint('🔴 [SIGNUP_GOOGLE] Error: $e');
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.login),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: LanguageSwitcher(),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join SelfMap and start your journey',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Display name field
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.displayName,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),

                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 24),

                      // Sign up button
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleSignup,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                      const SizedBox(height: 16),

                      // Login link
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => context.go(AppRoutes.login),
                        child: const Text('Already have an account? Sign in'),
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
                        onPressed: authState.isLoading
                            ? null
                            : _handleGoogleSignIn,
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
