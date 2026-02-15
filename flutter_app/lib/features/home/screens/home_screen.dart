import 'package:flutter/material.dart';
import '../../profile/screens/profile_screen.dart';
import '../../news/screens/news_screen.dart';
import '../../executive_offices/screens/office_list_screen.dart';
import '../../university_representatives/screens/representative_list_screen.dart';
import 'notifications_screen.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/web_navigation_bar.dart';
import '../../../core/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = <Widget>[
      Center(child: Text(AppLocalizations.of(context).translate('welcome_home'), style: const TextStyle(fontSize: 24))), // Home Placeholder
      const NewsScreen(),
      const ProfileScreen(),
    ];
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.menu, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  offset: const Offset(0, 50),
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                  onSelected: (value) {
                    if (value == 'offices') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfficeListScreen()),
                      );
                    } else if (value == 'representatives') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RepresentativeListScreen()),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final iconColor = isDark ? Colors.white : Colors.black;
                    final containerColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

                    return [
                      PopupMenuItem<String>(
                        value: 'offices',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: containerColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.business_outlined, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(AppLocalizations.of(context).translate('executive_offices'), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'representatives',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: containerColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.school_outlined, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(AppLocalizations.of(context).translate('university_representatives'), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
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
                _buildNavItem(1, Icons.article_outlined, Icons.article),
                _buildNavItem(2, Icons.person_outline, Icons.person),
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
