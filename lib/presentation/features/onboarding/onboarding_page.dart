import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'widgets/welcome_screen.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool _showWelcome = true;
  int _currentStep = 0;
  final int _totalSteps = 5;

  final Map<int, String> _selectedAnswers = {};

  List<Map<String, dynamic>> _getLocalizedQuestions(AppLocalizations l10n) {
    return [
      {
        'question': l10n.onboardingQuestion1,
        'options': [
          l10n.onboardingQ1Option1,
          l10n.onboardingQ1Option2,
          l10n.onboardingQ1Option3,
        ],
      },
      {
        'question': l10n.onboardingQuestion2,
        'options': [
          l10n.onboardingQ2Option1,
          l10n.onboardingQ2Option2,
          l10n.onboardingQ2Option3,
        ],
      },
      {
        'question': l10n.onboardingQuestion3,
        'options': [
          l10n.onboardingQ3Option1,
          l10n.onboardingQ3Option2,
          l10n.onboardingQ3Option3,
        ],
      },
      {
        'question': l10n.onboardingQuestion4,
        'options': [
          l10n.onboardingQ4Option1,
          l10n.onboardingQ4Option2,
          l10n.onboardingQ4Option3,
        ],
      },
      {
        'question': l10n.onboardingQuestion5,
        'options': [
          l10n.onboardingQ5Option1,
          l10n.onboardingQ5Option2,
          l10n.onboardingQ5Option3,
        ],
      },
    ];
  }

  Future<void> _completeOnboarding() async {
    try {
      // Convert selected answers to a format suitable for the database
      // Map question indices to question keys and answers
      final answers = <String, String>{};

      for (int i = 0; i < _selectedAnswers.length; i++) {
        final questionKey = 'question_${i + 1}';
        final answer = _selectedAnswers[i];
        if (answer != null) {
          answers[questionKey] = answer;
        }
      }

      debugPrint(
        '📝 [ONBOARDING] Saving ${answers.length} answers to database',
      );

      // Save the answers and complete onboarding in the database
      await ref
          .read(authControllerProvider.notifier)
          .completeOnboarding(answers: answers);

      if (mounted) {
        // Navigate to dashboard - router will handle the redirect based on onboarding status
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      // Handle error if needed
      debugPrint('🔴 [ONBOARDING] Error completing onboarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Show welcome screen first
    if (_showWelcome) {
      return WelcomeScreen(
        onGetStarted: () {
          setState(() {
            _showWelcome = false;
          });
        },
      );
    }

    // Show questionnaire
    final questions = _getLocalizedQuestions(l10n);
    final currentQuestion = questions[_currentStep];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                ),
                const SizedBox(height: 16),

                // Step indicator
                Text(
                  l10n.onboardingQuestionPrefix(_currentStep + 1, _totalSteps),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Question
                Text(
                  currentQuestion['question'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: (currentQuestion['options'] as List).length,
                    itemBuilder: (context, index) {
                      final option =
                          currentQuestion['options'][index] as String;
                      final isSelected =
                          _selectedAnswers[_currentStep] == option;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedAnswers[_currentStep] = option;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            side: BorderSide(
                              width: isSelected ? 2 : 1,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            backgroundColor: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1)
                                : null,
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          child: Text(l10n.onboardingBackButton),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedAnswers.containsKey(_currentStep)
                            ? () {
                                if (_currentStep < _totalSteps - 1) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                } else {
                                  _completeOnboarding();
                                }
                              }
                            : null,
                        child: Text(
                          _currentStep < _totalSteps - 1
                              ? l10n.onboardingNextButton
                              : l10n.onboardingFinishButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
