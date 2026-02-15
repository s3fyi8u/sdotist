import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/l10n/app_localizations.dart';

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
          SnackBar(content: Text(AppLocalizations.of(context).translate('new_passwords_not_match'))),
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
            SnackBar(content: Text(AppLocalizations.of(context).translate('password_changed'))),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
           // Basic error handling, improvement would be to parse the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).translate('password_change_failed')}: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final t = AppLocalizations.of(context);


    return Scaffold(
      appBar: AppBar(title: Text(t.translate('change_password'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _currentPasswordController,
                label: t.translate('current_password'),
                hint: t.translate('enter_current_password'),
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) => value!.isEmpty ? t.translate('required') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                label: t.translate('new_password'),
                hint: t.translate('enter_new_password'),
                prefixIcon: Icons.lock_reset,
                obscureText: true,
                validator: (value) =>
                    value!.length < 8 ? t.translate('password_min_8') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: t.translate('confirm_new_password'),
                hint: t.translate('reenter_new_password'),
                prefixIcon: Icons.lock_reset,
                obscureText: true,
                validator: (value) => value!.isEmpty ? t.translate('required') : null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: t.translate('change_password'),
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
