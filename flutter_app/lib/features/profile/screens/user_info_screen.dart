
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/content_card.dart';

class UserInfoScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserInfoScreen({super.key, required this.userData});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late Map<String, dynamic> _userData;
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
  }

  Future<void> _updateProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      // 1. Upload Image (web-compatible)
      String? imageUrl;
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        imageUrl = await _apiClient.uploadImageBytes(bytes, pickedFile.name);
      } else {
        imageUrl = await _apiClient.uploadImage(pickedFile.path);
      }
      
      if (imageUrl != null) {
        // 2. Update User Profile
        await _apiClient.dio.put(
          ApiConstants.me,
          data: {'profile_image': imageUrl},
        );

        // 3. Update Local State
        setState(() {
          _userData['profile_image'] = imageUrl;
        });
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully!')),
          );
        }
      } else {
        throw Exception("Failed to upload image");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating image: $e')),
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
      appBar: AppBar(title: const Text('User Information')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Image with Edit Icon
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _userData['profile_image'] != null
                          ? CachedNetworkImageProvider(
                              _userData['profile_image'].toString()
                            )
                          : null,
                      child: _userData['profile_image'] == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _updateProfileImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Info Tiles
              _buildInfoTile(context, Icons.person, 'Name', _userData['name']),
              _buildInfoTile(context, Icons.email, 'Email', _userData['email']),
              _buildInfoTile(context, Icons.cake, 'Date of Birth', _userData['date_of_birth']),
              _buildInfoTile(context, Icons.school, 'University', _userData['university']),
              _buildInfoTile(context, Icons.workspace_premium, 'Degree', _userData['degree']),
              _buildInfoTile(context, Icons.book, 'Specialization', _userData['specialization']),
              _buildInfoTile(context, Icons.calendar_today, 'Academic Year', _userData['academic_year']),
            ],
          ),
        ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return ContentCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          value, 
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
