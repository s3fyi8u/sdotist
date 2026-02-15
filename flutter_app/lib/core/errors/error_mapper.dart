import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'app_error.dart';

class ErrorMapper {
  static AppError map(dynamic error) {
    if (error is DioException) {
      return _mapDioError(error);
    } else if (error is SocketException) {
      return AppError(
        title: 'No Internet Connection',
        message: 'Please check your internet connection and try again.',
        type: AppErrorType.network,
      );
    } else if (error is TimeoutException) {
      return AppError(
        title: 'Connection Timed Out',
        message: 'The connection is too slow. Please try again later.',
        type: AppErrorType.timeout,
      );
    } else if (error is AppError) {
      return error;
    } else {
      return AppError(
        title: 'Something went wrong',
        message: 'An unexpected error occurred. Please try again.',
        type: AppErrorType.unknown,
        originalException: error,
      );
    }
  }

  static AppError _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          title: 'Connection Timed Out',
          message: 'The server is taking too long to respond.',
          type: AppErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return AppError(
          title: 'Connection Error',
          message: 'Unable to connect to the server. Please check your internet.',
          type: AppErrorType.network,
        );
      case DioExceptionType.badResponse:
        return _mapBadResponse(error);
      case DioExceptionType.cancel:
        return AppError(
          title: 'Request Cancelled',
          message: 'The request was cancelled.',
          type: AppErrorType.unknown,
          retryable: false,
        );
      default:
        return AppError(
          title: 'Network Error',
          message: 'A network error occurred. Please try again.',
          type: AppErrorType.network,
        );
    }
  }

  static AppError _mapBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    
    // Try to get message from server response if available
    String? serverMessage;
    if (data is Map && data.containsKey('detail')) {
      serverMessage = data['detail'].toString();
    }

    switch (statusCode) {
      case 401:
        return AppError(
          title: 'Authentication Failed',
          message: serverMessage ?? 'You need to login to perform this action.',
          type: AppErrorType.unauthorized,
          retryable: false, 
        );
      case 403:
        return AppError(
          title: 'Access Denied',
          message: serverMessage ?? 'You do not have permission to access this resource.',
          type: AppErrorType.forbidden,
          retryable: false,
        );
      case 404:
        return AppError(
          title: 'Not Found',
          message: 'The requested resource was not found.',
          type: AppErrorType.notFound,
          retryable: false,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return AppError(
          title: 'Server Error',
          message: 'Our servers are currently experiencing issues. Please try again later.',
          type: AppErrorType.server,
        );
      default:
        return AppError(
          title: 'Error ${statusCode ?? ""}',
          message: serverMessage ?? 'An unexpected error occurred.',
          type: AppErrorType.unknown,
        );
    }
  }
}
