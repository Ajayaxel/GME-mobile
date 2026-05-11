import '../../domain/models/export_record.dart';

abstract class ExportRepository {
  Future<List<ExportRecord>> getRecords();
}
