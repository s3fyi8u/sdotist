import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PendingRegistrationsScreen extends StatefulWidget {
  const PendingRegistrationsScreen({super.key});

  @override
  State<PendingRegistrationsScreen> createState() => _PendingRegistrationsScreenState();
}

class _PendingRegistrationsScreenState extends State<PendingRegistrationsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingRegistrations();
  }

  Future<void> _fetchPendingRegistrations() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.dio.get(ApiConstants.pendingRegistrations);
      setState(() {
        _pendingUsers = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _approveUser(int userId) async {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, size: 40, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                t.translate('confirm_approve'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                t.translate('approve_user_confirm'),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                      ),
                      child: Text(
                        t.translate('cancel'),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(t.translate('approve')),
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
        await _apiClient.dio.post(ApiConstants.approveRegistration(userId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('user_approved')),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        _fetchPendingRegistrations();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectUser(int userId) async {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Text(
                t.translate('confirm_reject'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                t.translate('reject_user_confirm'),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                      ),
                      child: Text(
                        t.translate('cancel'),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(t.translate('reject')),
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
        await _apiClient.dio.post(ApiConstants.rejectRegistration(userId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('user_rejected')),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        _fetchPendingRegistrations();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Future<void> _viewDocument(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('pending_registrations')),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.translate('no_data'),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPendingRegistrations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingUsers.length,
                    itemBuilder: (context, index) {
                      final user = _pendingUsers[index];
                      return ContentCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Info
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                    backgroundImage: user['profile_image'] != null
                                        ? NetworkImage(user['profile_image'])
                                        : null,
                                    child: user['profile_image'] == null
                                        ? Text(
                                            (user['name'] ?? '?')[0].toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['name'] ?? t.translate('no_name'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          user['email'] ?? t.translate('no_email'),
                                          style: TextStyle(
                                            color: isDark ? Colors.white54 : Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Academic Info
                              if (user['university'] != null) ...[
                                _buildInfoRow(
                                  Icons.school_outlined,
                                  user['university'],
                                  isDark,
                                ),
                                const SizedBox(height: 4),
                              ],
                              if (user['degree'] != null) ...[
                                _buildInfoRow(
                                  Icons.badge_outlined,
                                  '${user['degree']} ${user['academic_year'] != null ? '- Year ${user['academic_year']}' : ''}',
                                  isDark,
                                ),
                                const SizedBox(height: 4),
                              ],
                              if (user['specialization'] != null && user['specialization'].toString().isNotEmpty) ...[
                                _buildInfoRow(
                                  Icons.book_outlined,
                                  user['specialization'],
                                  isDark,
                                ),
                                const SizedBox(height: 4),
                              ],

                              const Divider(height: 24),

                              // Document & Actions
                              Row(
                                children: [
                                  // View Document Button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: user['document_url'] != null
                                          ? () => _viewDocument(user['document_url'])
                                          : null,
                                      icon: const Icon(Icons.description_outlined, size: 18),
                                      label: Text(
                                        t.translate('view_document'),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Reject Button
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () => _rejectUser(user['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: Text(t.translate('reject'), style: const TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Approve Button
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () => _approveUser(user['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: Text(t.translate('approve'), style: const TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                ],
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

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
