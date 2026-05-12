import '../models/processing_batch.dart';

abstract class ProcessingRepository {
  Future<List<ProcessingBatch>> getProcessingBatches();
  Future<void> createProcessingBatch(Map<String, dynamic> data);
  Future<void> deleteProcessingBatch(String id);
}
