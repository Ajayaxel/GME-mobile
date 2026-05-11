import '../models/processing_batch.dart';

abstract class ProcessingRepository {
  Future<List<ProcessingBatch>> getProcessingBatches();
}
