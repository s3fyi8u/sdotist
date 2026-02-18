import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/l10n/app_localizations.dart';

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
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_loading_offices')}: $e')),
        );
      }
    }
  }

  Future<void> _deleteOffice(int officeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('confirm_delete'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).translate('delete_office_confirm'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context).translate('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context).translate('delete')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _apiClient.dio.delete('${ApiConstants.offices}$officeId');
        _fetchOffices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('office_deleted'))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).translate('error_deleting_office')}: $e')),
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
        title: Text(AppLocalizations.of(context).translate('manage_offices')),
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
                            Text(office['description'] ?? AppLocalizations.of(context).translate('no_description')),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.people),
                                  label: Text(AppLocalizations.of(context).translate('members')),
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
          SnackBar(content: Text(widget.office == null ? AppLocalizations.of(context).translate('office_added') : AppLocalizations.of(context).translate('office_updated'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_saving_office')}: $e')),
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
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? t.translate('edit_office') : t.translate('add_office'))),
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
                label: t.translate('name'),
                hint: t.translate('office_name'),
                validator: (value) => value!.isEmpty ? t.translate('name_required') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descController,
                label: t.translate('description'),
                hint: t.translate('description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: isEditing ? t.translate('update_office') : t.translate('create_office'),
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
  
  void _showMemberForm({Map<String, dynamic>? member}) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberFormScreen(
            officeId: widget.officeId,
            member: member,
          ),
        ),
      ).then((_) => _fetchMembers());
  }

  Future<void> _deleteMember(int memberId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('confirm_delete'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).translate('delete_member_confirm'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context).translate('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context).translate('delete')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _apiClient.dio.delete('${ApiConstants.offices}${widget.officeId}/members/$memberId');
        _fetchMembers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('member_deleted'))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).translate('error_deleting_member')}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('manage_members'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMemberForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _members.isEmpty
        ? Center(child: Text(AppLocalizations.of(context).translate('no_members')))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _members.length,
          itemBuilder: (context, index) {
              final member = _members[index];
                  final t = AppLocalizations.of(context);
                  final role = member['role'] ?? 'member';
                  return ContentCard(
                  child: ListTile(
                    leading: member['image_url'] != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(member['image_url']),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(member['name']),
                    subtitle: Text(member['position'] ?? t.translate(role)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showMemberForm(member: member),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMember(member['id']),
                      ),
                    ],
                  ),
                ),
              );
          },
      ),
    );
  }
}

class MemberFormScreen extends StatefulWidget {
  final int officeId;
  final Map<String, dynamic>? member;
  const MemberFormScreen({super.key, required this.officeId, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  late String _role;

  bool get isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?['name'] ?? '');
    _positionController = TextEditingController(text: widget.member?['position'] ?? '');
    _emailController = TextEditingController(text: widget.member?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.member?['phone'] ?? '');
    _role = widget.member?['role'] ?? 'member';
  }

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
      String? imageUrl = widget.member?['image_url'];
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

      if (isEditing) {
        await _apiClient.dio.put(
          '${ApiConstants.offices}${widget.officeId}/members/${widget.member!['id']}',
          data: data,
        );
      } else {
        await _apiClient.dio.post(
          '${ApiConstants.offices}${widget.officeId}/members',
          data: data,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? AppLocalizations.of(context).translate('member_updated') : AppLocalizations.of(context).translate('member_added'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_saving_member')}: $e')),
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
      appBar: AppBar(title: Text(isEditing ? t.translate('edit_member') : t.translate('add_member'))),
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
                      : (isEditing && widget.member!['image_url'] != null)
                          ? NetworkImage(widget.member!['image_url']) as ImageProvider
                          : null,
                  child: (_imageBytes == null && (!isEditing || widget.member!['image_url'] == null))
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: t.translate('name'),
                hint: t.translate('member_name'),
                validator: (value) => value!.isEmpty ? t.translate('name_required') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _positionController,
                label: t.translate('position'),
                hint: t.translate('position_hint'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: t.translate('email'),
                hint: t.translate('email_address'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: t.translate('phone'),
                hint: t.translate('phone_number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(labelText: t.translate('member_role')),
                items: [
                  DropdownMenuItem(value: 'member', child: Text(t.translate('member'))),
                  DropdownMenuItem(value: 'head', child: Text(t.translate('head'))),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: isEditing ? t.translate('update_member') : t.translate('add_member'),
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
