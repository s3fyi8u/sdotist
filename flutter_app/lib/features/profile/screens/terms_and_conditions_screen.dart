import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms and Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: February 13, 2026',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              '1. Introduction',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These Website Standard Terms and Conditions written on this webpage shall manage your use of our website. These Terms will be applied fully and affect to your use of this App.',
            ),
            const SizedBox(height: 16),
            Text(
              '2. Intellectual Property Rights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Other than the content you own, under these Terms, we own all the intellectual property rights and materials contained in this App.',
            ),
             const SizedBox(height: 16),
            Text(
              '3. Restrictions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are specifically restricted from all of the following: publishing any App material in any other media; selling, sublicensing and/or otherwise commercializing any App material.',
            ),
             const SizedBox(height: 16),
            Text(
              '4. Limitation of liability',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'In no event shall we, nor any of our officers, directors and employees, shall be held liable for anything arising out of or in any way connected with your use of this App.',
            ),
          ],
        ),
      ),
    );
  }
}
