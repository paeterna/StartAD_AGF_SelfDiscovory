import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/school/school_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/school.dart';
import '../../../generated/l10n/app_localizations.dart';
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
  School? _selectedSchool;

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

    // Validate school selection
    if (_selectedSchool == null) {
      debugPrint('🔴 [SIGNUP] School selection required');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a school'),
          backgroundColor: Colors.red,
        ),
      );
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

      // Save school assignment (now required)
      debugPrint(
        '🔵 [SIGNUP] Assigning student to school: ${_selectedSchool!.name}',
      );
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId != null) {
        await ref
            .read(schoolAssignmentControllerProvider)
            .assignStudentToSchool(
              userId: userId,
              schoolId: _selectedSchool!.id,
            );
        debugPrint('✅ [SIGNUP] School assignment successful');
      }

      if (mounted) {
        debugPrint('🔵 [SIGNUP] Navigating to onboarding...');
        context.go(AppRoutes.onboarding);
        debugPrint('✅ [SIGNUP] Navigation complete');
      }
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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

  Widget _buildSchoolSelection() {
    final schoolsAsync = ref.watch(activeSchoolsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // School dropdown
        schoolsAsync.when(
          data: (schools) {
            return DropdownButtonFormField<School>(
              value: _selectedSchool,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
              items: schools.map((school) {
                return DropdownMenuItem<School>(
                  value: school,
                  child: Text(school.displayLabel),
                );
              }).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select a school';
                }
                return null;
              },
              onChanged: (school) {
                setState(() {
                  _selectedSchool = school;
                });
              },
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, stack) => Text(
            'Error loading schools: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context)!;

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
                      Text(
                        l10n.authSignupTitle,
                        style: const TextStyle(
                          fontSize: 32,
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
                      const SizedBox(height: 32),

                      // Display name field
                      TextFormField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: l10n.authDisplayNameLabel,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: Validators.displayName,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),

                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: l10n.authConfirmPasswordLabel,
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

                      // School selection
                      _buildSchoolSelection(),
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
                            : Text(l10n.authSignupButton),
                      ),
                      const SizedBox(height: 16),

                      // Login link
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => context.go(AppRoutes.login),
                        child: Text(l10n.authSwitchToLogin),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
