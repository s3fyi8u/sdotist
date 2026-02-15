import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class ManageNewsScreen extends StatefulWidget {
  const ManageNewsScreen({super.key});

  @override
  State<ManageNewsScreen> createState() => _ManageNewsScreenState();
}

class _ManageNewsScreenState extends State<ManageNewsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _newsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.get(ApiConstants.news);
      setState(() {
        _newsList = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading news: $e')),
        );
      }
    }
  }

  Future<void> _deleteNews(int newsId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this news item?'),
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
        await _apiClient.dio.delete('${ApiConstants.news}$newsId');
        _fetchNews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting news: $e')),
          );
        }
      }
    }
  }

  void _showNewsForm({Map<String, dynamic>? newsItem}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsFormScreen(newsItem: newsItem)),
    ).then((_) => _fetchNews());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage News'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewsForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _newsList.length,
              itemBuilder: (context, index) {
                final news = _newsList[index];
                return ContentCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: news['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              news['image'].toString(),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(Icons.article),
                    title: Text(news['title'] ?? 'No Title'),
                    subtitle: Text(
                      news['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showNewsForm(newsItem: news),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNews(news['id']),
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

class NewsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? newsItem;
  const NewsFormScreen({super.key, this.newsItem});

  @override
  State<NewsFormScreen> createState() => _NewsFormScreenState();
}

class _NewsFormScreenState extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _bodyController;
  
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.newsItem?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.newsItem?['description'] ?? '');
    _bodyController = TextEditingController(text: widget.newsItem?['body'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bodyController.dispose();
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
    if (_bodyController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('News body is required')),
        );
        return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.newsItem?['image'];
      if (_pickedImage != null) {
        imageUrl = await _uploadPickedImage();
      }

      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'body': _bodyController.text,
        'image': imageUrl,
      };

      if (widget.newsItem == null) {
        await _apiClient.dio.post(ApiConstants.news, data: data);
      } else {
        await _apiClient.dio.put('${ApiConstants.news}${widget.newsItem!['id']}', data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.newsItem == null ? 'News added successfully' : 'News updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving news: $e')),
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
    final isEditing = widget.newsItem != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit News' : 'Add News')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: _imageBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_imageBytes!),
                              fit: BoxFit.cover,
                            )
                          : (isEditing && widget.newsItem!['image'] != null)
                              ? DecorationImage(
                                  image: NetworkImage(widget.newsItem!['image']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_imageBytes == null && (!isEditing || widget.newsItem!['image'] == null))
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to add/change image', style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 4),
                              Text('Recommended: 1280×720 (16:9)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          )
                        : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter news title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  if (value.length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Short description',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bodyController,
                label: 'Body',
                hint: 'Full news content',
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: isEditing ? 'Update News' : 'Publish News',
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
