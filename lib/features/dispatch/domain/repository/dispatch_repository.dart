import '../../domain/models/dispatch_record.dart';

abstract class DispatchRepository {
  Future<List<DispatchRecord>> getRecords();
}
