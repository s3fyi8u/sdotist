import 'package:flutter/material.dart';
import '../../events/models/event_model.dart';
import '../../events/services/events_service.dart';
import '../../events/screens/create_event_screen.dart';
import '../../events/screens/event_registrations_screen.dart';
import '../../events/screens/qr_scanner_screen.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/l10n/app_localizations.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final EventsService _eventsService = EventsService();
  List<Event> _eventsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventsService.getEvents();
      setState(() {
        _eventsList = events;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('confirm_delete') ?? 'Confirm Delete'),
        content: Text(AppLocalizations.of(context).translate('delete_event_confirm') ?? 'Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).translate('delete') ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _eventsService.deleteEvent(eventId);
        _fetchEvents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('event_deleted') ?? 'Event deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting event: $e')),
          );
        }
      }
    }
  }

  void _navigateToCreateEvent({Event? event}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(eventToEdit: event),
      ),
    );
    
    if (result == true) {
      _fetchEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('manage_events') ?? 'Manage Events'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateEvent(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _eventsList.isEmpty
              ? Center(child: Text(t.translate('no_events') ?? 'No events found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _eventsList.length,
                  itemBuilder: (context, index) {
                    final event = _eventsList[index];
                    return ContentCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: event.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      event.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  )
                                : const Icon(Icons.event, size: 40),
                            title: Text(event.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${event.date.toString().substring(0, 16)} • ${event.location}'),
                                const SizedBox(height: 4),
                                Text(
                                  event.description ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: t.translate('edit') ?? 'Edit',
                                  onPressed: () => _navigateToCreateEvent(event: event),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: t.translate('delete') ?? 'Delete',
                                  onPressed: () => _deleteEvent(event.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.people, color: Colors.green),
                                  tooltip: t.translate('view_registrations') ?? 'Registrations',
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventRegistrationsScreen(eventId: event.id),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.qr_code_scanner, color: Colors.purple),
                                  tooltip: t.translate('scan_qr') ?? 'Scan QR',
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QRScannerScreen(eventId: event.id),
                                    ),
                                  ),
                                ),
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
}
