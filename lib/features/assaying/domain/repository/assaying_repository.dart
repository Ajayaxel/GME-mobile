import '../../domain/models/assaying_record.dart';

abstract class AssayingRepository {
  Future<List<AssayingRecord>> getRecords();
}
