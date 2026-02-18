
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import '../../auth/screens/session_expired_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../news/screens/news_screen.dart';
import '../../executive_offices/screens/office_list_screen.dart';
import '../../university_representatives/screens/representative_list_screen.dart';
import 'notifications_screen.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/web_navigation_bar.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/screens/events_list_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Verify session/fetch profile after frame (ensures Navigator is ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final authProvider = Provider.of<AuthProvider>(context, listen: false);
       if (authProvider.isAuthenticated) {
         authProvider.fetchUserProfile().catchError((e) {
           if (e is DioException && e.response?.statusCode == 401) {
               debugPrint("Session expired (Home check). Redirecting...");
               authProvider.logout(); // Clear token to prevent loop
               // Explicitly redirect using local context to bypass potentially detached GlobalKey
               Navigator.of(context).pushNamedAndRemoveUntil('/session_expired', (route) => false);
           } else {
              debugPrint("Session check completed with error: $e");
           }
         });
       }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    _pages = <Widget>[
      const HomeTab(),
      const EventsListScreen(),
      const NewsScreen(),
      const ProfileScreen(),
    ];
    
    if (isAdmin) {
      _pages.add(const AdminDashboardScreen());
    }
    
    // Check for arguments to set initial index
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      if (args < _pages.length) {
        _selectedIndex = args;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: _buildMobileScaffold(context),
      tabletScaffold: _buildDesktopScaffold(context), // Tablet shares desktop layout for now
      desktopScaffold: _buildDesktopScaffold(context),
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          WebNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _pages.elementAt(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 
        ? AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 30,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  'sdotist',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
            ],
          )
        : null,

      body: Column(
        children: [
          Expanded(
            child: _pages.elementAt(_selectedIndex),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home),
                _buildNavItem(1, Icons.event_outlined, Icons.event),
                _buildNavItem(2, Icons.article_outlined, Icons.article),
                _buildNavItem(3, Icons.person_outline, Icons.person),
                if (Provider.of<AuthProvider>(context).isAdmin)
                  _buildNavItem(4, Icons.admin_panel_settings_outlined, Icons.admin_panel_settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Icon(
                isSelected ? filledIcon : outlineIcon,
                size: 26,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
