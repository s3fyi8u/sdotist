import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
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
                              office['image_url'].toString(),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.business),
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

class OfficeFormScreen extends StatefulWidget {
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
  XFile? _pickedImage;
  Uint8List? _imageBytes;
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
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadPickedImage() async {
    if (_pickedImage == null || _imageBytes == null) return null;
    final fileName = _pickedImage!.name;
    if (kIsWeb) {
      return await _apiClient.uploadImageBytes(_imageBytes!, fileName);
    } else {
      return await _apiClient.uploadImage(_pickedImage!.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.office?['image_url'];
      if (_pickedImage != null) {
        imageUrl = await _uploadPickedImage();
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
                  backgroundImage: _imageBytes != null 
                      ? MemoryImage(_imageBytes!) 
                      : (isEditing && widget.office!['image_url'] != null)
                          ? NetworkImage(widget.office!['image_url']) as ImageProvider
                          : null,
                  child: (_imageBytes == null && (!isEditing || widget.office!['image_url'] == null)) 
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
  
  void _showMemberForm() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberFormScreen(officeId: widget.officeId),
        ),
      ).then((_) => _fetchMembers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Members')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMemberForm,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: _members.length,
          itemBuilder: (context, index) {
              final member = _members[index];
              return ListTile(
                  leading: member['image_url'] != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(member['image_url']),
                      )
                    : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(member['name']),
                  subtitle: Text(member['position'] ?? member['role']),
              );
          },
      ),
    );
  }
}

class MemberFormScreen extends StatefulWidget {
  final int officeId;
  const MemberFormScreen({super.key, required this.officeId});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String _role = 'member';

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadPickedImage() async {
    if (_pickedImage == null || _imageBytes == null) return null;
    final fileName = _pickedImage!.name;
    if (kIsWeb) {
      return await _apiClient.uploadImageBytes(_imageBytes!, fileName);
    } else {
      return await _apiClient.uploadImage(_pickedImage!.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadPickedImage();
      }

      final data = {
        'name': _nameController.text,
        'position': _positionController.text.isNotEmpty ? _positionController.text : null,
        'email': _emailController.text.isNotEmpty ? _emailController.text : null,
        'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
        'role': _role,
        'image_url': imageUrl,
      };

      await _apiClient.dio.post('${ApiConstants.offices}${widget.officeId}/members', data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding member: $e')),
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
      appBar: AppBar(title: const Text('Add Member')),
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
                  backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                  child: _imageBytes == null
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Member Name',
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _positionController,
                label: 'Position',
                hint: 'e.g. President, Secretary',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Email Address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'member', child: Text('Member')),
                  DropdownMenuItem(value: 'head', child: Text('Head')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Add Member',
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
