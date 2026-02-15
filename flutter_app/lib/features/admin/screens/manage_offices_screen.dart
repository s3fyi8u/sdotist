import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class ManageOfficesScreen extends StatefulWidget {
  const ManageOfficesScreen({super.key});

  @override
  State<ManageOfficesScreen> createState() => _ManageOfficesScreenState();
}

class _ManageOfficesScreenState extends State<ManageOfficesScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _offices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOffices();
  }

  Future<void> _fetchOffices() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.get(ApiConstants.offices);
      setState(() {
        _offices = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading offices: $e')),
        );
      }
    }
  }

  Future<void> _deleteOffice(int officeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this office?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiClient.dio.delete('${ApiConstants.offices}$officeId');
        _fetchOffices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Office deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting office: $e')),
          );
        }
      }
    }
  }

  void _showOfficeForm({Map<String, dynamic>? office}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OfficeFormScreen(office: office)),
    ).then((_) => _fetchOffices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Offices'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOfficeForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offices.length,
              itemBuilder: (context, index) {
                final office = _offices[index];
                return ContentCard(
                  child: ExpansionTile(
                    leading: office['image_url'] != null
                        ? ClipOval(
                            child: Image.network(
                              office['image_url'].toString().replaceFirst('http://', 'https://').replaceFirst('sdotist.org/static', 'api.sdotist.org/static'),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.business),
                    title: Text(office['name'] ?? 'No Name'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(office['description'] ?? 'No Description'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.people),
                                  label: const Text('Members'),
                                  onPressed: () {
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ManageOfficeMembersScreen(officeId: office['id']),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showOfficeForm(office: office),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteOffice(office['id']),
                                ),
                              ],
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

class OfficeFormScreen extends StatefulWidget { // Renamed from AddOfficeScreen
  final Map<String, dynamic>? office;
  const OfficeFormScreen({super.key, this.office});

  @override
  State<OfficeFormScreen> createState() => _OfficeFormScreenState();
}

class _OfficeFormScreenState extends State<OfficeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.office?['name'] ?? '');
    _descController = TextEditingController(text: widget.office?['description'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.office?['image_url'];
      if (_imageFile != null) {
        imageUrl = await _apiClient.uploadImage(_imageFile!.path);
      }

      final data = {
        'name': _nameController.text,
        'description': _descController.text,
        'image_url': imageUrl,
      };

      if (widget.office == null) {
         await _apiClient.dio.post(ApiConstants.offices, data: data);
      } else {
         await _apiClient.dio.put('${ApiConstants.offices}${widget.office!['id']}', data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.office == null ? 'Office added successfully' : 'Office updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving office: $e')),
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
    final isEditing = widget.office != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Office' : 'Add Office')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageFile != null 
                      ? FileImage(_imageFile!) 
                      : (isEditing && widget.office!['image_url'] != null)
                          ? NetworkImage(widget.office!['image_url'].toString().replaceFirst('http://', 'https://').replaceFirst('sdotist.org/static', 'api.sdotist.org/static')) as ImageProvider
                          : null,
                  child: (_imageFile == null && (!isEditing || widget.office!['image_url'] == null)) 
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey) 
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Office Name',
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: isEditing ? 'Update Office' : 'Create Office',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageOfficeMembersScreen extends StatefulWidget {
  final int officeId;
  const ManageOfficeMembersScreen({super.key, required this.officeId});

  @override
  State<ManageOfficeMembersScreen> createState() => _ManageOfficeMembersScreenState();
}

class _ManageOfficeMembersScreenState extends State<ManageOfficeMembersScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.get('${ApiConstants.offices}${widget.officeId}');
      setState(() {
        _members = response.data['members'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showAddMemberDialog() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member management to be implemented fully based on API specifics')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Members')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: _members.length,
          itemBuilder: (context, index) {
              final member = _members[index];
              return ListTile(
                  title: Text(member['name']),
                  subtitle: Text(member['role']),
              );
          },
      ),
    );
  }
}
