import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/primary_button.dart';
import 'create_notification_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  AppError? _error;
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _wasAuthenticated = Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
    _fetchNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isAuthenticated && !_wasAuthenticated) {
      _wasAuthenticated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchNotifications();
      });
    }
    _wasAuthenticated = auth.isAuthenticated;
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.dio.get('/notifications/');
      if (mounted) {
        setState(() {
          _notifications = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = ErrorMapper.map(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Auth Guard
    if (!authProvider.isAuthenticated) {
      return _buildGuestUI(context);
    }
    // Error Guard
    if (_error != null) {
      return ErrorScreen(
        error: _error!,
        onRetry: _fetchNotifications,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateNotificationScreen()),
                );
                if (result == true) {
                  _fetchNotifications();
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No notifications yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return ContentCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.notifications_outlined, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['title'] ?? 'No Title',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification['body'] ?? '',
                                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notification['created_at'] != null
                                        ? DateTime.parse(notification['created_at']).toLocal().toString().split('.')[0]
                                        : '',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildGuestUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Login Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please sign in to view your notifications\nand stay updated.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Login Now', 
                onPressed: () {
                   Navigator.pushNamed(context, '/login').then((_) {
                      if (mounted) {
                        setState(() {});
                      }
                   });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

