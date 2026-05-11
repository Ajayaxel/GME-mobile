import '../../domain/repository/transportation_repository.dart';
import '../../domain/models/transporter.dart';
import '../datasource/transportation_remote_datasource.dart';

class TransportationRepositoryImpl implements TransportationRepository {
  final TransportationRemoteDataSource remoteDataSource;

  TransportationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Transporter>> getTransporters() async {
    return await remoteDataSource.getTransporters();
  }
}
