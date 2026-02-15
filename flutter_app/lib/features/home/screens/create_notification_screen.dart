import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/l10n/app_localizations.dart';

class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  State<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiClient.dio.post(
        '/notifications/',
        data: {
          'title': _titleController.text,
          'body': _bodyController.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('notification_sent'))),
        );
        Navigator.pop(context, true); // Return true to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_sending_notification')}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('send_notification'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: t.translate('title'),
                hint: t.translate('notification_title'),
                prefixIcon: Icons.title,
                validator: (value) => value!.isEmpty ? t.translate('please_enter_title') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bodyController,
                label: t.translate('message_body'),
                hint: t.translate('enter_message'),
                prefixIcon: Icons.message_outlined,
                maxLines: 5,
                validator: (value) => value!.isEmpty ? t.translate('please_enter_message') : null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: t.translate('send_notification'),
                onPressed: _isLoading ? () {} : _sendNotification,
                isLoading: _isLoading,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
