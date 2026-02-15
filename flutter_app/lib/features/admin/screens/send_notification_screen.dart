import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/l10n/app_localizations.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _apiClient.dio.post(
        ApiConstants.notifications,
        data: {
          'title': _titleController.text,
          'body': _bodyController.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('notification_sent'))),
        );
        Navigator.pop(context);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: t.translate('title'),
                hint: t.translate('notification_title_hint'),
                validator: (value) => value!.isEmpty ? t.translate('title_required') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bodyController,
                label: t.translate('message'),
                hint: t.translate('notification_body_hint'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? t.translate('message_required') : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: t.translate('send_broadcast'),
                isLoading: _isLoading,
                onPressed: _sendNotification,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
