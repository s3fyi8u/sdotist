import 'package:flutter/material.dart';
import '../errors/app_error.dart';
import '../errors/error_mapper.dart';
import '../l10n/app_localizations.dart';

class ErrorScreen extends StatefulWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onLogin;
  final VoidCallback? onGoBack;

  const ErrorScreen({
    super.key,
    required this.error,
    this.onRetry,
    this.onLogin,
    this.onGoBack,
  });

  // Factory constructor to create from raw exception
  factory ErrorScreen.fromException(dynamic exception, {VoidCallback? onRetry}) {
    return ErrorScreen(
      error: ErrorMapper.map(exception),
      onRetry: onRetry,
    );
  }

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available and build is finished
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.error.type == AppErrorType.unauthorized || 
          widget.error.type == AppErrorType.forbidden) {
        _handleUnauthorized();
      }
    });
  }

  void _handleUnauthorized() {
    if (widget.onLogin != null) {
      widget.onLogin!();
    } else {
      // Clear stack and go to login to prevent going back to restricted page
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If unauthorized, show nothing effectively (or a loader) while redirecting
    if (widget.error.type == AppErrorType.unauthorized || 
        widget.error.type == AppErrorType.forbidden) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.onGoBack != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: widget.onGoBack,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(context),
            const SizedBox(height: 32),
            Text(
              widget.error.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.error.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (widget.error.type) {
      case AppErrorType.network:
        icon = Icons.wifi_off_rounded;
        color = Colors.orange;
        break;
      case AppErrorType.server:
        icon = Icons.dns_rounded;
        color = Colors.red;
        break;
      case AppErrorType.unauthorized:
        icon = Icons.lock_person_rounded;
        color = Colors.blue;
        break;
      case AppErrorType.forbidden:
        icon = Icons.block_rounded;
        color = Colors.red;
        break;
      case AppErrorType.notFound:
        icon = Icons.search_off_rounded;
        color = Colors.grey;
        break;
      case AppErrorType.timeout:
        icon = Icons.timer_off_rounded;
        color = Colors.orange;
        break;
      case AppErrorType.unknown:
      default:
        icon = Icons.error_outline_rounded;
        color = Colors.grey;
        break;
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (widget.error.retryable && widget.onRetry != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: widget.onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).translate('try_again')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
