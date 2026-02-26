import 'package:flutter/material.dart';
import '../../features/auth/screens/register_screen.dart';
import '../l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── LEFT: Logo + Association Name ──────────────────
          InkWell(
            onTap: () => onItemTapped(0),
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logoo.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.translate('home_main_title'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      t.translate('home_main_subtitle'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── CENTER: Navigation Links (text only) ──────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavBarItem(
                title: t.translate('about_us'),
                isActive: false,
                onTap: () => onItemTapped(0), // scrolls to about section
              ),
              const SizedBox(width: 28),
              _NavBarItem(
                title: t.translate('members'),
                isActive: selectedIndex == 3,
                onTap: () => onItemTapped(3),
              ),
              const SizedBox(width: 28),
              _NavBarItem(
                title: t.translate('news'),
                isActive: selectedIndex == 1,
                onTap: () => onItemTapped(1),
              ),
              const SizedBox(width: 28),
              _NavBarItem(
                title: t.translate('events'),
                isActive: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
              const SizedBox(width: 28),
              _NavBarItem(
                title: t.translate('welcome_home_title'),
                isActive: selectedIndex == 0,
                onTap: () => onItemTapped(0),
              ),
            ],
          ),

          const Spacer(),

          // ── RIGHT: Notification + Register Button ─────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                  size: 22,
                ),
                onPressed: () {
                  // Navigate to notifications
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  t.translate('register_membership'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black87;
    final inactiveColor = isDark ? Colors.white60 : Colors.grey.shade600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
              color: widget.isActive || _isHovered ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}
