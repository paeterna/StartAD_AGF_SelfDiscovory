import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
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

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'When faced with a problem, I prefer to:',
      'options': [
        'Analyze it logically',
        'Think creatively',
        'Discuss with others',
      ],
    },
    {
      'question': 'I feel most energized when:',
      'options': [
        'Working independently',
        'Collaborating with a team',
        'Leading group activities',
      ],
    },
    {
      'question': 'When starting a new project, I:',
      'options': [
        'Follow established methods',
        'Experiment with new approaches',
        'Combine proven and new ideas',
      ],
    },
    {
      'question': 'I am most interested in:',
      'options': [
        'Learning new skills',
        'Mastering what I know',
        'Applying knowledge practically',
      ],
    },
    {
      'question': 'When working on tasks, I:',
      'options': [
        'Focus on the big picture',
        'Pay attention to details',
        'Balance both approaches',
      ],
    },
  ];

  Future<void> _completeOnboarding() async {
    // In a real app, save the answers and generate initial trait scores
    await ref.read(authControllerProvider.notifier).completeOnboarding();

    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final currentQuestion = _questions[_currentStep];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
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
                'Question ${_currentStep + 1} of $_totalSteps',
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
                    final option = currentQuestion['options'][index] as String;
                    final isSelected = _selectedAnswers[_currentStep] == option;

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
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                        child: const Text('Back'),
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
                        _currentStep < _totalSteps - 1 ? 'Next' : 'Finish',
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
