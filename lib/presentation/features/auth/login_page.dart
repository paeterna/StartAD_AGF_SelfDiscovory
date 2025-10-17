import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/language_switcher.dart';

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
      await ref
          .read(authControllerProvider.notifier)
          .signIn(email: email, password: _passwordController.text);

      debugPrint('✅ [LOGIN] Sign in successful for: $email');

      if (mounted) {
        debugPrint('🔵 [LOGIN] Navigating to dashboard...');
        context.go(AppRoutes.dashboard);
        debugPrint('✅ [LOGIN] Navigation complete');
      }
    } on Exception catch (e) {
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
      debugPrint(
        '🔵 [GOOGLE_SIGNIN] Calling auth controller signInWithGoogle...',
      );
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      debugPrint('✅ [GOOGLE_SIGNIN] OAuth request initiated successfully');
      debugPrint(
        '🔵 [GOOGLE_SIGNIN] User will be redirected to Google consent screen',
      );
      // The OAuth flow will redirect the user, so no need to manually navigate
    } on Exception catch (e) {
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

    final l10n = AppLocalizations.of(context)!;
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authResetPassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.authResetPasswordMessage),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.authEmailLabel,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: Validators.email,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: Text(l10n.authSendResetLink),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final email = emailController.text.trim();
      debugPrint(
        '🔵 [FORGOT_PASSWORD] User confirmed, sending reset link to: $email',
      );

      try {
        debugPrint(
          '🔵 [FORGOT_PASSWORD] Calling auth controller resetPassword...',
        );
        await ref
            .read(authControllerProvider.notifier)
            .resetPassword(email: email);

        debugPrint(
          '✅ [FORGOT_PASSWORD] Reset email sent successfully to: $email',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.authResetPasswordSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on Exception catch (e) {
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
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      child: Scaffold(
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
                      // Top row with school button and language switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // School sign-in button
                          OutlinedButton.icon(
                            onPressed: authState.isLoading
                                ? null
                                : () => context.go(AppRoutes.schoolLogin),
                            icon: const Icon(Icons.school_outlined, size: 18),
                            label: const Text('Sign in as School'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          // Language switcher
                          const LanguageSwitcher(),
                        ],
                      ),
                      const SizedBox(height: 32),

                          // Logo/Title
                          Text(
                            l10n.appName,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 400 ? 36 : 48, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tagline,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l10n.authEmailLabel,
                              prefixIcon: const Icon(Icons.email_outlined),
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
                              labelText: l10n.authPasswordLabel,
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
                              child: Text(l10n.authForgotPassword),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login button
                          ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleLogin,
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.authLoginButton),
                          ),
                          const SizedBox(height: 16),

                          // Sign up link
                          TextButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => context.go(AppRoutes.signup),
                            child: Text(l10n.authSwitchToSignup),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(l10n.authDividerOr),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Google Sign-In button
                          OutlinedButton.icon(
                            onPressed: authState.isLoading
                                ? null
                                : _handleGoogleSignIn,
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: Text(l10n.authGoogleSignIn),
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
                                onPressed: () =>
                                    context.push(AppRoutes.privacy),
                                child: Text(l10n.authPrivacyLink),
                              ),
                              const Text(' • '),
                              TextButton(
                                onPressed: () => context.push(AppRoutes.terms),
                                child: Text(l10n.authTermsLink),
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
          ),
      );
  }
}
