import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred']);
}

/// Global Error Handler to convert catch blocks/exceptions to Failures
class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Failure) {
      return error;
    } else {
      return UnknownFailure(error.toString());
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final dynamic responseData = error.response?.data;
        String message = 'A server error occurred';

        try {
          if (responseData is Map) {
            message = (responseData['message'] ?? responseData['error'] ?? error.message ?? message).toString();
          } else if (responseData is String && responseData.isNotEmpty) {
            message = responseData;
          } else if (error.message != null) {
            message = error.message!;
          }
        } catch (_) {
          message = error.message ?? message;
        }
        
        if (statusCode == 401 || statusCode == 403) {
          return AuthFailure(message);
        } else if (statusCode == 422) {
          return ValidationFailure(message);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure('Server Error ($statusCode)');
        }
        return ServerFailure(message);
      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled');
      default:
        return const UnknownFailure();
    }
  }
}
