import 'package:flutter/material.dart';
import '../errors/app_error.dart';
import '../errors/error_mapper.dart';

class ErrorScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onGoBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: onGoBack,
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
              error.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
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

    switch (error.type) {
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
    if (error.type == AppErrorType.unauthorized) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onLogin ?? () => Navigator.pushNamed(context, '/login'),
          icon: const Icon(Icons.login),
          label: const Text('Login Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (error.retryable && onRetry != null) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
