import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/executive_offices/screens/office_list_screen.dart';
import '../../features/university_representatives/screens/representative_list_screen.dart';
import '../constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WebNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const WebNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo Section
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 40,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 12),
              Text(
                'sdotist',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          
          const Spacer(),

          // Center Navigation Links
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavBarItem(
                title: 'Home',
                icon: Icons.home_outlined,
                isActive: selectedIndex == 0,
                onTap: () => onItemTapped(0),
              ),
              const SizedBox(width: 30),
              _NavBarItem(
                title: 'News',
                icon: Icons.article_outlined,
                isActive: selectedIndex == 1,
                onTap: () => onItemTapped(1),
              ),
              const SizedBox(width: 30),
              _NavBarItem(
                title: 'Profile',
                icon: Icons.person_outline,
                isActive: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
            ],
          ),

          const Spacer(),

          // Right Side Actions
          Row(
            children: [
              // Dropdowns for extra features
               PopupMenuButton<String>(
                tooltip: 'More',
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.grid_view, size: 20, color: isDark ? Colors.white : Colors.black),
                ),
                onSelected: (value) {
                  if (value == 'offices') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OfficeListScreen()));
                  } else if (value == 'representatives') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RepresentativeListScreen()));
                  }
                },
                itemBuilder: (context) => [
                   PopupMenuItem(
                    value: 'offices',
                    child: Row(
                      children: const [
                        Icon(Icons.business_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Executive Offices'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'representatives',
                    child: Row(
                      children: const [
                        Icon(Icons.school_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('University Representatives'),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 20),

              // Auth State
              if (authProvider.isAuthenticated)
                _buildUserProfile(context)
              else
                Row(
                  children: [
                     TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Login'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    // This could fetch realtime user data if stored in provider, 
    // for simplicity we show a generic avatar or placeholder until profile loads
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
      child: const CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 20, color: Colors.white),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive 
        ? Theme.of(context).primaryColor 
        : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]);
        
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive ? BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ) : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
