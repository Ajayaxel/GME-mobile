import '../models/bagging_record.dart';

abstract class BaggingRepository {
  Future<List<BaggingRecord>> getAllEntries();
  Future<BaggingRecord> createEntry(Map<String, dynamic> entryData);
  Future<void> deleteEntry(String id);
}
