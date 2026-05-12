import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../utils/navigation_service.dart';
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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final message = response?.data is Map ? response?.data['message']?.toString() : response?.data?.toString();
    
    if (response?.statusCode == 401 || 
        (message != null && (message.contains('Not authorized') || message.contains('token failed')))) {
      // Clear token and other data
      await storageService.clearAll();
      
      // Navigate to login screen
      final context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
    super.onError(err, handler);
  }
}
