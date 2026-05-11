import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiInterceptor extends Interceptor {
  final StorageService storageService;

  ApiInterceptor({required this.storageService});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
