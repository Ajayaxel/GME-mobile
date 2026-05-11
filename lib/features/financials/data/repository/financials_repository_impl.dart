import '../../domain/repository/financials_repository.dart';
import '../../domain/models/invoice.dart';
import '../datasource/financials_remote_datasource.dart';

class FinancialsRepositoryImpl implements FinancialsRepository {
  final FinancialsRemoteDataSource remoteDataSource;

  FinancialsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Invoice>> getInvoices() async {
    return await remoteDataSource.getInvoices();
  }
}
