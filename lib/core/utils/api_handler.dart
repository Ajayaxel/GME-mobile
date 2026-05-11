import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

typedef FutureCall<T> = Future<T> Function();

class ApiHandler {
  /// Wraps a Future call to handle errors globally and return an Either<Failure, T>
  static Future<Either<Failure, T>> safeApiCall<T>(FutureCall<T> call) async {
    try {
      final response = await call();
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
