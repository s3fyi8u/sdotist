import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/l10n/app_localizations.dart';

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
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_loading_news')}: $e')),
        );
      }
    }
  }

  Future<void> _deleteNews(int newsId) async {
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
                AppLocalizations.of(context).translate('delete_news_confirm'),
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Expanded(
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
        await _apiClient.dio.delete('${ApiConstants.news}$newsId');
        _fetchNews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('news_deleted'))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).translate('error_deleting_news')}: $e')),
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
        title: Text(AppLocalizations.of(context).translate('manage_news')),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewsForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout.constrainedBox(
              context,
              maxWidth: 900,
              ListView.builder(
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
            ),
    );
  }
}

/// Represents an image in the form - either an existing URL or a newly picked file
class _ImageItem {
  final String? existingUrl;  // For existing images from server
  final XFile? pickedFile;     // For newly picked images
  final Uint8List? bytes;       // Image bytes for display
  
  _ImageItem({this.existingUrl, this.pickedFile, this.bytes});
  
  bool get isExisting => existingUrl != null;
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
  
  final List<_ImageItem> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.newsItem?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.newsItem?['description'] ?? '');
    _bodyController = TextEditingController(text: widget.newsItem?['body'] ?? '');
    
    // Load existing images
    if (widget.newsItem != null) {
      final existingImages = widget.newsItem!['images'] as List<dynamic>? ?? [];
      if (existingImages.isNotEmpty) {
        for (var img in existingImages) {
          if (img is Map && img['image_url'] != null) {
            _images.add(_ImageItem(existingUrl: img['image_url'].toString()));
          }
        }
      } else if (widget.newsItem!['image'] != null) {
        // Fallback to legacy single image
        _images.add(_ImageItem(existingUrl: widget.newsItem!['image'].toString()));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      for (var image in pickedImages) {
        final bytes = await image.readAsBytes();
        setState(() {
          _images.add(_ImageItem(pickedFile: image, bytes: bytes));
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<String?> _uploadImage(_ImageItem item) async {
    if (item.isExisting) return item.existingUrl;
    
    if (item.pickedFile == null || item.bytes == null) return null;
    
    final fileName = item.pickedFile!.name;
    if (kIsWeb) {
      return await _apiClient.uploadImageBytes(item.bytes!, fileName);
    } else {
      return await _apiClient.uploadImage(item.pickedFile!.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bodyController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('body_required'))),
        );
        return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload all images and collect URLs
      final List<String> imageUrls = [];
      for (var item in _images) {
        final url = await _uploadImage(item);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'body': _bodyController.text,
        'image': imageUrls.isNotEmpty ? imageUrls[0] : null,
        'images': imageUrls,
      };

      if (widget.newsItem == null) {
        await _apiClient.dio.post(ApiConstants.news, data: data);
      } else {
        await _apiClient.dio.put('${ApiConstants.news}${widget.newsItem!['id']}', data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.newsItem == null ? AppLocalizations.of(context).translate('news_added') : AppLocalizations.of(context).translate('news_updated'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_saving_news')}: $e')),
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
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? t.translate('edit_news') : t.translate('add_news'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Images (${_images.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(t.translate('add_images')),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                t.translate('recommended_dimensions'),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 8),
              
              // Image grid / empty state
              if (_images.isEmpty)
                GestureDetector(
                  onTap: _pickImage,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to add images', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 120,
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _images.removeAt(oldIndex);
                        _images.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _images[index];
                      return Container(
                        key: ValueKey('img_$index'),
                        width: 120,
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: item.isExisting
                                    ? Image.network(
                                        item.existingUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                                      )
                                    : Image.memory(
                                        item.bytes!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            // Delete button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                            // Order badge
                            if (_images.length > 1)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: t.translate('title'),
                hint: t.translate('news_title_hint'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.translate('title_required');
                  }
                  if (value.length < 5) {
                    return t.translate('title_min_5');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: t.translate('description'),
                hint: t.translate('news_description_hint'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bodyController,
                label: t.translate('news_body'),
                hint: t.translate('news_body_hint'),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: isEditing ? t.translate('news_updated').replaceAll(' successfully', '') : t.translate('add_news'),
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
