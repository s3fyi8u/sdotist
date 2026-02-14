enum AppErrorType {
  network,
  server,
  unauthorized,
  forbidden,
  notFound,
  timeout,
  unknown,
}

class AppError {
  final String title;
  final String message;
  final AppErrorType type;
  final bool retryable;
  final dynamic originalException;

  AppError({
    required this.title,
    required this.message,
    required this.type,
    this.retryable = true,
    this.originalException,
  });

  @override
  String toString() => 'AppError(title: $title, message: $message, type: $type)';
}
