import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/api/api_client.dart';


import 'user_info_screen.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/error_screen.dart';

import 'settings_screen.dart';
import '../../../core/widgets/content_card.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ... state variables and methods remain the same (`_userData`, `_updateProfileImage`, etc.)
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  AppError? _error;
  final ApiClient _apiClient = ApiClient();


  @override
  void initState() {
    super.initState();
    // Defer profile fetch to after build or check auth first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
        _fetchProfile();
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.dio.get(ApiConstants.me);
      
      setState(() {
        _userData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        if (e is DioException && e.response?.statusCode == 401) {
           // Let 401 be handled by logic or ErrorMapper if preferred.
           // Existing logic: logout and clear data.
           // ErrorMapper can also handle this if we want to show a screen.
           // For Profile, let's keep the guest UI logic or map it.
           // If we map it to AppError.unauthorized, ErrorScreen has a Login button.
        }
        
        setState(() {
          _isLoading = false;
          _error = ErrorMapper.map(e);
        });
      }
    }
  }



  Future<void> _refreshProfile() async {
    // Check auth status again
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      if (_userData == null) {
          setState(() => _isLoading = true);
          _fetchProfile();
      }
    } else {
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Auto-fetch profile if authenticated but no data and not loading/error
    if (authProvider.isAuthenticated && _userData == null && !_isLoading && _error == null) {
       // Avoid calling setState in build, utilize addPostFrameCallback
       WidgetsBinding.instance.addPostFrameCallback((_) {
         _refreshProfile();
       });
    }

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null && _userData == null) {
       // Only show error screen if we don't have user data (initially)
       return ErrorScreen(error: _error!, onRetry: _fetchProfile);
    }

    if (!authProvider.isAuthenticated) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'You are not logged in',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Login or create an account to view your profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.pushNamed(context, '/login')
                             .then((_) => _refreshProfile());
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                        ),
                      ),
                      onPressed: () {
                          Navigator.pushNamed(context, '/register')
                              .then((_) => _refreshProfile());
                      },
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false, // Align to left
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Header & Barcode
                      ContentCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Side: Profile Pic + Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_userData!['profile_image'] != null) {
                                        _showEnlargedImage(
                                          context, 
                                          _userData!['profile_image'], 
                                          "Profile Picture",
                                          isCircular: true,
                                        );
                                      }
                                    },
                                    child: Hero(
                                      tag: 'profile_image',
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: _userData!['profile_image'] != null
                                            ? CachedNetworkImageProvider(
                                                _userData!['profile_image'].toString()
                                                .replaceFirst('http://', 'https://')
                                                .replaceFirst('sdotist.org/static', 'api.sdotist.org/static')
                                              )
                                            : null,
                                        child: _userData!['profile_image'] == null
                                            ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _userData!['name'] ?? 'No Name',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userData!['university'] ?? 'No University',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userData!['specialization'] ?? 'No Specialization',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Right Side: Barcode
                            FutureBuilder<Response<List<int>>>(
                              future: _apiClient.dio.get<List<int>>(
                                ApiConstants.myBarcode,
                                options: Options(responseType: ResponseType.bytes),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(height: 80, width: 80, child: Center(child: CircularProgressIndicator()));
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  return const SizedBox(
                                    height: 100, width: 100, 
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.qr_code_2, size: 40, color: Colors.grey),
                                        Text("Unavailable", style: TextStyle(fontSize: 10)),
                                      ],
                                    )
                                  );
                                }
                                
                                final imageBytes = Uint8List.fromList(snapshot.data!.data!);
                                
                                return GestureDetector(
                                  onTap: () {
                                     showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Image.memory(imageBytes, fit: BoxFit.contain),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'qr_code',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        imageBytes,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Menu Items
                      Column(
                        children: [
                          if (authProvider.isAdmin) ...[
                            ContentCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdminDashboardScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          ContentCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserInfoScreen(userData: _userData!),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white.withValues(alpha: 0.1) 
                                        : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.person_outline, 
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : Colors.black
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                          
                          ContentCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white.withValues(alpha: 0.1) 
                                        : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.settings_outlined, 
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : Colors.black
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                             authProvider.logout();
                             Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red.withValues(alpha: 0.05),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showEnlargedImage(BuildContext context, String imageUrl, String title, {Map<String, String>? headers, bool isCircular = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4,
                      child: isCircular 
                      ? AspectRatio(
                          aspectRatio: 1,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: imageUrl.replaceFirst('http://', 'https://').replaceFirst('sdotist.org/static', 'api.sdotist.org/static'),
                              httpHeaders: headers,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    Text(error.toString(), style: const TextStyle(fontSize: 8), textAlign: TextAlign.center),
                                    Text(url, style: const TextStyle(fontSize: 8, color: Colors.blue), textAlign: TextAlign.center),
                                  ],
                                ),
                            ),
                          ),
                        )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl.replaceFirst('http://', 'https://').replaceFirst('sdotist.org/static', 'api.sdotist.org/static'),
                          httpHeaders: headers,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    Text(error.toString(), style: const TextStyle(fontSize: 8), textAlign: TextAlign.center),
                                    Text(url, style: const TextStyle(fontSize: 8, color: Colors.blue), textAlign: TextAlign.center),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
