import '../../domain/models/export_record.dart';

abstract class ExportRepository {
  Future<List<ExportRecord>> getRecords();
  Future<void> createRecord(Map<String, dynamic> data);
  Future<void> uploadDocument(String id, String docKey, String filePath);
  Future<void> deleteDocument(String id, String docKey);
}
