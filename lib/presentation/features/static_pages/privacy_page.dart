import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('Privacy Policy')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Last updated: January 2025',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),
              SizedBox(height: 16),
              Text(
                'SelfMap is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16),
              Text(
                'Information We Collect',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Account information (email, name)\n'
                '• Assessment responses and results\n'
                '• Progress and activity data\n'
                '• Career preferences and selections',
              ),
              SizedBox(height: 16),
              Text(
                'How We Use Your Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• To provide personalized career recommendations\n'
                '• To track your discovery progress\n'
                '• To improve our services\n'
                '• To send important updates (with your consent)',
              ),
              SizedBox(height: 16),
              Text(
                'Data Security',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We implement industry-standard security measures to protect your data. Your information is never shared with third parties without your explicit consent.',
              ),
              SizedBox(height: 16),
              Text(
                'Your Rights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You have the right to:\n'
                '• Access your data\n'
                '• Request data deletion\n'
                '• Opt out of data collection\n'
                '• Update your information',
              ),
              SizedBox(height: 24),
              SizedBox(height: 16),
              Text(
                'For questions about this policy, please contact us at privacy@selfmap.app',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
