import '../../domain/models/assaying_record.dart';

abstract class AssayingRepository {
  Future<List<AssayingRecord>> getRecords();
  Future<void> createSample(Map<String, dynamic> data);
  Future<void> deleteSample(String id);
}
