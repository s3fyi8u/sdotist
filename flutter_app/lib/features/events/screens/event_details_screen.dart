import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/event_model.dart';
import '../services/events_service.dart';
import 'event_registrations_screen.dart';
import 'qr_scanner_screen.dart';
import '../../../core/l10n/app_localizations.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventsService _eventsService = EventsService();
  late Future<Event> _eventFuture;
  Event? _event;

  @override
  void initState() {
    super.initState();
    _refreshEvent();
  }

  void _refreshEvent() {
    setState(() {
      _eventFuture = _eventsService.getEvent(widget.eventId).then((event) {
        _event = event;
        return event;
      });
    });
  }

  Future<void> _register() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      await _eventsService.registerForEvent(widget.eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('registration_successful') ?? 'Registered successfully')),
        );
        _refreshEvent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _unregister() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context).translate('cancel_registration') ?? 'Cancel Registration'),
        content: Text(AppLocalizations.of(context).translate('confirm_cancel_registration') ?? 'Are you sure you want to cancel your registration for this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).translate('confirm') ?? 'Confirm',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _eventsService.unregisterFromEvent(widget.eventId);
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('registration_cancelled') ?? 'Registration cancelled')),
          );
          _refreshEvent();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('login_required') ?? 'Login Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).translate('login_to_register_event') ?? 'You must login or create an account to register for this event.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context).translate('cancel') ?? 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context).translate('login') ?? 'Login'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final userId = authProvider.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('event_details') ?? 'Event Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<Event>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Event not found'));
          }

          final event = snapshot.data!;
          final isRegistered = event.registrations.any((r) => r.userId == userId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (event.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: event.imageUrl!,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(context, Icons.calendar_today, _formatDate(event.date)),
                      const SizedBox(height: 8),
                      _buildInfoRow(context, Icons.location_on, event.location),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).translate('description') ?? 'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      if (isAdmin) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventRegistrationsScreen(eventId: event.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: Text(AppLocalizations.of(context).translate('view_registrations') ?? 'View Registrations'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                               // Open QR Scanner
                               final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QRScannerScreen(eventId: event.id),
                                  ),
                               );
                               if (result == true) {
                                  _refreshEvent();
                               }
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: Text(AppLocalizations.of(context).translate('verify_attendance') ?? 'Verify Attendance'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Distinct color
                            ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isRegistered ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isRegistered ? Colors.grey : Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              isRegistered 
                                ? (AppLocalizations.of(context).translate('already_registered') ?? 'Registered')
                                : (AppLocalizations.of(context).translate('register') ?? 'Register'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        if (isRegistered) ...[
                           const SizedBox(height: 12),
                           SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: _unregister,
                                child: Text(
                                  AppLocalizations.of(context).translate('cancel_registration') ?? 'Cancel Registration',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                           ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[800],
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
