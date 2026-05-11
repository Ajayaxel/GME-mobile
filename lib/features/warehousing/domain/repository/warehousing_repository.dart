import '../../domain/models/bagging_record.dart';

abstract class WarehousingRepository {
  Future<List<BaggingRecord>> getRecords();
}
