import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined, 
            size: 100, 
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('welcome_home') ?? 'Welcome Home! 🏠',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
