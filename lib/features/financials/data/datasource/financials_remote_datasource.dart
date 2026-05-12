import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/invoice.dart';

abstract class FinancialsRemoteDataSource {
  Future<List<Invoice>> getInvoices();
  Future<void> createInvoice(Map<String, dynamic> data);
}

class FinancialsRemoteDataSourceImpl implements FinancialsRemoteDataSource {
  final Dio dio;

  FinancialsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await dio.get(ApiConstants.invoices);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load invoices");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> createInvoice(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.invoices, data: data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.response?.data?['error'] ?? e.message ?? "Failed to create invoice";
      throw Exception(message);
    }
  }
}
