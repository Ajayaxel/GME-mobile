import '../../domain/models/invoice.dart';

abstract class FinancialsRepository {
  Future<List<Invoice>> getInvoices();
  Future<void> createInvoice(Map<String, dynamic> data);
}
