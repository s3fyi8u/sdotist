import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
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
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('confirm_delete')),
        content: Text(AppLocalizations.of(context).translate('delete_user_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
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
      builder: (context) => AlertDialog(
        title: Text('${AppLocalizations.of(context).translate('edit_user')}: ${user['name']}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('role')),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _updateUserRole(user['id'], selectedRole);
            },
            child: Text(AppLocalizations.of(context).translate('save')),
          ),
        ],
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
          : ListView.builder(
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
    );
  }
}
