import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/events_service.dart';
import '../../../core/l10n/app_localizations.dart';

class EventRegistrationsScreen extends StatefulWidget {
  final int eventId;

  const EventRegistrationsScreen({super.key, required this.eventId});

  @override
  State<EventRegistrationsScreen> createState() => _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen> {
  final EventsService _eventsService = EventsService();
  late Future<List<EventRegistration>> _registrationsFuture;

  @override
  void initState() {
    super.initState();
    _registrationsFuture = _eventsService.getEventRegistrations(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('registrations') ?? 'Registrations'),
      ),
      body: FutureBuilder<List<EventRegistration>>(
        future: _registrationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).translate('no_data') ?? 'No registrations'));
          }

          final registrations = snapshot.data!;
          return ListView.builder(
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: registration.user.profileImage != null 
                    ? NetworkImage(registration.user.profileImage!) 
                    : null,
                  child: registration.user.profileImage == null 
                    ? const Icon(Icons.person) 
                    : null,
                ),
                title: Text(registration.user.name),
                subtitle: Text(registration.user.email),
                trailing: registration.attended
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.circle_outlined, color: Colors.grey),
              );
            },
          );
        },
      ),
    );
  }
}
