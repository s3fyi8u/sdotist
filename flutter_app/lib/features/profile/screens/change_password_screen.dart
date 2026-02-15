import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }

      try {
        await Provider.of<AuthProvider>(context, listen: false).changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
           // Basic error handling, improvement would be to parse the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to change password: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);


    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                hint: 'Enter current password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                label: 'New Password',
                hint: 'Enter new password',
                prefixIcon: Icons.lock_reset,
                obscureText: true,
                validator: (value) =>
                    value!.length < 8 ? 'Must be at least 8 chars' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                hint: 'Re-enter new password',
                prefixIcon: Icons.lock_reset,
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Change Password',
                onPressed: _submit,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
