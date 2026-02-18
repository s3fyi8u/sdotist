import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../core/l10n/app_localizations.dart';

class ManageRepresentativesScreen extends StatefulWidget {
  const ManageRepresentativesScreen({super.key});

  @override
  State<ManageRepresentativesScreen> createState() => _ManageRepresentativesScreenState();
}

class _ManageRepresentativesScreenState extends State<ManageRepresentativesScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _representatives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRepresentatives();
  }

  Future<void> _fetchRepresentatives() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.get(ApiConstants.representatives);
      setState(() {
        _representatives = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_loading_reps')}: $e')),
        );
      }
    }
  }

  Future<void> _deleteRepresentative(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
                AppLocalizations.of(context).translate('delete_rep_confirm'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
        await _apiClient.dio.delete('${ApiConstants.representatives}$id');
        _fetchRepresentatives();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('rep_deleted'))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).translate('error_deleting_rep')}: $e')),
          );
        }
      }
    }
  }

  void _showRepresentativeForm({Map<String, dynamic>? representative}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RepresentativeFormScreen(representative: representative)),
    ).then((_) => _fetchRepresentatives());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('manage_representatives')),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRepresentativeForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _representatives.length,
              itemBuilder: (context, index) {
                final rep = _representatives[index];
                return ContentCard(
                  child: ListTile(
                    leading: rep['image_url'] != null
                        ? ClipOval(
                            child: Image.network(
                              rep['image_url'].toString(),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            ),
                          )
                        : const Icon(Icons.person),
                    title: Text(rep['name'] ?? AppLocalizations.of(context).translate('no_name')),
                    subtitle: Text(rep['university'] ?? AppLocalizations.of(context).translate('no_university')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRepresentativeForm(representative: rep),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRepresentative(rep['id']),
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

class RepresentativeFormScreen extends StatefulWidget {
  final Map<String, dynamic>? representative;
  const RepresentativeFormScreen({super.key, this.representative});

  @override
  State<RepresentativeFormScreen> createState() => _RepresentativeFormScreenState();
}

class _RepresentativeFormScreenState extends State<RepresentativeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  final List<String> _universities = [
    'Istanbul University', 'Marmara University', 'Yildiz Technical University',
    'Istanbul Technical University', 'Bogazici University', 'Koc University',
    'Sabanci University', 'Bilgi University', 'Bahcesehir University',
    'Ozyegin University', 'Yeditepe University', 'Aydin University',
    'Medipol University', 'Gelisim University', 'Kultur University',
    'Beykent University', 'Nisantasi University', 'Altinbas University',
    'Halic University', 'Uskudar University', 'Istinye University',
    'Fenerbahce University', 'Galatasaray University', 'Mimar Sinan University',
    'Turk-Alman University', 'Saglik Bilimleri University', 'Cerrahpasa University',
    'Medeniyet University', '29 Mayis University', 'Demiroglu Bilim University',
    'Fatih Sultan Mehmet University', 'Gedik University', 'Isik University',
    'Ibn Haldun University', 'Sebahattin Zaim University', 'Ticaret University',
    'Rumeli University', 'Topkapi University', 'Yeni Yuzyil University',
    'Biruni University', 'Kent University', 'Atlas University',
  ];
  String? _selectedUniversity;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.representative?['name'] ?? '');
    _selectedUniversity = widget.representative?['university'];
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    if (_selectedUniversity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('select_university_required'))),
        );
        return;
    }
    
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.representative?['image_url'];
      if (_pickedImage != null) {
        imageUrl = await _uploadPickedImage();
      }

      final data = {
        'name': _nameController.text,
        'university': _selectedUniversity,
        'image_url': imageUrl,
      };

      if (widget.representative == null) {
        await _apiClient.dio.post(ApiConstants.representatives, data: data);
      } else {
        await _apiClient.dio.put('${ApiConstants.representatives}${widget.representative!['id']}', data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.representative == null ? AppLocalizations.of(context).translate('rep_added') : AppLocalizations.of(context).translate('rep_updated'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_saving_rep')}: $e')),
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
    final isEditing = widget.representative != null;
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? t.translate('edit_representative') : t.translate('add_representative'))),
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
                      : (isEditing && widget.representative!['image_url'] != null)
                          ? NetworkImage(widget.representative!['image_url']) as ImageProvider
                          : null,
                  child: (_imageBytes == null && (!isEditing || widget.representative!['image_url'] == null)) 
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey) 
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: t.translate('name'),
                hint: t.translate('rep_name'),
                validator: (value) => value!.isEmpty ? t.translate('name_required') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUniversity,
                decoration: InputDecoration(
                  labelText: t.translate('university'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _universities.map((uni) {
                  return DropdownMenuItem(value: uni, child: Text(uni));
                }).toList(),
                onChanged: (val) => setState(() => _selectedUniversity = val),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: isEditing ? t.translate('update_representative') : t.translate('add_representative'),
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
