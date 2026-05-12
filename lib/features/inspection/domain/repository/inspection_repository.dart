import '../../domain/models/inspection_record.dart';

abstract class InspectionRepository {
  Future<List<InspectionRecord>> getRecords();
  Future<void> createInspection(Map<String, dynamic> data);
  Future<void> deleteInspection(String id);
}
