import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../services/events_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../upload/services/upload_service.dart'; 

import '../models/event_model.dart';
// ... previous imports ...

class CreateEventScreen extends StatefulWidget {
  final Event? eventToEdit;
  const CreateEventScreen({super.key, this.eventToEdit});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  final _eventsService = EventsService();
  final _uploadService = UploadService();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.eventToEdit?.description ?? '');
    _locationController = TextEditingController(text: widget.eventToEdit?.location ?? '');
    
    if (widget.eventToEdit != null) {
      _selectedDate = widget.eventToEdit!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.eventToEdit!.date);
      _imageUrl = widget.eventToEdit!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        // Upload the image
        // Assuming UploadService has a method to upload XFile or File
        // Based on typical implementation in this project
        // We'll use the uploadService instance we created
        final String url = await _uploadService.uploadImage(image);
        
        setState(() {
          _imageUrl = url;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
      setState(() => _isLoading = true);
      try {
        final DateTime eventDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        if (widget.eventToEdit == null) {
          await _eventsService.createEvent(
            _titleController.text,
            _descriptionController.text,
            eventDateTime,
            _locationController.text,
            imageUrl: _imageUrl,
          );
        } else {
          await _eventsService.updateEvent(
            widget.eventToEdit!.id,
            _titleController.text,
            _descriptionController.text,
            eventDateTime,
            _locationController.text,
            imageUrl: _imageUrl,
          );
        }

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
              widget.eventToEdit == null 
                  ? (AppLocalizations.of(context).translate('event_created') ?? 'Event created')
                  : (AppLocalizations.of(context).translate('event_updated') ?? 'Event updated')
            )),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
// ... error handling ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('create_event') ?? 'Create Event')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: _imageUrl != null
                              ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageUrl == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(AppLocalizations.of(context).translate('pick_image') ?? 'Pick Image'),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('event_title') ?? 'Title'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('event_description') ?? 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('event_location') ?? 'Location'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_selectedDate == null
                          ? (AppLocalizations.of(context).translate('select_event_date') ?? 'Select Date & Time')
                          : "${_selectedDate!.toLocal().toString().split(' ')[0]} ${_selectedTime?.format(context) ?? ''}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(AppLocalizations.of(context).translate('create') ?? 'Create'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
