import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/l10n/app_localizations.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.get(ApiConstants.register); // /users/
      setState(() {
        _users = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_loading_users')}: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
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
                AppLocalizations.of(context).translate('delete_user_confirm'),
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
        await _apiClient.dio.delete('${ApiConstants.register}$userId');
        _fetchUsers(); // Refresh list
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate('user_deleted'))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).translate('error_deleting_user')}: $e')),
          );
        }
      }
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'] ?? 'user';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context).translate('edit_user')}: ${user['name']}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('role'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          DropdownMenuItem(value: 'user', child: Text(AppLocalizations.of(context).translate('user'))),
                          DropdownMenuItem(value: 'admin', child: Text(AppLocalizations.of(context).translate('admin'))),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedRole = value);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () async {
                        Navigator.pop(context);
                        _updateUserRole(user['id'], selectedRole);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context).translate('save')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserRole(int userId, String newRole) async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.dio.put(
        '${ApiConstants.register}$userId',
        data: {'role': newRole},
      );
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('user_role_updated'))),
        );
      }
      _fetchUsers();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error_updating_user')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('manage_users')),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout.constrainedBox(
              context,
              maxWidth: 900,
              ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ContentCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['profile_image'] != null
                          ? NetworkImage(user['profile_image'].toString())
                          : null,
                      child: user['profile_image'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user['name'] ?? AppLocalizations.of(context).translate('no_name')),
                    subtitle: Text(user['email'] ?? AppLocalizations.of(context).translate('no_email')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user['role'] == 'admin')
                           const Padding(
                             padding: const EdgeInsetsDirectional.only(end: 8.0),
                             child: Chip(
                               label: Text('Admin', style: TextStyle(fontSize: 10)),
                               padding: EdgeInsets.zero,
                               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                             ),
                           ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditUserDialog(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user['id']),
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
