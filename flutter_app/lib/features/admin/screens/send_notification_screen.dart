import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

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
          const SnackBar(content: Text('Notification sent successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending notification: $e')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Notification Title',
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bodyController,
                label: 'Message',
                hint: 'Notification Body',
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Message is required' : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Send Broadcast',
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
