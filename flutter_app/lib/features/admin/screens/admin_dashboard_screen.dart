import 'package:flutter/material.dart';
import 'manage_users_screen.dart';
import 'manage_news_screen.dart';
import 'manage_offices_screen.dart';
import 'manage_representatives_screen.dart';
import 'send_notification_screen.dart';
import 'pending_registrations_screen.dart';
import 'manage_events_screen.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/l10n/app_localizations.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('admin_dashboard')),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.translate('management'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  title: t.translate('users'),
                  icon: Icons.people_outline,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: t.translate('news'),
                  icon: Icons.article_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageNewsScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: t.translate('offices'),
                  icon: Icons.business_outlined,
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageOfficesScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: t.translate('representatives'),
                  icon: Icons.school_outlined,
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageRepresentativesScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: t.translate('notifications'),
                  icon: Icons.notifications_active_outlined,
                  color: Colors.red,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SendNotificationScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: t.translate('pending_registrations'),
                  icon: Icons.assignment_outlined,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PendingRegistrationsScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  title: t.translate('manage_events') ?? 'Events',
                  icon: Icons.calendar_today_outlined,
                  color: Colors.indigo,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageEventsScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ContentCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
