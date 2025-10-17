import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('Terms of Use')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Use',
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
                'By using SelfMap, you agree to these Terms of Use. Please read them carefully.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16),
              Text(
                'Acceptable Use',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You agree to use SelfMap only for lawful purposes and in accordance with these Terms. You must not use SelfMap in any way that violates applicable laws or regulations.',
              ),
              SizedBox(height: 16),
              Text(
                'User Accounts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You are responsible for maintaining the confidentiality of your account credentials and for all activities under your account.',
              ),
              SizedBox(height: 16),
              Text(
                'Content',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'All content provided through SelfMap is for informational purposes only. Career recommendations are suggestions based on your inputs and should not be considered professional advice.',
              ),
              SizedBox(height: 16),
              Text(
                'Limitation of Liability',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'SelfMap is provided "as is" without warranties of any kind. We are not liable for any decisions made based on information provided by the platform.',
              ),
              SizedBox(height: 16),
              Text(
                'Changes to Terms',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We reserve the right to modify these Terms at any time. Continued use of SelfMap after changes constitutes acceptance of the new Terms.',
              ),
              SizedBox(height: 16),
              Text(
                'For questions about these terms, please contact us at legal@selfmap.app',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
