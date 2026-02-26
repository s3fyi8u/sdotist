import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class WebFooter extends StatelessWidget {
  final Function(int)? onNavTap;

  const WebFooter({super.key, this.onNavTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // ── Main Footer Content ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column 1: Association info
                          Expanded(flex: 3, child: _buildBrandColumn(context, t)),
                          const SizedBox(width: 32),
                          // Column 2: Quick Links
                          Expanded(flex: 2, child: _buildQuickLinksColumn(context, t)),
                          const SizedBox(width: 32),
                          // Column 3: Services
                          Expanded(flex: 2, child: _buildServicesColumn(context, t)),
                          const SizedBox(width: 32),
                          // Column 4: Contact
                          Expanded(flex: 2, child: _buildContactColumn(context, t)),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBrandColumn(context, t),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildQuickLinksColumn(context, t)),
                              Expanded(child: _buildServicesColumn(context, t)),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildContactColumn(context, t),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),

          // ── Divider ───────────────────────────────────────
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),

          // ── Copyright ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Text(
              '© 2026 رابطة الطلاب السودانيين في إسطنبول. جميع الحقوق محفوظة.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ── Column 1: Brand ───────────────────────────────────────
  Widget _buildBrandColumn(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            const Text(
              'الرابطة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'رابطة الطلاب السودانيين في إسطنبول',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Column 2: Quick Links ─────────────────────────────────
  Widget _buildQuickLinksColumn(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'روابط سريعة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _footerLink(t.translate('welcome_home_title'), () => onNavTap?.call(0)),
        const SizedBox(height: 10),
        _footerLink(t.translate('events'), () => onNavTap?.call(2)),
        const SizedBox(height: 10),
        _footerLink(t.translate('news'), () => onNavTap?.call(1)),
      ],
    );
  }

  // ── Column 3: Services ────────────────────────────────────
  Widget _buildServicesColumn(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('services'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _footerLink(t.translate('profile'), () => onNavTap?.call(3)),
        const SizedBox(height: 10),
        _footerLink(t.translate('help_support'), null),
        const SizedBox(height: 10),
        _footerLink(t.translate('about_us'), () => onNavTap?.call(0)),
      ],
    );
  }

  // ── Column 4: Contact ─────────────────────────────────────
  Widget _buildContactColumn(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('contact_us'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'info@sdotist.org',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ── Footer Link Item ──────────────────────────────────────
  Widget _footerLink(String text, VoidCallback? onTap) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
