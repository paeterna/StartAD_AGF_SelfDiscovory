import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/gradient_background.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('About SelfMap')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About SelfMap',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'SelfMap is a self-discovery platform designed to help high school students explore their interests, discover careers, and plan their future.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Through interactive quizzes, games, and personalized recommendations, SelfMap guides students on a journey of self-discovery to find careers that match their unique traits and interests.',
              ),
              const SizedBox(height: 24),
              const Text(
                'Features',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Personality and skills assessments\n'
                '• Career matching based on your traits\n'
                '• Personalized roadmaps to your goals\n'
                '• Progress tracking and streaks\n'
                '• Multilingual support (English & Arabic)',
              ),
              const SizedBox(height: 24),
              const Text(
                'Version',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appVersion,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Contact Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Email: support@selfmap.app\n'
                'Website: www.selfmap.app',
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  '© 2025 SelfMap. All rights reserved.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
