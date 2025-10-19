import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/profiles/profiles_providers.dart';
import '../../../application/school/school_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/school.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';

/// Page for completing signup after Google OAuth
/// Shows for new users who signed in with Google
class ContinueSignupPage extends ConsumerStatefulWidget {
  const ContinueSignupPage({super.key});

  @override
  ConsumerState<ContinueSignupPage> createState() => _ContinueSignupPageState();
}

class _ContinueSignupPageState extends ConsumerState<ContinueSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();

  School? _selectedSchool;
  int? _selectedGrade;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      setState(() {
        _displayNameController.text = user.displayName;
        _emailController.text = user.email;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    if (_selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authPleaseSelectSchool),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authPleaseSelectGrade),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Save display name and grade
      await ref
          .read(profilesServiceProvider)
          .updateProfile(
            displayName: _displayNameController.text.trim(),
            grade: _selectedGrade,
          );

      // Assign school
      await ref
          .read(schoolAssignmentControllerProvider)
          .assignStudentToSchool(
            userId: userId,
            schoolId: _selectedSchool!.id,
          );

      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolsAsync = ref.watch(activeSchoolsProvider);
    final l10n = AppLocalizations.of(context)!;

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.authContinueSignupTitle),
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
                      Text(
                        l10n.authContinueSignupWelcome,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authContinueSignupSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Display Name
                      TextFormField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: l10n.authNameLabel,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.authPleaseEnterName;
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Email (locked)
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: l10n.authEmailLocked,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.lock_outline),
                        ),
                        enabled: false, // Locked field
                      ),
                      const SizedBox(height: 16),

                      // Grade Selection
                      DropdownButtonFormField<int>(
                        initialValue: _selectedGrade,
                        decoration: InputDecoration(
                          labelText: l10n.authGradeLabel,
                          prefixIcon: const Icon(Icons.grade_outlined),
                          border: const OutlineInputBorder(),
                          hintText: l10n.authGradeHint,
                        ),
                        items: [9, 10, 11, 12].map((grade) {
                          return DropdownMenuItem<int>(
                            value: grade,
                            child: Text('${l10n.authGradeLabel} $grade'),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return l10n.authPleaseSelectGrade;
                          }
                          return null;
                        },
                        onChanged: _isLoading
                            ? null
                            : (grade) {
                                setState(() {
                                  _selectedGrade = grade;
                                });
                              },
                      ),
                      const SizedBox(height: 16),

                      // School Selection
                      schoolsAsync.when(
                        data: (schools) {
                          return DropdownButtonFormField<School>(
                            initialValue: _selectedSchool,
                            decoration: InputDecoration(
                              labelText: l10n.authSchoolLabel,
                              prefixIcon: const Icon(Icons.school_outlined),
                              border: const OutlineInputBorder(),
                              hintText: l10n.authSchoolHint,
                            ),
                            items: schools.map((school) {
                              return DropdownMenuItem<School>(
                                value: school,
                                child: Text(school.displayLabel),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return l10n.authPleaseSelectSchool;
                              }
                              return null;
                            },
                            onChanged: _isLoading
                                ? null
                                : (school) {
                                    setState(() {
                                      _selectedSchool = school;
                                    });
                                  },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (error, stack) => Text(
                          'Error loading schools: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Continue Button
                      FilledButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.continueButton),
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
