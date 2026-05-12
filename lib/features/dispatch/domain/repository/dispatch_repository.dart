import '../../domain/models/dispatch_record.dart';

abstract class DispatchRepository {
  Future<List<DispatchRecord>> getRecords();
  Future<DispatchRecord> createRecord(Map<String, dynamic> record);
  Future<void> deleteRecord(String id);
}
