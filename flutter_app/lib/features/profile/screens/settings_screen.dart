
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/content_card.dart';

import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_and_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _version = '';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      String? value = await _storage.read(key: 'notifications_enabled');
      if (value != null) {
        setState(() {
          _notificationsEnabled = value == 'true';
        });
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _storage.write(key: 'notifications_enabled', value: value.toString());
  }

  void _showLanguageSheet(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    t.translate('select_language'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...LocaleProvider.supportedLocales.map((locale) {
                  final langName = LocaleProvider.languageNames[locale.languageCode] ?? locale.languageCode;
                  final isSelected = localeProvider.locale.languageCode == locale.languageCode;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    title: Text(
                      langName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      localeProvider.setLocale(locale);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('settings'))),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Selector
          ContentCard(
            onTap: () => _showLanguageSheet(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      t.translate('language'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      localeProvider.currentLanguageName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                    Icon(AppLocalizations.of(context).forwardIcon, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Theme Toggle
          ContentCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      t.translate('dark_mode'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  thumbColor: WidgetStateProperty.all(isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notifications Toggle
          ContentCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                     Icon(
                      _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      t.translate('notifications'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  thumbColor: WidgetStateProperty.all(isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Change Password
          ContentCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
              title: Text(t.translate('change_password'), style: Theme.of(context).textTheme.titleMedium),
              trailing: Icon(AppLocalizations.of(context).forwardIcon, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Terms and Conditions
          ContentCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.description_outlined, color: Theme.of(context).iconTheme.color),
              title: Text(t.translate('terms_and_conditions'), style: Theme.of(context).textTheme.titleMedium),
              trailing: Icon(AppLocalizations.of(context).forwardIcon, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),

          // Privacy Policy
          ContentCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).iconTheme.color),
              title: Text(t.translate('privacy_policy'), style: Theme.of(context).textTheme.titleMedium),
              trailing: Icon(AppLocalizations.of(context).forwardIcon, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // App Version
          Center(
            child: Text(
              '${t.translate('version')} $_version',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
